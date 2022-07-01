//
//  LPVoiceButton.swift
//  ChineseLearning
//
//  Created by ThomasXu on 22/05/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit
import CocoaLumberjack
import AVFoundation
import QuartzCore

enum LCVoiceStyle {
    case right // speaker to the right
    case wave
    case speaker
    case review
}

protocol LCVoiceButtonDelegate {
    func buttonPlayStop()
    func buttonPlayStart()
}
@IBDesignable
class LCVoiceButton: UIButtonVerticalLayout {
    static var singlePlayer: LCPlayer = LCPlayer(type: .Audio)
    var lcPlayer: LCPlayer!
    fileprivate var timer: Timer!
    fileprivate var voiceCount: Int = 0
    
    fileprivate var caAnimation = CABasicAnimation(keyPath: "position")
    fileprivate var waveView: WaveAnimationView!
    
    var voice1:UIImage!
    var voice2:UIImage!
    var voice3:UIImage!
    var defaultImage:UIImage!
    var delegate: LCVoiceButtonDelegate?
    //埋点
    var Scope = ""
    var Subscope = ""
    var indexPathStr = ""
    var Lessonid = ""
    var Event = ""
    
    //swift convert
    var style = LCVoiceStyle.speaker {
        didSet {
            if style == .review {
                shouldVerticalLayout = false
            }
        }
    }
    //swift convert
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.voice1 = ChImageAssets.VoiceIcon1.image
        self.voice2 = ChImageAssets.VoiceIcon2.image
        self.voice3 = ChImageAssets.VoiceIcon3.image
        self.imageView?.animationImages = [voice1, voice2, voice3]
        self.imageView?.animationDuration = 1
        self.imageView?.animationRepeatCount = 0
        self.adjustsImageWhenHighlighted = false
        self.contentMode = .scaleToFill
        lcPlayer = LCVoiceButton.singlePlayer
        setSubviews()
    }
    
    init(frame:CGRect, style:LCVoiceStyle) {
        super.init(frame: frame)
        self.style = style
        self.voice1 = ChImageAssets.VoiceIcon1.image
        self.voice2 = ChImageAssets.VoiceIcon2.image
        self.voice3 = ChImageAssets.VoiceIcon3.image
        self.imageView?.animationImages = [voice1, voice2, voice3]
        self.imageView?.animationDuration = 1
        self.imageView?.animationRepeatCount = 0
        self.adjustsImageWhenHighlighted = false
        self.contentMode = .scaleToFill
        
        lcPlayer = LCVoiceButton.singlePlayer
        
        setSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.contentMode = .scaleToFill

        lcPlayer = LCVoiceButton.singlePlayer
    }
    
    func setSubviews() {
        self.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        if (style == .speaker) {

        }
        if style == .right {
            self.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            DispatchQueue.main.async() {
                self.setImage(self.defaultImage, for: .normal)
            }
        }

        else if (style == .review) {
            layer.cornerRadius = 16
            layer.masksToBounds = true
            layer.borderColor = UIColor.hex(hex: "4e80d9").cgColor
            layer.borderWidth = 1

            setTitleColor(UIColor.hex(hex: "4e80d9"), for: .normal)
        
        }
        addTarget(self, action: #selector(playAudio), for: .touchUpInside)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(outputAudioPort(notification:)), name: NSNotification.Name.AVAudioSessionRouteChange, object: AVAudioSession.sharedInstance())
    }
    
    @objc func playAudio() {

        var info = ["Scope" : self.Scope,"Lessonid" : self.Lessonid,"IndexPath" : self.indexPathStr,"Event" : self.Event]
        if self.Scope == "ConversationChallenge" {
            info = ["Scope" : self.Scope,"Lessonid" : self.Lessonid,"Subscope" : "Test","IndexPath" : self.indexPathStr,"Event" : self.Event]
        }
        UserManager.shared.logUserClickInfo(info)

        play()
    }
    
    func pause(){
        self.lcPlayer.pausePlay()
        self.buttonPlayPasue()
    }
    
    func stop() {
        self.lcPlayer.pausePlay()
        self.buttonPlayFinish()
    }
    
    class func stopGlobal(_ shouldClear:Bool = false) {
        LCVoiceButton.singlePlayer.pausePlay()
//        LCVoiceButton.singlePlayer.removeObservers()
    }
    
    
    var audioUrl: String?
    var nextType = true //下一个是什么类型，如果是quiz,播放完后就显示Continue
    
    //每次用户点击播放的时候，界面应该马上有反应，所以应该马上开始计时，如果资源发生错误，应该停止计时
    func play() {
        if audioUrl == nil {
            return
        }
        if lcPlayer.playerPlaying {
            pause()
        }
//        self.isSelected = !self.isSelected
        if (nil != lcPlayer.delegate && lcPlayer.delegate !== self)
        {//这里使用对象进行比较，而不是音频URL，因为它们可能相等
            self.lcPlayer.delegate?.playFinish()
        }
        lcPlayer.delegate = self

        self.lcPlayer.setPlayUrl(webUrl: self.audioUrl!)
//            if self.isSelected {
//            DispatchQueue.main.async {
//                self.imageView!.startAnimating()
//            }
//                DispatchQueue.main.async {
//                    self.centerButtonOpen()
//                }
//            }
        let dq = DispatchQueue(label:"audioPlay")
        dq.asyncAfter(deadline: .now() + 0.1) {
            if false == self.lcPlayer.startPlay() {
                DispatchQueue.main.async {
                    self.imageView!.stopAnimating()
                }
                self.centerButtonClosed()
            }
            
        }
    }
    func changeImages(voice1:UIImage,voice2:UIImage,voice3:UIImage,defaultImage:UIImage){
        DispatchQueue.main.async() {
            self.setImage(defaultImage, for: .normal)
            
            self.voice1 = voice1
            self.voice2 = voice2
            self.voice3 = voice3
            self.defaultImage = defaultImage
            
            self.imageView?.animationImages = [self.voice1, self.voice2, self.voice3]
        }
        
    }
    func changeToSpeakerImages(){
        DispatchQueue.main.async() {
            self.setImage(ChImageAssets.VoiceIcon3.image, for: .normal)
            
            self.voice1 = ChImageAssets.VoiceIcon1.image
            self.voice2 = ChImageAssets.VoiceIcon2.image
            self.voice3 = ChImageAssets.VoiceIcon3.image
            
            self.imageView?.animationImages = [self.voice1, self.voice2, self.voice3]
        }
        
    }
    
    func centerButtonOpen() {
//        showAnimatonWithSeleted(Rotataion: CGFloat(Double.pi/2))
//        self.isSelected = true
    }
    func centerButtonClosed() {
//        showAnimatonWithSeleted(Rotataion: 0)
//        self.isSelected = false
    }
    func showAnimatonWithSeleted(Rotataion: CGFloat) {
//        UIView.animate(withDuration: 1, delay: 0.05, usingSpringWithDamping: 0.2, initialSpringVelocity: 5, options: .allowUserInteraction, animations: {
//            self.transform = CGAffineTransform(rotationAngle: Rotataion)
//        }) { (finished) in
//
//        }
    }
    
    
    func buttonPlayPasue(){
        if style == .speaker || style == .right {
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    self.imageView?.stopAnimating()
                }
                self.centerButtonClosed()
            }
        }
        else if style == .wave {
            if waveView != nil {
                waveView.layer.removeAllAnimations()
                waveView.removeFromSuperview()
            }
        }
    }

    
    func buttonPlayFinish(){
        //是否在读完语音后显示continue
//        if nextType {
          self.delegate?.buttonPlayStop()
//        }
        if style == .speaker || style == .right {
            DispatchQueue.main.async {
                self.imageView?.stopAnimating()
            }
            DispatchQueue.main.async {
                self.centerButtonClosed()
            }
        }
        else if style == .wave {
            if waveView != nil {
                waveView.layer.removeAllAnimations()
                waveView.removeFromSuperview()
            }
            }
        }
}

