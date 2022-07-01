//
//  PractiseTurnViewController
//  PracticeChinese
//
//  Created by 费跃 on 10/12/17.
//  Copyright © 2017 msra. All rights reserved.
//


import Foundation
import UIKit
import AVFoundation


class PractiseTurnViewController: BasePrictiseChatTurnViewController  {
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
    var scenarioLessonTurnArray = [ChatTurn]()
    //收集所有语音，在summary展示
    var summaryLessonArray = [PractiseMessageModel]()
    //需要加强的单词
    var hintTurnArray = [HintDetail]()
    var quizCount = 0
    //没有answer,最后一个不成对
    var nullAnswer: Bool = false
    //是不是改跳转了
    var chatNum: Int = 0
    
    //进度条
    var progressView = CustomViewProgressView()
    //slideView
    var sliderView = CustomSlider()
    //进度
    var progress = Progress()
    //故事背景，标题
    var titleLabel: UILabel!
    var titleText: String = ""
    var backButton: UIButton!
    
    var progressNum = 0
    //0表示用户作为回答问题的一方，1表示用户作为提问的一方
    var TurnType = 0
    var refreshLand = true
    //防止多次跳转
    var pushed = false
    //分数回调
    var finishPratise: ((Int) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentIndex = 0
        
        progress = Progress.discreteProgress(totalUnitCount: 4)
        progress.addObserver(self, forKeyPath: "fractionCompleted", options: [.new, .old], context: nil)
        var statusHeight:CGFloat = 0
        if AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax {
            statusHeight = 34
        }
        progressView.frame = CGRect(x: 0, y: statusHeight, width: ScreenUtils.width, height: 10)
        progressView.backgroundColor = UIColor.white
        progressView.progressTintColor = UIColor.hex(hex: "4E80D9")
        progressView.transform = CGAffineTransform(scaleX: 1.0, y: 3.5)
        progressView.progressViewStyle = .default
        progressView.trackTintColor = UIColor.white
        progressView.progress = Float(progressNum) / Float(quizCount)
        self.navigationController?.view.addSubview(self.progressView)
        
        let introFont = FontUtil.getFont(size: 14, type: .Regular)
        if TurnType == 0 {
            self.titleText = (self.scenarioLesson.Summary?.Text)!
        }else {
            self.titleText = (self.scenarioLesson.Summary?.NativeText)!
        }
        titleLabel = UILabel(frame:  CGRect(x: 60, y: statusHeight + 10, width: ScreenUtils.width - 120, height: self.titleText.height(withConstrainedWidth: ScreenUtils.width - 120, font: introFont)))
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor.hex(hex: "4E80D9")
        titleLabel.text = self.scenarioLesson.Summary?.NativeText
        titleLabel.font = introFont
        titleLabel.textAlignment = .center
        
        backButton = UIButton(frame: CGRect(x: FontAdjust().quitButtonTop(), y: statusHeight, width: 40, height: 40))
        backButton.setImage(ChImageAssets.CloseIcon.image, for: .normal)
        backButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        self.navigationController?.view.addSubview(titleLabel)
        self.navigationController?.view.addSubview(backButton)
        
        logId = courseId
        Scope = "Practise"
        Subscope = "Test"
        
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
        
        if self.scenarioLessonTurnArray.count > 0 {
            let chat = self.scenarioLessonTurnArray[0]
            self.teacherAvatar = chat.ChaUrl == nil ? "" : chat.ChaUrl!
            self.userAvatar = chat.AnswerOptions![0].ChaUrl != nil ? chat.AnswerOptions![0].ChaUrl! : ""
            indexPathStr = chat.Question!
        }
        
        self.nextButton.isHidden = true
        //默认先不播放语音
        self.bubbleCanPlayAudio = false
        //开始就判断是不是成对的
        let chat = self.scenarioLessonTurnArray.last
        //如果答案是空说明不成对，成对打分完成后跳转，不成对，语音播放完后跳转
        if chat?.Tokens!.count == 0{
            //不成对，左边少一个回复，这种情况是打完分再跳转
            nullAnswer = true
        }else {
            //读完语音跳转
            nullAnswer = false
        }
        self.recordView.filename = "\(self.scenarioLesson.Id!)_\(progressNum)_\(UUID().uuidString)"
        CWLog(self.recordView.filename)
        addAnswer()
        showQuiz()
    }
    
