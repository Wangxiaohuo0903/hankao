//
//  ChanllenViewController
//  PracticeChinese
//
//  Created by 费跃 on 10/12/17.
//  Copyright © 2017 msra. All rights reserved.
//


import Foundation
import UIKit
import AVFoundation


class ChanllenViewController: BaseChatViewController  {
    func cancleLoading() {
        closeTapped()
    }
    var unlock: Bool = false//是否具有解锁功能
    var sentenceDict: VideoSentenceDictionary!
    var checkButton: UIButton!
    var totalScore: Int = 0
    let beginnerGuideKeys = [UserDefaultsKeyManager.readBeginnerGuideRecording, UserDefaultsKeyManager.hintBeginnerGuideRecording]
    var currentBeginnerGuideKeyIndex = 0
    var canAutoShowHint: Bool = false
    var courseId: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        logId = courseId
        Scope = "ConversationChallenge"
        Subscope = "Test"
        
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
        //设置回退按钮为白色
        self.navigationController?.navigationBar.tintColor = UIColor.textBlack333
        self.navigationItem.hidesBackButton = true
        recordView.delegate = self
        let xframe = recordView.frame
        let space: CGFloat = 6
        let buttonHeight = xframe.height - space * 2
        let buttonX: CGFloat = xframe.width/2 - buttonHeight / 2
        let buttonY = xframe.height / 2 - buttonHeight / 2

        checkButton = UIButton(frame:CGRect(x: buttonX, y: buttonY, width: buttonHeight, height: buttonHeight))
        checkButton.setImage(ChImageAssets.CheckIcon.image, for: .normal)
        checkButton.addTarget(self, action: #selector(checkResult), for: .touchUpInside)
        recordView.addSubview(checkButton)
        checkButton.isHidden = true
        
        if self.scenarioLesson.ChatTurn!.count > 0 {
            let chat = self.scenarioLesson.ChatTurn![0]
            self.teacherAvatar = chat.ChaUrl == nil ? "" : chat.ChaUrl!
            self.userAvatar = chat.AnswerOptions![0].ChaUrl != nil ? chat.AnswerOptions![0].ChaUrl! : ""
            indexPathStr = chat.Question!
        }
        
        self.nextButton.isHidden = true
                
        showQuiz()
    }
    
    @objc func checkResult() {
        self.backButton.removeFromSuperview()
        let vc = ChallengeResultViewController()
        var count = self.scenarioLesson.ChatTurn!.count
        vc.id = self.scenarioLesson.Id!
        vc.unlock = self.unlock
        if count == 0 {
            count += 1
        }
        vc.score = totalScore / count;
        if(AppData.userAssessmentEnabled && UserManager.shared.isLoggedIn()){
            //埋点：点击Check并记录最终得分
            let chat = self.scenarioLesson.ChatTurn![self.currentIndex]
            let info = ["Scope" : "ConversationChallenge","Lessonid" : self.courseId,"Subscope" : "Test","IndexPath" : chat.Question,"Event" : "CheckAverage","Value" : String(totalScore / count)]
            UserManager.shared.logUserClickInfo(info)
        }
        self.ch_pushViewController(vc, animated: true)
    }
    
    override func clickNext() {
        ToastAlertView.hide()
//        ExpAnimationView.quit()
        if self.currentIndex == (self.scenarioLesson.ChatTurn?.count)! - 1 {
            checkResult()
            checkButton.isHidden = false
        }
        else {
            self.currentIndex += 1
            showQuiz()
        }
    }
    
    func showQuiz() {
        if self.scenarioLesson.ChatTurn!.count == 0 {
            return 
        }
        //默认不显示小灯泡，可录音状态
        self.shouldCanRecord = false
        self.bubbleCanPlayAudio = true
        let chat = self.scenarioLesson.ChatTurn![self.currentIndex]
        var audioUrl = ""
        if self.sentenceDict.TextDictionary![chat.Question!] == nil {
            
        }else {
            audioUrl = self.sentenceDict.TextDictionary![chat.Question!]!.AudioUrl!
        }
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
                }else{
                    for i in 0...PinyinFormat(ipa).count-1{
                        pinyinStr.append(NSAttributedString(string: PinyinFormat(ipa)[i], attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.lightText])))
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
        
