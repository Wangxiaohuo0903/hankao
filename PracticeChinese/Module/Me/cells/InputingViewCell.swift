//
//  InputingViewCell.swift
//  PracticeChinese
//
//  Created by 费跃 on 9/19/17.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import NVActivityIndicatorView
import UIKit
import SnapKit

class InputViewCell: UITableViewCell {
    var avatarImg:UIImageView!
    var activityView: NVActivityIndicatorView!
    var bubbleView: UIView!
    //埋点
    var Scope = ""
    var Subscope = ""
    var indexPathStr = ""
    var Lessonid = ""
    var Event = ""
    var chatImage: UIImageView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
//        self.backgroundColor = UIColor.orange
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setContent( msg: ChatMessageModel,showAvatarImage:Bool = true ) {
        let pos = msg.position
        if avatarImg != nil {
            avatarImg.removeFromSuperview()
            activityView.removeFromSuperview()
            bubbleView.removeFromSuperview()
        }
        if chatImage != nil {
            chatImage.removeFromSuperview()
        }
        avatarImg = UIImageView(frame: CGRect(x: pos == .left ? 0 : ScreenUtils.width - 67.5, y: 0, width: 40, height: 40))
        avatarImg.layer.cornerRadius = 20
        avatarImg.clipsToBounds = true
        avatarImg.contentMode = .scaleAspectFill
        avatarImg.isHidden = false
        if !showAvatarImage {
            avatarImg.isHidden = true
        }
        if msg.position == .right {
            //头像
            if self.Scope == "ConversationChallenge" {
                avatarImg.sd_setImage(with: URL(string: msg.avatarUrl), placeholderImage: ChImageAssets.Avatar.image)
            }else {
                avatarImg.sd_setImage(with: UserManager.shared.getAvatarUrl(), placeholderImage: ChImageAssets.Avatar.image, options: .refreshCached, completed: nil)
            }
            chatImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 22.5, height: 20))
            chatImage.image = UIImage(named: "chat_ava_right")
            self.addSubview(chatImage)
            self.sendSubviewToBack(chatImage)
            chatImage.snp.remakeConstraints { (make) -> Void in
                make.right.equalTo(self.snp.right).offset(-42.5)
                make.height.equalTo(20)
                make.width.equalTo(20)
            }
        }
        else {
            
            avatarImg.sd_setImage(with: URL(string: ""), placeholderImage: ChImageAssets.AvatarSystem.image, options: .refreshCached, completed: nil)
            chatImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 22.5, height: 20))
            chatImage.image = UIImage(named: "chat_ava_left")
            self.addSubview(chatImage)
            self.sendSubviewToBack(chatImage)
            chatImage.snp.remakeConstraints { (make) -> Void in
                make.top.equalTo(self)
                make.left.equalTo(self.snp.left).offset(42)
                make.width.equalTo(60)
                make.height.equalTo(20)
            }
            
        }
        
        if !showAvatarImage {
            chatImage.isHidden = true
        }else {
            chatImage.isHidden = false
        }

        let bubbleHeight = 40
        let activityWidth = 40
        activityView = pos == .left ? NVActivityIndicatorView(frame: CGRect(x: 10, y: 6.5, width: 40, height: 25), type: NVActivityIndicatorType.ballPulseSync, color: UIColor.blueTheme, padding: 0) :NVActivityIndicatorView(frame: CGRect(x: 10, y: 6.5, width: 40, height: 25), type: NVActivityIndicatorType.ballPulseSync, color: UIColor.white, padding: 0)

        bubbleView = UIView(frame: CGRect(x: pos == .left ? Int(50) : Int(ScreenUtils.width - 102.5 - CGFloat(activityWidth)), y: max(0, (40-bubbleHeight)/2), width: activityWidth+20, height: bubbleHeight))
        bubbleView.backgroundColor = pos == .left ? UIColor.hex(hex: "F1F0F0") : UIColor.hex(hex: "4E80D9")
        bubbleView.layer.cornerRadius = 12.5
        bubbleView.addSubview(activityView)
        bubbleView.layer.borderColor = pos == .left ? UIColor.hex(hex: "F1F0F0").cgColor : UIColor.hex(hex: "4E80D9").cgColor
        activityView.startAnimating()
        
        self.addSubview(avatarImg)
        self.addSubview(bubbleView)
        
        activityView.snp.remakeConstraints { (make) -> Void in
            make.center.equalTo(bubbleView.snp.center)
            make.width.equalTo(activityView.frame.width)
            make.height.equalTo(activityView.frame.height)
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
            make.width.equalTo(activityWidth+20)
        }

    }
}
