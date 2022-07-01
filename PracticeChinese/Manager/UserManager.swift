//
//  UserManager.swift
//  ChineseLearning
//
//  Created by feiyue on 06/04/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON
import Alamofire
import SDWebImage
import CocoaLumberjack
import NVActivityIndicatorView
import KeychainAccess
import FBSDKLoginKit

/** 登录方式 */
enum LoginAccountType: Int {
    case LinkedInLogin
    case FacebookLogin
    case LiveLogin
}

enum SummaryType: Int {
    case daily
    case weekly
    case monthly
}

class DateFrame: NSObject {
    var start:String = ""
    var end:String = ""
    init(start:String, end:String) {
        self.start = start
        self.end = end
    }
}

extension String {
    //崩溃
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
}


class HistoryManager:NSObject {
    static var shared = HistoryManager()
    
    var dailyIndex = [String]()
    var weeklyIndex = [String]()
    var monthlyIndex = [String]()

    func dateToString(_ date:Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return dateFormatter.string(from:date)
    }
    
    func getDailyInfo(_ count: Int) -> [DateFrame] {
        dailyIndex.removeAll()
        
        var dailyList = [DateFrame]()

        let date = Date()
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        let currentDate = Calendar.current.date(from: dateComponents)
        var newComponents = DateComponents()
        for i in 1...count {
            newComponents.day = i - count
            var newDate = Calendar.current.date(byAdding: newComponents, to: currentDate!)
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd"
            dailyIndex.append(formatter.string(from: newDate!))

            let start = dateToString(newDate!)
            newComponents.day = i - count + 1
            newDate = Calendar.current.date(byAdding: newComponents, to: currentDate!)
            let end = dateToString(newDate!)
            dailyList.append(DateFrame(start: start, end: end))
        }
        return dailyList
    }
    
    func getWeekInfo(_ count: Int) -> [DateFrame] {
        var weekList = [DateFrame]()
        weeklyIndex.removeAll()
        let date = Date()
        let dateComponents = Calendar.current.dateComponents([.year, .weekOfYear], from: date)
        let firstDate = Calendar.current.date(from: dateComponents)
        var newComponents = DateComponents()
        for i in 1...count {
            newComponents.weekOfYear = dateComponents.weekOfYear! + i - count - 1
            newComponents.day = 0
            var newDate = Calendar.current.date(byAdding: newComponents, to: firstDate!)
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd"
            weeklyIndex.append(formatter.string(from: newDate!))

            let start = dateToString(newDate!)
            newComponents.weekOfYear = dateComponents.weekOfYear! + i - count - 1

            newComponents.day = 7
            newDate = Calendar.current.date(byAdding: newComponents, to: firstDate!)
            let end = dateToString(newDate!)
            weekList.append(DateFrame(start: start, end: end))
        }

        return weekList
    }
    
    func getMonthInfo(_ count: Int) -> [DateFrame] {
        var monthList = [DateFrame]()
        monthlyIndex.removeAll()
        let date = Date()
        let dateComponents = Calendar.current.dateComponents([.year, .month], from: date )
        let firstDate = Calendar.current.date(from: dateComponents)
        var newComponents = DateComponents()
        for i in 1...count {
            newComponents.month = i - count
            var newDate = Calendar.current.date(byAdding: newComponents, to: firstDate!)
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            monthlyIndex.append(formatter.string(from: newDate!))

            let start = dateToString(newDate!)
            newComponents.month = i - count + 1
            newDate = Calendar.current.date(byAdding: newComponents, to: firstDate!)

            let end = dateToString(newDate!)
            monthList.append(DateFrame(start: start, end: end))
        }

        return monthList
    }
    
    func getIndex(type: SummaryType) -> [String] {
        switch type {
        case .daily:
            return dailyIndex
        case .weekly:
            return weeklyIndex
        default:
            return monthlyIndex
        }
    }

}

//MARK: - : 用户管理
class UserManager: NSObject {
    //MARK: - : 属性
    var model:UserModel?
    var userInfo:AccountInfo!
    var tmpModel:UserModel?
    var scenarioTaskSummary:GetScenarioTaskSummaryResult!
    
