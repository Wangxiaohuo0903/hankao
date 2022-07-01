//
//  ChatViewController.swift
//  PracticeChinese
//
//  Created by 费跃 on 9/5/17.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class ChatRepeatViewController: BaseChatViewController,ChActivityViewCancleDelegate,NetworkRequestFailedLoadDelegate {
    func reloadData() {
        loadData()
    }
    var currentTokensModelArray = [ChatMessageTokenModel]()
    //加载失败的返回
    func backClick() {
        LCVoiceButton.stopGlobal()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    var pinyinGroup = [String]()
    var pinyinAllGroup = [String]()
    var pinyinText = ""
    var recordIndex = 0
    var shouldHideNextButton:Bool = true {
        didSet {
            self.nextButton.isHidden = shouldHideNextButton
        }
    }
    var showLast = false
    var showNext = false
    var repeatId: String!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Repeat"
        logId = repeatId
        Scope = "Speak"
        
        //制作毛玻璃效果
        var navHeight = self.ch_getNavigationBarHeight()
        if (AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax) {
            navHeight += ch_getStatusBarHeight()
        }
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        visualEffectView.frame = CGRect(x: 0, y: 0, width: ScreenUtils.width, height: navHeight)
        visualEffectView.alpha = 0.95
        
        self.view.addSubview(visualEffectView)
        self.view.bringSubviewToFront(visualEffectView)
        loadData()
    }
    func loadData() {
        ChActivityView.shared.delegate = self
        ChActivityView.show(.CancleFullScreen, UIApplication.shared.keyWindow!, UIColor.loadingBgColor, ActivityViewText.HomePageLoading,UIColor.loadingTextColor,UIColor.gray)
        
        CourseManager.shared.getSpeakLessonInfo(id: repeatId) {
            (data,error) in
            if data != nil {
                self.repeatLesson = data!.Lesson as? ReadAfterMeLesson
                
                self.nextButton.isHidden = true
                self.hintButton.isHidden = true
                self.recordView.delegate = self
                //向下的
                self.nextButton.setBackgroundImage(ChImageAssets.SpeakNextChat.image, for: .normal)
                self.showQuiz()
                self.analytics()
            }
            else {
//                self.presentUserToast(message: "Load lesson error.")
                if let requestError = error {
                    
                    var networkErrorText = NetworkRequestFailedText.DataError
                    if requestError.localizedDescription.hasPrefix("The request timed out.")
                    {
                        networkErrorText = NetworkRequestFailedText.NetworkTimeout
                        
                    }else if requestError.localizedDescription.hasPrefix("The Internet connection appears to be offline.") {
                        networkErrorText = NetworkRequestFailedText.NetworkError
                    }
                    let alertView = AlertNetworkRequestFailedView.init(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height))
                    alertView.delegate = self
                    alertView.show(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height),superView:self.view,alertText:networkErrorText,textColor:UIColor.loadingTextColor,bgColor: UIColor.loadingBgColor)
                }
            }
            ChActivityView.hide()
        }
    }
    func analytics() {
        if UserManager.shared.isLoggedIn(){
            if(!AppData.userAssessmentEnabled){
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    LCAlertView.show(title: String.PrivacyTitle, message: String.PrivacyConsent, leftTitle: "Don't Allow", rightTitle: "Allow", style: .center, leftAction: {
                        LCAlertView.hide()
                    }, rightAction: {
                        LCAlertView.hide()
                        AppData.setUserAssessment(true)
                    })
                }
            }
        }
    }
    //取消加载
    func cancleLoading () {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func clickNext() {
        super.clickNext()
        if self.currentIndex == (self.repeatLesson.QuizzesList?.count)! - 1 {
            
            let chatData = self.repeatLesson.QuizzesList![self.currentIndex]
            //埋点：点击进入Scenario(情景对话)
            let info = ["Scope" : "Speak","Lessonid" : repeatId,"IndexPath" : chatData.Quiz?.Text,"Event" : "NextPart"]
            UserManager.shared.logUserClickInfo(info)
            
            
            let scenarioId = self.repeatLesson.Id!.replacingOccurrences(of: "r-CN", with: "s-CN")
                let vc = ChatScenarioViewController()
                vc.scenarioId = scenarioId
                self.ch_pushViewController(vc, animated: true)
        }
        else {
            let chatData = self.repeatLesson.QuizzesList![self.currentIndex]
            //埋点：点击右下角Next
            let info = ["Scope" : "Speak","Lessonid" : repeatId,"IndexPath" : chatData.Quiz?.Text,"Event" : "Next"]
            UserManager.shared.logUserClickInfo(info)

            self.currentIndex += 1
            self.nextButton.isHidden = true
            showQuiz()
        }

        
    }
    
    func showQuiz() {
        
        self.nextButton.isHidden = true
        self.shouldCanRecord = false
        self.recordIndex = 0
        self.bubbleCanPlayAudio = true
        self.recordView.filename = "\(self.repeatLesson.Id!)_\(self.currentIndex)_\(self.recordIndex)"

        if self.currentIndex == (self.repeatLesson.QuizzesList?.count)! - 1 {
            self.nextButton.setBackgroundImage(ChImageAssets.SpeakContinueChat.image, for: .normal)
//            self.nextButton.setBackgroundImage(ChImageAssets.SpeakContinueChat.image, for: .highlighted)
//            self.nextButton.setBackgroundImage(ChImageAssets.SpeakContinueChat.image, for: .selected)
        }
        let newMsgModel = ChatMessageModel(type: .audio, text: "", pinyin: "", imageUrl: "", avatarUrl: self.teacherAvatar, audioUrl: "", position: .left, textArray:nil)
        newMsgModel.CellHeight = 48
        self.msgList.append(newMsgModel)
        self.reloadView()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            if(self.msgList.count != 0){
                self.msgList.removeLast()
            }
            if self.currentIndex == 0 {
                let title = "Please repeat after me. Here we go!"
                let msgModel = ChatMessageModel(text: title,position: BubblePosition.left, avatar: self.teacherAvatar)
                let textHeight = title.height(withConstrainedWidth: ScreenUtils.width - 70 - 26  - 20, font: FontUtil.getTextFont())
                let mTextHeight = max(textHeight+15, textHeight + 20)
                msgModel.CellHeight = Int(mTextHeight)
                self.msgList.append(msgModel)
            }
            else {
                let title = "Let’s do one more!"
                let msgModel = ChatMessageModel(text: title,position: BubblePosition.left, avatar: self.teacherAvatar)
                let textHeight = title.height(withConstrainedWidth: ScreenUtils.width - 70 - 26  - 20, font: FontUtil.getTextFont())
                let mTextHeight = max(textHeight+15, textHeight + 20)
                msgModel.CellHeight = Int(mTextHeight)
                self.msgList.append(msgModel)
            }
            self.reloadView()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if self.currentIndex < self.repeatLesson.QuizzesList!.count && self.msgList.count > 0 {
                let quiz = self.repeatLesson.QuizzesList![self.currentIndex]
                //替换
                var pinyin = NSMutableAttributedString()
                var chinese = NSMutableAttributedString()
                self.pinyinGroup.removeAll()
                self.pinyinAllGroup.removeAll()
                var tokenModelArray = [ChatMessageTokenModel]()
                
                var tokenAllArray = [[IllustrationText]]()

                for token in quiz.Quiz!.Tokens! {
                    var has = false
                    for (i,tokensA1) in tokenAllArray.enumerated() {

                        let hasToken = tokensA1.contains { element in
                            if element.Tags == nil {
                                return false
                            } else {
                                if element.Tags![0] == token.Tags![0] && token.Tags![0] != "0" {
                                    //已经有了，可以追加
                                    return true
                                } else {
                                    //没有，重新添加
                                    return false
                                }
                            }
                        }
                        has = hasToken
                        if has {
                            var tokensA11 = tokenAllArray[i]
                            tokensA11.append(token)
                            tokenAllArray[i] = tokensA11
                            break
                        }
                    }
                    if has {
                        
                    }else {
                        var tokensA2 = [IllustrationText]()
                        tokensA2.append(token)
                        tokenAllArray.append(tokensA2)
                    }
                }
                
                
                for tokensArray in tokenAllArray{
                    pinyin = NSMutableAttributedString(string: "")
                    chinese = NSMutableAttributedString(string: "")
                    let tokenModel = ChatMessageTokenModel()
                    tokenModel.direct = ChatDirect.left
                    for token in tokensArray {
                        chinese.append(NSAttributedString(string: token.Text!, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.textBlack])))
                        //设置拼音
                        var pinyinStr = NSMutableAttributedString(string: "")
                        if(token.IPA1 != nil && token.IPA1 != ""){//不是标点或者特殊的符号
                            let ipa = token.IPA1!
                            if(PinyinFormat(ipa).count == 1){
                                pinyinStr = NSMutableAttributedString(string: PinyinFormat(ipa)[0], attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.lightText]))
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
                            }else{
                                for i in 0...PinyinFormat(ipa).count-1{
                                    if PinyinFormat(ipa)[i] != PinyinFormat(token.IPA)[i] {
                                      //存在变调
                                        pinyinStr.append(NSAttributedString(string: PinyinFormat(ipa)[i], attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.hex(hex: "4e80d9")])))
                                        if self.isChinese(chinese: token.Text!) {
                                            self.pinyinGroup.append(PinyinFormat(ipa)[i])
                                        }
                                        self.pinyinAllGroup.append(PinyinFormat(ipa)[i])
                                    }else {
                                        pinyinStr.append(NSAttributedString(string: PinyinFormat(ipa)[i], attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.lightText])))
                                        if self.isChinese(chinese: token.Text!) {
                                            self.pinyinGroup.append(PinyinFormat(ipa)[i])
                                        }
                                        self.pinyinAllGroup.append(PinyinFormat(ipa)[i])
                                    }

                                }
                            }
                            pinyin.append(pinyinStr)
                            pinyin.append(NSAttributedString(string: " ", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.lightText])))
                        }
                    }
                    if pinyin.mutableString.hasSuffix(" ") {
                        pinyin.deleteCharacters(in: NSRange(location: pinyin.length - 1, length: 1))
                    }
                    
                    tokenModel.text =  chinese
                    tokenModel.pinyinText =  pinyin
                    tokenModelArray.append(tokenModel)
                }
                self.pinyinText = self.pinyinAllGroup.joined(separator: " ")
                self.currentTokensModelArray.removeAll()
                for model in tokenModelArray {
                    self.currentTokensModelArray.append(model.copy() as! ChatMessageTokenModel)
                }
               
                let pinyinUpload = self.pinyinGroup.joined(separator: " ")
            //添加Quiz数据,左边
                let msgModel = ChatMessageModel(type: .audiotext, text: quiz.Quiz!.Text, pinyin: pinyinUpload, imageUrl: "", avatarUrl: self.teacherAvatar, audioUrl: quiz.Quiz!.AudioUrl, position: BubblePosition.left, en: quiz.Quiz!.NativeText!, index: "\(self.currentIndex+1)/\(self.repeatLesson.QuizzesList!.count)", textArray:tokenModelArray)

                var mTextHeight = CGFloat(0.0)
                
                let en = msgModel.en
                let textArray = msgModel.textArray
                let buttonsViewHeight:CGFloat = 36
                
                mTextHeight += buttonsViewHeight
                
                let cardMaxWidth = AdjustGlobal().CurrentScaleWidth - 70 - 26 - 20
                
                let enHeight = en.string.height(withConstrainedWidth: cardMaxWidth, font: FontUtil.getDescFont()) + 2
                var indexLabelWidth:CGFloat = 0
                if msgModel.index != "" {
                    let indexFont = FontUtil.getFont(size: FontAdjust().FontSize(11), type: .Regular)
                    indexLabelWidth = self.getLabelWidth(labelStr: msgModel.index, font: indexFont)+6
                }else{
                    let indexFont = FontUtil.getFont(size: FontAdjust().FontSize(11), type: .Regular)
                    let string  = "Reference Answer"
                    indexLabelWidth = self.getLabelWidth(labelStr: string, font: indexFont)+8
                }
                
                //20左右padding+15喇叭weight+20喇叭index间距
                let chineseandpinyinLabel = SpeakTokensView(frame: CGRect(x: 13, y: 0, width: cardMaxWidth, height: 150), tokens: textArray, chineseSize: FontAdjust().Speak_ChineseAndPinyin_C(), pinyinSize: FontAdjust().Speak_ChineseAndPinyin_P(), style: .chineseandpinyin, changeAble: true,showIpa:false,scope: self.Scope,cColor:UIColor.black,pColor:UIColor.lightText,scoreRight:false)
                chineseandpinyinLabel.setData()
                
                let getHeight = chineseandpinyinLabel.getViewHeight()
                
                mTextHeight += getHeight + enHeight + 15
                msgModel.CellHeight = Int(mTextHeight)
                self.msgList.append(msgModel)
                self.reloadView()
                self.showNext = false
            }
        }
    }

    
    func isChinese(chinese: String) ->Bool {
        let regex = "[\u{4e00}-\u{9fa5}]+"
        let pred = NSPredicate(format: "SELF MATCHES %@", regex)
        if pred.evaluate(with: chinese) {
            CWLog("中文")
            return true
        }
        CWLog("英文")
        return false
    }
    
    
    func getScoredText(_ detail:SpeechRateData?, originText:String, tokens:[IllustrationText]) -> [NSMutableAttributedString] {
        let attString = NSMutableAttributedString(string: originText, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.speakscoreWhite]))
        let pinyinString = NSMutableAttributedString(string: self.pinyinGroup.joined(separator: " "), attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.speakscoreWhite]))
        if let data = detail {
                let pat = "[\\u4e00-\\u9fa5]"
                let regex = try! NSRegularExpression(pattern: pat, options: [])
                let matches = regex.matches(in: originText, options: [], range: NSRange(location: 0, length: originText.characters.count))
                if matches.count != data.WordDetails!.count {
                    return [attString,pinyinString]
                }
                var currentPos = 0
                for (i, word) in data.WordDetails!.enumerated() {
                    let range = NSRange(location: currentPos, length: self.pinyinGroup[i].count)
                    currentPos += 1 + self.pinyinGroup[i].count
                    if word.PronunciationScore! < 40 {
                        attString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.speakscoreRed, range: matches[i].range)
                        pinyinString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.speakscoreRed, range: range)
                    }
                    else if word.PronunciationScore! >= 60 {
                        attString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.speakscoreGreen, range: matches[i].range)
                        pinyinString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.speakscoreGreen, range: range)
                    }else {
                        attString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.speakscoreWhite, range: matches[i].range)
                        pinyinString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.speakscoreWhite, range: range)
                    }
                }
        }
        
        //此时拼音已经弄好了颜色，不过是缺少英文部分的，比如，wo xing jiao
        let pinyinSet = pinyinString.string.split(separator: " ")
        var k = 0
        var attributeSet = [[String : Any]]()
        //swift convert
        for (_, py) in pinyinSet.enumerated() {
            let startIndex = pinyinString.string.index(pinyinString.string.startIndex, offsetBy: k)
            let range = pinyinString.string.range(of: py, options: .caseInsensitive, range: startIndex..<pinyinString.string.endIndex, locale:nil)
            var nsrange = NSMakeRange(0, pinyinString.string.count)
            let attributes = convertFromNSAttributedStringKeyDictionary(pinyinString.attributes(at: pinyinString.string.distance(from: startIndex, to: range!.lowerBound), effectiveRange: &nsrange))
            attributeSet.append(attributes)
            k += pinyinString.string.distance(from: range!.lowerBound, to: range!.upperBound)
        }
        //swift convert
        var i = 0
        var pinyinArray = self.pinyinText.components(separatedBy: " ")
        var attributesArray = [NSMutableAttributedString]()
        for str in pinyinArray {
            attributesArray.append(NSMutableAttributedString(string: str, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.speakscoreWhite])))
        }
        
        for var (j, pinyinStr) in attributesArray.enumerated() {
            if i == pinyinSet.count {
                i = 0
            }
            // punctuation symbols
            
            k = 0
            var tmpText = NSMutableAttributedString(string: pinyinStr.string)
            //swift convert
            while k < pinyinStr.string.count && i < pinyinSet.count {
                let startIndex = pinyinStr.string.index(pinyinStr.string.startIndex, offsetBy: k)
                let r = pinyinStr.string.range(of: pinyinSet[i], options: .caseInsensitive, range: startIndex..<pinyinStr.string.endIndex, locale:nil)
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
        }

        var pinyinStringOfAll = NSMutableAttributedString(string: "", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.speakscoreWhite]))
        
        for attiStr in attributesArray {
            pinyinStringOfAll.append(attiStr)
            pinyinStringOfAll.append(NSAttributedString(string: " "))
        }
        if pinyinStringOfAll.string.hasSuffix(" ") {
            pinyinStringOfAll.deleteCharacters(in: NSRange(location: pinyinStringOfAll.length - 1, length: 1))
        }
        
        CWLog("得分情况\([attString, pinyinStringOfAll])")
        return [attString, pinyinStringOfAll]
    }
    override func showBeginnerGuide() {
        if(!self.quitIsPresent){
            self.presentBeginnerGuide()
        }
    }
    
    override func closeCancelEvent() {
        self.presentBeginnerGuide()
    }

}