    @objc func checkResult() {
        if pushed == false {
            pushed = true
        }else {
            //已经跳转过了
            return
        }
        let vc = PractiseSummaryViewController.init(nibName: "PractiseSummaryViewController", bundle: Bundle.main)
        vc.refreshLand = self.refreshLand
        vc.Id = self.scenarioLesson.Id!
        vc.score = totalScore / quizCount;
        vc.hintTurnArray = self.hintTurnArray
        vc.summaryLessonArray = self.summaryLessonArray
        vc.finishPratise = { score in
            //做完学以致用
            self.finishPratise?(score)
        }
        self.progressView.removeFromSuperview()
        self.titleLabel.removeFromSuperview()
        self.backButton.removeFromSuperview()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.fromColor(color: UIColor.clear), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.ch_pushViewController(vc, animated: true)
    }

    //左边回复
    func showQuiz() {
        showMask = true
        if self.scenarioLessonTurnArray.count == 0 {
            return 
        }
        if self.currentIndex >= self.scenarioLessonTurnArray.count  {
            //没了，跳到结果页面
            return
        }
        let chat = self.scenarioLessonTurnArray[self.currentIndex]
        //有右边，没左边
        if (chat.Tokens?.count == 0 || chat.Tokens == nil) && chat.AnswerOptions?.count != 0 {
            //只有回复，没有提问的话，打分完成后跳转结果页面
            self.showMask = false
            self.reloadView()
            return
        }
        chatNum += 1
        //默认不显示小灯泡，可录音状态
        self.shouldCanRecord = true
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
            if(token.IPA != nil && token.IPA != ""){//不是标点或者特殊的符号
                let ipa = token.IPA!
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
        //语音暂时没有
        if let audioUrl = self.sentenceDict.TextDictionary?[chat.Question!]?.AudioUrl {
            for chatTurn in summaryLessonArray {
                if chatTurn.question == chat.Question {
                    chatTurn.audioUrl = audioUrl
                }
            }
            chat.AudioUrl = audioUrl
            var english = chat.NativeQuestion
            if chat.NativeQuestion == "" {
                english = chat.Displayquestion
            }
            self.msgList.append(ChatMessageModel(type: .audiotext, text: "", pinyin: "", imageUrl: "", avatarUrl:chat.ChaUrl, audioUrl: audioUrl, position: .left, en: english!, index: "\(self.currentIndex)/\(self.scenarioLessonTurnArray.count)",textArray:tokenModelArray))
        }else {
            let audioUrl = "https://mtutordev.blob.core.chinacloudapi.cn/system-audio/lesson/zh-CN/zh-CN/0342b5aff1e19bfaaa604e265278e317.mp3"
            for chatTurn in summaryLessonArray {
                if chatTurn.question == chat.Question {
                    chatTurn.audioUrl = audioUrl
                }
            }
            chat.AudioUrl = audioUrl
            var english = chat.NativeQuestion
            if chat.NativeQuestion == "" {
                english = chat.Displayquestion
            }
            self.msgList.append(ChatMessageModel(type: .audiotext, text: "", pinyin: "", imageUrl: "", avatarUrl:chat.ChaUrl, audioUrl: audioUrl, position: .left, en: english!, index: "\(self.currentIndex)/\(self.scenarioLessonTurnArray.count)",textArray:tokenModelArray))
        }
        indexPathStr = chat.Question!
        self.reloadView()
    }
    
    func addAnswer() {
        if self.currentIndex >= self.scenarioLessonTurnArray.count {
            self.reloadView()
            return
        }
        let chat = self.scenarioLessonTurnArray[self.currentIndex]
        chatNum += 1
        let answer = chat.AnswerOptions![0]
        //是否能弹出提示，默认是
        showMask = true
        self.msgList.append(ChatMessageModel(type: .audiotext, text: "", pinyin: "", imageUrl: "", avatarUrl:UserManager.shared.getAvatarUrl()?.absoluteString, audioUrl: "", position: .right, en: answer.nativeText!, index: "\(self.currentIndex+1)/\(self.scenarioLessonTurnArray.count)",textArray:nil))
        self.reloadView()
    }
    
    
    override func showHints() {

    }
    override func showBeginnerGuide() {
        if(!self.quitIsPresent){
//            self.presentBeginnerGuide()
        }
    }
    
    override func closeCancelEvent() {
//        self.presentBeginnerGuide()
    }

}

extension PractiseTurnViewController: LCRecordingViewDelegate, BeginnerGuideCloseDelegate {
    override func buttonPlayStop() {
        CWLog("播放完毕")
        if !nullAnswer {
            //成对的，
            if chatNum == self.scenarioLessonTurnArray.count * 2 {
                checkResult()
                self.recordView.startButton.isHidden = true
                checkButton.isHidden = false
                return
            }
        }

        //语音播放完毕之后，
        self.bubbleCanPlayAudio = false
        self.shouldCanRecord = true
        self.showMask = false
        //读完语音先减掉一个左侧的
            if(self.msgList.count != 0){
                self.msgList.removeFirst()
                let indexSet = IndexSet(arrayLiteral: 0)
                self.tableView.deleteSections(indexSet, with: .fade)
            }
            self.showQuiz()

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
            let showY = self.recordView.frame.minY  + CGFloat(6)
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
//            presentBeginnerGuide()
        }
    }
    
    
    func recordingStart()//开始录音
    {

        
    }
    func recordingAutoCommit()//到时间自动提交
    {

    }
    func recordingCancel()//取消录音
    {

    }
    func recordingSubmit(duration:Double)//提交录音
    {
        //不可再录音
        self.shouldCanRecord = false

        let chatData : ChatTurn?
        if self.currentIndex >= self.scenarioLessonTurnArray.count {
            chatData = self.scenarioLessonTurnArray.first
        }else {
            chatData = self.scenarioLessonTurnArray[self.currentIndex]
        }
        if chatData == nil {
            return
        }
        chatData?.userAudioUrl = DocumentManager.urlFromFilename(filename: "\(self.recordView.filename).m4a")

        self.makingScore = true
        self.reloadView()
        let audioData = try! Data(contentsOf: DocumentManager.urlFromFilename(filename: "\(self.recordView.filename).m4a"))
        let byteData = [Byte](audioData)
        let chat = chatData!
        var keywords = [String]()
        for word in chat.AnswerOptions![0].HintDetails! {
            keywords.append(word.Text!)
        }
        if keywords.count == 0 {
            let a = chat.Tokens!
            let result = a.sorted { (token1, token2) -> Bool  in
                return token1.DifficultyLevel! > token2.DifficultyLevel!
            }
            for (i,token) in result.enumerated() {
                if i < 3 {
                    keywords.append(token.Text!)
                }
            }
        }
        if keywords.count == 0 {
            keywords.append(chat.AnswerOptions![0].Text!)
        }
        self.bubbleCanPlayAudio = false
        let speechInput = chatRateInput(question: chat.Question!, keywords: keywords, expectedAnswer: chat.AnswerOptions![0].Text!, data: byteData, speechMimeType: "audio/amr", sampleRate: RecordManager.sharedInstance.sampleRate, lessonId: self.scenarioLesson.Id!, language: AppData.lang)
        CourseManager.shared.rateSpeechScenario(speechInput: speechInput){
            data in
            if data == nil {
                //若不判断，有可能会崩溃
//                self.chatNum -= 1
                self.presentUserToast(message: "Error occured during scoring")
                self.bubbleCanPlayAudio = false
                self.shouldCanRecord = true
                self.makingScore = false
                self.reloadView()
                return
            }
            //打分完成
            let result = data as? ScenarioChatRateResult
            self.currentScore = Double(result!.Score!)
            self.makingScore = false
            self.scoreResult = true
            self.reloadView()
            
            if result != nil {
                //需要加强的单词
                if (result?.Score!)! < 60
                {
                    for detail in (chatData?.AnswerOptions![0].HintDetails!)! {
                        var contains = false
                        for hint in self.hintTurnArray {
                            if detail.Text ==  hint.Text {
                                contains = true
                                break
                            }
                        }
                        if contains == false {
                            self.hintTurnArray.append(detail)
                        }
                    }
                    
                }
                
                for chatTurn in self.summaryLessonArray {
                    if chatData?.AnswerOptions![0].Text == chatTurn.question {
                        chatTurn.userAudioUrl = DocumentManager.urlFromFilename(filename: "\(self.recordView.filename).m4a") as NSURL
                        chatTurn.score = result!.Score!
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if self.nullAnswer {
                        //成对的，
                        if self.chatNum == self.scenarioLessonTurnArray.count * 2 - 1 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.checkResult()
                                self.recordView.startButton.isHidden = true
                                self.checkButton.isHidden = false
                            }
                            return
                        }else {
                            //打分完成后停留1秒
                            if(self.msgList.count != 0){
                                self.msgList.removeFirst()
                                let indexSet = IndexSet(arrayLiteral: 0)
                                self.tableView.deleteSections(indexSet, with: .fade)
                            }
                            self.progressNum += 1
                            self.progressView.progress = Float(self.progressNum)/Float(self.quizCount)
                            self.scoreResult = false
                            self.bubbleCanPlayAudio = true
                            self.currentIndex += 1
                            self.showMask = false
                            self.addAnswer()
                        }
                    }else {
                        //打分完成后停留1秒
                        if(self.msgList.count != 0){
                            self.msgList.removeFirst()
                            let indexSet = IndexSet(arrayLiteral: 0)
                            self.tableView.deleteSections(indexSet, with: .fade)
                        }
                        self.progressNum += 1
                        self.progressView.progress = Float(self.progressNum)/Float(self.quizCount)
                        self.makingScore = false
                        self.scoreResult = false
                        self.showMask = false
                        self.bubbleCanPlayAudio = true
                        self.currentIndex += 1
                        self.addAnswer()
                    }
                    self.recordView.filename = "\(self.scenarioLesson.Id!)_\(self.progressNum)_\(UUID().uuidString)"
                    CWLog(self.recordView.filename)
                }
                self.totalScore += result!.Score!
                if(UIApplication.topViewController()?.isKind(of: PractiseTurnViewController.self))!{
                    if result!.Score! < 60 {
                        self.audioPlayer = AVPlayer(url: ChBundleAudioUtil.successquizWrong.url)
                        self.audioPlayer.play()
                        return
                    }else {
                        self.audioPlayer = AVPlayer(url: ChBundleAudioUtil.successquizRight.url)
                        self.audioPlayer.play()
                    }
                }
            }
            else {
//                self.chatNum -= 1
                self.presentUserToast(message: "Error occured during scoring")
                self.bubbleCanPlayAudio = false
                self.shouldCanRecord = true
                self.makingScore = false
                self.reloadView()
            }
        }
        
    }
    
}

