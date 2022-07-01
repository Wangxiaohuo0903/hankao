//
//  PractiseViewController
//  PracticeChinese
//
//  Created by 费跃 on 10/12/17.
//  Copyright © 2017 msra. All rights reserved.
//


import Foundation
import UIKit
import AVFoundation

class PractiseViewController: BasePrictiseChatViewController  {
    func cancleLoading() {
        closeTapped()
    }
//    var unlock: Bool = false//是否具有解锁功能
    var sentenceDict: VideoSentenceDictionary!
    var checkButton: UIButton!
    var totalScore: Int = 0
    let beginnerGuideKeys = [UserDefaultsKeyManager.readBeginnerGuideRecording, UserDefaultsKeyManager.hintBeginnerGuideRecording]
    var currentBeginnerGuideKeyIndex = 0
    var canAutoShowHint: Bool = false
    //没有answer,最后一个不成对
    var nullAnswer: Bool = false
    //是不是改跳转了
    var lastChatTurn: Bool = false
    var lastChatTurn_answer: Bool = false
    var courseId: String = ""
    var quizCount = 0
    var scenarioLessonArray = [ChatTurn]()
    var scenarioLessonTurnArray = [ChatTurn]()
    //收集所有语音，在summary展示
    var summaryLessonArray = [PractiseMessageModel]()
    //需要加强的单词
    var hintTurnArray = [HintDetail]()
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
    //防止多次跳转
    var pushed = false
    var progressNum = 0
    //0表示用户作为回答问题的一方，1表示用户作为提问的一方
    var TurnType = 0
    // 是否需要刷新土地和阳光值
    var refreshLand = true
    var meButton: LCVoiceButtonWave!
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
        progressView = CustomViewProgressView(progressViewStyle: .default)
        progressView.frame = CGRect(x: 0, y: statusHeight, width: ScreenUtils.width, height: 10)
        progressView.transform = CGAffineTransform(scaleX: 1.0, y: 3.5)
        
