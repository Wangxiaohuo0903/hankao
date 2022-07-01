//
//  ButtonViews.swift
//  PracticeChinese
//
//  Created by ThomasXu on 11/07/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit
import CocoaLumberjack
import AVFoundation


protocol ButtonWithContentDelegate: class {
    func showContent()
    func hideContent()
}

class ButtonWithContent: UIView {
    
    var textLabel: UILabel!
    var imageView: UIImageView!
    var isPresenting = false
    weak var contentDelegate: ButtonWithContentDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width * 0.8, height: frame.height))
        textLabel.text = "text"
    //    textLabel.textColor = UIColor.hex(hex: <#T##String#>)
        self.addSubview(textLabel)
        
        imageView = UIImageView(frame: CGRect.zero)
        imageView.image = ChImageAssets.arrowDown.image
        self.addSubview(imageView)
        
        self.isPresenting = false
        
        self.isUserInteractionEnabled = true
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(userTap))
        self.addGestureRecognizer(recognizer)
    }
    
    //设置文本内容，需要首先设置字体
    func setText(text: String) {
        self.textLabel.text = text
        self.textLabel.sizeToFit()
        self.textLabel.frame = CGRect(x: 0, y: 0, width: textLabel.frame.width, height: frame.height)
        
        let left = frame.width - textLabel.frame.width
        var imgWidth = left * 0.8
        imgWidth = (imgWidth < frame.height * 0.7 ? imgWidth : frame.height * 0.7)*0.7
        let imgX = textLabel.frame.maxX + (left - imgWidth) / 2
        let imgY = (frame.height - imgWidth) / 2
        imageView.frame = CGRect(x: imgX, y: imgY, width: imgWidth, height: imgWidth)
    }
    
    @objc func userTap() {
        if self.isPresenting {
            self.isPresenting = false
            self.contentDelegate?.hideContent()
            self.imageView.image = ChImageAssets.arrowDown.image
        } else {
            self.isPresenting = true
            self.contentDelegate?.showContent()
            self.imageView.image = ChImageAssets.arrowUp.image
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

protocol LCVoiceButtonAbstractDelegate: class {
    func finish()
}

class LCVoiceButtonAbstract: UIButton {
    fileprivate static var singlePlayer: LCPlayer = LCPlayer(type: .Audio)
    var lcPlayer: LCPlayer!
    var delegate: LCVoiceButtonAbstractDelegate?
    fileprivate var isPlaying: Bool = false
    
    var audioUrl: String? {
        didSet {
            if let url = audioUrl {
                self.lcPlayer.setPlayUrl(webUrl: url)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        lcPlayer = LCVoiceButtonAbstract.singlePlayer//()// LCPlayer(type: .Audio)
        lcPlayer.delegate = self
        self.isPlaying = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(pressHome(notification:)), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterFromHome(nofitication:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        addTarget(self, action: #selector(clickButton), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //开始展示动画等，在子类中重写该方法
    func loadResource() {
        
    }
    
    //在子类中重写该方法，复原显示等
    func clearResource() {
//        print("Clear resource xxx")
    }
    
    @objc func pressHome(notification: NSNotification) {
        self.stop()
    }
    
    //手动停止播放，子类不应该重写该方法，如果需要清理资源，应该在clearResource中进行，但是不能设置成私有的
    //因为需要在外部调用
    func stop() {
        clearResource()
        if self.isPlaying {
            self.lcPlayer.pausePlay()
            self.playFinish()
            self.isPlaying = false
        }
    }
    
    //开始播放
    func start() {
        loadResource()
        if let url = audioUrl {
            if (nil != lcPlayer.delegate && lcPlayer.delegate !== self) {//这里使用对象进行比较，而不是音频URL，因为它们可能相等
                lcPlayer.delegate?.playFinish()
            }
            self.lcPlayer.setPlayUrl(webUrl: url)
            self.lcPlayer.delegate = self
        }
        if false == self.lcPlayer.startPlay() {
            return
        }
        self.loadResource()
        self.isPlaying = true
    }
    
    @objc func enterFromHome(nofitication: NSNotification) {
    //    UIApplication.topViewController()?.presentUserToast(message: "\(self.lcPlayer)")
        self.stop()
    }
    
    //每次用户点击播放的时候，界面应该马上有反应，所以应该马上开始计时，如果资源发生错误，应该停止计时
    @objc func clickButton() {
        if self.isPlaying {
            self.stop()
            self.isPlaying = false
        } else {
            self.isPlaying = true
            self.start()
        }
    }
    
    deinit {
        if self.isPlaying {
            self.stop()
        }
    }
}

extension LCVoiceButtonAbstract: LCPlayerDelegate {
    func periodicUpdateView(time: CMTime) {
    }
    
    //因为有可能在没有播放时调用该方法（切换音频资源时，所以需要进行判断）
    func playFinish() {
    //    UIApplication.topViewController()?.presentUserToast(message: "\(self)\n\(self.lcPlayer)\n\(self.isPlaying)")
        
        self.isPlaying = false
            self.clearResource()
        self.delegate?.finish()
    }
    
    func loadTimeRange() {
    }
    
    func playStart() {//播放真正开始
    }
    
    func errorGetData(error: Error?) {
        UIApplication.topViewController()?.presentUserErrorMessage()
        self.clearResource()
    }
}

class LCVoiceButtonNormal: LCVoiceButtonAbstract {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setSubviews()
    }
    
    func setSubviews() {
        setImage(ChImageAssets.audioPlayWord.image, for: .normal)
    }
}

//循环切换图片的Button
class LCVoiceButtonSwitch: LCVoiceButtonAbstract {
    
    fileprivate var timer: Timer!
    var voiceCount = 0
    var type = 0 //0为蓝色音波，1为白色音波
    
    var animationImages = [ChImageAssets.VoiceIcon1.image, ChImageAssets.VoiceIcon2.image, ChImageAssets.VoiceIcon3.image]
    
    var animationImageswhite = [UIImage(cgImage: (ChImageAssets.VoiceIconWhite1.image?.cgImage!)!, scale: (ChImageAssets.VoiceIconWhite1.image?.scale)!, orientation: UIImage.Orientation.upMirrored),UIImage(cgImage: (ChImageAssets.VoiceIconWhite2.image?.cgImage!)!, scale: (ChImageAssets.VoiceIconWhite2.image?.scale)!, orientation: UIImage.Orientation.upMirrored),UIImage(cgImage: (ChImageAssets.VoiceIconWhite3.image?.cgImage!)!, scale: (ChImageAssets.VoiceIconWhite3.image?.scale)!, orientation: UIImage.Orientation.upMirrored)]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setSubviews()
    }
    
    required init?(frame: CGRect,type :Int) {
        super.init(frame: frame)
        self.type = type
        setSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func setSubviews() {
        if self.type == 0 {
            setImage(ChImageAssets.voiceLeft3.image, for: .normal)
        }else{
            setImage(UIImage(cgImage: (ChImageAssets.VoiceIconWhite3.image?.cgImage!)!, scale: (ChImageAssets.VoiceIconWhite3.image?.scale)!, orientation: UIImage.Orientation.upMirrored), for: .normal)
        }
        self.imageView?.contentMode = .scaleAspectFit
        self.audioUrl = ""
    }
    
    func initAnimationIcon() {
        if nil != self.timer {
            self.timer.invalidate()
            self.timer = nil
        }
        if self.type == 0 {
            setImage(ChImageAssets.voiceLeft3.image, for: .normal)
        }else{
            setImage(UIImage(cgImage: (ChImageAssets.VoiceIconWhite3.image?.cgImage!)!, scale: (ChImageAssets.VoiceIconWhite3.image?.scale)!, orientation: UIImage.Orientation.upMirrored), for: .normal)
        }
    }
    
    override func clearResource() {
        self.initAnimationIcon()
    }
    
    //每次用户点击播放的时候，界面应该马上有反应，所以应该马上开始计时，如果资源发生错误，应该停止计时
    override func loadResource() {
        if timer != nil {
            timer.invalidate()
        }
        self.voiceCount = 0
        
        if #available(iOS 10.0, *) {
            timer = Timer(timeInterval: 0.25, repeats: true) {
                _ in
                self.setImage(self.getImgForCount(count: self.voiceCount), for: .normal)
                self.voiceCount += 1
            }
        } else {
            timer = Timer.schedule(timeInterval: 0.25, repeats: true) {
                _ in
                self.setImage(self.getImgForCount(count: self.voiceCount), for: .normal)
                self.voiceCount += 1
            }
            // Fallback on earlier versions
        }
        RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
    }
    
    private func getImgForCount(count: Int) -> UIImage? {
        if self.type == 0 {
            if animationImages.count <= 0 {
                return nil
            }
            let index = count % animationImages.count
            return animationImages[index];
        }else{
            if animationImageswhite.count <= 0 {
                return nil
            }
            let index = count % animationImageswhite.count
            return animationImageswhite[index];
        }
    }
    
}