class PractiseIntroTurnViewController: UIViewController,ChActivityViewCancleDelegate ,NetworkRequestFailedLoadDelegate {
    func reloadData() {
        loadData()
    }
    //加载失败的返回
    func backClick() {
       closeTapped()
    }
    var refreshLand = true
    var sentenceDict: VideoSentenceDictionary!
    var scenarioLesson: ScenarioLesson!
    var scenarioLessonTurnArray = [ChatTurn]()
    //收集所有语音，在summary展示
    var summaryLessonArray = [PractiseMessageModel]()
    //需要加强的单词
    var hintTurnArray = [HintDetail]()
    var courseId: String = ""
    var unlock: Bool = false//是否具有解锁功能
    var totalScore: Int = 0
    var quizCount = 0
    //0表示用户作为回答问题的一方，1表示用户作为提问的一方
    var TurnType = 0
    
    var introTextChinese:String = ""
    var introTextEnglish:String = ""

    var bgImageView: UIImageView!
    var blueMastar: UIView!
    var storybackgroundC: UILabel!
    var storybackgroundE: UILabel!
    var introChinese: UILabel!
    var introEnglish: UILabel!
    var changeChinese: UILabel!
    var changeEnglish: UILabel!
    
    var startButton: UIButton!
    var progressNum = 0
    var willAppear = false
    //分数回调
    var finishPratise: ((Int) -> Void)?
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override var prefersStatusBarHidden: Bool {
        return willAppear
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.HiddenJZStatusBar(alpha: 1)
    }
    override func viewDidLoad() {
        LCVoiceButton.singlePlayer.delegate = nil
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.fromColor(color: UIColor.init(white: 1, alpha: 0.0)), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.hidesBackButton = true
        loadData()
        
    }
    func loadData() {

        if let introduction = self.scenarioLesson.Introducation?.Text {
            if TurnType == 0 {
                self.introTextChinese = (self.scenarioLesson.Introducation?.Text)!
                self.introTextEnglish = (self.scenarioLesson.Introducation?.NativeText)!
            }else {
                //两秒后跳转到
                self.introTextChinese = ""
                self.introTextEnglish = ""
            }
        }
        else {
            self.introTextChinese = ""
            self.introTextEnglish = ""
        }
        
        self.setupContent()
//        self.analytics()
        
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
    func closeTapped() {
        self.navigationController?.dismiss(animated: false, completion: nil )
        ToastAlertView.hide()
    }
    func setupContent() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.fromColor(color: UIColor.init(white: 1, alpha: 0.0)), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        if TurnType == 0 {
            
        }else {
  
            storybackgroundC = UILabel(frame: CGRect(x: 0.0, y: ScreenUtils.height/2 - 30, width: ScreenUtils.width, height: 36.0))
            storybackgroundC.text = "我问你答"
            storybackgroundC.textColor = UIColor.textBlack333
            storybackgroundC.font = FontUtil.getFont(size: 22, type: .Bold)
            storybackgroundC.textAlignment = .center
            view.addSubview(storybackgroundC)

            storybackgroundE = UILabel(frame: CGRect(x: 0.0, y: storybackgroundC.frame.maxY + 10, width: ScreenUtils.width, height: 36.0))
            storybackgroundE.text = "R o l e  S w a p"
            storybackgroundE.textColor = UIColor.lightText
            storybackgroundE.font = FontUtil.getFont(size: 14, type: .Regular)
            storybackgroundE.textAlignment = .center
            view.addSubview(storybackgroundE)
            self.view.backgroundColor = UIColor.white
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.startConversation()
            }
            return
        }
        

    }
    
    func startConversation() {
        //埋点：点击Start
        let info = ["Scope" : "Practise","Lessonid" : self.courseId,"Subscope" : "IntroPage","Event" : "Start"]
//        UserManager.shared.logUserClickInfo(info)
        
        let vc = PractiseTurnViewController()
        vc.refreshLand = self.refreshLand
        vc.scenarioLesson = self.scenarioLesson
        vc.sentenceDict = self.sentenceDict
        vc.quizCount = self.quizCount
        vc.totalScore = self.totalScore
        vc.scenarioLessonTurnArray = self.scenarioLessonTurnArray
        vc.summaryLessonArray = self.summaryLessonArray
        vc.hintTurnArray = self.hintTurnArray
        vc.unlock = self.unlock
        vc.courseId = self.courseId
        vc.progressNum = progressNum
        vc.finishPratise = { score in
            //做完学以致用
            self.finishPratise?(score)
        }
        self.ch_pushViewController(vc, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        willAppear = true
        self.HiddenJZStatusBar(alpha: 0)
    }
    //无网络提示
    func showNetworkFailedRequestView() {
        let alertView = AlertNetworkRequestFailedView.init(frame: CGRect(x: 0, y: 60, width: ScreenUtils.width, height: ScreenUtils.height - 60))
        alertView.delegate = self
        alertView.show(frame: CGRect(x: 0, y: 60, width: ScreenUtils.width, height: ScreenUtils.height - self.ch_getStatusBarHeight()),superView:self.navigationController!.view,alertText:NetworkRequestFailedText.NetworkError,textColor:UIColor.loadingTextColor,bgColor: UIColor.loadingBgColor,showHidenButton: true)
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