        progressView.progressTintColor = UIColor.hex(hex: "4E80D9")
        progressView.progressViewStyle = .default
        progressView.trackTintColor = UIColor.white
        progressView.progress = Float(progressNum)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.navigationController?.view.addSubview(self.progressView)
        }
        
        let introFont = FontUtil.getFont(size: 14, type: .Regular)
        if TurnType == 0 {
            self.titleText = (self.scenarioLesson.Summary?.Text)!
        }else {
            self.titleText = (self.scenarioLesson.Summary?.NativeText)!
        }
        
        titleLabel = UILabel(frame:  CGRect(x: CGFloat(60.0), y: statusHeight + 10, width: ScreenUtils.width - 120, height: self.titleText.height(withConstrainedWidth: ScreenUtils.width - 120, font: introFont)))
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor.hex(hex: "4E80D9")
        titleLabel.text = self.titleText
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
        
        self.quizCount = 0
        
        for chatTurn in (self.scenarioLesson.ChatTurn)! {
            if chatTurn.TurnType == 0 {
                self.scenarioLessonArray.append(chatTurn)
                if chatTurn.AnswerOptions?.count != 0 {
                    self.quizCount += 1
                }
            }
        }
        
        for chatTurn in (self.scenarioLesson.ChatTurn)! {
            if chatTurn.TurnType == 1 {
                self.scenarioLessonTurnArray.append(chatTurn)
                if chatTurn.AnswerOptions?.count != 0 {
                    self.quizCount += 1
                }
            }
        }
        let maxIndex = max( self.scenarioLessonArray.count, self.scenarioLessonTurnArray.count)
        var i = 0
        while i < maxIndex {
            
            if i < self.scenarioLessonArray.count {
                let chatTurn = self.scenarioLessonArray[i]
                if chatTurn.Tokens?.count != 0 {
                    
                    var pinyin:String = ""
                    var chinese:String = ""
                    if (chatTurn.Tokens?.count)! > 0 {
                        //FIXME: - : 怎么判断是纯英文的？tokens 为空
                        for token in chatTurn.Tokens! {
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
                        let modelAnswer = PractiseMessageModel(question:chatTurn.Question!,english: chatTurn.NativeQuestion!, chinese: chinese, pinyin: pinyin, audiourl: "", userAudio: NSURL(string: "")!, score: -1, tokens:chatTurn.Tokens!)
                        summaryLessonArray.append(modelAnswer)
                    }
                }
            }
            
            if i < self.scenarioLessonTurnArray.count {
                let chatTurnRight = self.scenarioLessonTurnArray[i]
                if chatTurnRight.Tokens?.count != 0 {
                    
                    
                    var pinyin:String = ""
                    var chinese:String = ""
                    if (chatTurnRight.Tokens?.count)! > 0 {
                        //FIXME: - : 怎么判断是纯英文的？tokens 为空
                        for token in chatTurnRight.Tokens! {
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
                        let modelAnswer = PractiseMessageModel(question:chatTurnRight.Question!,english: chatTurnRight.NativeQuestion!, chinese: chinese, pinyin: pinyin, audiourl: "", userAudio: NSURL(string: "")!, score: -1, tokens:chatTurnRight.Tokens!)
                        summaryLessonArray.append(modelAnswer)
                    }
                }
            }
            i += 1
            
        }
        
        if self.scenarioLessonArray.count > 0 {
            let chat = self.scenarioLessonArray[0]
            self.teacherAvatar = chat.ChaUrl == nil ? "" : chat.ChaUrl!
            self.userAvatar = chat.AnswerOptions![0].ChaUrl != nil ? chat.AnswerOptions![0].ChaUrl! : ""
            indexPathStr = chat.Question!
        }
        self.nextButton.isHidden = true
        self.bubbleCanPlayAudio = true
        
        //开始就判断是不是成对的
        let chat = self.scenarioLessonArray.last
        
        //如果答案是空说明不成对，成对打分完成后跳转，不成对，语音播放完后跳转
        if chat?.AnswerOptions!.count == 0{
            nullAnswer = true
        }else {
            nullAnswer = false
        }
        
        self.recordView.filename = "\(self.scenarioLesson.Id!)_\(self.currentIndex)_\(UUID().uuidString)"
        showQuiz()
        addAnswer()
    }
    //重写退出
    override func closeTapped() {
        super.closeTapped()
        self.buttonPlayStop()
    }
    @objc func checkResult() {
        // add the swap view
        if pushed == false {
            pushed = true
        }else {
            //已经跳转过了
            return
        }
        let turnView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height))
        turnView.backgroundColor = UIColor.white
        turnView.alpha = 0
        let title1 = UILabel(frame: CGRect(x: 0.0, y: ScreenUtils.height/2 - 30, width: ScreenUtils.width, height: 36.0))
        title1.text = "我问你答"
        title1.textColor = UIColor.textBlack333
        title1.font = FontUtil.getFont(size: 22, type: .Bold)
        title1.textAlignment = .center
        turnView.addSubview(title1)
        
        let title2 = UILabel(frame: CGRect(x: 0.0, y: title1.frame.maxY + 10, width: title1.frame.width, height: 36.0))
        title2.text = "R o l e  S w a p"
        title2.textColor = UIColor.lightText
        title2.font = FontUtil.getFont(size: 14, type: .Regular)
        title2.textAlignment = .center
        turnView.addSubview(title2)
        
        UIApplication.shared.keyWindow?.addSubview(turnView)
        
        UIView.animate(withDuration: 0.25, animations: {
            turnView.alpha = 1
        }, completion: { (_) in
            self.pushNextPratise()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                UIView.animate(withDuration: 0.25, animations: {
                    turnView.alpha = 0
                }, completion: { (_) in
                    turnView.removeFromSuperview()
                })
            }
        })
    }
    func pushNextPratise() {
        self.progressView.removeFromSuperview()
        self.titleLabel.removeFromSuperview()
        self.backButton.removeFromSuperview()
        
        let vc = PractiseTurnViewController()
        vc.refreshLand = self.refreshLand
        vc.TurnType = 1
        vc.scenarioLesson = self.scenarioLesson
        vc.sentenceDict = self.sentenceDict
        vc.quizCount = self.quizCount
        vc.totalScore = self.totalScore
        vc.scenarioLessonTurnArray = self.scenarioLessonTurnArray
        vc.summaryLessonArray = self.summaryLessonArray
        vc.hintTurnArray = self.hintTurnArray
        vc.courseId = self.courseId
        vc.progressNum = progressNum
        vc.finishPratise = { score in
           //做完学以致用
            self.finishPratise?(score)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    override func clickNext() {
        self.currentIndex += 1
        showQuiz()
    }
    
    func showQuiz() {
        let chatModel = self.msgList.last
        
        if (chatModel != nil) {
            if chatModel?.position == BubblePosition.left {
                return
            }
        }
        if self.scenarioLessonArray.count == 0 {
            return
        }
        if self.currentIndex == self.scenarioLessonArray.count - 1 {
            //该跳转了
            lastChatTurn = true
        }else {
            lastChatTurn = false
        }
        if self.currentIndex >= self.scenarioLessonArray.count {
            self.reloadView()
            return
        }
        let chat = self.scenarioLessonArray[self.currentIndex]
        
        //默认不显示小灯泡，可录音状态
        self.shouldCanRecord = false
        
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
        //注意改回去
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
            self.msgList.append(ChatMessageModel(type: .audiotext, text: "", pinyin: "", imageUrl: "", avatarUrl:self.teacherAvatar, audioUrl: audioUrl, position: .left, en: english!, index: "\(self.currentIndex+1)/\(self.scenarioLessonArray.count)",textArray:tokenModelArray))
        }else {
            let audioUrl = "https://mtutordev.blob.core.chinacloudapi.cn/system-audio/lesson/zh-CN/zh-CN/0342b5aff1e19bfaaa604e265278e317.mp3"
            for chatTurn in summaryLessonArray {
                if chatTurn.question == chat.Question {
                    chatTurn.audioUrl = audioUrl
                }
            }
            var english = chat.NativeQuestion
            if chat.NativeQuestion == "" {
                english = chat.Displayquestion
            }
            chat.AudioUrl = audioUrl
            self.msgList.append(ChatMessageModel(type: .audiotext, text: "", pinyin: "", imageUrl: "", avatarUrl:self.teacherAvatar, audioUrl: audioUrl, position: .left, en: english!, index: "\(self.currentIndex+1)/\(self.scenarioLessonArray.count)",textArray:tokenModelArray))
        }
        //是否能弹出提示，默认是
        indexPathStr = chat.Question!
        self.reloadView()
    }
    
    func addAnswer() {
        if self.currentIndex == self.scenarioLessonArray.count - 1 {
            lastChatTurn_answer = true
        }else {
            lastChatTurn_answer = false
        }
        if self.currentIndex >= self.scenarioLessonArray.count {
            self.reloadView()
            return
        }
        let chat = self.scenarioLessonArray[self.currentIndex]
        //如果答案是空，但是有提问，等提问播完再跳转
        if chat.AnswerOptions!.count == 0{
            self.showMask = false
            self.reloadView()
            return
        }
        let answer = chat.AnswerOptions![0]
        
        self.msgList.append(ChatMessageModel(type: .audiotext, text: "", pinyin: "", imageUrl: "", avatarUrl:UserManager.shared.getAvatarUrl()?.absoluteString, audioUrl: "", position: .right, en: answer.nativeText!, index: "\(self.currentIndex+1)/\(self.scenarioLessonArray.count)",textArray:nil))
        self.reloadView()
    }
    
    
    override func showHints() {
        
    }
    override func showBeginnerGuide() {
        
    }
    
    override func closeCancelEvent() {
    }
    
}