    static var shared = UserManager()
    
    private override init() {
    }
    
    func getUserModel() -> UserModel? {
        if isLoggedIn() {
            return model
        }
        
        if tmpModel != nil{
            return tmpModel
        }
        /** 未登录，或者没有用户信息的话进行游客登录 */
        if nil == model {
            self.logInAsVisitor()
        }
        return model
    }
    
    func getUUID() -> String {
        let keychain = Keychain(service: "com.microsoft.learnchinese-uuid")
        if let uuid = keychain["anonymousuuid"] {
            return uuid
        }
        else {
            var uuid = UUID().uuidString
            if UIDevice.current.identifierForVendor?.uuidString != nil {
                uuid = UIDevice.current.identifierForVendor!.uuidString
            }
            do {
                try keychain.set(uuid, key: "anonymousuuid")
            }
            catch{
                DDLogError("set uuid error!")
            }
            return uuid
        }
    }

    
    func getLearnedWords() -> Int {
        if scenarioTaskSummary != nil {
            return scenarioTaskSummary.TotalSpeakSentences!
        }
        return 0
    }
    
    func getTaskSummary(type:SummaryType, completion:@escaping (_ scores:[Int]?)->()) {
        var options = [String:String]()
        options["get-scenario-task-summary"] = ""
        var xIndexes = [DateFrame]()
        let indexCount = 7
        switch type {
        case .daily:
            xIndexes = HistoryManager.shared.getDailyInfo(indexCount)
        case .weekly:
            xIndexes = HistoryManager.shared.getWeekInfo(indexCount)
        case .monthly:
            xIndexes = HistoryManager.shared.getMonthInfo(indexCount)
        }

        let taskInput = Mapper<GetScenarioTaskSummaryInput>().map(JSON: [String:String]())
        taskInput?.Start = xIndexes[0].start
        taskInput?.End = xIndexes[xIndexes.count - 1].end
        taskInput?.Language = AppData.lang            
        var scores = xIndexes.map{_ in 0}
        let callback:(GetScenarioTaskSummaryResult?, Error?, String?)->() = {
            data, error, raw in
            if nil != error || nil == data {
                return
            }
            self.scenarioTaskSummary = data!
            for task in data!.HistoryTasks! {
                if let index = xIndexes.index(where: {$0.start <= task.Date! && $0.end >= task.Date!}) {
                    scores[index] += (task.FinishedLessons?.count)! * 20
                }
            }
            completion(scores)
        }

        RequestManager.shared.performRequest(urlRequest: Router.GetLessonOption("111", taskInput!, options), completionHandler: callback)
    }
    
    func logInAsVisitor(relogin:Bool = false, completion: (()->())? = nil) {
        
        if  (UserDefaults.standard.string(forKey: "demo_access_token") != nil) && !relogin {
            let tokenType = UserDefaults.standard.string(forKey: "demo_token_type")
            let expiresIn = UserDefaults.standard.integer(forKey: "demo_expires_in")
            let accessToken = UserDefaults.standard.string(forKey: "demo_access_token")
            tmpModel = UserModel(accessToken!, tokenType: tokenType, expiresIn: expiresIn,"", "", "", "")
            CourseManager.shared.SetCoursesList(update: true)
            if completion != nil {
                completion!()
            }
            return
        }
        let nounce = "Our mission is to empower every person and every organization on the planet to achieve more."
        var hmac = nounce
        for _ in 1...3 {
            hmac = hmac.sha1()
        }
        hmac = hmac.substring(to: 16)
        //fixed UUID()
        var uuid = getUUID()
        uuid = uuid.replacingOccurrences(of: "-", with: "")
        
        let secret = "\(uuid)\(hmac)".sha1()
        let callback: (UserModel?, Error?, String?)->() = {
            data, error, raw in
            if data?.accessToken == nil {
                DispatchQueue.main.async {
                    if completion != nil {
                        completion!()
                    }
                    ChActivityView.hide()
                }
                return
            }
            self.tmpModel =  data
            UserDefaults.standard.set(data?.accessToken, forKey: "demo_access_token")
            UserDefaults.standard.set(data?.tokenType, forKey: "demo_token_type")
            UserDefaults.standard.set(data?.expiresIn, forKey: "demo_expires_in")
            UserDefaults.standard.set(uuid, forKey: "demo_id")
            if self.isLoggedIn() {
                if self.getAccountType() == LoginAccountType.FacebookLogin {
                    //logout
                    let loginManager = FBSDKLoginManager()
                    loginManager.logOut()
                }
                self.signOutUser(){}
            }
            CourseManager.shared.SetCoursesList(update: true) {
                if completion != nil {
                    completion!()
                }
            }
            
        }
        RequestManager.shared.performRequest(urlRequest: Router.LogInDemo(uuid, secret), completionHandler: callback)
    }
    
