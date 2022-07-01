//
//  File.swift
//  PracticeChinese
//
//  Created by ThomasXu on 14/07/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

@IBDesignable
class LCVoiceButtonWave: LCVoiceButtonAbstract {
    
    fileprivate var caAnimation = CABasicAnimation(keyPath: "position")
    fileprivate var waveView: WaveAnimationView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadResource() {
        if (nil == waveView) {
            waveView = WaveAnimationView(frame: CGRect(x:  0 - self.imageView!.frame.width, y: 0, width: self.imageView!.frame.width * 2, height: self.imageView!.frame.height))
            self.imageView!.layer.masksToBounds = true
            self.imageView!.layer.cornerRadius = self.imageView!.frame.height/2
            caAnimation.duration = 0.8
            caAnimation.repeatCount = .infinity
            caAnimation.beginTime = 0
            caAnimation.fromValue = waveView.layer.position
            caAnimation.toValue = CGPoint(x:self.imageView!.frame.width, y:waveView.layer.position.y)
            
            self.imageView!.addSubview(waveView)
            self.waveView.layer.add(self.caAnimation, forKey: "CAWAVE")
        }
    }
    
    override func clearResource() {
        if nil != self.waveView {//这里可以设置隐藏
            waveView.layer.removeAllAnimations()
            waveView.removeFromSuperview()
            self.waveView = nil
        }
    }
}

extension LCVoiceButtonWave {
    override func layoutSubviews() {
        super.layoutSubviews()
        if let img = self.imageView, let title = self.titleLabel, let text = title.text {
            if text.characters.count <= 0 {
                return
            }
            let titleHeight = title.font.lineHeight
            let titleY = frame.height - titleHeight
            
            let imgTitleDis: CGFloat = 1
            let imgHeight = frame.height - imgTitleDis - titleHeight
            let realWidth = min(imgHeight, frame.width)
            let imgX = (frame.width - realWidth) / 2
            img.frame = CGRect(x: imgX, y: 0, width: realWidth, height: realWidth)
            
            title.frame = CGRect(x: 0, y: titleY, width: frame.width, height: titleHeight)
            title.textAlignment = .center
        }
    }
}