extension PractiseViewController: LCRecordingViewDelegate, BeginnerGuideCloseDelegate {
    override func buttonPlayStop() {
        //语音播放完毕之后，canAutoShowHint 为true说明已经提示
        
        //已经到最后一个，且成对，则播放完后跳转
        if lastChatTurn && nullAnswer {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.checkResult()
            }
            return
        }
        self.bubbleCanPlayAudio = false
        self.shouldCanRecord = true
        self.showMask = false
        self.reloadView()
    }
    
    func closeBeginnerGuide() {
        UserDefaults.standard.set(Int(1), forKey: self.beginnerGuideKeys[self.currentBeginnerGuideKeyIndex])
        UserDefaults.standard.synchronize()
        
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
        let chatData : ChatTurn?
        if self.currentIndex >= self.scenarioLessonArray.count {
            chatData = self.scenarioLessonArray.first
        }else {
            chatData = self.scenarioLessonArray[self.currentIndex]
        }
        if chatData == nil {
            return
        }
        //埋点：结束录音
        let info = ["Scope" : "Practise","Lessonid" : self.courseId,"Subscope" : "Test","IndexPath" : chatData?.Question,"Event" : "Recording","Value" : "Finish"]
        UserManager.shared.logUserClickInfo(info)
        self.shouldCanRecord = false
        //提交录音的时候立即删除之前的问题
        if(self.msgList.count != 0){
            let msg = self.msgList[0]
            if msg.position == .left {
                self.msgList.removeFirst()
                let indexSet = IndexSet(arrayLiteral: 0)
                self.tableView.deleteSections(indexSet, with: .fade)
                //录音完毕，left应该消失，然后出现下一个问题，灰色
            }
        }
        self.makingScore = true
        chatData?.userAudioUrl = DocumentManager.urlFromFilename(filename: "\(self.recordView.filename).m4a")
        if let audioData = try? Data(contentsOf: DocumentManager.urlFromFilename(filename: "\(self.recordView.filename).m4a")) {
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
            self.bubbleCanPlayAudio = false
            self.clickNext()
            if !self.nullAnswer && self.lastChatTurn_answer {
                //最后一个了
            }else {
                self.showMask = true
            }
            let speechInput = chatRateInput(question: chat.Question!, keywords: keywords, expectedAnswer:  chat.AnswerOptions![0].Text!, data: byteData, speechMimeType: "audio/amr", sampleRate: RecordManager.sharedInstance.sampleRate, lessonId: self.scenarioLesson.Id!, language: AppData.lang)
            CourseManager.shared.rateSpeechScenario(speechInput: speechInput){
                data in
                if data == nil {
                    //若不判断，有可能会崩溃
                    self.currentIndex -= 1
                    self.presentUserToast(message: "Error occured during scoring")
                    self.bubbleCanPlayAudio = false
                    self.shouldCanRecord = true
                    self.makingScore = false
                    if self.msgList.count > 2 {
                        self.msgList.removeLast()
                    }
                    self.reloadView()
                    return
                }
                let result = data as? ScenarioChatRateResult
                
                if result != nil {
                    self.currentScore = Double(result!.Score!)
                    self.makingScore = false
                    self.scoreResult = true
                    self.reloadView()
                    //需要加强的单词
                    if result!.Score! < 60
                    {
                        for detail in chat.AnswerOptions![0].HintDetails! {
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
                    
                    self.recordView.filename = "\(self.scenarioLesson.Id!)_\(self.currentIndex)_\(UUID().uuidString)"
                    //打分完成后停留1秒
                    if(self.msgList.count != 0){
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.progressNum += 1
                            self.progressView.progress = Float(self.progressNum)/Float(self.quizCount)
                            if !self.nullAnswer && self.lastChatTurn_answer {
                                //最后一个了
                            }else {
                                self.msgList.removeFirst()
                                let indexSet = IndexSet(arrayLiteral: 0)
                                self.tableView.deleteSections(indexSet, with: .fade)
                            }
                            self.totalScore += result!.Score!
                            self.makingScore = false
                            self.scoreResult = false
                            self.bubbleCanPlayAudio = true
                            //打分完成，判断一下还有没有answer，没有answer是指成对
                            if !self.nullAnswer && self.lastChatTurn_answer {
                                //此时quiz已经展示了，可以跳转
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    self.checkResult()
                                }
                            }else {
                                self.addAnswer()
                                
                            }
                        }
                    }
                    if(UIApplication.topViewController()?.isKind(of: PractiseViewController.self))!{
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
                    self.currentIndex -= 1
                    self.presentUserToast(message: "Error occured during scoring")
                    self.bubbleCanPlayAudio = false
                    self.shouldCanRecord = true
                    self.makingScore = false
                    if self.msgList.count > 2 {
                        self.msgList.removeLast()
                    }
                    self.reloadView()
                }
            }
        }else {
            self.presentUserToast(message: "Error occured during scoring,please try again.")
        }
    }
    
}