    func getUserId() -> String {
        if let user = model {
            if user.oauthId != nil {
                return user.oauthId!
            }
        }
        return ""
    }
    
    func updateUserCoin(coinDelta: Int, completion:@escaping (_ success:Bool)->()) {
        let timestamp = "\(Int(NSDate().timeIntervalSince1970))"
        let nonce = "\(timestamp)The more, the better."
        let sign = nonce.sha1().substring(to: 16)
        let callback: (ApiResponse?, Error?, String?)->() = {
            data, error, raw in
            if error == nil {
                //update success
                completion(true)
            }
            else {
                completion(false)
            }
        }
        RequestManager.shared.performRequest(urlRequest: Router.UpdateCoin(coinDelta, timestamp, sign), completionHandler: callback)
        
    }
    
    func getUserInfo(completion:@escaping (_ coin:Int)->()) {
        let callback: (AccountInfo?, Error?, String?)->() = {
            data, error, raw in
            self.userInfo = data
            if data != nil {
                if let coin = self.userInfo.Coin {
                    completion(coin)
                }else {
                    completion(0)
                }
            }

        }
        RequestManager.shared.performRequest(urlRequest: Router.getUserInfo, completionHandler: callback)
    }
    
    func getName() -> String? {
        if let user = model {
            if user.oauthFirstName == nil || user.oauthLastName == nil {
                return ""
            }
            if getAccountType() == LoginAccountType.FacebookLogin {
                return "\(user.oauthFirstName!)"
            }else {
                return "\(user.oauthFirstName!) \(user.oauthLastName!)"
            }
        }
        return "Sign in"
    }
    
    func getCoin() -> Int? {
        if let user = userInfo {
            return user.Coin
        }
        return 0
    }
    
    func getAvatarUrl() -> URL? {
        if let user = model {
            if user.oauthPictureUrl != nil
            {
                return URL(string: user.oauthPictureUrl!)
            }
        }

        return nil
    }
    
    func getAccountType() -> LoginAccountType? {
        return LoginAccountType(rawValue: UserDefaults.standard.integer(forKey: "userAccountType"))
    }
    
    func getAccountTypeString() -> String {
        if let type = getAccountType() {
            switch type {
            case .FacebookLogin: return "Facebook"
            case .LiveLogin: return "Microsoft"
            case .LinkedInLogin: return "LinkedIn"
            default: return "Test"
            }
        }
        return "Test"
    }
    
    func isLoggedIn() -> Bool {
        if UserDefaults.standard.string(forKey: "access_token") != nil {
            let accessToken = UserDefaults.standard.string(forKey: "access_token")
            let tokenType = UserDefaults.standard.string(forKey: "token_type")
            let expiresIn = UserDefaults.standard.integer(forKey: "expires_in")
            model = UserModel(accessToken!, tokenType: tokenType, expiresIn: expiresIn,"", "", "", "")
            model?.oauthPictureUrl = UserDefaults.standard.string(forKey: "picture_url")
            model?.oauthFirstName = UserDefaults.standard.string(forKey: "first_name")
            model?.oauthLastName = UserDefaults.standard.string(forKey: "last_name")
            model?.oauthId = UserDefaults.standard.string(forKey: "live_id")

            return true
        }
        if  UserDefaults.standard.string(forKey: "demo_access_token") != nil  {
            let tokenType = UserDefaults.standard.string(forKey: "demo_token_type")
            let expiresIn = UserDefaults.standard.integer(forKey: "demo_expires_in")
            let accessToken = UserDefaults.standard.string(forKey: "demo_access_token")
            tmpModel = UserModel(accessToken!, tokenType: tokenType, expiresIn: expiresIn,"","", "", "")
        }
        return false
    }
    
   
    
