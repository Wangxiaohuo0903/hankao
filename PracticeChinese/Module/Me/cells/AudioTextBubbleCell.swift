//
//  AudioTextBubbleCell.swift
//  PracticeChinese
//
//  Created by 费跃 on 9/11/17.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit
import SnapKit


class AudioTextBubbleCell:UITableViewCell,TextViewDelegate {
    func superViewConstraints() {
        
    }
    //头像
    var avatarImg:UIImageView!
    //英文
    var enLabel: UILabel!
    
    var bubbleView: UIView!
    //中拼
    var chineseandpinyinLabel: SpeakTokensView!
    //播放按钮
    var audioButton: LCVoiceButton!
    //
    var audioContainer: UIView!
    //1/7,进度指示
    var indexLabel: UILabel!
    //数据
    var msg:ChatMessageModel!
    //
    var buttonsView:UIView!
    
    var labelsView:UIView!
    
    var chatImage:UIImageView!
    //埋点
    var Scope = ""
    var Subscope = ""
    var indexPathStr = ""
    var Lessonid = ""
    var Event = ""
    var cellHeight = 0.0
    func tapped() {
        audioButton.play()
    }
    
  
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.hex(hex: "F1F0F0")
        self.selectionStyle = .none
        //最大宽度
        let cardMaxWidth = AdjustGlobal().CurrentScaleWidth - 70 - 26 - 20
        //大背景
        bubbleView = UIView()
        bubbleView.layer.cornerRadius = 12.5
        bubbleView.clipsToBounds = true
        bubbleView.backgroundColor = UIColor.hex(hex: "F1F0F0")
        bubbleView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(playAudio))
        bubbleView.addGestureRecognizer(gesture)
        self.addSubview(bubbleView)
        
        //顶部包含进度，语音按钮
        buttonsView = UIView()
        bubbleView.addSubview(buttonsView)
        
        //tokens,英文的背景
        labelsView = UIView()
        bubbleView.addSubview(labelsView)
        
        //头像
        avatarImg = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        avatarImg.layer.cornerRadius = 20
        avatarImg.layer.masksToBounds = true
        self.addSubview(avatarImg)
        
        //进度
        let indexFont = FontUtil.getFont(size: FontAdjust().FontSize(12), type: .Medium)
        indexLabel = UILabel(frame: CGRect.zero )
        indexLabel.textColor = UIColor.white
        indexLabel.font = indexFont
        indexLabel.numberOfLines = 0
        indexLabel.textAlignment = .center
        indexLabel.clipsToBounds = true
        indexLabel.backgroundColor = UIColor.blueTheme
        buttonsView.addSubview(indexLabel)
        
        //语音
        //宽18，高16
        audioContainer = UIView()