class PractiseIntroViewController: UIViewController,ChActivityViewCancleDelegate ,NetworkRequestFailedLoadDelegate ,UITableViewDelegate,UITableViewDataSource{
    var sentenceDict: VideoSentenceDictionary!
    var scenarioLesson: ScenarioLesson!
    var sentenceSortDict: VideoSentenceDictionary!
    var scenarioSortLesson: ScenarioLesson!
    //收集所有语音，在summary展示
    var scenarioLessonArray = [ChatTurn]()
    var scenarioLessonTurnArray = [ChatTurn]()
    var summaryLessonArray = [PractiseMessageModel]()
    var courseId: String = ""
    var unlock: Bool = false//是否具有解锁功能
    var refreshLand = true
    //0表示用户作为回答问题的一方，1表示用户作为提问的一方
    var TurnType = 0
    //分数回调
    var finishPratise: ((Int) -> Void)?
    var introTextChinese:String = ""
    var introTextEnglish:String = ""
    var titleLabel = UILabel()

    var tableView: UITableView!
    var HeadImageView = UIImageView()
    
    var navImageView = UIImageView()
    var backgroundView: PractiseIntroHeaderView?
    var willAppear = false
    //点击cell时是否播放语音
    var playAudio = false
    var score:Int = 0
    //当前点击的cell， 展开
    var selectedIndex: Int = 0
    var bottomView = UIView()
    var goButton = UIButton()
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override var prefersStatusBarHidden: Bool {
        return willAppear
    }
    
