//
//  ReadAftermeView.swift
//  PracticeChinese
//
//  Created by Temp on 2018/11/19.
//  Copyright © 2018 msra. All rights reserved.
//
//跟读
import UIKit

import Foundation
import SnapKit
import AVFoundation

class ReadAftermeView: QuizCardSuper,LCRecordingViewDelegate,LCVoiceButtonDelegate {
    func buttonPlayStop() {
        statusLabel.text = "Tap the button to repeat"
        self.recordingView_read.startButton.isEnabled = true
    }
    func buttonPlayStart() {
        self.recordingView_read.cancelRecording(sender: nil)
    }
    func recordingStart() {
        statusLabel.text = "Tap to stop recording"
        self.playButton.pause()
        self.recordingView_read.enableOtherViews()
        self.recordingView_read.backgroundColor = UIColor.white
    }
    
    func recordingAutoCommit() {
        self.recordingSubmit(duration: 10)
    }
    
    func recordingCancel() {
        statusLabel.text = "Tap the button to repeat"
        self.recordingView_read.backgroundColor = UIColor.clear
        self.recordingView_read.startButton.isEnabled = true
    }
    
    func recordingSubmit(duration: Double) {
        statusLabel.text = ""
        userAudioUrl = DocumentManager.urlFromFilename(filename: "\(self.recordingView_read.filename).m4a")

        self.answerVideoButton.audioUrl = self.userAudioUrl?.absoluteString
        //上传音频
        if let audioData = try? Data(contentsOf: DocumentManager.urlFromFilename(filename: "\(self.recordingView_read.filename).m4a")) {
            let byteData = [Byte](audioData)
            
            let speechInput = chatRateInput(question: (quizSample.Body?.Text)!, keywords: ["##"], expectedAnswer: (quizSample.Body?.Text)!, data: byteData, speechMimeType: "audio/amr", sampleRate: RecordManager.sharedInstance.sampleRate, lessonId: Lessionid, language: AppData.lang)
            ToastAlertView.show("Scoring...")
            self.recordingView_read.startButton.isEnabled = false
            CourseManager.shared.rateSpeechScenario(speechInput: speechInput){
                data in
                ToastAlertView.hide()
                if let result = data {
                    if result.Score! >= 60 {
                        self.audioRightPlayer.play()
                        self.sortToken(success:true)
                        self.chineseandpinyinLabel?.tokensArr = self.currentTokensModelArray
                        self.chineseandpinyinLabel?.setData()
                        //得分大于60才通过
                        //第二次录音了
                        if result.Score! >= 60 && result.Score! < 80 {
                            self.selectDelegate?.addSunValue(value: 2)
                        }
                        if result.Score! >= 80 && result.Score! < 90 {
                            self.selectDelegate?.addSunValue(value: 3)
                        }
                        if result.Score! >= 90 {
                            self.selectDelegate?.addSunValue(value: 4)
                        }
                        self.firstRight = true
                        //读完用户语音后跳转
                        self.isCorrect = 1
                        let delay = DispatchTime.now() + 1.0
                        DispatchQueue.main.asyncAfter(deadline: delay) {
                            self.answerVideoButton.play()
                        }
                    }else {
                        self.audioWrongPlayer.play()
                        self.updateTextColor(result: result,Scope:"Quiz_Read",success:false)
                        //没通过
                        self.isCorrect = 0
                        let delay = DispatchTime.now() + 1.0
                        if !self.firstRight {
                            //第二次
                            self.firstRight = true
                            //读完用户语音后跳转
                            self.isCorrect = 1
                            DispatchQueue.main.asyncAfter(deadline: delay) {
                                self.answerVideoButton.play()
                            }
                        }else {
                            //第一次
                            DispatchQueue.main.asyncAfter(deadline: delay) {
                                self.answerVideoButton.play()
                            }
                        }
                        self.firstRight = false
                    }
                    self.recordingView_read.filename = "Quiz_ReadAfterme_\(self.Lessionid)_\(UUID().uuidString)"
                }else {
                    self.recordingView_read.filename = "Quiz_ReadAfterme_\(self.Lessionid)_\(UUID().uuidString)"
                    UIApplication.topViewController()?.presentUserToast(message: "Error occured during scoring,please try again.")
                }
            }
        }else {
            UIApplication.topViewController()?.presentUserToast(message: "Error occured during scoring,please try again.")
        }
    }

    
    func updateTextColor(result:ScenarioChatRateResult,Scope:String,success:Bool) {
        var cColor = UIColor.correctColor
        if Scope == "Quiz_Read" {
            cColor = UIColor.textBlack333
        }
        var originText = ""
        for model in self.currentTokensModelArray {
            originText.append(model.text.string)
        }
        let attrstrings = self.getScoredText(result.Details, originText:
            originText)
        self.msgResult.type = ChatMessageType.audiotext
        self.msgResult.pinyinText = attrstrings[1]
        self.msgResult.score = result.PronunciationScore!
        self.msgResult.text = attrstrings[0]
        self.msgResult.textArray = self.currentTokensModelArray

        self.chineseandpinyinLabel?.tokensArr = self.currentTokensModelArray
        self.chineseandpinyinLabel?.MaxWidth = Double(quizWidth)
        if !success {
            self.chineseandpinyinLabel?.modifyTextColor(msg: self.msgResult)
        }
        self.chineseandpinyinLabel?.setData()
        self.quizView.addSubview(self.chineseandpinyinLabel!)

    }

