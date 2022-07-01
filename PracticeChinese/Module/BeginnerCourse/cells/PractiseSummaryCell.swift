//
//  PractiseSummaryCell.swift
//  PracticeChinese
//
//  Created by Temp on 2018/9/3.
//  Copyright © 2018年 msra. All rights reserved.
//

import UIKit

class PractiseSummaryCell: UITableViewCell,TextViewDelegate,LCVoiceButtonDelegate {
    func buttonPlayStop() {
        self.userAudioPlayBtn.isSelected = false
        if (audioButton != nil) {
            audioButton.pause()
        }
        if (userAudioButton != nil) {
            userAudioButton.pause()
        }
    }
    func buttonPlayStart() {
        
    }
    
    func superViewConstraints() {
        
    }
    
    func tapped() {
        
    }

    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var question: UILabel!
    
    @IBOutlet weak var exView: UIView!
    @IBOutlet weak var score: UIButton!
    
    @IBOutlet weak var line: UIView!
    var audioButton: LCVoiceButton!
    var userAudioButton: LCVoiceButton!
    
    @IBOutlet weak var userAudioPlayBtn: UIButton!
    @IBOutlet weak var userAudioBgView: UIView!
    
    @IBOutlet weak var audioContainer: UIView!
    //数据
    var msg:PractiseMessageModel!
    
    var chineseandpinyinLabel:TextView!
    
    @IBOutlet weak var chineseAndPinyinView: UIView!
    
    //埋点
    var Scope = ""
    var Subscope = ""
    var indexPathStr = ""
    var Lessonid = ""
    var Event = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.score.layer.cornerRadius = 5
        self.score.layer.masksToBounds = true

    }
    func setContent( msg: PractiseMessageModel) {
        self.msg = msg
        let url = msg.audioUrl
        let userAudioUrl = msg.userAudioUrl?.absoluteString
        let en = msg.english
        let score = msg.score
        let chinese = msg.chinese
        let pinyin = msg.pinyin
        
        if (score < 60) {
            self.score.setBackgroundImage(UIImage(named: "cry_again"), for: .normal)
            self.score.setTitle("", for: .normal)
            self.score.backgroundColor = UIColor.hex(hex: "f8e6e5")
        }else if (score >= 60 && score < 80) {
            self.score.setBackgroundImage(UIImage(named: ""), for: .normal)
            self.score.backgroundColor = UIColor.hex(hex: "F8F2E8")
            self.score.setTitleColor(UIColor.hex(hex: "EBA740"), for: .normal)
            self.score.setTitle("\(score)", for: .normal)
        }else if (score >= 80) {
            self.score.setBackgroundImage(UIImage(named: ""), for: .normal)
            self.score.backgroundColor = UIColor.hex(hex: "E9F2E7")
            self.score.setTitleColor(UIColor.hex(hex: "4FB277"), for: .normal)
            self.score.setTitle("\(score)", for: .normal)
        }
        
        
        let cardMaxWidth = AdjustGlobal().CurrentScaleWidth - 129
        //分语块的数组
        question.text = en
        
        if (audioButton != nil) {
            LCVoiceButton.singlePlayer.delegate = nil
            audioButton.removeFromSuperview()
            audioButton = nil
        }
        
        audioButton = LCVoiceButton(frame: CGRect(x: 0 , y: 0, width: Double(22.5), height: Double(15)), style: .speaker)
        audioButton.changeImages(voice1: ChImageAssets.VoiceIcon1.image!,voice2: ChImageAssets.VoiceIcon2.image!,voice3: ChImageAssets.VoiceIcon3.image!,defaultImage:ChImageAssets.VoiceIcon3.image!)
        audioButton.audioUrl = url
        audioButton.delegate = self
        audioContainer.addSubview(audioButton)

        if chineseandpinyinLabel != nil {
            chineseandpinyinLabel.removeFromSuperview()
            chineseandpinyinLabel = nil
        }
        
        if (userAudioButton != nil) {
            LCVoiceButton.singlePlayer.delegate = nil
            userAudioButton.removeFromSuperview()
            userAudioButton = nil
        }
        
        userAudioButton = LCVoiceButton(frame: CGRect(x: 0 , y: 0, width: Double(35), height: Double(35)), style: .speaker)
        userAudioButton.changeImages(voice1: UIImage(named: "stop_avatar")!,voice2: UIImage(named: "stop_avatar")!,voice3: UIImage(named: "stop_avatar")!,defaultImage:UIImage(named: "play_avatar")!)
        userAudioButton.audioUrl = userAudioUrl
        userAudioButton.delegate = self
        userAudioBgView.addSubview(userAudioButton)
        userAudioBgView.bringSubviewToFront(userAudioPlayBtn)
        chineseandpinyinLabel = TextView(frame: CGRect(x: 0, y: 0, width: cardMaxWidth, height: 49), chinese: chinese.string, chineseSize: FontAdjust().FontSize(20), pinyin: pinyin, pinyinSize: FontAdjust().FontSize(14), style: textStyle.chineseandpinyin, changeAble: true,showBoth:true)
        chineseandpinyinLabel.setLabelTextAli(chinese: .left, pinyin: .left)
        chineseandpinyinLabel.delegate = self
        chineseandpinyinLabel.setLabelColor(chinese: UIColor.hex(hex: "333333"), pinyin: UIColor.hex(hex: "666666"))
        chineseAndPinyinView.addSubview(chineseandpinyinLabel)
    }
    
    @IBAction func playUserAudio(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            if (userAudioButton != nil) {
                userAudioButton.play()
            }
        }else {
            if (userAudioButton != nil) {
                userAudioButton.pause()
            }
        }
    }
    func playAudio() {
        
        if (audioButton != nil) {
            audioButton.play()
        }
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