    func signInUser(_ user:UserModel,_ userAccountType:LoginAccountType) {
        LCConfigManager.shared.clearConfig()
        model = user

        UserDefaults.standard.set(model?.accessToken, forKey: "access_token")
        UserDefaults.standard.set(model?.tokenType, forKey: "token_type")
        UserDefaults.standard.set(model?.expiresIn, forKey: "expires_in")
        UserDefaults.standard.set(model?.oauthPictureUrl, forKey: "picture_url")
        UserDefaults.standard.set(model?.oauthRefreshToken, forKey: "oauth_refresh_token")
        UserDefaults.standard.set(model?.oauthFirstName, forKey: "first_name")
        UserDefaults.standard.set(model?.oauthLastName, forKey: "last_name")
        UserDefaults.standard.set(model?.oauthId, forKey: "live_id")
        
        UserDefaults.standard.set(userAccountType.rawValue, forKey: "userAccountType")
        
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: ChNotifications.UserSignedIn.notification, object: nil)
        CacheDataManager.shared.userSignIn()
    }
    
    func signOutUser(completion:@escaping ()->()) {
        let coverView = getCoverView()
        UIApplication.shared.keyWindow?.addSubview(coverView)
        
        LCConfigManager.shared.clearConfig()
        LearnProgressManager.shared.clearDailyPlan()//清空学习计划
        
        UserDefaults.standard.removeObject(forKey: "access_token")
        UserDefaults.standard.removeObject(forKey: "token_type")
        UserDefaults.standard.removeObject(forKey: "expires_in")
        UserDefaults.standard.removeObject(forKey: "picture_url")
        UserDefaults.standard.removeObject(forKey: "oauth_refresh_token")
        UserDefaults.standard.removeObject(forKey: "first_name")
        UserDefaults.standard.removeObject(forKey: "last_name")
        UserDefaults.standard.removeObject(forKey: "live_id")
        UserDefaults.standard.removeObject(forKey: "userAccountType")

        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
        
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        
        UserDefaults.standard.synchronize()
        model = nil
        AppData.setDefault()
        CacheDataManager.shared.userSignOut()

        NotificationCenter.default.addObserver(forName: ChNotifications.LessonProgressUpdated.notification, object: nil, queue: OperationQueue.current, using: {_ in
            coverView.removeFromSuperview()
        })
        coverView.removeFromSuperview()
        completion()
        NotificationCenter.default.post(name: ChNotifications.UserSignedOut.notification, object: nil)
    }

    
    func getCacheSize() -> Int {
        var cacheSize = 0
        let imageCache = SDImageCache.shared()
        cacheSize += Int(imageCache.getSize())
        cacheSize += DocumentManager.getCacheFolderSize()
        cacheSize += CacheManager.shared.getCachedFileTotalSize()
        return cacheSize
    }
    
    func clearCache(completion:@escaping ()->()) {
        LCConfigManager.shared.clearConfig()
        //clear file
        DocumentManager.clearCache()
        //clear image cache
        let cache = SDImageCache.shared()
        cache.clearMemory()//clear audio and video cache
        CacheManager.shared.clearCachedFiles() {
            deleted in
            //   print("\(deleted)")
        }
        cache.clearDisk(onCompletion: completion)
    }
    func logUserClick(_ log:[String:String]) {
        if AppData.userAssessmentEnabled == false {
            return
        }
        if let user = UserManager.shared.getUserModel() {
            var appLog = log
            appLog["AppName"] = "Chinese-iOS"
            
            let callback: (ApiResponse?, Error?, String?)->() = {
                data, error, raw in
                if error == nil {
                    DDLogDebug("click log success")
                }
                else {
                    DDLogDebug("click log failed")
                }
            }

            RequestManager.shared.performRequest(urlRequest: Router.ClickLog(appLog), completionHandler: callback)
        }
    }
    
    func logUserClickInfo(_ log:[AnyHashable : Any]) {
        if(AppData.userAssessmentEnabled && UserManager.shared.isLoggedIn()){
            if let user = UserManager.shared.getUserModel() {
                var appLog = ["AppClickInfo":convert(toJsonData: log)]
                appLog["AppName"] = "Chinese-iOS"
                let callback: (ApiResponse?, Error?, String?)->() = {
                    data, error, raw in
                    if error == nil {
                        DDLogDebug("clickInfo log success")
                    }
                    else {
                        DDLogDebug("clickInfo log failed")
                    }
                }
                RequestManager.shared.performRequest(urlRequest: Router.ClickLogInfo(appLog), completionHandler: callback)
            }
        }
    }
    
    func isAppFirstOpened() -> Bool {
        let opened = UserDefaults.standard.integer(forKey: "app_first_opened")
        if 0 == opened {
            return true
        }
        return false
    }
    //第一次下载，显示阳光值鼓励
    func isAppFirstOpenedShowCoin() -> Bool {
        let opened = UserDefaults.standard.integer(forKey: "app_first_opened_showCoin")
        if 0 == opened {
            return true
        }
        return false
    }
    func setAppShowedCoin() {
        UserDefaults.standard.set(Int(1), forKey: "app_first_opened_showCoin")
        UserDefaults.standard.synchronize()
    }
    
    func setAppOpened() {
        UserDefaults.standard.set(Int(1), forKey: "app_first_opened")
        UserDefaults.standard.synchronize()
    }
    
    func getCoverView() -> UIView {
        let blurView = UIView(frame:CGRect(x:0, y:0, width:ScreenUtils.width, height:ScreenUtils.height))
        blurView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        blurView.isUserInteractionEnabled  = true
        let spinner = NVActivityIndicatorView(frame: CGRect(x: ScreenUtils.widthByRate(x: 0.35), y: ScreenUtils.heightByRate(y: 0.5) - ScreenUtils.widthByRate(x: 0.15) - 40, width: ScreenUtils.widthByRate(x: 0.3), height: ScreenUtils.widthByRate(x: 0.3)) , type: NVActivityIndicatorType.ballSpinFadeLoader, color: UIColor.white, padding: 4)
        blurView.addSubview(spinner)
        
        let textLabel = UILabel(frame: CGRect(x: ScreenUtils.widthByRate(x: 0.2), y: ScreenUtils.heightByRate(y: 0.5) + ScreenUtils.widthByRate(x: 0.15) - 20, width: ScreenUtils.widthByRate(x: 0.6), height: 25))
        textLabel.textColor = UIColor.white
        textLabel.font = FontUtil.getFont(size: 21, type: .Regular)
        textLabel.text = "Wiping Data..."
        textLabel.textAlignment = .center
        blurView.addSubview(textLabel)
        
        spinner.startAnimating()
        return blurView
    }
    func convert(toJsonData dict: [AnyHashable : Any]?) -> String? {
        var error: Error?
        var jsonData: Data? = nil
        if let aDict = dict {
            jsonData = try? JSONSerialization.data(withJSONObject: aDict, options: .prettyPrinted)
        }
        var jsonString: String = ""
        if jsonData == nil {
            if let anError = error {
                print("\(anError)")
            }
        } else {
            if let aData = jsonData {
                jsonString = String(data: aData, encoding: .utf8) ?? ""
            }
        }
        var mutStr = jsonString
        let range: NSRange = NSMakeRange(0, jsonString.length)
        //去掉字符串中的空格
        if let subRange = Range<String.Index>(range, in: mutStr) { mutStr = mutStr.replacingOccurrences(of: " ", with: "", options: .literal, range: subRange) }
        let range2: NSRange = NSMakeRange(0, mutStr.length)
        //去掉字符串中的换行符
        if let subRange = Range<String.Index>(range2, in: mutStr) { mutStr = mutStr.replacingOccurrences(of: "\n", with: "", options: .literal, range: subRange) }
        return mutStr
    }
}
