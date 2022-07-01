//
//  RecordManager.swift
//  ChineseLearning
//
//  Created by feiyue on 31/03/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

let RecordSuccessNotification  = "RecordSuccessNotification"
let RecordTooShortNotification  = "RecordTooShortNotification"
let RecordTooLongNotification  = "RecordTooLongNotification"
let RecordFailNotification = "RecordFailNotification"

class RecordManager: NSObject, AVAudioRecorderDelegate {
    var sampleRate:Int = 32000
    var audioRecorder: AVAudioRecorder!
    //var recordingView: RecordingView!
    var previousURL: URL!
    var shouldNotify:Bool!
    var startMillis: Double = 0
    var endMillis:Double = 0
    public static var sharedInstance = RecordManager()
    var isRecording = false
    private override init() {
        super.init()
        
        //self.recordingView = RecordingView(frame:CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height))
        NotificationCenter.default.addObserver(self, selector: #selector(reactToInterruption(notification:)), name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reactToInterruption(notification:)), name: UIApplication.willResignActiveNotification, object: nil)//在这里注册可以完成目标，但是只要该实例存在（或者不存在？）那么每次按home以及返回都会触发。
        NotificationCenter.default.addObserver(self, selector: #selector(reactToDidBecomeActive(nofitication:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func reactToDidBecomeActive(nofitication: NSNotification) {
    }
    
    @objc func reactToInterruption(notification: NSNotification) {
        self.stopInterrupted()
    //    UIApplication.topViewController()?.presentUserToast(message: "get notification: \(notification.name)")
    }
    
    func start(url:URL, completionHandler:@escaping (_ success:Bool)->()) {
        self.startMillis = NSDate().timeIntervalSince1970
        self.previousURL = url
        let recordingSession = AVAudioSession.sharedInstance()
        if recordingSession.recordPermission == .undetermined {
            recordingSession.requestRecordPermission() {
                allowed in
            }
            completionHandler(false)
            return
        }

        recordingSession.requestRecordPermission() {
            [unowned self] allowed in
            if allowed {
                LCVoiceButton.stopGlobal()
                completionHandler(true)
                self.isRecording = true
                //延时0.1秒执行
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                        let settings = [
                            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                            AVSampleRateKey: self.sampleRate,
                            AVNumberOfChannelsKey: 1,
                            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                        ]
                        //begin record
                        self.audioRecorder = try! AVAudioRecorder(url: url, settings: settings)
                        self.audioRecorder.delegate = self
                        self.audioRecorder.isMeteringEnabled = true
                        self.audioRecorder.prepareToRecord()
                        self.audioRecorder.record()
                }
                
            }
            else {
                completionHandler(false)
                LCAlertView.show(title: "Record Failed", message: "Please ensure the access to your microphone", leftTitle: "Setting", rightTitle: "Cancel", style: .center, leftAction: {
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(settingsUrl)

                        } else {
                            UIApplication.shared.openURL(settingsUrl)
                            // Fallback on earlier versions
                        }

                    }

                    LCAlertView.hide()
                }, rightAction: {LCAlertView.hide()})
            }

        }
    }
    
    func validateRecordedFile() -> Bool {
        let assetMedia = AVAsset(url: self.previousURL)
        let duration = assetMedia.duration
        var timeElapsed = self.endMillis - self.startMillis
        if timeElapsed < 1 {
            UIApplication.topViewController()?.presentUserToast(message: "Recording time must exceed 1 second, please try again.")
            return false
        }
        if timeElapsed >= 20 {
            UIApplication.topViewController()?.presentUserToast(message: "Recording time exceeds 20 seconds, please try again.")
            return false
        }
        return true
    }
    //获取语音的时长
    func validateRecordedFileTime(audioUrl: String!) ->Double {
        if (!(audioUrl != nil)) {
            return 0
        }
        let assetMedia = AVAsset(url: NSURL.init(string: audioUrl)! as URL)
        let duration = assetMedia.duration
        return duration.seconds
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        //if flag && validateRecordedFile() && shouldNotify {
                //NotificationCenter.default.post(name: NSNotification.Name(rawValue: RecordSuccessNotification), object: nil)
        //}
        //else if shouldNotify{
            //UIApplication.topViewController()?.presentUserToast(message: "record failed...")
           // NotificationCenter.default.post(name: NSNotification.Name(rawValue: RecordFailNotification), object: nil)
        //}
    }
    
    func stop(_ completionHandler:@escaping(_ success:Bool)->()) {
        self.endMillis = NSDate().timeIntervalSince1970
        guard audioRecorder != nil else {
            return
        }
        isRecording = false
        shouldNotify = true
        audioRecorder.stop()

        if validateRecordedFile() {
            completionHandler(true)
        }
        else {
            completionHandler(false)
        }
    }
    
    func stopInterrupted() {
        guard audioRecorder != nil else {
            return
        }
        shouldNotify = false
        if audioRecorder.isRecording {
            audioRecorder.stop()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: RecordFailNotification), object: nil)
        }
    }
}


