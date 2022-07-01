//
//  QuizCardSingleTextAudioText.swift
//  PracticeChinese
//
//  Created by summer on 2017/9/8.
//  Copyright © 2017年 msra. All rights reserved.
//
//补全句子
import Foundation
import SnapKit
import AVFoundation

class QuizCardTextAudio: QuizCardSuper {
    
    var QuizTextLabel:MTextView!
    var quizView:UIView!
    var quizViewHeight:CGFloat = 0
    var VioceHeight:CGFloat = 0
    var labelGap:CGFloat = 0
    var isCorrect:Int = 0
    var quizSample: QuizSample!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isCorrect = 0
        quizView = UIView()
        quizView.backgroundColor = UIColor.quizTheme
        self.addSubview(quizView)
        
        makeContinuButton()
        if(AdjustGlobal().CurrentScale == AdjustScale.iPad){
            labelGap = 20
        }else{
            labelGap = 10
        }
        
        
        var  buttonheight:CGFloat = 0
        
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
            buttonheight = 34
        }else{
            buttonheight = UIAdjust().adjustByHeight(15)
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
        
        let textLabel = UILabel(frame: CGRect(x:0 , y:90, width: self.frame.width - 80, height: 20))
//        textLabel.text = "Choose what you hear."
        textLabel.textColor = UIColor.textGray
        textLabel.textAlignment = .left
        textLabel.font = FontUtil.getFont(size: FontAdjust().HeaderTitleFont(), type: .Regular)
        textLabel.adjustsFontSizeToFitWidth = true
        self.addSubview(textLabel)
        
        
        
        if(AdjustGlobal().CurrentScale == AdjustScale.iPad){
            VioceHeight = 38
        }else{
            VioceHeight = 28
        }
        
        videoButtonView = UIView(frame:CGRect(x:self.frame.width*0.5-12.5 , y:self.frame.height*0.20-ScreenUtils.heightByM(y: CGFloat(35)), width: 28, height: 28))
        videoButtonView.backgroundColor = UIColor.white
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
        videoButtonView.isHidden = true
        self.addSubview(videoButtonView)
        
        
        videoButton.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(videoButtonView)
            make.width.height.equalTo(VioceHeight - 10)
        }
        
        var ButtonsHeight:CGFloat = 0
        
        if(AdjustGlobal().CurrentScale == AdjustScale.iPad){
            ButtonsHeight = 300 + UIAdjust().adjustByHeight(60)
        }else if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
            ButtonsHeight = 259 + UIAdjust().adjustByHeight(45)
        }else{
            ButtonsHeight = 225 + UIAdjust().adjustByHeight(60)
        }
        
        var textLabelHeight:CGFloat = 0
        
        if(AdjustGlobal().CurrentScale == AdjustScale.iPad){
            textLabelHeight = 0
        }else{
            textLabelHeight = 0
        }
        
        textLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self)
            make.right.equalTo(self).offset(-66)
            make.height.equalTo(textLabelHeight)
            make.top.equalTo(self.snp.top).offset(10)
        }
        
        quizViewHeight = self.frame.height - textLabelHeight - ButtonsHeight
        
        quizView.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(self)
            make.left.equalTo(self)
            make.height.equalTo(quizViewHeight)
            make.top.equalTo(self)
        }
        
    }

    
    override func setData(quiz:QuizSample,voice:Dictionary<String,SentenceDetail>){
        self.answer = quiz.Answer! - 1
        quizSample = quiz
        //FIXME: - : 　是否有语音
        if(quiz.Body?.AudioUrl != nil && (quiz.Body?.AudioUrl?.hasSuffix("mp3"))!){
            videoButton.audioUrl = quiz.Body?.AudioUrl
        }
        QuizTextLabel = MTextView(frame: CGRect(x: 0, y: 0, width: self.frame.width , height: quizViewHeight), tokens: (quiz.Body?.Tokens!)!, chineseSize: FontAdjust().ChineseAndPinyin_C(), pinyinSize: FontAdjust().ChineseAndPinyin_P(), style: .chineseandpinyin, changeAble: true,showIpa:false)
        QuizTextLabel.itemAli = .left
        QuizTextLabel.selectEnable = false
        QuizTextLabel.setData()
        QuizTextLabel.changeTextColor(chineseTextColor: UIColor.quizTextBlack, pinyinTextColor: UIColor.quizTextBlack)
        QuizTextLabel.backgroundColor = UIColor.white
        quizView.addSubview(QuizTextLabel)
        
        QuizTextLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(quizView)
            make.right.equalTo(quizView)
            make.centerY.equalTo(quizView)
            make.height.equalTo(QuizTextLabel.getViewHeight())
            make.width.equalTo(QuizTextLabel.getViewWidth())
        }
        
        videoButtonView.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(VioceHeight)
            make.left.equalTo(self).offset(5)
            make.centerY.equalTo(quizView)
        }
        
        
        var pinyin:String = ""
        var chinese:String = ""
        var english:String = ""
        
        
        
        var buttonHeight:CGFloat = 0
        if(AdjustGlobal().CurrentScale == AdjustScale.iPad){
            buttonHeight = 80
        }else{
            buttonHeight = 58
        }
        
        var buttonWidth:CGFloat = self.frame.width
        //FIXME: - : 答案区
        if (quiz.Options?[0].Tokens?.count)! > 0 {
            //FIXME: - : 怎么判断是纯英文的？tokens 为空
            for token in (quiz.Options?[0].Tokens)! {
                chinese = chinese.appending(token.Text!)
                var ipa = ""
                var pinyinStr = ""//是一个数组，需要拼接
                if(token.IPA != nil && token.IPA != ""){//不是标点或者特殊的符号
                    ipa = token.IPA!
                    if(PinyinFormat(ipa).count == 1){
                        pinyinStr = PinyinFormat(ipa)[0]
                    }else{
                        for i in 0...PinyinFormat(ipa).count-1{
                            pinyinStr = pinyinStr + PinyinFormat(ipa)[i]
                        }
                    }
                }else {
                    if pinyin.hasSuffix(" ") {
                        pinyin = pinyin.substring(to: pinyin.length - 1)
                    }
                    pinyinStr = pinyinStr + token.NativeText!
                }
                pinyin = pinyin.appending("\(pinyinStr)\(" ")")
            }
        }else{
            if(quiz.Options?[0].Displaytext != nil){
                english = (quiz.Options?[0].Displaytext!)!
            }
        }
        let answerButton1 = OptionButton(frame: CGRect(x:0,y:0,width:buttonWidth,height:buttonHeight), chinese: chinese, pinyin: pinyin, english: english)
        answerButton1.buttonOrder = 0   //按钮顺序
        answerButton1.addTarget(self,action:#selector(tappedOptionButton),for:.touchUpInside)
        self.addSubview(answerButton1)

        pinyin = ""
        chinese = ""
        english = ""
        if (quiz.Options?[1].Tokens?.count)! > 0 {
            //FIXME: - : 怎么判断是纯英文的
            for token in (quiz.Options?[1].Tokens)! {
                chinese = chinese.appending(token.Text!)
                var ipa = ""
                var pinyinStr = ""//是一个数组，需要拼接
                if(token.IPA != nil && token.IPA != ""){//不是标点或者特殊的符号
                    ipa = token.IPA!
                    if(PinyinFormat(ipa).count == 1){
                        pinyinStr = PinyinFormat(ipa)[0]
                    }else{
                        for i in 0...PinyinFormat(ipa).count-1{
                            pinyinStr = pinyinStr + PinyinFormat(ipa)[i]
                        }
                    }
                }else {
                    if pinyin.hasSuffix(" ") {
                        pinyin = pinyin.substring(to: pinyin.length - 1)
                    }
                    pinyinStr = pinyinStr + token.NativeText!
                }
                pinyin = pinyin.appending("\(pinyinStr)\(" ")")
            }
        }else{
            if(quiz.Options?[1].Displaytext != nil){
                english = (quiz.Options?[1].Displaytext!)!
            }
        }
        let answerButton2 = OptionButton(frame: CGRect(x:0,y:0,width:buttonWidth,height:buttonHeight), chinese: chinese, pinyin: pinyin, english: english)
        answerButton2.buttonOrder = 1
        answerButton2.addTarget(self,action:#selector(tappedOptionButton),for:.touchUpInside)
        self.addSubview(answerButton2)
        

        pinyin = ""
        chinese = ""
        english = ""
        if (quiz.Options?[2].Tokens?.count)! > 0 {
            //FIXME: - : 怎么判断是纯英文的
            for token in (quiz.Options?[2].Tokens)! {
                chinese = chinese.appending(token.Text!)
                var ipa = ""
                var pinyinStr = ""//是一个数组，需要拼接
                if(token.IPA != nil && token.IPA != ""){//不是标点或者特殊的符号
                    ipa = token.IPA!
                    if(PinyinFormat(ipa).count == 1){
                        pinyinStr = PinyinFormat(ipa)[0]
                    }else{
                        for i in 0...PinyinFormat(ipa).count-1{
                            pinyinStr = pinyinStr + PinyinFormat(ipa)[i]
                        }
                    }
                }else {
                    if pinyin.hasSuffix(" ") {
                        pinyin = pinyin.substring(to: pinyin.length - 1)
                    }
                    pinyinStr = pinyinStr + token.NativeText!
                }
                pinyin = pinyin.appending("\(pinyinStr)\(" ")")
            }
        }else{
            if(quiz.Options?[2].Displaytext != nil){
                english = (quiz.Options?[2].Displaytext!)!
            }
        }
        
        let answerButton3 = OptionButton(frame: CGRect(x:0,y:0,width:buttonWidth,height:buttonHeight), chinese: chinese, pinyin: pinyin, english: english)
        answerButton3.buttonOrder = 2
        answerButton3.addTarget(self,action:#selector(tappedOptionButton),for:.touchUpInside)
        self.addSubview(answerButton3)
        
        buttons.append(answerButton1)
        buttons.append(answerButton2)
        buttons.append(answerButton3)
        
        var uibuttons = buttons
        uibuttons = uibuttons.shuffle()
        
        
        var buttonGrap:CGFloat = 0
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
            buttonGrap = 34 + 60 + 12
        }else{
            buttonGrap = UIAdjust().adjustByHeight(12) * 2 + 44
            if AdjustGlobal().CurrentScale == AdjustScale.iPad {
                buttonGrap = UIAdjust().adjustByHeight(12) * 2 + 60
            }
        }
        
        uibuttons[2].snp.makeConstraints { (make) -> Void in
            make.left.right.equalTo(self)
            make.height.equalTo(buttonHeight)
            make.bottom.equalTo(self.snp.bottom).offset(-buttonGrap)
            make.top.equalTo(uibuttons[1].snp.bottom).offset(12)
        }
        
        uibuttons[1].snp.makeConstraints { (make) -> Void in
            make.left.right.equalTo(self)
            make.height.equalTo(buttonHeight)
            make.bottom.equalTo(uibuttons[2].snp.top).offset(-UIAdjust().adjustByHeight(10))
            make.top.equalTo(uibuttons[0].snp.bottom).offset(UIAdjust().adjustByHeight(10))
        }
        
        uibuttons[0].snp.makeConstraints { (make) -> Void in
            make.left.right.equalTo(self)
            make.height.equalTo(buttonHeight)
            make.bottom.equalTo(uibuttons[1].snp.top).offset(-UIAdjust().adjustByHeight(10))
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
                if (videoButton.audioUrl != nil && (self.videoButton.audioUrl?.hasSuffix("mp3"))! && (UserDefaults.standard.integer(forKey: UserDefaultsKeyManager.readAudio) == 1)) {
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

extension QuizCardTextAudio:RNTextViewDelegate {
    func tapped() {
        
    }
    
    override func refreshPage() {
        super.refreshPage()
        superViewConstraints()
        
        var buttonHeight:CGFloat = 0
        if(AdjustGlobal().CurrentScale == AdjustScale.iPad){
            buttonHeight = 80
        }else{
            buttonHeight = 58
        }
        
        var buttonWidth:CGFloat = self.frame.width
        var uibuttons = buttons
        uibuttons = uibuttons.shuffle()
        
        uibuttons[2].snp.remakeConstraints { (make) -> Void in
            make.left.right.equalTo(self)
            make.height.equalTo(buttonHeight)
            make.bottom.equalTo(continueButton.snp.top).offset(-UIAdjust().adjustByHeight(15))
            make.top.equalTo(uibuttons[1].snp.bottom).offset(UIAdjust().adjustByHeight(10))
        }
        
        uibuttons[1].snp.remakeConstraints { (make) -> Void in
            make.left.right.equalTo(self)
            make.height.equalTo(buttonHeight)
            make.bottom.equalTo(uibuttons[2].snp.top).offset(-UIAdjust().adjustByHeight(10))
            make.top.equalTo(uibuttons[0].snp.bottom).offset(UIAdjust().adjustByHeight(10))
        }
        
        uibuttons[0].snp.remakeConstraints { (make) -> Void in
            make.left.right.equalTo(self)
            make.height.equalTo(buttonHeight)
            make.bottom.equalTo(uibuttons[1].snp.top).offset(-UIAdjust().adjustByHeight(10))
        }
    }
    
    func superViewConstraints() {
        QuizTextLabel.systemAutoChangeWithoutFrame()
        QuizTextLabel.snp.remakeConstraints { (make) -> Void in
            make.left.equalTo(quizView)
            make.right.equalTo(quizView)
            make.centerY.equalTo(quizView)
            make.height.equalTo(QuizTextLabel.getViewHeight())
            make.width.equalTo(QuizTextLabel.getViewWidth())
        }
    }
    
    
}








