//
//  LandDetailTableViewCell.swift
//  PracticeChinese
//
//  Created by Temp on 2018/9/3.
//  Copyright © 2018年 msra. All rights reserved.
//

import UIKit

class LandDetailTableViewCell: UITableViewCell,TextViewDelegate,LCVoiceButtonDelegate {
    func buttonPlayStop() {
        if (audioButton != nil) {
            audioButton.pause()
        }
    }
    
    func buttonPlayStart() {
        
    }
    
    func superViewConstraints() {
        
    }
    
    func tapped() {
        
    }
    var audioButton: LCVoiceButton!
    //数据
    var msg:PractiseMessageModel!
    
    @IBOutlet weak var line: UIView!
    @IBOutlet weak var audioContainer: UIStackView!
    @IBOutlet weak var question: UILabel!
    @IBOutlet weak var chinese: UILabel!
    @IBOutlet weak var pinyin: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var exView: UIView!
    @IBOutlet weak var bgViewLeft: NSLayoutConstraint!
    @IBOutlet weak var bgViewRight: NSLayoutConstraint!
    
    @IBOutlet weak var audioViewWidth: NSLayoutConstraint!
    
    //埋点
    var Scope = ""
    var Subscope = ""
    var indexPathStr = ""
    var Lessonid = ""
    var Event = ""
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func setContent( msg: PractiseMessageModel) {
        self.pinyin.adjustsFontSizeToFitWidth = true
        self.chinese.adjustsFontSizeToFitWidth = true
        self.msg = msg
        let url = msg.audioUrl
        let en = msg.english
        let chinese = msg.chinese
        let pinyin = msg.pinyin

        //分语块的数组
        question.text = en
        self.chinese.text = chinese.string
        self.pinyin.text = pinyin
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
