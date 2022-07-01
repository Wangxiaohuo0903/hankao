//
//  ChatScenarioViewController.swift
//  PracticeChinese
//
//  Created by 费跃 on 10/12/17.
//  Copyright © 2017 msra. All rights reserved.
//


import Foundation
import UIKit
import AVFoundation

class ChatScenarioViewController: BaseChatViewController,NetworkRequestFailedLoadDelegate,ChActivityViewCancleDelegate {
    //加载中点击取消
    func cancleLoading() {
      self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    //加载失败
    func reloadData() {
        loaddata()
    }
    
    func backClick() {
        
    }
    
    var sentenceDict:VideoSentenceDictionary!
    var hintIndex = 0
    var hasShowAnswer = false
    var showLast = false
    //记录最新的chatTurn是否显示了两个hint
    var clickTwo = false
    var showNext = false
    var canAutoShowHint: Bool = false
    var checkPic = false
    var scenarioId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Respond"
        logId = scenarioId
        Scope = "Scenario"
        
        recordView.delegate = self

        self.nextButton.setBackgroundImage(ChImageAssets.SpeakNextChat.image, for: .normal)
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
        loaddata()
    }
    func loaddata() {
        ChActivityView.shared.delegate = self
        ChActivityView.show(.CancleFullScreen, UIApplication.shared.keyWindow!, UIColor.loadingBgColor, ActivityViewText.HomePageLoading,UIColor.loadingTextColor,UIColor.gray)
        
        CourseManager.shared.getScenarioLessonInfo(id: scenarioId) {
            (data,error) in
            if data == nil {
                //                    self.presentUserToast(message: "Load lesson error.")
                if let requestError = error {
                    
                    var networkErrorText = NetworkRequestFailedText.DataError
                    if requestError.localizedDescription.hasPrefix("The request timed out")
                    {
                        networkErrorText = NetworkRequestFailedText.NetworkTimeout
                        
                    }else if requestError.localizedDescription.hasPrefix("The Internet connection appears to be offline.") {
                        networkErrorText = NetworkRequestFailedText.NetworkError
                    }
                    let alertView = AlertNetworkRequestFailedView.init(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height - self.ch_getStatusBarHeight()))
                    alertView.delegate = self
                    alertView.show(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height),superView:self.navigationController!.view,alertText:networkErrorText,textColor:UIColor.loadingTextColor,bgColor: UIColor.loadingBgColor)
                }
                return
            }
            ChActivityView.hide()
            self.scenarioLesson = data!.ScenarioLesson
            self.sentenceDict = data!.VideoSentenceDictionary
            self.showQuiz()
        }
    }
    
    override func clickNext() {
        ToastAlertView.hide()
//        ExpAnimationView.quit()
        super.clickNext()
        if self.currentIndex == (self.scenarioLesson.ChatTurn?.count)! - 1 {
            self.visualEffectView.removeFromSuperview()
            let vc = SpeakResultViewController()
            vc.id = self.scenarioLesson.Id!
            self.ch_pushViewController(vc, animated: true)
            //埋点：点击进入Summary Page
            let chatData = self.scenarioLesson.ChatTurn![self.currentIndex]
            let info = ["Scope" : "Scenario","Lessonid" : scenarioId,"IndexPath" : chatData.Question,"Event" : "NextPart"]
            UserManager.shared.logUserClickInfo(info)
        }
        else {
            //埋点：点击右下角Next
            let chatData = self.scenarioLesson.ChatTurn![self.currentIndex]
            let info = ["Scope" : "Scenario","Lessonid" : scenarioId,"IndexPath" : chatData.Question,"Event" : "Next"]
            UserManager.shared.logUserClickInfo(info)
            self.currentIndex += 1
            showQuiz()
        }
    }
    func showQuiz() {
        self.clickTwo = false
        self.hintIndex = 0
        self.hasShowAnswer = false
        self.nextButton.isHidden = true
        self.shouldCanRecord = false
        self.bubbleCanPlayAudio = true

        if self.currentIndex == (self.scenarioLesson.ChatTurn?.count)! - 1 {
            //向右的
            self.nextButton.setBackgroundImage(ChImageAssets.SpeakContinueChat.image, for: .normal)
//            self.nextButton.setBackgroundImage(ChImageAssets.SpeakContinueChat.image, for: .highlighted)
//            self.nextButton.setBackgroundImage(ChImageAssets.SpeakContinueChat.image, for: .selected)
        }
        let newMsgModel = ChatMessageModel(type: .audio, text: "", pinyin: "", imageUrl: "", avatarUrl: self.teacherAvatar, audioUrl: "", position: .left,textArray:nil)
        newMsgModel.CellHeight = 48
        self.msgList.append(newMsgModel)
        self.reloadView()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            if(self.msgList.count != 0){
                self.msgList.removeLast()
            }
            if self.currentIndex == 0 {
                let title = "Welcome to the dialogue section. Please answer my questions."
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
            if self.currentIndex < self.scenarioLesson.ChatTurn!.count && self.msgList.count > 0 {
                let chat = self.scenarioLesson.ChatTurn![self.currentIndex]
                self.indexPathStr = chat.Question!
                var audioUrl = ""
                if self.sentenceDict.TextDictionary![chat.Question!] == nil {
                    
                }else {
                    audioUrl = self.sentenceDict.TextDictionary![chat.Question!]!.AudioUrl!
                }
                self.teacherAvatar = chat.ChaUrl == nil ? "" : chat.ChaUrl!
                var tokenModelArray = [ChatMessageTokenModel]()
                
                var pinyin = NSMutableAttributedString()
                var chinese = NSMutableAttributedString()
                
                for token in chat.Tokens! {
                    pinyin = NSMutableAttributedString(string: "")
                    chinese = NSMutableAttributedString(string: "")
                    let tokenModel = ChatMessageTokenModel()
                    
                    chinese.append(NSAttributedString(string: token.Text!, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.textBlack])))
                    //设置拼音
                    var pinyinStr = NSMutableAttributedString(string: "")
                    if(token.IPA1 != nil && token.IPA1 != ""){//不是标点或者特殊的符号
                        let ipa = token.IPA1!
                        if(PinyinFormat(ipa).count == 1){
                            pinyinStr = NSMutableAttributedString(string: PinyinFormat(ipa)[0], attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.lightText]))
//                            if pinyinStr.string != PinyinFormat(token.IPA)[0] {
//                                //存在变调
//                                pinyinStr = NSMutableAttributedString(string: PinyinFormat(ipa)[0], attributes: [NSForegroundColorAttributeName : UIColor.hex(hex: "4e80d9")])
//                            }
                        }else{
                            for i in 0...PinyinFormat(ipa).count-1{
//                                if PinyinFormat(ipa)[i] != PinyinFormat(token.IPA)[i] {
//                                    //存在变调
//                                    pinyinStr.append(NSAttributedString(string: PinyinFormat(ipa)[i], attributes: [NSForegroundColorAttributeName : UIColor.hex(hex: "4e80d9")]))
//                                }else {
                                    pinyinStr.append(NSAttributedString(string: PinyinFormat(ipa)[i], attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.lightText])))
//                                }
                            }
                            if pinyinStr.mutableString.hasSuffix(" ") {
                                pinyinStr.removeAttribute(convertToNSAttributedStringKey(" "), range: NSRange(location: pinyinStr.length - 1, length: 1))
                            }
                        }
                        pinyin.append(pinyinStr)
                        pinyin.append(NSAttributedString(string: " ", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.lightText])))
                    }
                    if pinyin.mutableString.hasSuffix(" ") {
                        pinyin.removeAttribute(convertToNSAttributedStringKey(" "), range: NSRange(location: pinyin.length - 1, length: 1))
                    }
                    tokenModel.text =  chinese
                    tokenModel.pinyinText =  pinyin
                    tokenModelArray.append(tokenModel)
                
                }
                
                let msgModel = ChatMessageModel(type: .audiotext, text: "", pinyin: "", imageUrl: "", avatarUrl: self.teacherAvatar, audioUrl: audioUrl, position: .left, en: chat.NativeQuestion!, index: "\(self.currentIndex+1)/\(self.scenarioLesson.ChatTurn!.count)",textArray:tokenModelArray)
                
                
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
                self.checkPic = true
                if(chat.AnswerOptions![0].ImageUrl == nil){
                    self.canAutoShowHint = true
                    self.recordView.filename = "\(self.scenarioLesson.Id!)_\(self.currentIndex)"
                    self.showNext = false
                }
            }
        }
    }
    
    override func showHints() {

        let answer = self.scenarioLesson.ChatTurn![self.currentIndex].AnswerOptions![0]
        if hintIndex == 0 {
            let hintText1 = "Here you can say:\n\(answer.nativeText!)"
            let mTextHeight = hintText1.height(withConstrainedWidth: ScreenUtils.width - 30, font: FontUtil.getTextFont()) + 10
            let msgModel = ChatMessageModel(type: .tip, text: hintText1, pinyin: "", imageUrl: "", avatarUrl: "", audioUrl: "", position: .left,textArray:nil)
                msgModel.CellHeight = Int(mTextHeight)
            self.msgList.append(msgModel)
            self.reloadView()
            hintIndex = 1
            self.clickTwo = false
        }
        else if hintIndex == 1 {
            hintIndex = 0
            //最多显示两次
            self.clickTwo = true
            self.shouldShowHint = false
            var hintDetails = "These words may help you:"
            let nilstring = "nil"
            for hint in answer.HintDetails! {
                let text = (hint.Text != nil) ? hint.Text!:nilstring
                let pinyin = (hint.Pinyin != nil) ? hint.Pinyin!:nilstring
                let nativetext = (hint.NativeText != nil) ? hint.NativeText!:nilstring
                var pinyinS:String = ""
                if(pinyin != nilstring){
                    pinyinS = PinyinFormat(pinyin)[0]
                    if(PinyinFormat(pinyin).count == 1){
                        pinyinS = PinyinFormat(pinyin)[0]
                    }else{
                        for i in 1...PinyinFormat(pinyin).count-1{
                            pinyinS = pinyinS + " " + PinyinFormat(pinyin)[i]
                        }
                    }
                }
                hintDetails += "\n\(text)/\(pinyinS)/\(nativetext)"
            }
            let mTextHeight = hintDetails.height(withConstrainedWidth: ScreenUtils.width - 30, font: FontUtil.getTextFont()) + 10
            let msgModel = ChatMessageModel(type: .tip, text: hintDetails, pinyin: "", imageUrl: "", avatarUrl: "", audioUrl: "", position: .left,textArray:nil)
            msgModel.CellHeight = Int(mTextHeight)
            self.msgList.append(msgModel)
            
            self.reloadView()
            
        }
        //埋点：结束录音
        let info = ["Scope" : "Scenario","Lessonid" : scenarioId,"IndexPath" : indexPathStr,"Event" : "Prompt","Value" : (hintIndex + 1)] as [String : Any]
        UserManager.shared.logUserClickInfo(info)
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

extension ChatScenarioViewController: LCRecordingViewDelegate,BeginnerGuideCloseDelegate {
    override func buttonPlayStop() {
        let chat = self.scenarioLesson.ChatTurn![self.currentIndex]
        if(chat.AnswerOptions![0].ImageUrl != nil && ((chat.AnswerOptions![0].ImageUrl?.hasSuffix(".png"))! || (chat.AnswerOptions![0].ImageUrl?.hasSuffix(".jpg"))!) && checkPic){
            //添加图片cell
            let msgModel = ChatMessageModel(imageUrl: chat.AnswerOptions![0].ImageUrl, position:.left)
            msgModel.CellHeight = 132
            self.msgList.append(msgModel)
            
            self.reloadView()
            self.canAutoShowHint = true
            self.recordView.filename = "\(self.scenarioLesson.Id!)_\(self.currentIndex)"
            self.showNext = false
            self.checkPic = false
        }else {
            self.reloadView()
            self.canAutoShowHint = true
            self.recordView.filename = "\(self.scenarioLesson.Id!)_\(self.currentIndex)"
            self.showNext = false
            self.checkPic = false
        }
        if self.canAutoShowHint {
            self.canAutoShowHint = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.shouldCanRecord = true
                //语音播放完毕之后显示小灯泡
                //如果播放的不是最后一个
                if !self.clickTwo {
                    self.clickTwo = false
                    self.shouldShowHint = true
                }
                self.showBeginnerGuide()
            }
        }
    }

    func presentBeginnerGuide() {
        
        if UserDefaults.standard.integer(forKey: UserDefaultsKeyManager.hintBeginnerGuideRecording) > 0 {
            return
        }
        
        let button = self.hintButton!
        let point = button.superview!.convert(button.frame.origin, to: nil)
        
        
        let showX = point.x - ScreenUtils.heightBySix(y: 5)
        let showY = point.y - ScreenUtils.heightBySix(y: 5)
        let showWidth = button.frame.width + ScreenUtils.heightBySix(y: 10)
        let showHeight = button.frame.width + ScreenUtils.heightBySix(y: 10)
        let showRadius = showWidth / 2
        
        let font = BeginnerGuideView.noticeFont
        
        let noticeText = "During the dialogue section, you can tap this icon for tips to respond."
        
        let textWidth = ScreenUtils.widthByRate(x: 0.6)
        let textX = ScreenUtils.widthByRate(x: 0.3)
        
        let textHeight = noticeText.height(withConstrainedWidth: textWidth, font: font)
        let textY = showY - ScreenUtils.heightByM(y: 20) - textHeight
        let birdY = textY
        let birdX = (ScreenUtils.width*0.25 - BeginnerGuideView.birdWidth) / 2 + ScreenUtils.width*0.05
        let birdPoint = CGPoint(x: birdX, y: birdY)
        let noticeFrame = CGRect(x: textX, y: textY, width: textWidth, height: 1)
        let showFrame = CGRect(x: showX, y: showY, width: showWidth, height: showHeight)
        
        
        let guideView = BeginnerGuideView(frame: UIScreen.main.bounds, birdPoint: birdPoint, noticeText: noticeText, noticeFrame: noticeFrame, showFrame: showFrame, showRadius: showRadius)
        
        guideView.delegate = self
        UIApplication.shared.keyWindow?.addSubview(guideView)
    }
    
    func closeBeginnerGuide() {
        UserDefaults.standard.set(Int(1), forKey: UserDefaultsKeyManager.hintBeginnerGuideRecording)
        UserDefaults.standard.synchronize()
    }
    
    func recordingStart()//开始录音
    {
        let chatData = self.scenarioLesson.ChatTurn![self.currentIndex]
        self.nextButton.isHidden = true
        self.bubbleCanPlayAudio = false

        self.shouldShowHint = false
        
        let newMsgModel = ChatMessageModel(type: .audio, text: "", pinyin: "", imageUrl: "", avatarUrl: self.userAvatar, audioUrl: "", position: .right,textArray:nil)
        newMsgModel.CellHeight = 48
        self.msgList.append(newMsgModel)
        self.reloadView()
        //埋点：结束录音
        let info = ["Scope" : "Scenario","Lessonid" : scenarioId,"IndexPath" : chatData.Question,"Event" : "Recording","Value" : "Start"]
        UserManager.shared.logUserClickInfo(info)
    }
    func recordingAutoCommit()//到时间自动提交
    {
        
    }
    func recordingCancel()//取消录音
    {
        if(self.msgList.count != 0){
            self.msgList.removeLast()
        }
        
        let  model = self.msgList.last
        if model?.type == .tip {
            //说明点了两次
            if (model?.text.string.hasPrefix("These words may help you"))! {
                self.clickTwo = true
                self.shouldShowHint = false
            }else {
                //说明点了一次
                self.clickTwo = false
                self.shouldShowHint = true
            }
        }else {
            //上面的不是tip
            if clickTwo {
                //已经点了两次了
                self.shouldShowHint = false
            }else {
                self.shouldShowHint = true
            }
        }
        self.nextButton.isHidden = !self.showNext
        self.shouldCanRecord = true
        self.reloadView()
    }
    func itemTapMethod(gesture: UITapGestureRecognizer) {
        gesture.view?.removeFromSuperview()
    }
    func recordingSubmit(duration:Double)//提交录音
    {
        let chatData = self.scenarioLesson.ChatTurn![self.currentIndex]
        //埋点：结束录音
        let info = ["Scope" : "Scenario","Lessonid" : scenarioId,"IndexPath" : chatData.Question,"Event" : "Recording","Value" : "Finish"]
        UserManager.shared.logUserClickInfo(info)
        self.shouldCanRecord = false
        
        if(self.msgList.count != 0){
            self.msgList.removeLast()
        }
        let msgModel = ChatMessageModel(audioUrl: DocumentManager.urlFromFilename(filename: "\(self.recordView.filename).m4a").absoluteString, position: .right, score: -1, avatar:self.userAvatar)
        msgModel.CellHeight = 48
        self.msgList.append(msgModel)
        
        self.reloadView()
        if let audioData = try? Data(contentsOf: DocumentManager.urlFromFilename(filename: "\(self.recordView.filename).m4a")) {
            let byteData = [Byte](audioData)
                    let chat = self.scenarioLesson.ChatTurn![self.currentIndex]
                    var keywords = [String]()
                    for word in chat.AnswerOptions![0].HintDetails! {
                        keywords.append(word.Text!)
                    }

                    
                    let speechInput = chatRateInput(text: "", question: chat.Question!, keywords: keywords, expectedAnswer: chat.AnswerOptions![0].Text!, data: byteData, speechMimeType: "audio/amr", sampleRate: RecordManager.sharedInstance.sampleRate, lessonId: self.scenarioLesson.Id!, language: AppData.lang)
                    CourseManager.shared.rateSpeechScenario(speechInput: speechInput){
                        data in
                        if data == nil {
                            self.presentUserToast(message: "Error occured during scoring,please try again.")
                            if(self.msgList.count != 0){
                                self.msgList.removeLast()
                            }
                            self.reloadView()
                            self.shouldCanRecord = true
                            return
                        }
                        let result = data as! ScenarioChatRateResult
                        
                        if result != nil  {
                            
                            let bgView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height/2))
                            bgView.backgroundColor = UIColor.colorFromRGB(0, 0, 0, 0.2)
                            let textView = UITextView(frame: CGRect(x: 00, y: 0, width: ScreenUtils.width, height: ScreenUtils.height/2 - 40))
                            bgView.addSubview(textView)
                            textView.text = String(format: "%@", result.toJSON())
                            textView.font = FontUtil.getFont(size: FontAdjust().FontSize(16), type: .Regular)
                            if(self.msgList.count != 0){
                                self.msgList.removeLast()
                            }
                            let msgModel = ChatMessageModel(audioUrl: DocumentManager.urlFromFilename(filename:
                                "\(self.recordView.filename).m4a").absoluteString, position: .right, score: result.Score!, avatar:self.userAvatar)
                            msgModel.CellHeight = 48
                            self.msgList.append(msgModel)
                            
                            self.reloadView()
                            
                            let waitingMsgModel = ChatMessageModel(type: .audio, text: "", pinyin: "", imageUrl: "", avatarUrl: self.teacherAvatar, audioUrl: "", position: .left,textArray:nil)
                            waitingMsgModel.CellHeight = 48
                            self.msgList.append(waitingMsgModel)
                            self.reloadView()
                            self.recordView.filename = "\(self.scenarioLesson.Id!)_\(self.currentIndex)_\(UUID().uuidString)"
                            self.showNext = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                if(self.msgList.count != 0){
                                    self.msgList.removeLast()
                                }
                                let title = self.getRemarkByScore(score: result.Score!)
                                let msgModel = ChatMessageModel(text: title, position: .left)
                                let textHeight = title.height(withConstrainedWidth: ScreenUtils.width - 70 - 26  - 20, font: FontUtil.getTextFont())
                                let mTextHeight = max(textHeight+15, textHeight + 20)
                                msgModel.CellHeight = Int(mTextHeight)
                                self.msgList.append(msgModel)
                                self.reloadView()
                                
                                if self.hasShowAnswer == false {
                                    self.msgList.append(waitingMsgModel)
                                    self.reloadView()
                                    self.hasShowAnswer = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                        if(self.msgList.count != 0){
                                            self.msgList.removeLast()
                                        }
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {

                                            let answer = self.scenarioLesson.ChatTurn![self.currentIndex].AnswerOptions![0]
                                            var audioUrl = ""
                                            if self.sentenceDict.TextDictionary![answer.Text!] == nil {
                                                
                                            }else {
                                                audioUrl = self.sentenceDict.TextDictionary![answer.Text!]!.AudioUrl!
                                            }
                                            var tokenModelArray = [ChatMessageTokenModel]()
                                            
                                            var pinyin = NSMutableAttributedString()
                                            var chinese = NSMutableAttributedString()
                                            
                                            for token in answer.Tokens! {
                                                pinyin = NSMutableAttributedString(string: "")
                                                chinese = NSMutableAttributedString(string: "")
                                                let tokenModel = ChatMessageTokenModel()
                                                
                                                chinese.append(NSAttributedString(string: token.Text!, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.textBlack])))
                                                //设置拼音
                                                var pinyinStr = NSMutableAttributedString(string: "")
                                                if(token.IPA1 != nil && token.IPA1 != ""){//不是标点或者特殊的符号
                                                    let ipa = token.IPA1!
                                                    if(PinyinFormat(ipa).count == 1){
                                                        pinyinStr = NSMutableAttributedString(string: PinyinFormat(ipa)[0], attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.lightText]))
            //                                            if pinyinStr.string != PinyinFormat(token.IPA)[0] {
            //                                                //存在变调
            //                                                pinyinStr = NSMutableAttributedString(string: PinyinFormat(ipa)[0], attributes: [NSForegroundColorAttributeName : UIColor.hex(hex: "4e80d9")])
            //                                            }
                                                    }else{
                                                        for i in 0...PinyinFormat(ipa).count-1{
            //                                                if PinyinFormat(ipa)[i] != PinyinFormat(token.IPA)[i] {
            //                                                    //存在变调
            //                                                    pinyinStr.append(NSAttributedString(string: PinyinFormat(ipa)[i], attributes: [NSForegroundColorAttributeName : UIColor.hex(hex: "4e80d9")]))
            //                                                }else {
                                                                pinyinStr.append(NSAttributedString(string: PinyinFormat(ipa)[i], attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.lightText])))
            //                                                }
                                                        }
                                                        if pinyinStr.mutableString.hasSuffix(" ") {
                                                            pinyinStr.removeAttribute(convertToNSAttributedStringKey(" "), range: NSRange(location: pinyinStr.length - 1, length: 1))
                                                        }
                                                    }
                                                    pinyin.append(pinyinStr)
                                                    pinyin.append(NSAttributedString(string: " ", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.lightText])))
                                                }
                                                if pinyin.mutableString.hasSuffix(" ") {
                                                    pinyin.removeAttribute(convertToNSAttributedStringKey(" "), range: NSRange(location: pinyin.length - 1, length: 1))
                                                }
                                                tokenModel.text =  chinese
                                                tokenModel.pinyinText =  pinyin
                                                tokenModelArray.append(tokenModel)
                                                
                                            }
                                            let msgResult = ChatMessageModel(type: .audiotext, text: answer.Text!, pinyin: answer.IPA != nil ? PinyinFormat(answer.IPA!).joined(separator: " ") : "", imageUrl: "", avatarUrl: self.teacherAvatar, audioUrl: audioUrl, position: .left, en: answer.nativeText!,textArray:tokenModelArray)

                                            var mTextHeight = CGFloat(0.0)
                                            let en = msgResult.en
                                            let textArray = msgResult.textArray
                                            mTextHeight = 0
                                            var buttonsViewHeight:CGFloat = 43
                                            mTextHeight += buttonsViewHeight
                                            
                                            var cardMaxWidth = AdjustGlobal().CurrentScaleWidth - 70 - 26 - 20
                                            
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
                                            if (self.currentIndex == (self.scenarioLesson.ChatTurn!.count - 1)) && (self.showLast == false)  {
                                                
                                            }
                                            else {
                                                self.nextButton.isHidden = false
                                                self.shouldCanRecord = true
                                                self.reloadView()
                                            }
                                            self.msgList.append(msgResult)
                                            self.reloadView()

                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

                                            if (self.currentIndex == (self.scenarioLesson.ChatTurn!.count - 1)) && (self.showLast == false)  {
                                                self.showLast = true
                                                let msgModel = ChatMessageModel(type: .audio, text: "", pinyin: "", imageUrl: "", avatarUrl: self.teacherAvatar, audioUrl: "", position: .left,textArray:nil)
                                                msgModel.CellHeight = 48
                                                self.msgList.append(msgModel)
                                                self.reloadView()
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                    if(self.msgList.count != 0){
                                                        self.msgList.removeLast()
                                                    }
                                                    let title = "You have answered all the questions!"
                                                    let msgModel = ChatMessageModel(text: title,position: .left, avatar: self.teacherAvatar)
                                                    let textHeight = title.height(withConstrainedWidth: ScreenUtils.width - 70 - 26  - 20, font: FontUtil.getTextFont())
                                                    let mTextHeight = max(textHeight+15, textHeight + 20)
                                                    msgModel.CellHeight = Int(mTextHeight)
                                                    self.msgList.append(msgModel)
                                                    self.nextButton.isHidden = false
                                                    self.shouldCanRecord = true
                                                    self.reloadView()
                                                }
                                            }
                                            }

                                        }

                                    }
                                }
                                else {
                                    self.nextButton.isHidden = false
                                    self.shouldCanRecord = true
                                }

                            }
                            if(UIApplication.topViewController()?.isKind(of: ChatScenarioViewController.self))!{
                                //去掉经验值
            //                    ExpAnimationView.show(LessonRepeatViewController.getExpType(result.Score!))
                                self.audioPlayer = AVPlayer(url: ChBundleAudioUtil.successful.url)
                                self.audioPlayer.play()
                            }
                        }
                        else {
                            self.presentUserToast(message: "Error occured during scoring,please try again.")
                            if(self.msgList.count != 0){
                                self.msgList.removeLast()
                            }
                            self.reloadView()
                            self.shouldCanRecord = true
                        }
                    }
        }else {
            self.presentUserToast(message: "Error occured during scoring,please try again.")
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
fileprivate func convertToNSAttributedStringKey(_ input: String) -> NSAttributedString.Key {
	return NSAttributedString.Key(rawValue: input)
}
