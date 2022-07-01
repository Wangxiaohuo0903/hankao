//
//  RecordignWithProgressView.swift
//  PracticeChinese
//
//  Created by Temp on 2018/11/22.
//  Copyright © 2018 msra. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView
import AVFoundation

class RecordignWithProgressView: UIView {

    var startButton: UIButton!
    var timer:Timer?
    var change:CGFloat = 0.01
    var progressView: PNCircleChart!
    var progressBgView: PNCircleChart!
    var startMillisec: Double!
    weak var delegate: LCRecordingViewDelegate?
    var tipView:CountDownView!
    var filename:String = ""
    var isRecording = false
    var isCanceled = false
//    var coverView: UIView!
    var waitCount: NSNumber = 80//waitSeconds * CGFloat(10)
    var dynamicTime = false
    
    var audioURL = "" {
        didSet {
            if dynamicTime {
                if audioURL == nil {
                    audioURL = ""
                }
                if let url = URL(string: audioURL) {
                    waitCount = 80
//                    waitCount = NSNumber(value: RecordManager.sharedInstance.validateRecordedFileTime(audioUrl: audioURL))
                }else {
                    waitCount = 80
                }
            }else {
                waitCount = 80
            }
        }
    }
    func setProgress() {
        if progressView != nil {
            progressView.removeFromSuperview()
        }
        progressView = PNCircleChart(frame: CGRect(x: (frame.width-frame.height)/2, y: 0, width: frame.height, height: frame.height), total: waitCount, current: 0, clockwise: true)
        progressView.strokeColor = UIColor.hex(hex: "AECFFF")
        progressView.lineWidth = 2
        progressView.strokeColorGradientStart = UIColor.hex(hex: "AECFFF")
        progressView.countingLabel = nil
        addSubview(progressView)
        bringSubviewToFront(startButton)
        
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        progressBgView = PNCircleChart(frame: CGRect(x: (frame.width-frame.height)/2, y: 0, width: frame.height, height: frame.height), total: waitCount, current: waitCount, clockwise: true)!
        progressBgView.strokeColor = UIColor.hex(hex: "E8F0FD")
        progressBgView.lineWidth = 2
        progressBgView.countingLabel = nil
        progressBgView.displayAnimated = false
        progressBgView.stroke()
        addSubview(progressBgView)
        
        progressView = PNCircleChart(frame: CGRect(x: (frame.width-frame.height)/2, y: 0, width: frame.height, height: frame.height), total: waitCount, current: 0, clockwise: true)
        progressView.lineWidth = 4
        let xframe = CGRect(x: (frame.width-frame.height)/2, y: 0, width: frame.height, height: frame.height)
        
        let space: CGFloat = 3
        let buttonHeight = xframe.height - space * 2
        let buttonX: CGFloat = frame.width/2 - buttonHeight / 2
        let buttonY = xframe.height / 2 - buttonHeight / 2
        
        startButton = UIButton(frame:CGRect(x: buttonX, y: buttonY, width: buttonHeight, height: buttonHeight))
        startButton.setImage(ChImageAssets.startRecording.image, for: .normal)
        startButton.setImage(ChImageAssets.startRecording.image, for: .selected)
        startButton.setImage(ChImageAssets.recordGray.image, for: .disabled)
        startButton.addTarget(self, action: #selector(startRecording(sender:)), for: .touchUpInside)
        addSubview(startButton)

        tipView = CountDownView(frame: CGRect(x: ScreenUtils.width/2 - 60, y: ScreenUtils.heightByRate(y: 0.5)-100, width: 120, height: 120))
        NotificationCenter.default.addObserver(self, selector: #selector(recordFail), name: NSNotification.Name(rawValue: RecordFailNotification), object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setProgressView(){
        progressView = PNCircleChart(frame: CGRect(x: 0, y: 0, width: frame.height, height: frame.height), total: waitCount, current: 0, clockwise: true)
        progressView.strokeColor = UIColor.hex(hex: "AECFFF")
        progressView.lineWidth = 3
        progressView.strokeColorGradientStart = UIColor.hex(hex: "AECFFF")
        insertSubview(progressView, at: 0)
    }

    func removeRecordObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func synchronize(_ lockObj: Any!, _ closure: ()->()){
        objc_sync_enter(lockObj)
        closure()
        objc_sync_exit(lockObj)
    }
    
    @objc func startRecording(sender: UIButton) {
        sender.isUserInteractionEnabled = false
        
        if isRecording {
            RecordManager.sharedInstance.stop() {
                [unowned self] success in
                if success {
                    self.recordFinish()
                }
                else {
                    self.recordFail()
                }
                DispatchQueue.main.async {
                    if self.progressView != nil {
                        self.timer?.invalidate()
                        self.progressView.removeFromSuperview()
                        self.progressView = nil
                    }
                }
                sender.isUserInteractionEnabled = true
                self.isCanceled = false
                self.isRecording = false
                self.enableOtherViews()
                return
            }
            return
        }
        
        isRecording = false
        isCanceled = false
        RecordManager.sharedInstance.start(url: DocumentManager.urlFromFilename(filename: "\(filename).m4a")) {
            [unowned self] success in
            if success {
                sender.isUserInteractionEnabled = true
                self.delegate?.recordingStart()
                self.isRecording = true
                self.startButton.setImage(ChImageAssets.inRecording.image, for: .normal)
                self.setProgress()
                self.startMillisec = NSDate().timeIntervalSince1970 * 1000
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.refreshProgressView(_:)), userInfo: nil, repeats: true)
                RunLoop.main.add(self.timer!, forMode: RunLoop.Mode.common)
            }
            else {
                self.isRecording = false
                self.isCanceled = false
                sender.isUserInteractionEnabled = true
                
            }
        }

    }

