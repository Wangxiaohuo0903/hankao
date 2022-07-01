//
//  File.swift
//  PracticeChinese
//
//  Created by ThomasXu on 23/06/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView

protocol LCRecordingViewDelegate: class {
    func recordingStart()//开始录音
    func recordingAutoCommit()//到时间自动提交
    func recordingCancel()//取消录音
    func recordingSubmit(duration:Double)//提交录音
}

class LCRecordingView: UIView {
    
    var startButton: UIButton!
    var change:CGFloat = 0.01
    var startMillisec: Double!
    weak var delegate: LCRecordingViewDelegate?
    var filename:String = ""
    var isRecording = false
    var isCanceled = false
    var superViewIndex: Int!//在父View中的位置
    var coverView: UIView!
    var animateView: NVActivityIndicatorView!
    //私有属性
    private var rippleColor = UIColor.hex(hex: "4E80D9")
    private var rippleLayer: CALayer?
    //添加了一个属性表示波纹是否出现
    var rippleState = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isMultipleTouchEnabled = false
        let xframe = CGRect(x: (frame.width-frame.height)/2, y: 0, width: frame.height, height: frame.height)

        let space: CGFloat = 6
        let buttonHeight = xframe.height - space * 2
        let buttonX: CGFloat = frame.width/2 - buttonHeight / 2
        let buttonY = xframe.height / 2 - buttonHeight / 2

        animateView = NVActivityIndicatorView(frame: CGRect(x: xframe.minX - ScreenUtils.heightBySix(y: 20), y: xframe.minY - ScreenUtils.heightBySix(y: 20), width: xframe.width + ScreenUtils.heightBySix(y: 40), height: xframe.height + ScreenUtils.heightBySix(y: 40)), type: .ballScaleMultiple, color: UIColor.white, padding: 0)
        addSubview(animateView)
        animateView.isHidden = true
        

        startButton = UIButton(frame:CGRect(x: buttonX, y: buttonY, width: buttonHeight, height: buttonHeight))
        startButton.setImage(ChImageAssets.MicrophoneBlue.image, for: .normal)
        startButton.setImage(ChImageAssets.InRecording01.image, for: .selected)
        stop()
        startButton.addTarget(self, action: #selector(startRecording(sender:)), for: .touchUpInside)
        addSubview(startButton)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(recordFinish), name: NSNotification.Name(rawValue: RecordSuccessNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(recordFail), name: NSNotification.Name(rawValue: RecordFailNotification), object: nil)
        
        self.coverView = UIView(frame:CGRect(x:0, y:0, width:ScreenUtils.width, height:ScreenUtils.height))
        self.coverView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.coverView.isUserInteractionEnabled  = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        if !isRecording {
            isRecording = true
            self.startButton.isSelected = true
            UIApplication.topViewController()?.view.addSubview(self.coverView)
            UIApplication.topViewController()?.view.bringSubviewToFront(self)

            RecordManager.sharedInstance.start(url: DocumentManager.urlFromFilename(filename: "\(filename).m4a")) {
                [unowned self] success in
                if success {
                    self.delegate?.recordingStart()
                    self.began()
                    self.animateView.isHidden = false
                    self.animateView.startAnimating()
                    self.startMillisec = NSDate().timeIntervalSince1970 * 1000
                    self.isRecording = true
                    sender.isUserInteractionEnabled = true
                    return
                }
                else {
                    self.startButton.isSelected = false
                    self.isRecording = false
                    self.isCanceled = false
                    sender.isUserInteractionEnabled = true

                }
            }
        }
        else {
            
            RecordManager.sharedInstance.stop() {
                [unowned self] success in
                if success {
                    self.recordFinish()
                }
                else {
                    self.recordFail()
                }
                self.enableOtherViews()
                self.isRecording = false
                self.isCanceled = false
                sender.isUserInteractionEnabled = true
                return
            }
        }
    }
    
    func enableOtherViews() {
        self.coverView.removeFromSuperview()
    }
    
    //在取消录音时，会调用recorder的stop方法，此时仍然会收到通知
    func recordFinish() {
        enableOtherViews()  
        self.animateView.isHidden = true
        self.startButton.alpha = 1
        self.startButton.isSelected = false
//        self.startButton.setImage(ChImageAssets.MicrophoneBlue.image, for: .normal)
        stop()
        let timeInterval = Double((NSDate().timeIntervalSince1970 * 1000 - self.startMillisec) / 1000 )
        if false == self.isCanceled {//如果是人为取消，则不做处理
            self.delegate?.recordingSubmit(duration: timeInterval)
        }
    }
    @objc func recordFail() {
        self.isRecording = false//取消录音
        self.startButton.isSelected = false
//        self.startButton.setImage(ChImageAssets.MicrophoneBlue.image, for: .normal)
        self.delegate?.recordingCancel()
        self.animateView.isHidden = true
        self.startButton.alpha = 1
        stop()
    }
    func cancelRecording(sender: AnyObject?) {
        if false == isRecording {
            return
        }
        enableOtherViews()
        
        isRecording = false
        isCanceled = true
        RecordManager.sharedInstance.stopInterrupted()
    }
    
    func began() {
        stop()
        rippleLayer = CALayer.createRippleLayer(frame: CGRect(x: 0, y: 0, width: startButton.frame.width, height: startButton.frame.height), duration: 4, ripColor: rippleColor)
        startButton.layer.insertSublayer(rippleLayer!, at: 0)
        rippleState = true
    }
    
    func stop() {
        rippleLayer?.removeFromSuperlayer()
        rippleLayer = nil
        rippleState = false
    }
    
}


class CountDownView: UIView{
    var count:Int = 0 {
        didSet {
            switch count {
            case 5: countImage.image = ChImageAssets.countDown5.image
            case 4: countImage.image = ChImageAssets.countDown4.image
            case 3: countImage.image = ChImageAssets.countDown3.image
            case 2: countImage.image = ChImageAssets.countDown2.image
            default: countImage.image = ChImageAssets.countDown1.image
            }
        }
    }
    var countImage:UIImageView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        countImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        
        addSubview(countImage)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CALayer {
    //创建出动画layer
    static func createRippleLayer(frame: CGRect, duration: CFTimeInterval, ripColor: UIColor = .blue) -> CALayer {
        let shape = CAShapeLayer()
        let newFrame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
        let bound = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        shape.frame = bound
        shape.path = UIBezierPath(ovalIn: bound).cgPath
        shape.fillColor = ripColor.cgColor
        shape.opacity = 0
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [alphaAnimation(), scaleAnimation()]
        animationGroup.duration = 2
        animationGroup.autoreverses = false
        animationGroup.repeatCount = HUGE
        shape.add(animationGroup, forKey: "animationGroup")
        
        let replicatorLayer = CAReplicatorLayer()
        replicatorLayer.frame = newFrame
        replicatorLayer.instanceCount = 10
        replicatorLayer.instanceDelay = 0.5
        replicatorLayer.addSublayer(shape)
        return replicatorLayer
    }
    
    //透明度动画
    private static func alphaAnimation() -> CABasicAnimation {
        let alpha = CABasicAnimation(keyPath: "opacity")
        alpha.fromValue = 1
        alpha.toValue = 0
        return alpha
    }
    
    //放大动画
    private static func scaleAnimation() -> CABasicAnimation {
        let scale = CABasicAnimation(keyPath: "transform")
        scale.fromValue = CATransform3DScale(CATransform3DIdentity, 0.5, 0.5, 0)
        scale.toValue = CATransform3DScale(CATransform3DIdentity, 1.2, 1.2, 0)
        return scale
    }
}