    //中拼
    var chineseandpinyinLabel: SpeakTokensView?
    var answerVideoButton:CircularProgressView!
    var quizData:QuizSample!
    var quizView:UIView!
    var quizViewHeight:CGFloat = 0
    var quizWidth:CGFloat = 0
    
    var VioceHeight:CGFloat = 0
    var labelGap:CGFloat = 0
    var isCorrect:Int = 0
    var quizSample: QuizSample!
    var playButton: LCVoiceButton!
    var userAudioUrl : URL?
    var pinyinGroup = [String]()
    var pinyinAllGroup = [String]()
    var pinyinText = ""
    var statusLabel = UILabel()
    var currentTokensModelArray = [ChatMessageTokenModel]()
    var msgResult = ChatMessageModel(imageUrl: "", position: BubblePosition.right)
    //录音按钮
    var recordingView_read: RecordignWithProgressView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.quizWidth = frame.size.width - 60
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
        
        
        if(AdjustGlobal().CurrentScale == AdjustScale.iPad){
            VioceHeight = 30
        }else{
            VioceHeight = 20
        }
        
        var ButtonsHeight:CGFloat = 0
        
        if(AdjustGlobal().CurrentScale == AdjustScale.iPad){
            ButtonsHeight = 300 + UIAdjust().adjustByHeight(60)
        }else if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
            ButtonsHeight = 259 + UIAdjust().adjustByHeight(45)
        }else{
            ButtonsHeight = 225 + UIAdjust().adjustByHeight(58)
        }
        
        var textLabelHeight:CGFloat = 0
        
        if(AdjustGlobal().CurrentScale == AdjustScale.iPad){
            textLabelHeight = 45
        }else{
            textLabelHeight = 45
        }
        
        quizViewHeight = self.frame.height - buttonheight * 2 - buttonGap - textLabelHeight
        
        
        continueButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.snp.bottom).offset(0)
            make.width.equalTo(self.continueWidth)
            make.height.equalTo(buttonGap)
            make.centerX.equalTo(self)
        }
        
        let textLabel = UILabel(frame: CGRect(x:0 , y:90, width: self.frame.width - 80, height: 20))
        textLabel.text = " Repeat sentence practice."
        textLabel.textColor = UIColor.textGray
        textLabel.textAlignment = .left
        textLabel.font = FontUtil.getFont(size: FontAdjust().HeaderTitleFont(), type: .Regular)
        textLabel.adjustsFontSizeToFitWidth = true
        self.addSubview(textLabel)
        
        
        if playButton == nil {
            playButton = LCVoiceButton(frame: CGRect(x: CGFloat(13), y: CGFloat(27), width: CGFloat(18), height: CGFloat(18)), style: .speaker)
            playButton.delegate = self
            playButton.changeToSpeakerImages()
            quizView.addSubview(playButton)
        }

        
        videoButtonView = UIView(frame:CGRect(x:self.frame.width*0.5-12.5 , y:self.frame.height*0.20-ScreenUtils.heightByM(y: CGFloat(35)), width: 36, height: 36))
        videoButtonView.backgroundColor = UIColor.white
        videoButtonView.layer.cornerRadius = VioceHeight/2
        videoButtonView.isHidden = true
        videoButton = CircularProgressView.init(frame: CGRect(x:5 , y:5, width: 18, height: 18), back: UIColor.hex(hex: "E8F0FD"), progressColor: UIColor.hex(hex: "AECFFF"), lineWidth: 2, audioURL: nil, targetObject:self)
        videoButton.playerFinishedBlock = {
            if (self.quizSample.Body!.AudioUrl != nil && (self.quizSample.Body!.AudioUrl!.hasSuffix("mp3"))) && self.isCorrect == 1 {
                self.isCorrect = 0
                self.selectDelegate?.gotoNextpage()
                for button in self.buttons {
                    button.makeButtonDisabled()
                }
            }else {
                self.statusLabel.text = "Tap the button to repeat"
                self.recordingView_read.startButton.isEnabled = true
            }
        }
        videoButtonView.addSubview(videoButton)
        quizView.addSubview(videoButtonView)
        

        videoButton.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(videoButtonView)
            make.width.height.equalTo(VioceHeight - 10)
        }
        
        
        quizView.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(self)
            make.left.equalTo(self)
            make.height.equalTo(quizViewHeight)
            make.top.equalTo(textLabel.snp.bottom).offset(0)
        }
        
        recordingView_read = RecordignWithProgressView(frame: CGRect(x: 0, y: (quizViewHeight / 2 - 80)/2 + quizViewHeight / 2 , width: self.frame.width, height: 80))
        recordingView_read.delegate = self
        recordingView_read.dynamicTime = true
        recordingView_read.filename = "Quiz_ReadAfterme_\(Lessionid)_\(UUID().uuidString)"
        recordingView_read.startButton.isEnabled = false
        
        quizView.addSubview(recordingView_read)
        
        statusLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 20)
        statusLabel.textColor = UIColor.colorFromRGB(51, 51, 51, 0.3)
        statusLabel.textAlignment = .center
        statusLabel.font = FontUtil.getFont(size: 12, type: .Regular)
        quizView.addSubview(statusLabel)
        
        
        textLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self)
            make.right.equalTo(self).offset(-66)
            make.height.equalTo(textLabelHeight)
            make.top.equalTo(self.snp.top).offset(10)
            make.bottom.equalTo(quizView.snp.top).offset(0)
        }
        recordingView_read.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(quizView)
            make.left.equalTo(quizView)
            make.height.equalTo(80)
            make.top.equalTo(quizView).offset((quizViewHeight / 2 - 80)/2 + quizViewHeight / 2 )
        }
        statusLabel.snp.makeConstraints { (make) -> Void in
            make.left.right.equalTo(self)
            make.height.equalTo(30)
            make.top.equalTo(self.recordingView_read.snp.bottom).offset(10)
        }
        
        answerVideoButton = CircularProgressView.init(frame: CGRect(x:5 , y:5, width: 18, height: 18), back: UIColor.hex(hex: "E8F0FD"), progressColor: UIColor.hex(hex: "AECFFF"), lineWidth: 2, audioURL: nil, targetObject:self)
        answerVideoButton.isHidden = true
        answerVideoButton.playerFinishedBlock = {
            if self.isCorrect == 1 {
                if (self.quizSample.Body!.AudioUrl != nil && (self.quizSample.Body!.AudioUrl!.hasSuffix("mp3"))) {
                    self.isCorrect = 0
                    self.selectDelegate?.gotoNextpage()
                    
                }
            }else {
                //读完用户的语音之后变成黑色
                self.sortToken(success:false)
                self.chineseandpinyinLabel?.tokensArr = self.currentTokensModelArray
                self.chineseandpinyinLabel?.setData()
                self.playButton.play()
            }
        }
    }
    
    
    func getLabelWidth(labelStr:String,font:UIFont)->CGFloat{
        let maxSie:CGSize = CGSize(width:self.frame.width,height:40)
        return (labelStr as NSString).boundingRect(with: maxSie, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):font]), context: nil).size.width
    }
    
    override func setData(quiz:QuizSample,voice:Dictionary<String,SentenceDetail>){
        quizSample = quiz
        //FIXME: - : 　是否有语音
        quizData = quiz
        sortToken(success:false)
        if(quiz.Body?.AudioUrl != nil && (quiz.Body?.AudioUrl?.hasSuffix("mp3"))!){
            videoButton.audioUrl = quiz.Body?.AudioUrl
            playButton.audioUrl = quiz.Body?.AudioUrl
            self.recordingView_read.audioURL = (quiz.Body?.AudioUrl)!
            msgResult = ChatMessageModel(audioUrl: (quiz.Body?.AudioUrl)!, position: .right)
        }else {
            let audio = "https://mtutordev.blob.core.chinacloudapi.cn/system-audio/lesson/zh-CN/zh-CN/0342b5aff1e19bfaaa604e265278e317.mp3"
            videoButton.audioUrl = audio
            playButton.audioUrl = audio
            self.recordingView_read.audioURL = audio
            msgResult = ChatMessageModel(audioUrl: audio, position: .right)
        }
        
        //tokens
        chineseandpinyinLabel = SpeakTokensView(frame: CGRect(x: 40, y: 0, width: quizWidth, height: 150), tokens: [], chineseSize: FontAdjust().ChineseAndPinyin_C_Big(), pinyinSize: FontAdjust().ChineseAndPinyin_P_Big(), style: .chineseandpinyin, changeAble: true,showIpa:false,scope: "Quiz_Read",cColor:UIColor.textBlack333,pColor:UIColor.textBlack333,scoreRight:true)
        
        self.chineseandpinyinLabel?.tokensArr = self.currentTokensModelArray
        self.chineseandpinyinLabel?.MaxWidth = Double(quizWidth)
        self.chineseandpinyinLabel?.clipsToBounds = false
        self.chineseandpinyinLabel?.setData()
        quizView.addSubview(chineseandpinyinLabel!)
        chineseandpinyinLabel?.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(quizView).offset(40)
            make.height.equalTo((chineseandpinyinLabel?.getViewHeight())!)
            make.width.equalTo(quizWidth)
            make.centerY.equalTo(quizView).offset(-(quizViewHeight / 2 - (chineseandpinyinLabel?.getViewHeight())!) / 2)
        }

        videoButtonView.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(VioceHeight)
            make.left.equalTo(self).offset(5)
            make.centerY.equalTo(chineseandpinyinLabel!)
        }
        
        playButton.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(VioceHeight)
            make.left.equalTo(self).offset(10)
            make.centerY.equalTo(quizView).offset(-(quizViewHeight / 2 - (chineseandpinyinLabel?.getViewHeight())!) / 2)
        }
        self.answer = quiz.Answer! - 1

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

