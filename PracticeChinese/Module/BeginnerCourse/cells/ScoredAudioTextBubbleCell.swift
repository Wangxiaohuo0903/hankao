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


class ScoredAudioTextBubbleCell:UITableViewCell,TextViewDelegate {
    func tapped() {
        audioButton.play()
    }
    
    func superViewConstraints() {
        
    }
    //头像
    var avatarImg:UIImageView!
    //英文
    var enLabel: UILabel!
    
    var bubbleIcon:UIImageView!

    var bubbleView: UIView!
    //中拼
    var chineseandpinyinLabel: SpeakTokensView!
    //播放按钮
    var audioButton: LCVoiceButton!
    //
//    var audioContainer: UIView!
    //
    var audioBg: UIView!
    //打分图
    var trophyImg: UIImageView!
    //打分文字
    var trophyScore: UILabel!
    //
    var msg: ChatMessageModel!
    var bubbleWidth:CGFloat = 0
    var buttonsView:UIView!
    var labelsView:UIView!
    var chatImage:UIImageView!
    //埋点
    var Scope = ""
    var Subscope = ""
    var indexPathStr = ""
    var Lessonid = ""
    var Event = ""
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        self.backgroundColor = UIColor.cyan
        self.selectionStyle = .none
        //最大宽度
        let cardMaxWidth = AdjustGlobal().CurrentScaleWidth - 70 - 26 - 20
        //大背景
        bubbleView = UIView()
        bubbleView.layer.cornerRadius = 12.5
        bubbleView.clipsToBounds = true
        bubbleView.isUserInteractionEnabled = true
        bubbleView.layer.masksToBounds = false
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
        avatarImg = UIImageView(frame: CGRect(x: ScreenUtils.width - 60, y: 0, width: 40, height: 40))
        avatarImg.layer.cornerRadius = 20
        avatarImg.layer.masksToBounds = true
        self.addSubview(avatarImg)
        //语音
        //宽18，高16
        audioBg = UIView()
        audioBg.layer.cornerRadius = 15
        buttonsView.addSubview(audioBg)
        
        audioButton = LCVoiceButton(frame: CGRect(x: 0 , y: 0, width: Double(18), height: Double(16)), style: .speaker)
        audioButton.changeImages(voice1: ChImageAssets.VoiceIconWhiteRight1.image!,voice2: ChImageAssets.VoiceIconWhiteRight2.image!,voice3: ChImageAssets.VoiceIconWhiteRight3.image!,defaultImage:ChImageAssets.VoiceIconWhiteRight3.image!)
        audioButton.Scope = self.Scope
        audioButton.Lessonid = self.Lessonid
        audioButton.indexPathStr = self.indexPathStr
        audioBg.addSubview(audioButton)
        