    func reloadData() {
        loadData()
    }
    //加载失败的返回
    func backClick() {
        closeTapped()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.HiddenJZStatusBar(alpha: 1)
    }
    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.fromColor(color: UIColor.init(white: 1, alpha: 0.0)), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        makeTableView()
        madeBottomBtn()
        loadData()
    }
    func makeTableView() {
        tableView = UITableView(frame: CGRect(x: 0, y:ScreenUtils.height, width: ScreenUtils.width, height:  ScreenUtils.height), style: .grouped)
        tableView.register(LandDetailTableViewCell.nibObject, forCellReuseIdentifier: LandDetailTableViewCell.identifier)
        tableView.register(PractiseReadingCell.nibObject, forCellReuseIdentifier: PractiseReadingCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
    }
    func madeBottomBtn() {
        let bottomHeight = 90.0
        bottomView.frame = CGRect(x: CGFloat(0.0), y: ScreenUtils.height, width: ScreenUtils.width, height: CGFloat(bottomHeight))
        bottomView.isUserInteractionEnabled = true
        self.view.addSubview(bottomView)
      
        self.gradientColor(gradientView: bottomView, frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: 90), upTodown: true)
        
        let buttonWidth = Double((ScreenUtils.width - 60)/2.0)
        let buttonX = (ScreenUtils.width - CGFloat(buttonWidth)) / 2
        let buttonHeight = 44.0
        let buttonY =  (bottomHeight - buttonHeight)/2
        
        goButton.frame = CGRect(x: Double(buttonX), y: buttonY, width: buttonWidth, height: buttonHeight)
        goButton.setTitle("Got it!", for: .normal)
        goButton.titleLabel?.font = FontUtil.getTitleFont()
        goButton.setBackgroundImage(UIImage.fromColor(color: UIColor.blueTheme), for: .normal)
        goButton.layer.cornerRadius = CGFloat(buttonHeight / 2)
        goButton.layer.masksToBounds = true
        goButton.titleLabel?.textColor = UIColor.white
        goButton.addTarget(self, action: #selector(startConversation), for: .touchUpInside)
        bottomView.addSubview(goButton)
    }
    func loadData() {
        ChActivityView.shared.delegate = self
        ChActivityView.show(.CancleFullScreen, UIApplication.shared.keyWindow!, UIColor.loadingBgColor, ActivityViewText.HomePageLoading,UIColor.loadingTextColor,UIColor.gray)
        CourseManager.shared.getScenarioLessonInfo(id: courseId) {
            (lesson,error) in
            ChActivityView.hide(statusAlpha: 0)
            self.HiddenJZStatusBar(alpha: 0)
            if lesson == nil {
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
                    alertView.show(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height),superView:self.navigationController!.view,alertText:networkErrorText,textColor:UIColor.loadingTextColor,bgColor: UIColor.loadingBgColor,showHidenButton: true)
                }
                return
            }
            self.scenarioLesson = lesson!.ScenarioLesson
            self.sentenceDict = lesson!.VideoSentenceDictionary
            self.scenarioSortLesson = lesson!.ScenarioLesson
            self.sentenceSortDict = lesson!.VideoSentenceDictionary
            self.sortChatTurns()
            if (self.scenarioLesson.Introducation?.Text) != nil {
                self.introTextChinese = (self.scenarioLesson.Introducation?.Text)!
                self.introTextEnglish = (self.scenarioLesson.Introducation?.NativeText)!
            }
            else {
                self.introTextChinese = ""
                self.introTextEnglish = ""
            }
            
            self.createNavView()
            self.setupContent()
            self.analytics()
            self.tableView.reloadData()
        }
    }
    //排序
    func sortChatTurns() {
        
        for chatTurn in (self.scenarioLesson.ChatTurn)! {
            if chatTurn.TurnType == 0 {
                self.scenarioLessonArray.append(chatTurn)
                if chatTurn.AnswerOptions?.count != 0 {
                }
            }
        }
        
        for chatTurn in (self.scenarioLesson.ChatTurn)! {
            if chatTurn.TurnType == 1 {
                self.scenarioLessonTurnArray.append(chatTurn)
                if chatTurn.AnswerOptions?.count != 0 {
                    //                    self.quizCount += 1
                }
            }
        }
        let maxIndex = max( self.scenarioLessonArray.count, self.scenarioLessonTurnArray.count)
        var i = 0
        while i < maxIndex {
            
            if i < self.scenarioLessonArray.count {
                let chatTurn = self.scenarioLessonArray[i]
                if chatTurn.Tokens?.count != 0 {
                    
                    var pinyin:String = ""
                    var chinese:String = ""
                    if (chatTurn.Tokens?.count)! > 0 {
                        //FIXME: - : 怎么判断是纯英文的？tokens 为空
                        for token in chatTurn.Tokens! {
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
                        //注意改回去
                        var audioURL = ""
                        if let audioUrl = self.sentenceDict.TextDictionary?[chatTurn.Question!]?.AudioUrl {
                            audioURL = audioUrl
                        }else {
                            audioURL = "https://mtutordev.blob.core.chinacloudapi.cn/system-audio/lesson/zh-CN/zh-CN/0342b5aff1e19bfaaa604e265278e317.mp3"
                        }
                        let modelAnswer = PractiseMessageModel(question:chatTurn.Question!,english: chatTurn.NativeQuestion!, chinese: chinese, pinyin: pinyin, audiourl: audioURL, userAudio: NSURL(string: "")!, score: -1, tokens:chatTurn.Tokens!,"Practisee_ReadAfterme_\(summaryLessonArray.count)_\(UUID().uuidString)")
                        summaryLessonArray.append(modelAnswer)
                    }
                }
            }
            
            if i < self.scenarioLessonTurnArray.count {
                let chatTurnRight = self.scenarioLessonTurnArray[i]
                if chatTurnRight.Tokens?.count != 0 {
                    var pinyin:String = ""
                    var chinese:String = ""
                    if (chatTurnRight.Tokens?.count)! > 0 {
                        //FIXME: - : 怎么判断是纯英文的？tokens 为空
                        for token in chatTurnRight.Tokens! {
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
                        //注意改回去
                        var audioURL = ""
                        if let audioUrl = self.sentenceDict.TextDictionary?[chatTurnRight.Question!]?.AudioUrl {
                            audioURL = audioUrl
                        }else {
                            audioURL = "https://mtutordev.blob.core.chinacloudapi.cn/system-audio/lesson/zh-CN/zh-CN/0342b5aff1e19bfaaa604e265278e317.mp3"
                        }
                        let modelAnswer = PractiseMessageModel(question:chatTurnRight.Question!,english: chatTurnRight.NativeQuestion!, chinese: chinese, pinyin: pinyin, audiourl: audioURL, userAudio: NSURL(string: "")!, score: -1, tokens:chatTurnRight.Tokens!,"Practisee_ReadAfterme_\(summaryLessonArray.count)_\(UUID().uuidString)")
                        summaryLessonArray.append(modelAnswer)
                    }
                }
            }
            i += 1
        }
        tableView.reloadData()
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
        self.HeadImageView.removeFromSuperview()
        self.navImageView.removeFromSuperview()
        //需要暂停语音
        let indexPath = NSIndexPath(row: selectedIndex, section: 0)
        if let cell = self.tableView.cellForRow(at: indexPath as IndexPath) as? PractiseReadingCell {
            cell.videoButton.pause()
            cell.userAudioButton.pause()
            cell.recordingView_read.cancelRecording(sender: nil)
        }
        self.navigationController?.dismiss(animated: false, completion: nil )
        ToastAlertView.hide()
    }
    func createNavView() {
        navImageView.isUserInteractionEnabled = true
        navImageView.frame = CGRect(x: 0, y: 0, width: ScreenUtils.width, height: self.ch_getStatusNavigationHeight())
        navImageView.backgroundColor = UIColor.hex(hex: "4974CE")
        navImageView.alpha = 0
        var top:Double = 0
        
        
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
            top = 20
        }
        titleLabel = UILabel(frame: CGRect(x: 50.0, y: top, width: Double(ScreenUtils.width - 100.0), height: Double(self.ch_getStatusNavigationHeight())))
        titleLabel.textColor = UIColor.white
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        
        let attributedStrM : NSMutableAttributedString = NSMutableAttributedString()
        
        let rangestring : NSAttributedString = NSAttributedString(string:"\(self.scenarioLesson.Name!)\n", attributes: convertToOptionalNSAttributedStringKeyDictionary([ convertFromNSAttributedStringKey(NSAttributedString.Key.font) : FontUtil.getFont(size: 14, type: .Regular)]))
        let messagestring : NSAttributedString = NSAttributedString(string:self.scenarioLesson.NativeName!, attributes: convertToOptionalNSAttributedStringKeyDictionary([ convertFromNSAttributedStringKey(NSAttributedString.Key.font) : FontUtil.getFont(size: 16, type: .Medium)]))
        
        attributedStrM.append(rangestring)
        attributedStrM.append(messagestring)
        titleLabel.attributedText = attributedStrM
        navImageView.addSubview(titleLabel)
        // 白色返回
        var backTop = 0
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
            backTop = 34
        }
        let backButton = UIButton(frame: CGRect(x: 0, y: backTop, width: 40, height: 40))
        backButton.setImage(ChImageAssets.CloseIcon_light.image, for: .normal)
        backButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        backButton.isUserInteractionEnabled = true
        navImageView.addSubview(backButton)
        self.navigationController?.view.addSubview(navImageView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    func setupContent() {
//        self.score = CourseManager.shared.getCourseScore("\(self.courseId)")
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.fromColor(color: UIColor.init(white: 1, alpha: 0.0)), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()

        HeadImageView.frame = CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height)
        HeadImageView.isUserInteractionEnabled = true
        HeadImageView.sd_setImage(with: URL(string: self.scenarioLesson.BackgroundImage!), placeholderImage: UIImage.fromColor(color: UIColor.colorFromRGB(17, 83, 180, 0.7)), options: .refreshCached) { (image, error, type, url) in
            
        }
        backgroundView = Bundle.main.loadNibNamed("PractiseIntroHeaderView", owner: nil, options: nil)?[0] as? PractiseIntroHeaderView
        if backgroundView != nil {
            backgroundView?.frame = CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height)
            backgroundView?.setData(score: self.score, nameC: self.scenarioLesson.Name!, nameE: self.scenarioLesson.NativeName!, introC: self.introTextChinese, introE: self.introTextEnglish)
            backgroundView?.startButton.addTarget(self, action: #selector(showPractiseReading), for: .touchUpInside)
            HeadImageView.addSubview(backgroundView!)
        
            backgroundView?.backButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
            self.navigationController?.view.addSubview(HeadImageView)
        }
    }
    //判断分数
    @objc func showPractiseReading() {
        if score < 60 {
            //没做过或者没及格
            let bottomHeight:CGFloat = 90.0
            UIView.animate(withDuration: 0.5, animations: {
                self.HeadImageView.frame = CGRect(x: 0, y: -ScreenUtils.height, width: ScreenUtils.width, height: ScreenUtils.height)
                self.tableView.frame = CGRect(x: 0, y: self.ch_getStatusNavigationHeight(), width: ScreenUtils.width, height: ScreenUtils.height - self.ch_getStatusNavigationHeight())
                self.navImageView.alpha = 1
            }) { (completed) in
                UIView.animate(withDuration: 0.2, animations: {
                    self.playAudio = true
                    self.tableView.reloadData()
                    self.HeadImageView.alpha = 0
                    let bottomY = ScreenUtils.height - CGFloat(bottomHeight)
                    self.bottomView.frame = CGRect(x: 0, y:bottomY, width: ScreenUtils.width, height:  ScreenUtils.height - bottomHeight)
                    self.view.bringSubviewToFront(self.bottomView)
                }, completion: { (finished) in
                    self.HeadImageView.removeFromSuperview()
                })
            }
        }else {
            //已经成功了
            startConversation()
        }
    }
    func dealPosition() {
        
    }
    @objc func startConversation() {
        if self.score < 60 {
            LCAlertView_Land.show(title: "Are You Ready", message: "You will lose \(SunValueManager.shared().sunValue) points if failed. Earn double points if succeeded.", leftTitle: "Go", rightTitle: "Later", style: .center, leftAction: {
                //OK
                LCAlertView_Land.hide()
                self.gotoPractiseVC(unlock:true)
            }, rightAction: {
                LCAlertView_Land.hide()
            }, disapperAction: {
                LCAlertView_Land.hide()
            })
        }else {
            self.gotoPractiseVC(unlock:false)
        }
    }
    func gotoPractiseVC (unlock:Bool) {
        navImageView.removeFromSuperview()
        HeadImageView.removeFromSuperview()
        //需要暂停语音
        let indexPath = NSIndexPath(row: selectedIndex, section: 0)
        if let cell = self.tableView.cellForRow(at: indexPath as IndexPath) as? PractiseReadingCell {
            cell.videoButton.pause()
            cell.userAudioButton.pause()
            cell.recordingView_read.cancelRecording(sender: nil)
            cell.repeatId = self.courseId
        }
        let vc = PractiseViewController()
        vc.refreshLand = self.refreshLand
        vc.scenarioLesson = self.scenarioLesson
        vc.sentenceDict = self.sentenceDict
        vc.courseId = self.courseId
        vc.titleText = self.introTextEnglish
        vc.finishPratise = { score in
            //做完学以致用
            self.finishPratise?(score)
        }
        self.ch_pushViewController(vc, animated: true)
        var subVCs = self.navigationController?.viewControllers
        if (subVCs?.count)! > 1 {
            subVCs?.remove(at: 0)
            self.navigationController?.viewControllers = subVCs!
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //hide status bar
        willAppear = true
        self.HiddenJZStatusBar(alpha: 0)
    }
    //无网络提示
    func showNetworkFailedRequestView() {
        let alertView = AlertNetworkRequestFailedView.init(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height))
        alertView.delegate = self
        alertView.show(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height),superView:self.view,alertText:NetworkRequestFailedText.NetworkError,textColor:UIColor.loadingTextColor,bgColor: UIColor.loadingBgColor,showHidenButton: true)
        ChActivityView.hide(statusAlpha: 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.summaryLessonArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == selectedIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: PractiseReadingCell.identifier) as! PractiseReadingCell
            cell.selectionStyle = .none
            let chat = self.summaryLessonArray[indexPath.row]
            cell.setContent(msg: chat)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if self.playAudio && !cell.recordingView_read.isRecording {
                    cell.videoButton.play()
                    self.playAudio = false
                }else {
                    self.playAudio = false
                }
            }
            cell.rateFinished = { (score,chinese) in
                chat.score = score
                chat.chinese = chinese
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: LandDetailTableViewCell.identifier) as! LandDetailTableViewCell
        let chat = self.summaryLessonArray[indexPath.row]
        cell.chinese.adjustsFontSizeToFitWidth = false
        cell.chinese.numberOfLines = 0
        cell.setContent(msg: chat)
        cell.selectionStyle = .none
        cell.line.isHidden = false
        cell.bgView.layer.mask = nil
        cell.exView.isHidden = false
        cell.bgView.backgroundColor = UIColor.white
        cell.bgViewLeft.constant = 15
        cell.bgViewRight.constant = 15
        cell.audioViewWidth.constant = 0
        cell.audioContainer.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let chat = self.summaryLessonArray[indexPath.row]
        if indexPath.row == selectedIndex {
            return 264
        }
        let englishheight = getLabelheight(labelStr: chat.english, font: FontUtil.getFont(size: FontAdjust().FontSize(Double(14)), type: .Regular))
        
        let chineseheight = getLabelheight(labelStr: chat.chinese.string, font: FontUtil.getFont(size: FontAdjust().FontSize(Double(22)), type: .Regular))
        
        let pinyinheight = getLabelheight(labelStr: chat.pinyin, font: FontUtil.getFont(size: FontAdjust().FontSize(Double(14)), type: .Regular))
        
        return englishheight + chineseheight + pinyinheight + 30 + 4
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //需要暂停语音
        let indexPath0 = IndexPath(row: selectedIndex, section: 0)
        if let cell = self.tableView.cellForRow(at: indexPath0 as IndexPath) as? PractiseReadingCell {
            cell.videoButton.pause()
            cell.userAudioButton.pause()
            cell.recordingView_read.cancelRecording(sender: nil)
        }
        if selectedIndex != indexPath.row {
            playAudio = true
        }else {
            playAudio = false
        }
        self.selectedIndex = indexPath.row
        self.tableView.reloadRows(at: [indexPath,indexPath0], with: .automatic)
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)

    }
    
    func getLabelheight(labelStr:String,font:UIFont)->CGFloat{
        let labelWidth = ScreenUtils.width - 74
        let maxSie:CGSize = CGSize(width:labelWidth,height:1000)
        return (labelStr as String).boundingRect(with: maxSie, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):font]), context: nil).size.height
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height / 2))
        return footerView
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.summaryLessonArray.count > 0 {
            let chat = self.summaryLessonArray.last
            return ScreenUtils.height - 264
        }
        return ScreenUtils.height/2
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
}

class CustomViewProgressView: UIProgressView {
    
}
class CustomSlider: UISlider {
    
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
