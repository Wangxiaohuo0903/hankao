//
//  LeftTextBubbleCell.swift
//  PracticeChinese
//
//  Created by 费跃 on 9/7/17.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import SnapKit

enum BubblePosition {
    case left
    case right
}

class TextBubbleCell:UITableViewCell {
    var avatarImg:UIImageView!
    var bubbleIcon:UIImageView!
    var chatImage:UIImageView!
    var titleLabel:UILabel!
    var bubbleView: UIView!
    var showAvatarImage = true
    //埋点
    var Scope = ""
    var Subscope = ""
    var indexPathStr = ""
    var Lessonid = ""
    var Event = ""
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    
    func setContent(msg: ChatMessageModel,showAvatarImage:Bool = true ) {
        let pos = msg.position
        let text = msg.text
        self.showAvatarImage = showAvatarImage
        
        if avatarImg != nil {
            avatarImg.removeFromSuperview()
            titleLabel.removeFromSuperview()
            bubbleView.removeFromSuperview()
            chatImage.removeFromSuperview()
            avatarImg = nil
            titleLabel = nil
            bubbleView = nil
            chatImage = nil
        }
        //聊天框头像
        avatarImg = UIImageView(frame: CGRect(x: pos == .left ? 0 : ScreenUtils.width - 60, y: 0, width: 40, height: 40))
        avatarImg.layer.cornerRadius = 20
        avatarImg.contentMode = .scaleAspectFill
        avatarImg.layer.masksToBounds = true
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
        }
        else {
            avatarImg.sd_setImage(with: URL(string: ""), placeholderImage: ChImageAssets.AvatarSystem.image, options: .refreshCached, completed: nil)
        }
        
        let textHeight = text.string.height(withConstrainedWidth: ScreenUtils.width - 70 - 26 - 20, font: FontUtil.getTextFont())
        let textWidth = text.string.wdith(withConstrainedWidth: ScreenUtils.width - 70 - 26 - 20, font: FontUtil.getTextFont())
        
        let bubbleHeight = max(textHeight+15, textHeight + 20)
        
        titleLabel = UILabel(frame: CGRect(x: 13, y: 0, width: textWidth, height: bubbleHeight))
        titleLabel.textColor = UIColor.textLightBlack
        titleLabel.font = FontUtil.getTextFont()
        titleLabel.numberOfLines = 0
        titleLabel.attributedText = text
        
        //可以在这里设置对话图片
        bubbleView = UIView(frame: CGRect(x: pos == .left ? 45  : ScreenUtils.width - 75 - textWidth, y: max(0, (40-bubbleHeight)/2), width: textWidth + 26, height: bubbleHeight))
        bubbleView.backgroundColor = UIColor.hex(hex: "F1F0F0")
        bubbleView.layer.cornerRadius = 12.5

        chatImage = UIImageView(frame: CGRect(x: 42, y: 0, width: textWidth + 26, height: 20))
        chatImage.image = UIImage(named: "chat_ava_left")
        chatImage.layer.masksToBounds = true
        chatImage.isHidden = false
        if !showAvatarImage {
            chatImage.isHidden = true
        }
        self.addSubview(chatImage)
        self.sendSubviewToBack(chatImage)
        
        bubbleView.addSubview(titleLabel)
        self.addSubview(avatarImg)
        self.addSubview(bubbleView)
        
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
            make.top.bottom.equalTo(self)
            if(pos == .left){
                make.left.equalTo(self.snp.left).offset(50)
            }else{
                make.right.equalTo(self.snp.right).offset(-50)
            }
            make.width.equalTo(textWidth+30)
        }
        chatImage.snp.remakeConstraints { (make) -> Void in
            make.top.equalTo(self)
            make.left.equalTo(self.snp.left).offset(42)
            make.width.equalTo(60)
            make.height.equalTo(20)
        }
        

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