extension LCVoiceButton: LCPlayerDelegate {
    func periodicUpdateView(time: CMTime) {
    }
    
    func playFinish() {
        self.buttonPlayFinish()
    }
    
    func loadTimeRange() {
    }
    
    func playStart() {//播放真正开始时才播放动画
        self.delegate?.buttonPlayStart()
        DispatchQueue.main.async {
            self.imageView!.startAnimating()
        }
    }
    
    func errorGetData(error: Error?) {
        if style == .speaker {
            DispatchQueue.main.async {
                self.imageView!.startAnimating()
            }
        }
        else if style == .wave {
            waveView.layer.removeAllAnimations()
            waveView.removeFromSuperview()
        }
        //UIApplication.topViewController()?.presentUserErrorMessage()
    }
}

class WaveAnimationView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.hex(hex: "9bc2ed")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func draw(_ rect: CGRect) {
        var yc:CGFloat = 10
        var x:CGFloat = 0
        var y:CGFloat=rect.size.height;
        var w:CGFloat=0;
        var context:CGContext = UIGraphicsGetCurrentContext()!
        var path = CGMutablePath()
        var cycles:CGFloat = 2;//number of waves
        x = rect.size.width / cycles;
        context.setStrokeColor(UIColor.hex(hex: "4e80d9").cgColor)
        context.setFillColor(UIColor.hex(hex: "4e80d9").cgColor)
        
        context.setLineWidth(1)
        path.move(to: CGPoint(x:rect.size.width, y:y/2))
        path.addLine(to: CGPoint(x:rect.size.width, y:y))
        path.addLine(to: CGPoint(x:0, y:y))
        path.addLine(to: CGPoint(x:0, y:y/2))
        
        while (w<=rect.size.width) {
            path.move(to: CGPoint(x:w, y:y/2))
            path.addQuadCurve(to: CGPoint(x:w+x/2, y:y/2), control: CGPoint(x: w+x/4, y:y/2-yc))
            path.addQuadCurve(to: CGPoint(x:w+x, y:y/2), control: CGPoint(x: w+3*x/4, y:y/2+yc))
            w+=x;
        }
        context.addPath(path)
        context.drawPath(using: .fillStroke)
        
    }
}