extension ReadAftermeView:RNTextViewDelegate{
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
            make.bottom.equalTo(uibuttons[2].snp.top).offset(-12)
            make.top.equalTo(uibuttons[0].snp.bottom).offset(12)
        }
        
        uibuttons[0].snp.makeConstraints { (make) -> Void in
            make.left.right.equalTo(self)
            make.height.equalTo(buttonHeight)
            make.bottom.equalTo(uibuttons[1].snp.top).offset(-12)
        }
        
    }
    
    func superViewConstraints() {
        if (chineseandpinyinLabel != nil) {
            chineseandpinyinLabel?.setData()

            chineseandpinyinLabel?.snp.remakeConstraints { (make) -> Void in
                make.left.equalTo(quizView).offset(40)
                make.height.equalTo((chineseandpinyinLabel?.getViewHeight())!)
                make.width.equalTo(quizWidth)
                make.centerY.equalTo(quizView).offset(-(quizViewHeight / 2 - (chineseandpinyinLabel?.getViewHeight())!) / 2)
            }
            playButton.snp.remakeConstraints { (make) -> Void in
                make.width.height.equalTo(VioceHeight)
                make.left.equalTo(self).offset(10)
                make.centerY.equalTo(chineseandpinyinLabel!)
            }
            

        }
    }
    func getScoredText(_ detail:SpeechRateData?, originText:String) -> [NSMutableAttributedString] {
        let attString = NSMutableAttributedString(string: originText, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.speakscoreBlack]))
        let pinyinString = NSMutableAttributedString(string: self.pinyinGroup.joined(separator: " "), attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.speakscoreBlack]))
        if let data = detail {
            let pat = "[\\u4e00-\\u9fa5]"
            let regex = try! NSRegularExpression(pattern: pat, options: [])
            let matches = regex.matches(in: originText, options: [], range: NSRange(location: 0, length: originText.characters.count))
            if matches.count != data.WordDetails!.count {
                return [attString,pinyinString]
            }
            var currentPos = 0
            for (i, word) in data.WordDetails!.enumerated() {
                var range = NSRange(location: currentPos, length: self.pinyinGroup[i].count)
                currentPos += 1 + self.pinyinGroup[i].count
                if word.PronunciationScore! < 40 {
                    attString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.speakscoreRed, range: matches[i].range)
                    pinyinString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.speakscoreRed, range: range)
                }
                else if word.PronunciationScore! >= 60 {
                    attString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.speakscoreGreen, range: matches[i].range)
                    pinyinString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.speakscoreGreen, range: range)
                }else {
                    attString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.speakscoreBlack, range: matches[i].range)
                    pinyinString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.speakscoreBlack, range: range)
                }
            }
        }
        
        //此时拼音已经弄好了颜色，不过是缺少英文部分的，比如，wo xing（li） jiao (liwei)
        //pinyinString = “wo xing jiao”
        //pinyinSet = [wo,xing,jiao]
        let pinyinSet = pinyinString.string.split(separator: " ")
        
        var k = 0
        var attributeSet = [[String : Any]]()
        //swift convert
        for (i, py) in pinyinSet.enumerated() {
            var nsrange = NSRange(location: k, length: py.count)
            let attributes = convertFromNSAttributedStringKeyDictionary(pinyinString.attributes(at: k,effectiveRange: &nsrange))
            attributeSet.append(attributes)
            k += 1 + py.count
        }
        //swift convert
        
        let pinyinArray = self.pinyinText.components(separatedBy: " ")
        var muattributesArray = [NSMutableAttributedString]()
        if pinyinArray.count == pinyinSet.count {
            return [attString,pinyinString]
        }else {
            var attributesArray = [NSMutableAttributedString]()
            for str in pinyinArray {
                attributesArray.append(NSMutableAttributedString(string: str, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.speakscoreBlack])))
            }
            k = 0
            var i = 0
            //attributesArray = [wo ,xing ,jiao]
            for var (j, pinyinStr) in attributesArray.enumerated() {
                if i == pinyinSet.count {
                    for var(n,pinyinLeft) in attributesArray.enumerated() {
                        if n >= j {
                          muattributesArray.append(pinyinLeft)
                        }
                    }
                    break
                }
                // punctuation symbols
                var tmpText = NSMutableAttributedString(string: pinyinStr.string)
                
                //swift convert
                while i < pinyinSet.count {
                    if pinyinStr.string == pinyinSet[i] {
                        let nsrange = NSRange(location: 0, length: tmpText.string.count)
                        tmpText.addAttributes(convertToNSAttributedStringKeyDictionary(attributeSet[i]), range: nsrange)
                        i += 1
                    }
                    k = k + 1 + pinyinStr.string.count
                    break
                }
                muattributesArray.append(tmpText)
                //swift convert
            }
            
        }
        //拼接并且去掉末尾的j空格
        let pinyinStringOfAll = NSMutableAttributedString(string: "", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.speakscoreBlack]))
        
        for attiStr in muattributesArray {
            pinyinStringOfAll.append(attiStr)
            pinyinStringOfAll.append(NSAttributedString(string: " "))
        }
        if pinyinStringOfAll.string.hasSuffix(" ") {
            pinyinStringOfAll.deleteCharacters(in: NSRange(location: pinyinStringOfAll.length - 1, length: 1))
        }
        return [attString, pinyinStringOfAll]
    }
    func isChinese(chinese: String) ->Bool {
        let regex = "[\u{4e00}-\u{9fa5}]+"
        let pred = NSPredicate(format: "SELF MATCHES %@", regex)
        if pred.evaluate(with: chinese) {
            return true
        }
        return false
    }
    
    func sortToken(success: Bool = false) {
        var chineseColor = UIColor.textBlack
        var pinyinColor = UIColor.textBlack
        if success {
            chineseColor = UIColor.correctColor
            pinyinColor = UIColor.correctColor
        }
        
        let pinyin = NSMutableAttributedString()
        var chinese = NSMutableAttributedString()
        self.pinyinGroup.removeAll()
        self.pinyinAllGroup.removeAll()
        var tokenModelArray = [ChatMessageTokenModel]()
        for token in (quizSample.Body?.Tokens!)!{
            chinese = NSMutableAttributedString(string: "")
            let tokenModel = ChatMessageTokenModel()
            tokenModel.direct = ChatDirect.left
            let chinsesArray = token.Text?.components(separatedBy: " ")
            let chineseText = chinsesArray?.joined(separator: "")
            chinese.append(NSAttributedString(string: chineseText!, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : chineseColor])))
            let ipa = token.IPA1!
            var pinyinStr = NSMutableAttributedString(string: "")
            if(PinyinFormat(ipa).count == 0){
                tokenModel.text =  chinese
                tokenModel.pinyinText =  NSMutableAttributedString(string: "", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : pinyinColor]))
                tokenModelArray.append(tokenModel)
                continue
            }
            if(PinyinFormat(ipa).count == 1){
                pinyinStr = NSMutableAttributedString(string: PinyinFormat(ipa)[0], attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : pinyinColor]))
                if pinyinStr.string != PinyinFormat(token.IPA!)[0] {
                    //存在变调
                    pinyinStr = NSMutableAttributedString(string: PinyinFormat(ipa)[0], attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.hex(hex: "4e80d9")]))
                    if self.isChinese(chinese: token.Text!) {
                        self.pinyinGroup.append(PinyinFormat(ipa)[0])
                    }
                    self.pinyinAllGroup.append(PinyinFormat(ipa)[0])
                }else {
                    if self.isChinese(chinese: token.Text!) {
                        self.pinyinGroup.append(PinyinFormat(ipa)[0])
                    }
                    self.pinyinAllGroup.append(PinyinFormat(ipa)[0])
                }
            }
            else{
                for i in 0...PinyinFormat(ipa).count-1{
                    if PinyinFormat(ipa)[i] != PinyinFormat(token.IPA)[i] {
                        //存在变调
                        pinyinStr.append(NSAttributedString(string: PinyinFormat(ipa)[i], attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.hex(hex: "4e80d9")])))
                        if self.isChinese(chinese: token.Text!) {
                            self.pinyinGroup.append(PinyinFormat(ipa)[i])
                        }
                        self.pinyinAllGroup.append(PinyinFormat(ipa)[i])
                    }else {
                        pinyinStr.append(NSAttributedString(string: PinyinFormat(ipa)[i], attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : pinyinColor])))
                        if self.isChinese(chinese: token.Text!) {
                            self.pinyinGroup.append(PinyinFormat(ipa)[i])
                        }
                        self.pinyinAllGroup.append(PinyinFormat(ipa)[i])
                    }
                    
                }
            }
            if pinyinStr.mutableString.hasSuffix(" ") {
                pinyinStr.deleteCharacters(in: NSRange(location: pinyin.length - 1, length: 1))
            }
            tokenModel.text =  chinese
            tokenModel.pinyinText =  pinyinStr
            tokenModelArray.append(tokenModel)

        }
        self.pinyinText = self.pinyinAllGroup.joined(separator: " ")
        self.currentTokensModelArray.removeAll()
        for model in tokenModelArray {
            self.currentTokensModelArray.append(model.copy() as! ChatMessageTokenModel)
        }
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKeyDictionary(_ input: [NSAttributedString.Key: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSAttributedStringKeyDictionary(_ input: [String: Any]) -> [NSAttributedString.Key: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
