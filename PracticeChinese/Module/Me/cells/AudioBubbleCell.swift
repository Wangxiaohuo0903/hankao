//
//  AudioBubbleCell.swift
//  PracticeChinese
//
//  Created by 费跃 on 9/11/17.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView
import SnapKit

class AudioBubbleCell:UITableViewCell {
    var avatarImg:UIImageView!
    var audioButton:LCVoiceButton!
    var bubbleView: UIView!
    var trophyImg: UIImageView!
    var trophyScore: UILabel!
    var animateView: NVActivityIndicatorView!
    var chatImage: UIImageView!
    //埋点
    var Scope = ""
    var Subscope = ""
    var indexPathStr = ""
    var Lessonid = ""
    var Event = ""
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        self.backgroundColor = UIColor.yellow
        self.selectionStyle = .none
        self.layer.masksToBounds = false
        self.contentView.layer.masksToBounds = false
        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
        
        avatarImg = UIImageView(frame: CGRect(x:ScreenUtils.width - 60, y: 0, width: 40, height: 40))
        avatarImg.layer.cornerRadius = 20
        avatarImg.layer.masksToBounds = true

        chatImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 22.5, height: 20))
        chatImage.image = UIImage(named: "chat_ava_right")
        self.addSubview(chatImage)
        self.sendSubviewToBack(chatImage)
        
        bubbleView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        bubbleView.backgroundColor = UIColor.hex(hex: "4E80D9")
        bubbleView.layer.borderColor = UIColor.hex(hex: "4E80D9").cgColor
        
        bubbleView.layer.cornerRadius = 12.5
//        bubbleView.addSubview(audioButton)
        
        bubbleView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(playAudio))
        bubbleView.addGestureRecognizer(gesture)
        self.addSubview(avatarImg)
        self.addSubview(bubbleView)
        trophyImg = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        trophyScore = UILabel(frame: CGRect(x: 0, y: 10, width: 0, height: 22))
        trophyScore.textColor = UIColor.white
        let scoreFont = FontUtil.getFont(size: 14, type: .Regular)
        trophyScore.font = scoreFont
        trophyScore.textAlignment = .center
        trophyImg.addSubview(trophyScore)
        bubbleView.addSubview(trophyImg)
        
        self.addSubview(avatarImg)
        self.addSubview(bubbleView)
        
        animateView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 25, height: 25), type: .ballSpinFadeLoader, color: UIColor.hex(hex: "77a4e6"), padding: 0)
        self.addSubview(animateView)
        
    }
    
    func setContent(msg: ChatMessageModel) {
        let pos = msg.position
        let url = msg.audioUrl

        if msg.position == .right {
            //头像
            if self.Scope == "ConversationChallenge" {
                avatarImg.sd_setImage(with: URL(string: msg.avatarUrl), placeholderImage: ChImageAssets.Avatar.image)
            }else {
                avatarImg.sd_setImage(with: UserManager.shared.getAvatarUrl(), placeholderImage: ChImageAssets.Avatar.image, options: .refreshCached, completed: nil)
            }
        }
        else {
            avatarImg.sd_setImage(with: URL(string: ""), placeholderImage: ChImageAssets.AvatarSystem.image, options: .refreshCached, completed: nil)
        }
        
        let buttonHeight = 20
        let buttonWidth = 20
        
        let bubbleHeight = 40
        
        if (audioButton != nil) {
            audioButton.delegate = nil
            audioButton.removeFromSuperview()
            audioButton = nil
        }
        
        audioButton = LCVoiceButton(frame: CGRect(x: 65, y: 0, width: 0, height: 0), style: .right)
        audioButton.changeImages(voice1: ChImageAssets.VoiceIconWhite1.image!,voice2: ChImageAssets.VoiceIconWhite2.image!,voice3: ChImageAssets.VoiceIconWhite3.image!,defaultImage:ChImageAssets.VoiceIconWhite3.image!)
        audioButton.Scope = self.Scope
        audioButton.Lessonid = self.Lessonid
        audioButton.indexPathStr = self.indexPathStr
        audioButton.audioUrl = url
        audioButton.Event = "ListenMyRecording"
        bubbleView.addSubview(audioButton)
        
        bubbleView.frame = CGRect(x: Int(ScreenUtils.width - 157.5  - CGFloat(buttonWidth)), y: max(0, (40-bubbleHeight)/2), width: buttonWidth+75, height: bubbleHeight)
        if msg.score == -1 {
            let animateWidth = 25

            animateView.isHidden = false
            animateView.snp.remakeConstraints { (make) -> Void in
                make.centerY.equalTo(bubbleView.snp.centerY)
                make.right.equalTo(bubbleView.snp.left).offset(-5)
                make.height.equalTo(animateWidth)
                make.width.equalTo(animateWidth)
            }
            
            animateView.startAnimating()
            
        }else {
            animateView.isHidden = true
        }

        audioButton.snp.remakeConstraints { (make) -> Void in
            make.centerY.equalTo(bubbleView.snp.centerY)
            make.right.equalTo(bubbleView.snp.right).offset(-8)
            make.width.height.equalTo(26)
        }
        
        avatarImg.snp.remakeConstraints { (make) -> Void in
            make.top.equalTo(self)
            if(pos == .left){
                make.left.equalTo(self.snp.left)
            }else{
                make.right.equalTo(self.snp.right)
            }
            make.width.height.equalTo(40)
        }
        
        bubbleView.snp.remakeConstraints { (make) -> Void in
            make.top.equalTo(self)
            make.bottom.equalTo(self).offset(-8)
            if(pos == .left){
                make.left.equalTo(self.snp.left).offset(50)
            }else{
                make.right.equalTo(self.snp.right).offset(-50)
            }
            make.width.equalTo(buttonWidth+75)
        }
        
        
//        if msg.score >= 0 {
            chatImage.snp.remakeConstraints { (make) -> Void in
                make.right.equalTo(self.snp.right).offset(-42.5)
                make.height.equalTo(20)
                make.width.equalTo(buttonWidth)
            }
//        }
        let trophyWidth = 48
        trophyImg.isHidden = true
        trophyScore.isHidden = true
        if msg.score >= 0 {
            trophyImg.isHidden = false
            trophyScore.isHidden = false
            if msg.score < 60 {
                trophyImg.image = ChImageAssets.medalGray.image
            }
            else {
                trophyImg.image = ChImageAssets.medalGolden.image
            }
            let scoreFont = FontUtil.getFont(size: 14, type: .Regular)
            trophyScore.frame = CGRect(x: 0, y: 10, width: trophyWidth, height: 22)
            if(AdjustGlobal().CurrentScale == AdjustScale.iPhonePlus){
                trophyScore.frame = CGRect(x: 0, y: 10, width: trophyWidth, height: 22)
            }else{
                trophyScore.frame = CGRect(x: 0, y: 12, width: trophyWidth, height: 22)
            }
            trophyScore.text = "\(msg.score)"
            trophyImg.snp.remakeConstraints { (make) -> Void in
                
                make.top.equalTo(bubbleView.snp.top)
                make.left.equalTo(bubbleView.snp.left).offset(-20)
                make.width.equalTo(trophyWidth)
                make.height.equalTo(45)
            }
            
        }
    }
    
    @objc func playAudio() {
//        audioButton.play()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
