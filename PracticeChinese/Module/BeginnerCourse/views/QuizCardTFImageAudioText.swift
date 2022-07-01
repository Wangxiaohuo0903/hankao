//
//  QuizCardTFImageAudioText.swift
//  PracticeChinese
//
//  Created by summer on 2017/9/11.
//  Copyright © 2017年 msra. All rights reserved.
//

import Foundation
import AVFoundation
import SnapKit

class QuizCardTFImageAudioText: QuizCardSuper {
    

    var textQuizLabel:RNTextView!
    var imageView:UIImageView!
    var quizView:UIView!
    var quizViewHeight:CGFloat = 0
    var isCorrect:Int = 0
    var quizSample: QuizSample!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isCorrect = 0
        quizView = UIView()
        quizView.backgroundColor = UIColor.quizTheme
        self.addSubview(quizView)
        
        makeContinuButton()
        
        var  buttonheight:CGFloat = 0
        
        
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
            buttonheight = 34
        }else{
            buttonheight = UIAdjust().adjustByHeight(12)
        }
        
        
        var buttonGap:CGFloat = 0
        if(AdjustGlobal().CurrentScale == AdjustScale.iPad){
            buttonGap = 60
            continueButton.layer.cornerRadius = 30
        }else{
            buttonGap = 44
            continueButton.layer.cornerRadius = 22
        }
        
        continueButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.snp.bottom).offset(0)
            make.width.equalTo(self.continueWidth)
            make.height.equalTo(buttonGap)
            make.centerX.equalTo(self)
        }
        
        
        imageView = UIImageView(image: UIImage(named: "quizimage"))
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.backgroundColor = UIColor.white
        imageView.frame = CGRect(x:0, y:0, width: self.frame.width, height: self.frame.height*0.35)
        imageView.layer.cornerRadius = 10.0
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        self.addSubview(imageView)
        
        var VioceHeight:CGFloat = 0
        
        if(AdjustGlobal().CurrentScale == AdjustScale.iPad){
            VioceHeight = 38
        }else{
            VioceHeight = 28
        }
        
        
        videoButtonView = UIView(frame:CGRect(x:10 , y:imageView.frame.height - 35, width: 28, height: 28))
        videoButtonView.backgroundColor = UIColor.blueTheme
        videoButtonView.layer.cornerRadius = VioceHeight/2
        
        videoButton = CircularProgressView.init(frame: CGRect(x:5 , y:5, width: 18, height: 18), back: UIColor.hex(hex: "E8F0FD"), progressColor: UIColor.hex(hex: "AECFFF"), lineWidth: 2, audioURL: nil, targetObject:self)
        videoButton.playerFinishedBlock = {
            if (self.quizSample.Body!.AudioUrl != nil && (self.quizSample.Body!.AudioUrl!.hasSuffix("mp3"))) && self.isCorrect == 1 {
                self.isCorrect = 0
                self.selectDelegate?.gotoNextpage()
                for button in self.buttons {
                    button.makeButtonDisabled()
                }
            }
        }
        videoButtonView.addSubview(videoButton)
        self.addSubview(videoButtonView)
        
        videoButton.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(videoButtonView)
            make.width.height.equalTo(VioceHeight - 13)
        }
        
        var buttonHeight:CGFloat = 0
        if(AdjustGlobal().CurrentScale == AdjustScale.iPad){
            buttonHeight = 80
        }else{
            buttonHeight = 58
        }
        
        var buttonWidth:CGFloat = self.frame.width
        
        
        let answerButton3 = OptionButton(frame: CGRect(x:0,y:0,width:buttonWidth,height:buttonHeight), chinese: "", pinyin: "", english: "False")
        answerButton3.buttonOrder = 1
        answerButton3.addTarget(self,action:#selector(tappedOptionButton),for:.touchUpInside)
        self.addSubview(answerButton3)
        
        let answerButton2 = OptionButton(frame: CGRect(x:0,y:0,width:buttonWidth,height:buttonHeight), chinese: "", pinyin: "", english: "True2")
        answerButton2.buttonOrder = 0
        answerButton2.addTarget(self,action:#selector(tappedOptionButton),for:.touchUpInside)
        self.addSubview(answerButton2)
        
        buttons.append(answerButton2)
        buttons.append(answerButton3)
        
        answerButton3.snp.makeConstraints { (make) -> Void in
            make.left.right.equalTo(self)
            make.height.equalTo(buttonHeight)
            make.bottom.equalTo(continueButton.snp.top).offset(-UIAdjust().adjustByHeight(15))
            make.top.equalTo(answerButton2.snp.bottom).offset(UIAdjust().adjustByHeight(10))
        }
        
        answerButton2.snp.makeConstraints { (make) -> Void in
            make.left.right.equalTo(self)
            make.height.equalTo(buttonHeight)
            make.bottom.equalTo(answerButton3.snp.top).offset(-UIAdjust().adjustByHeight(10))
            make.top.equalTo(quizView.snp.bottom)
        }
        
        var imageWidth:CGFloat = self.frame.width
        var imageHeight:CGFloat = imageWidth/3*2
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhone4 || AdjustGlobal().CurrentScale == AdjustScale.iPhone5){
            imageHeight = imageWidth/16*9
        }else{
            imageHeight = imageWidth/3*2
        }
        
        imageView.snp.makeConstraints { (make) -> Void in
            make.left.right.equalTo(self)
            make.top.equalTo(self)
            make.width.equalTo(imageWidth)
            make.height.equalTo(imageHeight)
            make.bottom.equalTo(quizView.snp.top)
        }
        
        
        
        videoButtonView.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(imageView).offset(10)
            make.bottom.equalTo(imageView.snp.bottom).offset(-10)
            make.width.height.equalTo(VioceHeight)
        }
        
        quizViewHeight = self.frame.height - imageHeight - buttonHeight*2 - buttonGap - buttonheight - UIAdjust().adjustByHeight(25)
        
        quizView.snp.makeConstraints { (make) -> Void in
            make.left.right.equalTo(self)
            make.top.equalTo(imageView.snp.bottom)
            make.bottom.equalTo(answerButton2.snp.top)
            make.height.equalTo(quizViewHeight)
        }
    }
    
    
    override func setData(quiz:QuizSample,voice:Dictionary<String,SentenceDetail>){
        //FIXME: - : 　是否有语音
        if(quiz.Body?.AudioUrl != nil && (quiz.Body?.AudioUrl?.hasSuffix("mp3"))!){
            videoButton.audioUrl = quiz.Body?.AudioUrl
        }
        
        if(voice[(quiz.Body?.AudioText)!]?.PictureUrl != nil || quiz.Body?.Url != nil){
            let url = (quiz.Body?.Url == nil) ? URL(string: (voice[(quiz.Body?.AudioText)!]?.PictureUrl)!) : URL(string: (quiz.Body?.Url)!)
            if(url != nil){
                imageView.sd_setImage(with: url, placeholderImage: UIImage.fromColor(color: UIColor.lightGray), options: .refreshCached, completed: nil)
            }
        }
        
        self.answer = quiz.Answer!
        
        //用"#"单个字母来切分
        let text = quiz.Body?.Displaytext?.characters.split(separator: "#").map(String.init)
        
        var chinese:String = ""
        var english:String = ""
        if(text?.count == 2){
            chinese = (text?[0])!
            english = (text?[1])!
        }
        
        textQuizLabel = RNTextView(frame: CGRect(x:0,y:0,width:self.frame.width,height:quizViewHeight), chinese: english, chineseSize: FontAdjust().FontSize(22), pinyin: chinese, pinyinSize: FontAdjust().FontSize(12), style: textStyle.chineseandpinyin, changeAble: false, pinyinFontRegular:true)
        textQuizLabel.setLabelColor(chinese: UIColor.white, pinyin: UIColor.white)
        textQuizLabel.setLabelFont(chinese: "PingFang SC", pinyin:  "PingFang SC", textStyle: textStyle.chineseandpinyin)
        self.addSubview(textQuizLabel)
        textQuizLabel.delegate = self
        textQuizLabel.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(quizView)
            make.width.equalTo(textQuizLabel.frameWidth)
            make.height.equalTo(textQuizLabel.frameHeight)
        }
    }
    
    
    override func showContinue() {
        var  buttonheight:CGFloat = 0
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
            buttonheight = 34
        }else{
            buttonheight = UIAdjust().adjustByHeight(12)
        }
        var buttonGap:CGFloat = 0
        if(AdjustGlobal().CurrentScale == AdjustScale.iPad){
            buttonGap = 60
            continueButton.layer.cornerRadius = 30
        }else{
            buttonGap = 44
            continueButton.layer.cornerRadius = 22
        }
        UIView.animate(withDuration: 0.3) {
            self.continueButton.alpha = 1
            self.continueButton.snp.remakeConstraints { (make) -> Void in
                make.bottom.equalTo(self.snp.bottom).offset(-buttonheight)
                make.width.equalTo(self.continueWidth)
                make.height.equalTo(buttonGap)
                make.centerX.equalTo(self)
            }
            self.layoutIfNeeded()
        }
    }
    
    override func tappedOptionButton(button:OptionButton){
        self.videoButton.stop()
        for i in 0...2{
            buttons[i].refreshToNomalColor()
        }

        if(button.buttonOrder != self.answer){
            if firstRight {
                //第一次选择错误
                self.firstClickRight = false
                self.selectDelegate?.showSamepage(tag: quizSample.Tags)
            }
            firstRight = false
            self.selectDelegate?.addSunValue(value: -1)
            self.audioWrongPlayer?.play()
            if (timer != nil) {
                timer.invalidate()
            }
            let rateClosure:(Timer) -> Void = {_ in
                for i in 0...2{
                    self.buttons[i].refreshToNomalColor()
                }
            }
            if #available(iOS 10.0, *) {
                self.timer = Timer(timeInterval: 1, repeats: true, block: rateClosure)
            } else {
                self.timer = Timer.schedule(timeInterval: 1, repeats: true, block: rateClosure)
            }
            RunLoop.current.add(self.timer, forMode: RunLoop.Mode.common)
            self.isCorrect = 0
            button.setWrong()
        }else{
            audioRightPlayer?.play()
            self.isCorrect = 1
            buttons[self.answer].setCorrect()
            if firstRight {
                self.firstClickRight = true
                self.selectDelegate?.addSunValue(value: 2)
                firstRight = true
            }
            if (timer != nil) {
                timer.invalidate()
            }
            //不允许别的被点击
            for button in buttons {
                button.makeButtonDisabled()
            }
            if (nil != selectDelegate)
            {//这里使用对象进行比较，而不是音频URL，因为它们可能相等
                if (videoButton.audioUrl != nil  && (self.videoButton.audioUrl?.hasSuffix("mp3"))! && (UserDefaults.standard.integer(forKey: UserDefaultsKeyManager.readAudio) == 1)) {
                    self.videoButton.playNotChangeAudioImage(self.videoButton.audioUrl)
                }else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.selectDelegate?.gotoNextpage()
                        for button in self.buttons {
                            button.makeButtonDisabled()
                        }
                    }
                }
            }
        }
        self.updateQuizSelectStatus(lid: Lessionid, question: (quizSample.Body?.Text)!, answer: button.buttonOrder, passed:self.firstClickRight ) { (result) in
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


extension QuizCardTFImageAudioText:RNTextViewDelegate{
    func tapped() {
        
    }
    
    func superViewConstraints() {
        
    }
}