//        audioButton = LCVoiceButton(frame: CGRect(x: 0 , y: 0, width: Double(18), height: Double(16)), style: .speaker)
//        audioButton.changeImages(voice1: ChImageAssets.VoiceIcon1.image!,voice2: ChImageAssets.VoiceIcon2.image!,voice3: ChImageAssets.VoiceIcon3.image!)
//        audioButton.Scope = self.Scope
//        audioButton.Lessonid = self.Lessonid
//        audioButton.indexPathStr = self.indexPathStr
//        audioContainer.addSubview(audioButton)
        buttonsView.addSubview(audioContainer)
        
        //聊天框的尖尖部分
        chatImage = UIImageView()
        chatImage.image = UIImage(named: "chat_left")
        chatImage.isHidden = true
        self.addSubview(chatImage)
        self.sendSubviewToBack(chatImage)
        
        //英文部分
        enLabel = UILabel()
        enLabel.textColor = UIColor.lightText
        enLabel.font = FontUtil.getDescFont()
        enLabel.numberOfLines = 0
        enLabel.textAlignment = .left
        labelsView.addSubview(enLabel)
        
        //tokens
        chineseandpinyinLabel = SpeakTokensView(frame: CGRect(x: 13, y: 0, width: cardMaxWidth, height: 150), tokens: [], chineseSize: FontAdjust().Speak_ChineseAndPinyin_C(), pinyinSize: FontAdjust().Speak_ChineseAndPinyin_P(), style: .chineseandpinyin, changeAble: true,showIpa:false,scope: self.Scope,cColor:UIColor.textBlack333,pColor:UIColor.textGray,scoreRight:false)
        labelsView.addSubview(chineseandpinyinLabel)
        
    }
    //设置数据
    func setContent( msg: ChatMessageModel) {
        self.msg = msg
        let url = msg.audioUrl
        let en = msg.en
        //分语块的数组
        let textArray = msg.textArray
        let cardMaxWidth = AdjustGlobal().CurrentScaleWidth - 70 - 26 - 20
        
        let cardMinWidth = AdjustGlobal().CurrentScaleWidth*0.3
        if (audioButton != nil) {
            audioButton.removeFromSuperview()
            audioButton = nil
        }
        audioButton = LCVoiceButton(frame: CGRect(x: 0 , y: 0, width: Double(18), height: Double(16)), style: .speaker)
        audioButton.changeImages(voice1: ChImageAssets.VoiceIcon1.image!,voice2: ChImageAssets.VoiceIcon2.image!,voice3: ChImageAssets.VoiceIcon3.image!,defaultImage:ChImageAssets.VoiceIcon3.image!)
        audioButton.Scope = self.Scope
        audioButton.Lessonid = self.Lessonid
        audioButton.indexPathStr = self.indexPathStr
        audioContainer.addSubview(audioButton)
        //设置语音
        audioButton.audioUrl = url
        //英文
        let enHeight = en.string.height(withConstrainedWidth: cardMaxWidth, font: FontUtil.getDescFont()) + 2
        let englishwidth = en.string.wdith(withConstrainedWidth: cardMaxWidth, font: FontUtil.getDescFont()) + 2
        
        //设置头像
        if self.Scope == "ConversationChallenge" {
            avatarImg.sd_setImage(with: URL(string: msg.avatarUrl), placeholderImage: ChImageAssets.AvatarSystem.image)
        }else {
            avatarImg.sd_setImage(with: URL(string: ""), placeholderImage: ChImageAssets.AvatarSystem.image, options: .refreshCached, completed: nil)
        }
        
        let padding = 2.5
        let pyTop = 2.5
        
        //进度或者答案提示Reference Answer
        let indexLabelHeight:CGFloat = 16
        var indexLabelWidth:CGFloat = 0
        let indexFont = FontUtil.getFont(size: FontAdjust().FontSize(12), type: .Medium)
        if msg.index != "" {
            indexLabel.text = msg.index
            indexLabelWidth = getLabelWidth(labelStr: indexLabel.text!, font: indexFont)+10
        }else{
            indexLabel.text = "Reference Answer"
            indexLabelWidth = getLabelWidth(labelStr: indexLabel.text!, font: indexFont)+10
        }
        indexLabel.layer.cornerRadius = indexLabelHeight/2
        indexLabel.frame = CGRect(x: 13, y: 10, width: indexLabelWidth, height: indexLabelHeight)
        
        //中文
        chineseandpinyinLabel.Scope = self.Scope
        chineseandpinyinLabel.MaxWidth = Double(cardMaxWidth)
        chineseandpinyinLabel.tokensArr = textArray
        chineseandpinyinLabel.setData()
        //中文高度
        let getHeight = chineseandpinyinLabel.getViewHeight()
        //宽度
        let enWidth = min(cardMaxWidth,max(cardMinWidth,max(chineseandpinyinLabel.getViewWidth(), max(englishwidth,(CGFloat(indexLabelWidth+26+15+10))))))
        let bubbleViewWidth = enWidth + 26
        //可显示高度
        let bubbleHeight = max(getHeight+enHeight + 29, 38)
        chatImage.frame = CGRect(x: 44, y: 0, width: bubbleViewWidth, height: bubbleHeight)
        //英文位置
        enLabel.frame = CGRect(x: 13, y: CGFloat(Double(getHeight)+padding+pyTop), width: englishwidth, height: enHeight)
        enLabel.attributedText = en
        
        bubbleView.frame = CGRect(x: 50, y: 0, width: enWidth+40, height: bubbleHeight)
        cellHeight = Double(bubbleHeight)


        bubbleView.frame = CGRect(x: 50, y: 0, width: bubbleViewWidth, height:chineseandpinyinLabel.getViewHeight() + enHeight + 36 + 15)

        let buttonsViewHeight:CGFloat = 36
        buttonsView.frame = CGRect(x: 0, y: 0, width: bubbleViewWidth, height: buttonsViewHeight)
        labelsView.frame = CGRect(x: 0, y: buttonsView.frame.maxY, width: bubbleViewWidth, height: bubbleHeight - buttonsViewHeight)

        //语音按钮
        audioContainer.layer.cornerRadius = 8
        audioContainer.frame = CGRect(x: CGFloat(bubbleViewWidth) - CGFloat(16  + 10), y: CGFloat(10), width: 18, height: 16)
        audioButton.frame = CGRect(x: 0, y: 0, width: 18, height: 16)
        
        var event = ""
        switch self.Scope {
        case "Speak":
            event = "ListenSampleAudio"
            chatImage.isHidden = true
        case "Scenario":
            event = "ListenQuestionAudio"
            chatImage.isHidden = true
            if msg.index == "" {
                //答案
                event = "ListenAnswer"
            }
        case "ConversationChallenge":
            chatImage.isHidden = false
            event = "ListenQuestionAudio"
        default:
            event = ""
        }
        
        audioButton.Event = event

    }
    @objc func playAudio() {
        audioButton.play()
    }
    
    func getLabelWidth(labelStr:String,font:UIFont)->CGFloat{
        var indexLabelHeight:CGFloat = 16

        let maxSie:CGSize = CGSize(width:self.frame.width,height:indexLabelHeight)
        return (labelStr as NSString).boundingRect(with: maxSie, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):font]), context: nil).size.width
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
