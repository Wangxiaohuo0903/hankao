//
//  PractiseLeftCell.swift
//  PracticeChinese
//
//  Created by Temp on 2018/8/27.
//  Copyright © 2018年 msra. All rights reserved.
//

import UIKit

class PractiseLeftCell: UITableViewCell {
    //头像
    var avatarImg:UIImageView!
    //中拼
    var chineseandpinyinLabel: SpeakTokensView!
    //bg
    var bubbleView: UIView!
    //英文
    var enLabel: UILabel!
    var nameLabel: UILabel!
    //数据
    var msg:ChatMessageModel!
    
    //播放按钮
    var audioButton: LCVoiceButton!
    
    var audioContainer: UIView!
    
    var bgMastar: UIView!
    
    let cardLeft: Int = 30
    let cardMaxWidth: Int = Int(AdjustGlobal().CurrentScaleWidth - 60)
    //埋点
    var Scope = ""
    var Subscope = ""
    var indexPathStr = ""
    var Lessonid = ""
    var Event = ""
    var disabled = false {
        didSet {
            if !disabled {
                UIView.animate(withDuration: 0.2) {
                    self.bgMastar.alpha = 0
                }
            }else {
                UIView.animate(withDuration: 0.2) {
                    self.bgMastar.alpha = 0.9
                }
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        self.selectionStyle = .none
        
        bubbleView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 0))
        bubbleView.backgroundColor = UIColor.clear
        self.addSubview(bubbleView)

        avatarImg = UIImageView(frame: CGRect(x: cardLeft, y: 0, width: 40, height: 40))
        avatarImg.layer.cornerRadius = 20
        avatarImg.layer.masksToBounds = true
        var introFontE = FontUtil.getFont(size: 14, type: .Regular)
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhone4 || AdjustGlobal().CurrentScale == AdjustScale.iPhone5){
            introFontE = FontUtil.getFont(size: 13, type: .Regular)
        }
        nameLabel = UILabel(frame: CGRect(x: avatarImg.frame.maxX + 15, y: 0, width: ScreenUtils.width - 100, height: avatarImg.frame.height) )
        nameLabel.textColor = UIColor.textBlack333
        nameLabel.font = introFontE
        nameLabel.numberOfLines = 1
        nameLabel.textAlignment = .left

        enLabel = UILabel(frame: CGRect(x: cardLeft, y: 0, width: cardMaxWidth, height: 0) )
        enLabel.textColor = UIColor.lightText
        enLabel.font = introFontE
        enLabel.numberOfLines = 0
        enLabel.textAlignment = .left
        
        bgMastar = UIView(frame: CGRect(x: 0.0, y: 0.0, width: ScreenUtils.width, height: 0))
        bgMastar.backgroundColor = UIColor.white
        bgMastar.alpha = 0.9
        
        audioContainer = UIView()
        audioContainer.backgroundColor = UIColor.clear
        let chineseSize = Double(30)
        let pinyinSize = Double(16)
        chineseandpinyinLabel = SpeakTokensView(frame: CGRect(x: cardLeft, y: 50, width: cardMaxWidth, height: 150), tokens: [], chineseSize: chineseSize, pinyinSize: pinyinSize, style: .chineseandpinyin, changeAble: true,showIpa:false,scope: self.Scope,cColor:UIColor.black,pColor:UIColor.textGray,scoreRight:false,true)
        
        bubbleView.addSubview(audioContainer)
        bubbleView.addSubview(avatarImg)
        bubbleView.addSubview(nameLabel)
        bubbleView.addSubview(chineseandpinyinLabel)
        bubbleView.addSubview(enLabel)
        bubbleView.addSubview(bgMastar)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setContent( msg: ChatMessageModel) {
        self.msg = msg
        let url = msg.audioUrl
        let en = msg.en
        //分语块的数组
        let textArray = msg.textArray
        enLabel.attributedText = en
        let imageName = msg.avatarUrl.components(separatedBy: "/")
        if let name = imageName.last {
            var userImageName = ""
            let leftNames = name.components(separatedBy: "_")
            if let leftName = leftNames.first {
                userImageName = leftName
            }
            nameLabel.text = userImageName
        }else {
            nameLabel.text = "Unknow"
        }
        var imageUrl = msg.avatarUrl
        let imageArr = msg.avatarUrl.components(separatedBy: " ")
        if imageArr.count > 0 {
           imageUrl = imageArr[0]
        }
        avatarImg.sd_setImage(with: URL(string: imageUrl), placeholderImage: ChImageAssets.Current_senten.image, options: .refreshCached, completed: nil)
        
        //20左右padding+15喇叭weight+20喇叭index间距
        
        //中文
        chineseandpinyinLabel.Scope = self.Scope
        chineseandpinyinLabel.MaxWidth = Double(cardMaxWidth)
        chineseandpinyinLabel.tokensArr = textArray
        chineseandpinyinLabel.setData()
        
        let getHeight = chineseandpinyinLabel.getViewHeight()
        var introFontE = FontUtil.getFont(size: 14, type: .Regular)
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhone4 || AdjustGlobal().CurrentScale == AdjustScale.iPhone5){
            introFontE = FontUtil.getFont(size: 13, type: .Regular)
        }
        let englishHeight = en.string.height(withConstrainedWidth: CGFloat(cardMaxWidth), font: introFontE)
        enLabel.frame = CGRect(x: CGFloat(cardLeft), y: chineseandpinyinLabel.frame.maxY + 10, width: CGFloat(cardMaxWidth), height: englishHeight)

        if (audioButton != nil) {
            audioButton.delegate = nil
            LCVoiceButton.singlePlayer.delegate = nil
            audioButton.removeFromSuperview()
            audioButton = nil
        }

        audioButton = LCVoiceButton(frame: CGRect(x: 20 , y: 0, width: Double(20), height: Double(20)), style: .speaker)
        audioButton.changeImages(voice1: ChImageAssets.VoiceIcon1.image!,voice2: ChImageAssets.VoiceIcon2.image!,voice3: ChImageAssets.VoiceIcon3.image!,defaultImage:ChImageAssets.VoiceIcon3.image!)
        audioButton.audioUrl = url
        audioButton.Scope = self.Scope
        audioButton.Lessonid = self.Lessonid
        audioButton.indexPathStr = self.indexPathStr
        audioButton.isHidden = true
        audioContainer.addSubview(audioButton)
        var event = ""
        switch self.Scope {
        case "Speak":
            event = "ListenSampleAudio"
        case "Scenario":
            event = "ListenQuestionAudio"
            if msg.index == "" {
                //答案
                event = "ListenAnswer"
            }
        case "ConversationChallenge":
            event = "ListenQuestionAudio"
        default:
            event = ""
        }
        audioButton.Event = event
        let cellheight = getHeight + englishHeight + 70
        bgMastar.frame = CGRect(x: 0.0, y: 0.0, width: ScreenUtils.width, height: cellheight)
        bubbleView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: cellheight)

    }
    
    func playAudio() {
        if (audioButton != nil) {
            audioButton.play()
        }
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
