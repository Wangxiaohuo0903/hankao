//
//  CacheManager.swift
//  UIViewTest
//
//  Created by ThomasXu on 19/05/2017.
//  Copyright © 2017 ThomasXu. All rights reserved.
//

import Foundation
import Alamofire
import CocoaLumberjack
import NVActivityIndicatorView
class AppUtil {
    public static var hasShownToast : Bool = false
    public static var sharedToastView: UILabel!
    
    class LCWaitingView: UIView {
        struct Singleton {
            static let instance = LCWaitingView(frame: CGRect.zero)
        }
    }
    
    public class var shared: LCAlertView {
        struct Singleton {
            static let instance = LCAlertView(frame: CGRect.zero)
        }
        return Singleton.instance
    }
    static func getSharedToastView(frame: CGRect?) -> UILabel {
        if let toastView = sharedToastView {
            if frame != nil {
                toastView.frame = frame!
            }
            return toastView
        }
        sharedToastView = UILabel(frame: frame!)
        return sharedToastView
    }
    
    static func AppExit(message: String) -> Never {
        return exit(0)
    }
    
    static func showWaitingView(work: (_ completion: () -> ()) -> ()) {
        let cover = getCoverView()
        UIApplication.shared.keyWindow?.addSubview(cover)
        work({
            cover.removeFromSuperview()
        })
    }
    
    static func getCoverView() -> UIView {
        let blurView = UIView(frame:CGRect(x:0, y:0, width:ScreenUtils.width, height:ScreenUtils.height))
        blurView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        blurView.isUserInteractionEnabled  = true
        let spinner = NVActivityIndicatorView(frame: CGRect(x: ScreenUtils.widthByRate(x: 0.35), y: ScreenUtils.heightByRate(y: 0.5) - ScreenUtils.widthByRate(x: 0.15) - 40, width: ScreenUtils.widthByRate(x: 0.3), height: ScreenUtils.widthByRate(x: 0.3)) , type: NVActivityIndicatorType.ballSpinFadeLoader, color: UIColor.white, padding: 4)
        blurView.addSubview(spinner)
        
        let textLabel = UILabel(frame: CGRect(x: ScreenUtils.widthByRate(x: 0.2), y: ScreenUtils.heightByRate(y: 0.5) + ScreenUtils.widthByRate(x: 0.15) - 20, width: ScreenUtils.widthByRate(x: 0.6), height: 25))
        textLabel.textColor = UIColor.white
        textLabel.font = FontUtil.getFont(size: 18, type: .Regular)

        textLabel.text = "Loading Data..."
        textLabel.textAlignment = .center
        blurView.addSubview(textLabel)

        spinner.startAnimating()
        return blurView
    }
    
    static func downloadUrls(urls: [String?], completion: @escaping (_ downloadResult: Bool) -> Void) {
        let downloadtasks = urls.filter({$0 != nil && $0 != ""})

        CacheManager.shared.downloadToPath(urls: downloadtasks, completion: {
            downloadSuccess in
            completion(downloadSuccess)
        })
    }
    
    static func downloadUrlsWithAnimation(urls: [String?], completion: @escaping (_ downloadResult: Bool) -> Void) {
        let blurView = getCoverView()
        UIApplication.shared.keyWindow?.addSubview(blurView)
        CacheManager.shared.downloadToPath(urls: urls, completion: {
            downloadSuccess in
            blurView.removeFromSuperview()
            completion(downloadSuccess)
        })
    }
}

class CacheManager {
    
    static let shared = CacheManager()
    private let fileManager = FileManager.default
    private let userDefault = UserDefaults.standard
    
    let cacheBasePath: String!
    private var cachedFiles: [String: [Any]]!
    private let MapKey = UserDefaultsKeyManager.cacheManager
    private let expireTime: Int = 10 * 24 * 60 * 60//过期时间为10天
    private var downloadManager: SessionManager!
    
    enum FileAttribute: Int {
        case cachedName = 0
        case lastVisit = 1
        case fileSize = 2
    }
 
    //如果有重复的文件，那么该怎么办？
    private func downloadFileFromUrl(url: String, filePath: String) {
        let destination: DownloadRequest.DownloadFileDestination = {
            _, response in
            return (URL(fileURLWithPath: filePath), [.removePreviousFile, .createIntermediateDirectories])
        }
        Alamofire.download(url, to: destination).response {
            response in
            if let error = response.error {
                self.logInfo("error download: \(url), error: \(error.localizedDescription)")
            } else {
                DDLogInfo(filePath)
            }
        }
    }
    
    public func getNeededUrls(urls: [String?]) -> ([String], [String]){
        var uniqueSet = Set<String>()
        for url in urls {
            if let url = url {
                uniqueSet.insert(url)
            }
        }
        let uniqueUrls = Array(uniqueSet)//去除重复的，那么排除生成相同的key的情况下，最后的文件不会重复
        var names = [String]()
        var downloadUrls = [String]()
        for url in uniqueUrls {
            let temp = self.getCachedFileName(urlString: url)
            if nil != self.cachedFiles[url] {
                if fileExistInDirectory(fileName: temp) {
                    continue
                } else {
                    self.cachedFiles.removeValue(forKey: url)//如果不存在这个文件就把 key 删除
                    downloadUrls.append(url)
                    names.append(temp)
                }
            } else {//不包含key，如果存在该文件，那么覆盖写
                downloadUrls.append(url)
                names.append(temp)
            }
        }
        self.updateDictionary()
        return (downloadUrls, names)
    }
    