//新手引导
extension ChatRepeatViewController: LCRecordingViewDelegate,BeginnerGuideCloseDelegate{
    func presentBeginnerGuide() {

        if UserDefaults.standard.integer(forKey: UserDefaultsKeyManager.readBeginnerGuideRecording) > 0 {
            return
        }
        
        let button = self.recordView.startButton!
        let point = button.superview!.convert(button.frame.origin, to: nil)
        
        
        let showX = point.x
        var showY = self.recordView.frame.minY  + CGFloat(6)
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
            showY = self.recordView.frame.minY  + CGFloat(6) - self.ch_getStatusBarHeight()
        }
        let showWidth = button.frame.width
        let showHeight = button.frame.height
        let showRadius = showWidth / 2
        
        let font = BeginnerGuideView.noticeFont
        
        let noticeText = "Please tap the recording button to start record."
        
        let textWidth = ScreenUtils.widthByRate(x: 0.6)
        let textX = ScreenUtils.widthByRate(x: 0.35)
        var offsety:CGFloat = 0
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
            offsety = self.ch_getNavigationBarHeight()
        }
        let textHeight = noticeText.height(withConstrainedWidth: textWidth, font: font)
        let textY = showY - ScreenUtils.heightByM(y: 20) - textHeight
        let birdY = textY - 10
        let birdX = (ScreenUtils.width*0.25 - BeginnerGuideView.birdWidth) / 2 + ScreenUtils.width*0.1
        let birdPoint = CGPoint(x: birdX, y: birdY+offsety)
        let noticeFrame = CGRect(x: textX, y: textY+offsety, width: textWidth, height: 1)
        let showFrame = CGRect(x: showX, y: showY+offsety, width: showWidth, height: showHeight)
        

        let guideView = BeginnerGuideView(frame: UIScreen.main.bounds, birdPoint: birdPoint, noticeText: noticeText, noticeFrame: noticeFrame, showFrame: showFrame, showRadius: showRadius)
        
        guideView.delegate = self
        UIApplication.shared.keyWindow?.addSubview(guideView)
    }
    
    func closeBeginnerGuide() {
        UserDefaults.standard.set(Int(1), forKey: UserDefaultsKeyManager.readBeginnerGuideRecording)
        UserDefaults.standard.synchronize()
        recordView.startRecording(sender: UIButton())
    }
    
    func recordingStart()//开始录音
    {
        let chatData = self.repeatLesson.QuizzesList![self.currentIndex]
        //埋点：开始录音
        let info = ["Scope" : "Speak","Lessonid" : repeatId,"IndexPath" : chatData.Quiz?.Text,"Event" : "Recording","Value" : "Start"]
        UserManager.shared.logUserClickInfo(info)
        
        self.bubbleCanPlayAudio = false
        self.bubbleCanAnimate = false
        self.nextButton.isHidden = true
        let newMsgModel = ChatMessageModel(type: .audio, text: "", pinyin: "", imageUrl: "", avatarUrl: self.userAvatar, audioUrl: "", position: .right,textArray:nil)
        newMsgModel.CellHeight = 48
        self.msgList.append(newMsgModel)
        self.reloadView()

    }
    func recordingAutoCommit()//到时间自动提交
    {
        
    }
    //当手速足够快点击录音 取消录音的回调会慢一步发生
    func recordingCancel()//取消录音
    {
        if(self.msgList.count != 0){
            self.msgList.removeLast()
        }
        self.nextButton.isHidden = !self.showNext
        self.shouldCanRecord = true
        self.reloadView()
    }
    func recordingSubmit(duration:Double)//提交录音
    {
        let chatData = self.repeatLesson.QuizzesList![self.currentIndex]
        //埋点：结束录音
        let info = ["Scope" : "Speak","Lessonid" : repeatId,"IndexPath" : chatData.Quiz?.Text,"Event" : "Recording","Value" : "Finish"]
        UserManager.shared.logUserClickInfo(info)
        
        self.shouldCanRecord = false

        if(self.msgList.count != 0){
            self.msgList.removeLast()
        }
        let msgModel = ChatMessageModel(audioUrl: DocumentManager.urlFromFilename(filename: "\(self.recordView.filename).m4a").absoluteString, position: .right, score: -1, avatar: self.userAvatar)
        msgModel.CellHeight = 48
        self.msgList.append(msgModel)
        self.reloadView()

        sendRecording()
//        if(AppData.userAssessmentEnabled){
//            sendRecording()
//        }else{
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                  LCAlertView.show(title: "", message: String.PrivacyConsent, leftTitle: "Allow", rightTitle: "Later", style: .center, leftAction: {
//                    LCAlertView.hide()
//                    AppData.setUserAssessment(true)
//                    self.sendRecording()
//                }, rightAction: {
//                    LCAlertView.hide()
//                    if(self.msgList.count != 0){
//                        self.msgList.removeLast()
//                    }
//                    self.reloadView()
//                    self.shouldCanRecord = true
//                })
//            }
//        }

    }
    func itemTapMethod(gesture: UITapGestureRecognizer) {
        gesture.view?.removeFromSuperview()
    }
    func sendRecording(){
        //上传音频
        let audioData = try! Data(contentsOf: DocumentManager.urlFromFilename(filename: "\(self.recordView.filename).m4a"))
        let byteData = [Byte](audioData)
        let chineseArray = self.repeatLesson.QuizzesList![self.currentIndex].Quiz!.Text?.components(separatedBy: [" "])
        CourseManager.shared.rateSpeechRepeat(lid: self.repeatLesson.Id!,text: self.repeatLesson.QuizzesList![self.currentIndex].Quiz!.Text!, data: byteData){
            data in
            if let result = data {
                
                if(self.msgList.count != 0){
                    self.msgList.removeLast()
                }
                self.bubbleCanAnimate = true
                
                let bgView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height/2))
                bgView.backgroundColor = UIColor.colorFromRGB(0, 0, 0, 0.2)
                let textView = UITextView(frame: CGRect(x: 00, y: 0, width: ScreenUtils.width, height: ScreenUtils.height/2 - 40))
                bgView.addSubview(textView)
                textView.text = String(format: "%@", (result.Details?.toJSON())!)
                textView.font = FontUtil.getFont(size: FontAdjust().FontSize(16), type: .Regular)
                var originText = ""
                
                for model in self.currentTokensModelArray {
                    originText.append(model.text.string)
                }
                
                let attrstrings = self.getScoredText(result.Details, originText:
                    originText, tokens: self.repeatLesson.QuizzesList![self.currentIndex].Quiz!.Tokens!)
                let msgResult = ChatMessageModel(audioUrl: self.repeatLesson.QuizzesList![self.currentIndex].Quiz!.AudioUrl!, position: .right)
                msgResult.type = ChatMessageType.audiotext
                msgResult.pinyinText = attrstrings[1]
                msgResult.audioUrl = DocumentManager.urlFromFilename(filename: "\(self.recordView.filename).m4a").absoluteString
                msgResult.score = result.SpeechScore!
                msgResult.text = attrstrings[0]
                msgResult.en = NSMutableAttributedString(string: self.repeatLesson.QuizzesList![self.currentIndex].Quiz!.NativeText!)
                msgResult.avatarUrl = self.userAvatar
                for model in self.currentTokensModelArray {
                    model.direct = ChatDirect.right
                }
                msgResult.textArray = self.currentTokensModelArray
                
                
                
                
                var mTextHeight = CGFloat(0.0)
                let en = msgResult.en
                let textArray = msgResult.textArray
                mTextHeight = 0
                let buttonsViewHeight:CGFloat = 43
                mTextHeight += buttonsViewHeight
                
                let cardMaxWidth = AdjustGlobal().CurrentScaleWidth - 70 - 26 - 20
                
                let enHeight = en.string.height(withConstrainedWidth: cardMaxWidth, font: FontUtil.getDescFont()) + 2
                let englishwidth = en.string.wdith(withConstrainedWidth: cardMaxWidth, font: FontUtil.getDescFont()) + 4
                
                var indexLabelWidth:CGFloat = 0
                
                if msgResult.index != "" {
                    let indexFont = FontUtil.getFont(size: FontAdjust().FontSize(11), type: .Regular)
                    indexLabelWidth = self.getLabelWidth(labelStr: msgResult.index, font: indexFont)+6
                }else{
                    let indexFont = FontUtil.getFont(size: FontAdjust().FontSize(11), type: .Regular)
                    let string  = "Reference Answer"
                    indexLabelWidth = self.getLabelWidth(labelStr: string, font: indexFont)+8
                }
                
                let chineseandpinyinLabel = SpeakTokensView(frame: CGRect(x: 13, y: 0, width: cardMaxWidth, height: 150), tokens: textArray, chineseSize: FontAdjust().Speak_ChineseAndPinyin_C(), pinyinSize: FontAdjust().Speak_ChineseAndPinyin_P(), style: .chineseandpinyin, changeAble: true,showIpa:false,scope: self.Scope,cColor:UIColor.black,pColor:UIColor.lightText,scoreRight:false)
                chineseandpinyinLabel.setData()
                let getHeight = chineseandpinyinLabel.getViewHeight()

                mTextHeight += getHeight + enHeight + 15
                msgResult.CellHeight = Int(mTextHeight)

                self.msgList.append(msgResult)
                
                self.recordIndex += 1
                self.recordView.filename = "\(self.repeatLesson.Id!)_\(self.currentIndex)_\(self.recordIndex)"
                
                self.reloadView()
                if(UIApplication.topViewController()?.isKind(of: ChatRepeatViewController.self))!{
                    //经验值去掉
                    //ExpAnimationView.show(LessonRepeatViewController.getExpType(result.SpeechScore!))
                    self.audioPlayer = AVPlayer(url: ChBundleAudioUtil.successful.url)
                    self.audioPlayer.play()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    let newMsgModel = ChatMessageModel(type: .audio, text: "", pinyin: "", imageUrl: "", avatarUrl: self.teacherAvatar, audioUrl: "", position: .left,textArray:nil)
                    newMsgModel.CellHeight = 48
                    self.msgList.append(newMsgModel)
                    self.reloadView()
                }
                self.showNext = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    if(self.msgList.count != 0){
                        self.msgList.removeLast()
                    }
                    let title = self.getRemarkByScore(score: result.SpeechScore!)
                    let msgModel = ChatMessageModel(text: title, position: .left, avatar: self.teacherAvatar)
                    let textHeight = title.height(withConstrainedWidth: ScreenUtils.width - 70 - 26  - 20, font: FontUtil.getTextFont())
                    let mTextHeight = max(textHeight+15, textHeight + 20)
                    msgModel.CellHeight = Int(mTextHeight)
                    self.msgList.append(msgModel)
                    self.reloadView()

                    if (self.currentIndex == (self.repeatLesson.QuizzesList!.count - 1)) && (self.showLast == false)  {
                        self.showLast = true
                        let msgModel = ChatMessageModel(type: .audio, text: "", pinyin: "", imageUrl: "", avatarUrl: self.teacherAvatar, audioUrl: "", position: .left,textArray:nil)
                        msgModel.CellHeight = 48
                        self.msgList.append(msgModel)
                        
                        self.reloadView()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            if(self.msgList.count != 0){
                                self.msgList.removeLast()
                            }
                            let title = "No more repeating tasks."
                            let msgModel = ChatMessageModel(text: title, position: .left, avatar:self.teacherAvatar)
                            let textHeight = title.height(withConstrainedWidth: ScreenUtils.width - 70 - 26  - 20, font: FontUtil.getTextFont())
                            let mTextHeight = max(textHeight+15, textHeight + 20)
                            msgModel.CellHeight = Int(mTextHeight)
                            self.msgList.append(msgModel)

                            self.reloadView()
                            self.nextButton.isHidden = false
                            self.shouldCanRecord = true
                        }
                    }
                    else {
                        self.nextButton.isHidden = false
                        self.shouldCanRecord = true
                    }
                }
            }
            else {
                if(self.msgList.count != 0){
                    self.msgList.removeLast()
                }
                self.reloadView()
                self.shouldCanRecord = true
                self.presentUserToast(message: "Error occured during scoring")
            }
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