        let msgModel = ChatMessageModel(type: .audiotext, text: "", pinyin: "", imageUrl: "", avatarUrl:self.teacherAvatar, audioUrl: audioUrl, position: .left, en: chat.NativeQuestion!, index: "\(self.currentIndex+1)/\(self.scenarioLesson.ChatTurn!.count)",textArray:tokenModelArray)
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
        //是否能弹出提示，默认是
        self.canAutoShowHint = true
        self.recordView.filename = "\(self.scenarioLesson.Id!)_\(self.currentIndex)_\(UUID().uuidString)"
        
        indexPathStr = chat.Question!
    }
    
    override func showHints() {
        let answer = self.scenarioLesson.ChatTurn![self.currentIndex].AnswerOptions![0]
        //attention 换行
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
        self.shouldShowHint = false
        //埋点：点击查看提示
        let info = ["Scope" : "ConversationChallenge","Lessonid" : self.courseId,"Subscope" : "Test","IndexPath" : indexPathStr,"Event" : "Prompt","Value" : 1] as [String : Any]
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

extension ChanllenViewController: LCRecordingViewDelegate, BeginnerGuideCloseDelegate {
    override func buttonPlayStop() {
        //语音播放完毕之后，canAutoShowHint 为true说明已经提示
        if LCVoiceButton.singlePlayer.playerPlaying {
            return
        }
        
        if self.canAutoShowHint {
            //canAutoShowHint 为false说明可以点击小灯泡
            self.canAutoShowHint = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let chat = self.scenarioLesson.ChatTurn![self.currentIndex]
                let answer = chat.AnswerOptions![0]
                let hintText1 = "Here you can say:\n \(answer.nativeText!)"
                let mTextHeight = hintText1.height(withConstrainedWidth: ScreenUtils.width - 30, font: FontUtil.getTextFont()) + 10
                let msgModel = ChatMessageModel(type: .tip, text: hintText1, pinyin: "", imageUrl: "", avatarUrl: "", audioUrl: "", position: .left,textArray:nil)
                msgModel.CellHeight = Int(mTextHeight)
                self.msgList.append(msgModel)
                self.reloadView()
                //　小灯泡可点
                self.shouldCanRecord = true
                self.shouldShowHint = true
                self.showBeginnerGuide()
            }
            
        }
    }
    
    func presentBeginnerGuide() {
        
         while self.currentBeginnerGuideKeyIndex < beginnerGuideKeys.count && UserDefaults.standard.integer(forKey: beginnerGuideKeys[self.currentBeginnerGuideKeyIndex]) > 0 {
            self.currentBeginnerGuideKeyIndex += 1
         }
         if self.currentBeginnerGuideKeyIndex >= beginnerGuideKeys.count {
             return
         }
 
        if self.currentBeginnerGuideKeyIndex == 0 {
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
            
            let textHeight = noticeText.height(withConstrainedWidth: textWidth, font: font)
            let textY = showY - ScreenUtils.heightByM(y: 20) - textHeight
            
            let birdY = textY - 10
            let birdX = (ScreenUtils.width*0.25 - BeginnerGuideView.birdWidth) / 2 + ScreenUtils.width*0.1
            var offsety:CGFloat = 0
            if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
                offsety = self.ch_getNavigationBarHeight()
            }
            let birdPoint = CGPoint(x: birdX, y: birdY+offsety)
            let noticeFrame = CGRect(x: textX, y: textY+offsety, width: textWidth, height: 1)
            let showFrame = CGRect(x: showX, y: showY+offsety, width: showWidth, height: showHeight)
            
            
            let guideView = BeginnerGuideView(frame: UIScreen.main.bounds, birdPoint: birdPoint, noticeText: noticeText, noticeFrame: noticeFrame, showFrame: showFrame, showRadius: showRadius)
            
            guideView.delegate = self
            UIApplication.shared.keyWindow?.addSubview(guideView)
        }
        if  self.currentBeginnerGuideKeyIndex == 1 {

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
    }
    
    func closeBeginnerGuide() {
        UserDefaults.standard.set(Int(1), forKey: self.beginnerGuideKeys[self.currentBeginnerGuideKeyIndex])
        UserDefaults.standard.synchronize()
        if self.currentBeginnerGuideKeyIndex < self.beginnerGuideKeys.count {
            presentBeginnerGuide()
        }
    }
    
    
    func recordingStart()//开始录音
    {
        let chat = self.scenarioLesson.ChatTurn![self.currentIndex]
        self.shouldShowHint = false
        self.bubbleCanPlayAudio = false

        let newMsgModel = ChatMessageModel(type: .audio, text: "", pinyin: "", imageUrl: "", avatarUrl: self.userAvatar, audioUrl: "", position: .right,textArray:nil)
        newMsgModel.CellHeight = 48
        self.msgList.append(newMsgModel)
        self.reloadView()
        //埋点：开始录音
        let info = ["Scope" : "ConversationChallenge","Lessonid" : self.courseId,"Subscope" : "Test","IndexPath" : chat.Question,"Event" : "Recording","Value" : "Start"]
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
        
        let  model = self.msgList.last as? ChatMessageModel
        if model?.type == .tip {
            if (model?.text.string.hasPrefix("These words may help you"))! {
                self.shouldShowHint = false
            }
            if (model?.text.string.hasPrefix("Here you can say"))! {
                self.shouldShowHint = true
            }
        }
        
        self.reloadView()
    }
    func recordingSubmit(duration:Double)//提交录音
    {
        let chatData = self.scenarioLesson.ChatTurn![self.currentIndex]
        //埋点：结束录音
        let info = ["Scope" : "ConversationChallenge","Lessonid" : self.courseId,"Subscope" : "Test","IndexPath" : chatData.Question,"Event" : "Recording","Value" : "Finish"]
        UserManager.shared.logUserClickInfo(info)
        self.shouldCanRecord = false
        
        if(self.msgList.count != 0){
            self.msgList.removeLast()
        }
        let msgModel = ChatMessageModel(audioUrl: DocumentManager.urlFromFilename(filename: "\(self.recordView.filename).m4a").absoluteString, position: .right, score: -1, avatar: self.userAvatar)
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
                    let speechInput = chatRateInput(question: chat.Question!, keywords: keywords, expectedAnswer: chat.AnswerOptions![0].Text!, data: byteData, speechMimeType: "audio/amr", sampleRate: RecordManager.sharedInstance.sampleRate, lessonId: self.scenarioLesson.Id!, language: AppData.lang)
                    
                    CourseManager.shared.rateSpeechScenario(speechInput: speechInput){
                        data in
                        
                        if data == nil {
                            //若不判断，有可能会崩溃
                            self.presentUserToast(message: "Error occured during scoring")
                            if(self.msgList.count != 0){
                                self.msgList.removeLast()
                            }
                            self.reloadView()
                            self.shouldCanRecord = true
                            return
                        }
                        let result = data as! ScenarioChatRateResult
                        if result != nil {

                            if(self.msgList.count != 0){
                                self.msgList.removeLast()
                            }
                            let msgModel = ChatMessageModel(audioUrl: DocumentManager.urlFromFilename(filename:
                                "\(self.recordView.filename).m4a").absoluteString, position: .right, score: result.Score!, avatar:self.userAvatar)
                            msgModel.CellHeight = 48
                            self.msgList.append(msgModel)
                            
                            self.totalScore += result.Score!
                            self.bubbleCanPlayAudio = false
                            self.reloadView()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.clickNext()
                            }
                            if(UIApplication.topViewController()?.isKind(of: ChanllenViewController.self))!{
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

class ChallengeIntroViewController: UIViewController,ChActivityViewCancleDelegate ,NetworkRequestFailedLoadDelegate {
    func reloadData() {
        loadData()
    }
    //加载失败的返回
    func backClick() {
       closeTapped()
    }
    var sentenceDict: VideoSentenceDictionary!
    var scenarioLesson: ScenarioLesson!
    var courseId: String = ""
    var unlock: Bool = false//是否具有解锁功能
    var teacherAvatar: String = ""
    var userAvatar:String = ""
    var introText:String = "" {
        didSet {
            setupContent()
        }
    }
    var backButton:UIButton!
    
    var leftAvatar: UIImageView!
    var rightAvatar: UIImageView!
    var titleLabel: UILabel!
    var introLabel: UILabel!
    var startButton: UIButton!
    
    var willAppear = false
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override var prefersStatusBarHidden: Bool {
        return willAppear
    }
    

    override func viewDidLoad() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.fromColor(color: UIColor.white), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        let navFrame = self.navigationController?.navigationBar.frame
        self.navigationController?.navigationBar.frame = CGRect(x: navFrame!.minX, y: 0, width: navFrame!.width, height: ScreenUtils.heightBySix(y: 100))
        var top = FontAdjust().quitButtonTop()
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
            top = self.ch_getStatusBarHeight()
        }
        backButton = UIButton(frame: CGRect(x: FontAdjust().quitButtonTop(), y: top, width: 40, height: 40))
        backButton.setImage(ChImageAssets.CloseIcon.image, for: .normal)
        backButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        self.navigationController?.view.addSubview(backButton)
        loadData()
    }
    func loadData() {
        ChActivityView.shared.delegate = self
        ChActivityView.show(.CancleFullScreen, UIApplication.shared.keyWindow!, UIColor.loadingBgColor, ActivityViewText.HomePageLoading,UIColor.loadingTextColor,UIColor.gray)
        CourseManager.shared.getScenarioLessonInfo(id: courseId) {
            (lesson,error) in
            ChActivityView.hide()
            if lesson == nil {
//                self.presentUserToast(message: "Load lesson error.")
                if let requestError = error {
                    
                    var networkErrorText = NetworkRequestFailedText.DataError
                    if requestError.localizedDescription.hasPrefix("The request timed out.")
                    {
                        networkErrorText = NetworkRequestFailedText.NetworkTimeout
                        
                    }else if requestError.localizedDescription.hasPrefix("The Internet connection appears to be offline.") {
                        networkErrorText = NetworkRequestFailedText.NetworkError
                    }
                    let alertView = AlertNetworkRequestFailedView.init(frame: CGRect(x: 0, y: 60, width: ScreenUtils.width, height: ScreenUtils.height - 60))
                    alertView.delegate = self
                    alertView.show(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height),superView:self.navigationController!.view,alertText:networkErrorText,textColor:UIColor.loadingTextColor,bgColor: UIColor.loadingBgColor,showHidenButton: true)
                }
                return
            }
            
            self.scenarioLesson = lesson!.ScenarioLesson
            self.sentenceDict = lesson!.VideoSentenceDictionary
            if self.scenarioLesson.ChatTurn!.count > 0 {
                var chat = self.scenarioLesson.ChatTurn![0]
                self.teacherAvatar = chat.ChaUrl == nil ? "" : chat.ChaUrl!
                self.userAvatar = chat.AnswerOptions![0].ChaUrl != nil ? chat.AnswerOptions![0].ChaUrl! : ""
            }
            if let introduction = self.scenarioLesson.Introducation?.Text {
                self.introText = introduction
            }
            else {
                self.introText = "This is a challenge lesson. Wish you good luck :)"
            }
            
            self.setupContent()
            self.analytics()
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
    func cancleLoading() {
        closeTapped()
    }
    @objc func closeTapped() {
        self.backButton.removeFromSuperview()
        self.navigationController?.dismiss(animated: true, completion: nil )
//        ExpAnimationView.quit()
        ToastAlertView.hide()
    }
    func setupContent() {
        view.backgroundColor = UIColor.white
        
        let titleFont = FontUtil.getFont(size: 20, type: .Medium)
        titleLabel = UILabel(frame: CGRect(x: ScreenUtils.widthByRate(x: 0.1), y: ScreenUtils.height / 7, width: ScreenUtils.widthByRate(x: 0.8), height: 30))
        titleLabel.text = "Conversation Challenge"
        titleLabel.textColor = UIColor.textBlack333
        titleLabel.font = titleFont
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        leftAvatar = UIImageView(frame: CGRect(x: ScreenUtils.widthByRate(x: 0.167), y: titleLabel.frame.maxY + 76, width: ScreenUtils.widthByRate(x: 0.25), height: ScreenUtils.widthByRate(x: 0.25)))
        leftAvatar.layer.cornerRadius = ScreenUtils.widthByRate(x: 0.125 )
        leftAvatar.layer.masksToBounds = true
        leftAvatar.sd_setImage(with: URL(string: teacherAvatar), placeholderImage: UIImage.fromColor(color: UIColor.placeholderImageColor), options: .refreshCached, completed: nil)
        
        rightAvatar = UIImageView(frame: CGRect(x: ScreenUtils.widthByRate(x: 0.583), y: titleLabel.frame.maxY + 76, width: ScreenUtils.widthByRate(x: 0.25), height: ScreenUtils.widthByRate(x: 0.25)))
        rightAvatar.layer.cornerRadius = ScreenUtils.widthByRate(x: 0.125)
        rightAvatar.layer.masksToBounds = true
        rightAvatar.sd_setImage(with: URL(string: userAvatar), placeholderImage: UIImage.fromColor(color: UIColor.placeholderImageColor), options: .refreshCached, completed: nil)
        
        let introFont = FontUtil.getFont(size: 16, type: .Regular)
        introLabel = UILabel(frame: CGRect(x: ScreenUtils.widthByRate(x: 0.1), y: leftAvatar.frame.maxY + 44, width: ScreenUtils.widthByRate(x: 0.8), height: introText.height(withConstrainedWidth: ScreenUtils.widthByRate(x: 0.8), font: introFont)))
        introLabel.text = introText
        introLabel.textColor = UIColor.textGray
        introLabel.font = introFont
        introLabel.numberOfLines = 0
        introLabel.textAlignment = .center
        
        view.addSubview(titleLabel)
        view.addSubview(leftAvatar)
        view.addSubview(rightAvatar)
        view.addSubview(introLabel)


        startButton = UIButton(frame:CGRect(x: (ScreenUtils.width - 150)/2, y: ScreenUtils.height - 42 - 45 - self.ch_getNavigationBarHeight() - self.ch_getStatusBarHeight(), width: 150, height: 45))
        startButton.titleLabel?.font = FontUtil.getTitleFont()
        startButton.setTitle("Start", for: .normal)
        startButton.setTitleColor(UIColor.white, for: .normal)
        startButton.setBackgroundImage(UIImage.fromColor(color: UIColor.blueTheme), for: .normal)
        startButton.layer.cornerRadius = 22.5
        startButton.layer.masksToBounds = true
        startButton.addTarget(self, action: #selector(startConversation), for: .touchUpInside)
        view.addSubview(startButton)
    }
    
    @objc func startConversation() {
        self.backButton.removeFromSuperview()
        //埋点：点击Start
        let info = ["Scope" : "ConversationChallenge","Lessonid" : self.courseId,"Subscope" : "IntroPage","Event" : "Start"]
        UserManager.shared.logUserClickInfo(info)
        
        let vc = ChanllenViewController()
        vc.scenarioLesson = self.scenarioLesson
        vc.sentenceDict = self.sentenceDict
        vc.unlock = self.unlock
        vc.courseId = self.courseId
        self.ch_pushViewController(vc, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //hide status bar
        self.navigationController?.view.addSubview(backButton)
        willAppear = true
        UIView.animate(withDuration: 0.2) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
        
    }
    //无网络提示
    func showNetworkFailedRequestView() {
        let alertView = AlertNetworkRequestFailedView.init(frame: CGRect(x: 0, y: 60, width: ScreenUtils.width, height: ScreenUtils.height - 60))
        alertView.delegate = self
        alertView.show(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height),superView:self.navigationController!.view,alertText:NetworkRequestFailedText.NetworkError,textColor:UIColor.loadingTextColor,bgColor: UIColor.loadingBgColor,showHidenButton: true)
        ChActivityView.hide()
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