    func enableOtherViews() {
//        self.coverView.removeFromSuperview()
    }

    //在取消录音时，会调用recorder的stop方法，此时仍然会收到通知
    func recordFinish() {
        enableOtherViews()
        if self.startMillisec == nil {
            return
        }
        var timeInterval:Double
        timeInterval = Double((NSDate().timeIntervalSince1970 * 1000 - self.startMillisec) / 1000 )
        
        DispatchQueue.main.async {
            [unowned self] in
            self.isRecording = false
            self.timer?.invalidate()
            self.startButton.setImage(ChImageAssets.startRecording.image, for: .normal)
            if self.progressView != nil {
                self.progressView.removeFromSuperview()
                self.progressView = nil
            }
            self.tipView.removeFromSuperview()
        }
        if false == self.isCanceled {//如果是人为取消，则不做处理
            self.delegate?.recordingSubmit(duration: timeInterval)
        }
    }
    @objc func recordFail() {
        if self.startMillisec == nil {
            return
        }
        
        self.isRecording = false//取消录音
        self.delegate?.recordingCancel()
        self.timer?.invalidate()
        
        DispatchQueue.main.async {
            [unowned self] in
            self.enableOtherViews()
            self.startButton.isEnabled = true
            self.startButton.setImage(ChImageAssets.startRecording.image, for: .normal)
            if self.progressView != nil {
                self.progressView.removeFromSuperview()
                self.progressView = nil
            }
            self.tipView.removeFromSuperview()
        }
    }
    func cancelRecording(sender: AnyObject?) {
        if self.startMillisec == nil {
            return
        }
        
        if false == isRecording {
            return
        }
        enableOtherViews()
        
        isRecording = false
        isCanceled = true
        self.startButton.isEnabled = true
        self.startButton.setImage(ChImageAssets.startRecording.image, for: .normal)
        RecordManager.sharedInstance.stopInterrupted()
        DispatchQueue.main.async {
            if self.progressView != nil {
                self.progressView.removeFromSuperview()
                self.progressView = nil
            }
        }
    }

    @objc internal func refreshProgressView(_:Timer) {
        if false == self.isRecording || self.progressView == nil{//停止计时仍然有可能会执行该方法
            return
        }
        //  Converted to Swift CGFloat4 by Swiftify v4.2.37045 - https://objectivec2swift.com/
        let current = NSDate().timeIntervalSince1970 * 1000
        self.progressView.current = Int((Double(current) - Double(self.startMillisec)) / waitCount.doubleValue ) as? NSNumber
        self.progressView.stroke()
        
        if self.progressView.current.doubleValue > waitCount.doubleValue + 15.0 {
            //        case 80:
            //            tipView.count = 3;
            ////            UIApplication.topViewController()?.view.addSubview(tipView);
            //        case 90:
            //            tipView.count = 2;
            //        case 100:
            //            tipView.count = 1;
            //        case 110:
            //            tipView.removeFromSuperview()
            isRecording = false
            RecordManager.sharedInstance.stop() {
                [unowned self] success in
                if success {
                    self.recordFinish()
                }
                else {
                    self.recordFail()
                }
                DispatchQueue.main.async {
                    if self.progressView != nil {
                        self.progressView.removeFromSuperview()
                        self.progressView = nil
                    }
                }
                self.isCanceled = false
                self.enableOtherViews()
                return
            }
            //            default:
            //            break
        }
    }
}