    public func downloadToPath(urls: [String?], completion: @escaping (_ downloadResult: Bool) -> ()) {
        let (downloadUrls, names) = getNeededUrls(urls: urls)
        if downloadUrls.count <= 0 {
            completion(true)
            return
        }

        var failedUrls = [String]()
        let group = DispatchGroup()
        
        for (index, url) in downloadUrls.enumerated() {
            group.enter()
            let destination: DownloadRequest.DownloadFileDestination = {
                _, response in
                let url = URL(fileURLWithPath: self.getCacheFilePath(fileName: names[index]))
                return (url, [.removePreviousFile, .createIntermediateDirectories])
            }
            downloadManager.download(url, to: destination).response {
                response in
                if let error = response.error {
                    self.logInfo("error download: \(url), error: \(error.localizedDescription)")
                    if #available(iOS 9.0, *) {
                        self.downloadManager.session.getAllTasks(completionHandler: {
                            tasks in
                            for task in tasks {
                                task.cancel()
                            }
                        })
                    } else {
                        self.downloadManager.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
                            dataTasks.forEach { $0.cancel() }
                            uploadTasks.forEach { $0.cancel() }
                            downloadTasks.forEach { $0.cancel() }
                        }
                    }
                }
                group.leave()
            }
        }// for index , url
        group.notify(queue: DispatchQueue.main) {
            for (index, url) in downloadUrls.enumerated() {
                if self.fileExistInDirectory(fileName: names[index]) {//如果文件存在下载成功
                    self.addNewCachedFile(key: url, fileName: names[index])
                } else {
                    failedUrls.append(url)
                }
            }
            self.updateDictionary()
            self.logInfo("failed urls: \(failedUrls)")
            completion(failedUrls.count <= 0)
        }

    }
    
    init() {
        cacheBasePath = CacheManager.getCachePath()
        if let value = userDefault.object(forKey: MapKey) {
            if let dict = value as? [String: [Any]] {
                self.cachedFiles = dict
            } else {
                self.logInfo("\(MapKey) is used by other value")
            }
        } else {
            self.cachedFiles = [String: [Any]]()
            userDefault.set(self.cachedFiles, forKey: MapKey)
        }
        clearOldFiles()
        clearFileNotInDirectory()
        
        //设置 下载
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10 //.timeoutIntervalForResource = 10
        //如果设置 .timeoutIntervalForRequest 的话，那么对于较大的视频文件，会使用较长的时间缓慢下载
        downloadManager = Alamofire.SessionManager(configuration: configuration)
    }
    
    func getCachedFileName(urlString: String) -> String {
        let extend = URL(string: urlString)?.pathExtension
        if let extend = extend {
            return getCachedFileName(source: urlString, extend: extend)
        } else {
            return getCachedFileName(source: urlString, extend: "")
        }
    }
    
    //web url 映射为 本地 文件名
    func getCachedFileName(source: String, extend: String) -> String {
        return "\(source.hash)." + extend
    }
    
    func logInfo(_ message: String) {
        DDLogDebug(message)
    }
    
    //清理超时文件，仅仅将文件从字典中删除
    private func clearOldFiles() {
        let index = FileAttribute.lastVisit.rawValue
        let current = Int(Date().timeIntervalSince1970)
        var removedKey = [String]()
        for file in self.cachedFiles {
            let attributes = file.value
            if index < attributes.count, let visit = attributes[index] as? Int {
                let timeDis = current - visit
                if timeDis > expireTime {
                    removedKey.append(file.key)
                }
            }
        }
        for key in removedKey {
            self.cachedFiles.removeValue(forKey: key)
        }
        self.updateDictionary()
    }
    
    //清除在缓存文件夹但是不在字典中的文件
    func clearFileNotInDirectory() {
        let paths = listFilePathsInCacheDirectory()
        var dictPaths = Set<String>()
        for file in self.cachedFiles {
            let name = file.value[0] as! String
            dictPaths.insert(getCacheFilePath(fileName: name))
        }
        for path in paths {
            if false == dictPaths.contains(path) {
                do {
                    try fileManager.removeItem(atPath: path)
                } catch {
                    DDLogInfo("delete error \(path) \(error)")
                }
            }
        }
    }
    
    private static func getCachePath() -> String {
        
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        if paths.count == 1{
            
        }
        let cachePath = paths[0] + "/LessonContents"
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: cachePath, isDirectory: &isDirectory) {
            if isDirectory.boolValue {
                return cachePath
            }
            AppUtil.AppExit(message: "cache path is a file")
        } else {
            do {
                try FileManager.default.createDirectory(atPath: cachePath, withIntermediateDirectories: false, attributes: nil)
                return cachePath
            } catch {
                AppUtil.AppExit(message: error.localizedDescription)
            }
        }
    }
    
    private func getCacheFilePath(fileName: String) -> String {
        return cacheBasePath + "/" + fileName
    }
    
    private func fileExistInDirectory(fileName: String) -> Bool {
        let path = getCacheFilePath(fileName: fileName)
        return fileManager.fileExists(atPath: path)
    }
    
    //检查文件是否存在于字典中，并且文件是否存在
    private func fileExist(urlString: String) -> URL? {
        if var cur = self.cachedFiles[urlString] {
            let fileName = self.getCachedFileName(urlString: urlString)
            if false == self.fileExistInDirectory(fileName: fileName) {//如果文件实际上不存在
                cachedFiles.removeValue(forKey: urlString)
                self.updateDictionary()
                return nil
            }
            let index = FileAttribute.lastVisit.rawValue
            if index < cur.count {
                cur[index] = Int(Date().timeIntervalSince1970)//更新访问时间，由于课程是整体缓存的，所以最后访问的单位是否应该是课程呢
            }
            self.cachedFiles[urlString] = cur
            self.updateDictionary()
            let path = getCacheFilePath(fileName: fileName)
            return URL(fileURLWithPath: path)
        } else {
            return nil
        }
    }
    
    //向字典中添加新文件
    public func addNewCachedFile(key: String, fileName: String) {
        var temp = Array<Any>()
        temp.append(fileName)
        temp.append(Int(Date().timeIntervalSince1970))
        temp.append(getFileSize(fileName: fileName))
        self.cachedFiles[key] = temp
    }
    
    //向字典中添加新文件并同步
    public func addNewCachedFileAndUpdate(key: String, fileName: String) {
        self.addNewCachedFile(key: key, fileName: fileName)
        self.updateDictionary()
    }
    
    private func getFileSize(fileName: String) -> Int {
        let path = getCacheFilePath(fileName: fileName)
        do {
            let attributes = try fileManager.attributesOfItem(atPath: path)
            let temp = attributes[FileAttributeKey.size] as! NSNumber
            let size = Int(temp.uint64Value)
            return size
        } catch {
            DDLogInfo("get filesize erro error attributes \(path) \(error)")
            return 0
        }
    }
    
    private func listFilesInCacheDirectory() -> [String] {
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: cacheBasePath)
            return contents
        } catch {
            DDLogInfo(error.localizedDescription)
            return [String]()
        }
    }
    
    private func listFilePathsInCacheDirectory() -> [String] {
        var paths = [String]()
        let contents = listFilesInCacheDirectory()
        for content in contents {
            paths.append(getCacheFilePath(fileName: content))
        }
        return paths
    }
    
    
    //缓存文件夹总共有多少字节
    func getCacheDirectoryFileTotalSize() -> UInt64 {
        let contents = listFilesInCacheDirectory()
        var size: UInt64 = 0
        for content in contents {
            let path = getCacheFilePath(fileName: content)
            DDLogInfo(path)
            do {
                let attributes = try fileManager.attributesOfItem(atPath: path)
                let temp = attributes[FileAttributeKey.size] as! NSNumber
                size += temp.uint64Value
            } catch {
                DDLogInfo("error attributes \(path) \(error)")
            }
        }
        return size
    }
    
    //如果key被其他值占用，且也是 [Any] 类型，那么就会出问题
    func getCachedFileTotalSize() -> Int {
        let index = FileAttribute.fileSize.rawValue
        var totalSize = 0
        for file in self.cachedFiles {
            let attributes = file.value
            if index < attributes.count, let size = attributes[index] as? Int {
                totalSize += size
            }
        }
        return totalSize
    }
    
    //清除在缓存文件夹中的文件
    private func clearAllCachedFilesInDirectory(progress: (_ removedFileSize: UInt64) -> ()) {
        let contents = listFilesInCacheDirectory()
        for content in contents {
            let path = getCacheFilePath(fileName: content)
            do {
                let attributes = try fileManager.attributesOfItem(atPath: path)
                let temp = attributes[FileAttributeKey.size] as! NSNumber
                try fileManager.removeItem(atPath: path)
                progress(temp.uint64Value)
            } catch {
                DDLogInfo("error attributes \(path) \(error)")
            }
        }
    }
    
    //更新缓存字典
    private func updateDictionary() {
        userDefault.set(self.cachedFiles, forKey: MapKey)
        userDefault.synchronize()
    }
    
    //清理缓存
    func clearCachedFiles(progress: (_ removedFileSize: UInt64) -> ()) {
        self.cachedFiles = [String: [Any]]()
        self.updateDictionary()
        self.clearAllCachedFilesInDirectory(progress: progress)//因为可能没有删除完全，所以可以在启动的时候进行检查，把字典中没有的条目删除
    }
    
    //如果在缓存中找到该文件，则返回缓存Url，否则返回原始Url
    func getCachedUrl(url: String?) -> URL? {
        if let url = url {
            return self.fileExist(urlString: url)
        }
        return nil
    }
}