        //分数
        let trophyWidth = 48
        let scoreFont = FontUtil.getFont(size: 14, type: .Medium)
        trophyImg = UIImageView(frame: CGRect(x: 5, y: 0, width: trophyWidth, height: 45))
        trophyScore = UILabel(frame: CGRect(x: 2, y: 10, width: trophyWidth - 4, height: 22))
        
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhonePlus){
            trophyScore.frame = CGRect(x: 2, y: 10, width: trophyWidth - 4, height: 22)
        }else{
            trophyScore.frame = CGRect(x: 2, y: 12, width: trophyWidth - 4, height: 22)
        }
        trophyImg.contentMode = .scaleAspectFill
        trophyScore.textColor = UIColor.white
        trophyScore.font = scoreFont
        trophyScore.textAlignment = .center
        trophyImg.addSubview(trophyScore)
        buttonsView.addSubview(trophyImg)
        
        //聊天框的尖尖部分
        chatImage = UIImageView()
        chatImage.image = UIImage(named: "chat_right")
        self.addSubview(chatImage)
        self.sendSubviewToBack(chatImage)
        
        //tokens
        chineseandpinyinLabel = SpeakTokensView(frame: CGRect(x: 13, y: 0, width: cardMaxWidth, height: 150), tokens: [], chineseSize: FontAdjust().Speak_ChineseAndPinyin_C(), pinyinSize: FontAdjust().Speak_ChineseAndPinyin_P(), style: .chineseandpinyin, changeAble: true,showIpa:false,scope: self.Scope,cColor:UIColor.textBlack333,pColor:UIColor.lightText,scoreRight:true)
        labelsView.addSubview(chineseandpinyinLabel)
        
        //英文部分
        enLabel = UILabel()
        enLabel.font = FontUtil.getDescFont()
        enLabel.numberOfLines = 0
        enLabel.textAlignment = .left
        enLabel.textColor = UIColor.white
        labelsView.addSubview(enLabel)
        
    }
    
    func setContent( msg: ChatMessageModel, animate: Bool = false) {
        self.msg = msg
        
        let url = msg.audioUrl
        let pinyin = msg.pinyinText
        let text = msg.text
        let en = msg.en
        let textArray = msg.textArray
        //最大宽度
        let cardMaxWidth = AdjustGlobal().CurrentScaleWidth - 70 - 26 - 20
        //最小宽度
        let cardMinWidth = AdjustGlobal().CurrentScaleWidth*0.3
        //get attributes for every single pinyin
        let pinyinSet = pinyin.string.split(separator: " ")
        var k = 0
        var attributeSet = [[String : Any]]()
        //swift convert
        for (_, py) in pinyinSet.enumerated() {
            let startIndex = pinyin.string.index(pinyin.string.startIndex, offsetBy: k)
            let range = pinyin.string.range(of: py, options: .caseInsensitive, range: startIndex..<pinyin.string.endIndex, locale:nil)
            var nsrange = NSMakeRange(0, pinyin.string.count)
            let attributes = convertFromNSAttributedStringKeyDictionary(pinyin.attributes(at: pinyin.string.distance(from: startIndex, to: range!.lowerBound), effectiveRange: &nsrange))
            attributeSet.append(attributes)
            k += pinyin.string.distance(from: range!.lowerBound, to: range!.upperBound)
        }
        //swift convert
        var i = 0
        var pinyinText = NSMutableAttributedString(string: "")
        //replace by text
        //swift range is terrible maybe bugs here
        
        for (j, model) in textArray.enumerated() {
            if i == pinyinSet.count {
                break
            }
            // punctuation symbols
            
            k = 0
            var tmpText = NSMutableAttributedString(string: model.pinyinText.string)
            //swift convert
            while k < model.pinyinText.string.count && i < pinyinSet.count {
                let startIndex = model.pinyinText.string.index(model.pinyinText.string.startIndex, offsetBy: k)
                let r = model.pinyinText.string.range(of: pinyinSet[i], options: .caseInsensitive, range: startIndex..<model.pinyinText.string.endIndex, locale:nil)
                if let range = r {
                    tmpText.addAttributes(convertToNSAttributedStringKeyDictionary(attributeSet[i]), range: NSMakeRange(tmpText.string.distance(from: startIndex, to: range.lowerBound) , tmpText.string.distance(from: range.lowerBound, to: range.upperBound)))
                    k = tmpText.string.distance(from: startIndex, to: range.upperBound)
                    i += 1
                }
                else {
                    k += 1
                }
            }
            //swift convert
            model.pinyinText = tmpText
        }

        var chinesetext = text.mutableString
        while true {
            let range = chinesetext.range(of: " ")
            if range.location == NSNotFound {
                break
            }
            chinesetext.deleteCharacters(in: range)

        }

        for (i,model) in textArray.enumerated() {
            var preText = NSMutableAttributedString(string: "")
            for (j,model) in textArray.enumerated() {
                //遍历前面的，
                if j < i {
                    preText = NSMutableAttributedString(string: (preText.mutableString as String) + (model.text.string as String))
                }else {
                    break
                }
                
            }
            let replaceText = text.attributedSubstring(from: NSRange(location: preText.length, length: model.text.length))
            
            model.text = replaceText 
            var range = NSRange(location: 0, length: model.text.length)
            let attributes = convertFromNSAttributedStringKeyDictionary(model.text.attributes(at: 0, effectiveRange: &range))
        }
        
        
        //头像

        if self.Scope == "ConversationChallenge" {
            avatarImg.sd_setImage(with: URL(string: msg.avatarUrl), placeholderImage: ChImageAssets.Avatar.image)
        }else {
            avatarImg.sd_setImage(with: UserManager.shared.getAvatarUrl(), placeholderImage: ChImageAssets.Avatar.image, options: .refreshCached, completed: nil)
        }

        //中文
        chineseandpinyinLabel.Scope = self.Scope
        chineseandpinyinLabel.MaxWidth = Double(cardMaxWidth)
        chineseandpinyinLabel.tokensArr = textArray
        chineseandpinyinLabel.setData()
        
        //英文宽度高度
        let enHeight = en.string.height(withConstrainedWidth: cardMaxWidth, font: FontUtil.getDescFont()) + 2
        let englishwidth = en.string.wdith(withConstrainedWidth: cardMaxWidth, font: FontUtil.getDescFont()) + 2
        //中拼高度
        let getHeight = chineseandpinyinLabel.getViewHeight()
        //中拼，英文
        let bubbleHeight = max(getHeight+enHeight + 43 + 15, 38)
        //长度
        let enWidth = min(cardMaxWidth,max(cardMinWidth,max(chineseandpinyinLabel.getViewWidth(), max(englishwidth,(CGFloat(40+26+15+10))))))
        bubbleWidth = enWidth + 26
        bubbleView.frame = CGRect(x: self.frame.width - bubbleWidth - 52, y: 0, width: bubbleWidth, height: bubbleHeight)
        
        let buttonsViewHeight:CGFloat = 43
        buttonsView.frame = CGRect(x: 0, y: 0, width: bubbleWidth, height: buttonsViewHeight)
        labelsView.frame = CGRect(x: 0, y: buttonsView.frame.maxY + 2, width: bubbleWidth, height: bubbleHeight - buttonsViewHeight)
        
        //英文
        enLabel.frame =  CGRect(x: 13, y: labelsView.frame.height - enHeight - 10, width: bubbleWidth, height: enHeight)
        enLabel.attributedText = en

        //语音按钮
        audioBg.frame = CGRect(x: Int(bubbleWidth - 32), y: 5, width: 30, height: 30)
        audioButton.frame = CGRect(x: 5, y: 5, width: 20, height: 20)
        audioButton.audioUrl = url
        audioButton.Scope = self.Scope
        audioButton.Lessonid = self.Lessonid
        audioButton.indexPathStr = self.indexPathStr
        audioButton.Event = "ListenMyRecording"
        
        //分数
        if msg.score < 60 {
            trophyImg.image = ChImageAssets.medalGray.image
        }
        else {
            trophyImg.image = ChImageAssets.medalGolden.image
        }
        //设置分数
        trophyScore.text = "\(msg.score)"

        chatImage.frame = CGRect(x: self.frame.width - bubbleWidth - 52, y: 0, width: bubbleWidth + 8, height: bubbleHeight)
//        if animate {
//            startAnimate()
//        }
    }
    
    func startAnimate() {
        let bgWidth = 30
        self.audioBg.frame =  CGRect(x: Int(bubbleWidth - 40.0), y: 5, width: bgWidth, height: bgWidth)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            UIView.animate(withDuration: 0.5) {
//                self.audioBg.frame = CGRect(x: Int(self.bubbleWidth - 32.0), y: 5, width: bgWidth, height: bgWidth)
//                self.audioBg.layer.cornerRadius = 15.0
//            }
//        }
        UIView.animate(withDuration: 0.1, animations: {
            self.bubbleView.alpha = 0.1
            self.chatImage.alpha = 0.1

            UIView.animate(withDuration: 0.8, animations: {
                self.bubbleView.alpha = 1
                self.chatImage.alpha = 1
            }, completion: { (finished) in
            })
            
        })
    }
    
    //主动点击播放按钮
    @objc func playAudio() {
        audioButton.play()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKeyDictionary(_ input: [NSAttributedString.Key: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSAttributedStringKeyDictionary(_ input: [String: Any]) -> [NSAttributedString.Key: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
