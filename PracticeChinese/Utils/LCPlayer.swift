//
//  LCPlayer.swift
//  UIViewTest
//
//  Created by ThomasXu on 18/05/2017.
//  Copyright © 2017 ThomasXu. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import CocoaLumberjack

protocol LCPlayerDelegate: class {
    func periodicUpdateView(time: CMTime)
    func playFinish()
    func loadTimeRange()
    func playStart()
    func errorGetData(error: Error?)
}

class LCPlayer: NSObject, AVAssetResourceLoaderDelegate {
    enum PlayType: String {
        case Audio = "Audio"
        case Video = "Video"
    }
    
    var player: AVPlayer!
    var webUrl: String!
    var asset: AVURLAsset!
    var playerItem: AVPlayerItem!
    var playProgressObserver: Any!//检测播放进度，更新进度条
    
    var playerPlaying: Bool = false
    var playerFinished: Bool = false
    var playerCanStart: Bool = false
    var playerPausing: Bool = false
    var isBadFile: Bool = false
    var isInterrupted = false
    var playType: PlayType!
    //播放完成的block
    var playCompleted:()->() = {}
    weak var delegate: LCPlayerDelegate?
    
    init(type: PlayType, _ other: Int) {
        self.player = AVPlayer()
        self.playType = type
        self.player.volume = 1.0
    }
    
    
   
    convenience init(type: PlayType) {
        self.init(type: type, 0)
    }
    
    var cacheURL: URL!
    var needCache: Bool!
    
    func startPlay() -> Bool {
        if self.isBadFile {
            return false
        }
        if false == self.setPlayer() {
            self.isBadFile = true
            return false
        }
        if self.playerPlaying {
            self.playFinish()
        }
        self.playerCanStart = true
        self.playerPlaying = true
        self.playerPausing = false
        self.player.play()
        if player.status == .readyToPlay {
            player.preroll(atRate: 1) { (progress) in
                print("progress \(progress)")
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(playbackFinished), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player.currentItem)
        return true
    }
    //播放完成
    @objc func playbackFinished() {
//        print("播放完成")
    }
    @objc func pausePlay() {
        self.playerCanStart = false
        self.playerPlaying = false
        self.playerPausing = true
        if (self.player != nil) {
            self.player.pause()
        }
    }
    
    func setPlayUrl(webUrl: String) {
        self.webUrl = webUrl
        self.needCache = false
        self.isBadFile = false
        self.playerPlaying = false
    }
    
    @objc func pressHome(notification: NSNotification) {
        if self.playerPlaying {
            self.player.pause()

            self.isInterrupted = true
            self.delegate?.playFinish()
        }
    }
    
    
    @objc func enterFromHome(nofitication: NSNotification) {
        if self.isInterrupted {
            self.isInterrupted = false
            self.player.play()
            self.delegate?.playStart()
        }

    }

    
    public func setPlayer() -> Bool {
        //清理资源
        if nil != self.playerItem {
            playerItem.removeObserver(self, forKeyPath: "status")
//            playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
//            NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerItem)
            self.playerItem = nil
            //self.asset = nil
            self.player.replaceCurrentItem(with: nil)
        }

        if self.webUrl == nil {
            return false
        }
        
        var selectedURL = CacheManager.shared.getCachedUrl(url: self.webUrl)
        
        if nil == selectedURL {
            selectedURL = URL(string: webUrl)
        }
        //DDLogInfo("selected url: \(selectedURL)")
        if nil == selectedURL {
            return false
        }
        
        //self.asset = AVURLAsset(url: selectedURL!)
        //asset.resourceLoader.setDelegate(self, queue: DispatchQueue.main)
        let item = AVPlayerItem(url: selectedURL!)
        self.playerPlaying = false
        self.playerCanStart = false
        self.playerFinished = false
//        item.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)//缓存
        item.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playFinish), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: item)//没有必要取消注册
        NotificationCenter.default.addObserver(self, selector: #selector(pausePlay), name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pressHome(notification:)), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterFromHome(nofitication:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        

        self.playerItem = item
        DispatchQueue.main.async {
            self.player.replaceCurrentItem(with: item)
        }
        /*
        if nil == self.playProgressObserver {
            let interval = CMTime(seconds: 0.25, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            self.playProgressObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: {
                [weak self] time in
                if false == self?.playerPlaying {
                    return
                }
                self?.delegate?.periodicUpdateView(time: time)
            })
        }
         */
        return true
    }
    
    func saveToCache() {
        if self.needCache {
            var presetName = AVAssetExportPresetAppleM4A//音频
            if self.playType == .Video {
                presetName = AVAssetExportPresetHighestQuality
            }
            if let exporter = AVAssetExportSession(asset: asset, presetName: presetName) {
                exporter.outputURL = self.cacheURL
                exporter.determineCompatibleFileTypes(completionHandler: {
                    types in
                    //print(types)
                })
                if exporter.asset.tracks(withMediaType: AVMediaType.video).count > 0 {
                    
                    exporter.outputFileType = AVFileType.mp4
                } else {
                    exporter.outputFileType = AVFileType.m4a
                }
                
                exporter.exportAsynchronously(completionHandler: {
                    if let error = exporter.error {
                        DDLogInfo("cache error: \(error)")
                    } else {
                        CacheManager.shared.addNewCachedFileAndUpdate(key: self.webUrl, fileName: self.cacheURL.lastPathComponent)
                    }
                })
                self.needCache = false
            }
        }
    }
    
   
    
    @objc func playFinish() {
        self.playerPlaying = false
        self.playerFinished = true
        self.player.seek(to: CMTime.zero)
        self.delegate?.playFinish()
//        DispatchQueue.main.async {
//            self.delegate?.playFinish()
//        }
    }
    
    func getCacheProgress() -> TimeInterval {
        if let ranges = self.player.currentItem?.loadedTimeRanges {
            if let first = ranges.first {
                let timeRange = first.timeRangeValue
                let startSeconds = CMTimeGetSeconds(timeRange.start)
                let durationSecond = CMTimeGetSeconds(timeRange.duration)
                let result = startSeconds + durationSecond
                return result
            }
        }
        fatalError("Error: get cache progress")
    }
    
    //要调用super？
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let playerItem = object as? AVPlayerItem else {return}//不能使用  as！//这里是否会发生不等于当前的情况，如果没有取消注册
        if keyPath == "loadedTimeRanges" {//缓冲进度
//            self.saveToCache()
            self.delegate?.loadTimeRange()
        } else if keyPath == "status" {
            if playerItem.status == AVPlayerItem.Status.readyToPlay {
                self.delegate?.playStart()
                if self.playerCanStart {
                    self.playerPlaying = true
                    self.player.play()
                }
            } else {
                self.isBadFile = true
                self.delegate?.errorGetData(error: playerItem.error)
            }
        }
    }
    func removeObservers() {
        if nil != self.playerItem {
            playerItem.removeObserver(self, forKeyPath: "status")
//            playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
            //self.player.removeTimeObserver(self.playProgressObserver)
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        if nil != self.playerItem {
            playerItem.removeObserver(self, forKeyPath: "status")
//            playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
            //self.player.removeTimeObserver(self.playProgressObserver)
      //      NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerItem)
            
        }
   //     print("de init player")
    }
}
