//
//  LessonScenarioManager.swift
//  PracticeChinese
//
//  Created by ThomasXu on 04/07/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import Alamofire
import CocoaLumberjack
import ObjectMapper

class CommentManager {
    static let goodRemarks = [ "Impressive!", "Good job!", "Well done!", "Nice job!", "Great job!"]
    static let commonRemarks = [ "Oops, try again!", "You can do better!", "Almost there!", "So close...", "Keep trying!"]
    static let perfectRemarks = ["Excellent!", "Fabulous!", "Awesome!", "Fantastic!", "You are the best!"]
    
    static func getRemarkByScore(score:Int) -> String {
        var candidates = [String]()
        if score > 90 {
            candidates = perfectRemarks
        }
        else if score < 60 {
            candidates = commonRemarks
        }
        else {
            candidates = goodRemarks
        }
        let w = Int(arc4random_uniform(100))
        let i = w % candidates.count
        return candidates[i]
    }
}

class LessonScenarioManager {
    
    var lesson: ScenarioLesson!
    var sentenceDict: VideoSentenceDictionary!
    var userAudioRecords: [(Int, URL?)]!

    var currentChatTurnIndex: Int = -1
    var lowScoreCount = 0//分数少于60分的次数
    let maxLowScoreCount = 2//小于60分的次数带到这么多时，可以进入下一题
    var currentScore: Int = -1
    var comments:[CommentItem] = []
    var timer:Timer!
    var dictionarys = [ChineseDictionary]()//在中文里，正确答案里面有音标，是使用token来表示的
    var quizPinyin = [ChineseDictionary]()

    let scores = [90, 80, 90, 90, 80, 89]
    var scoresIndex = 0
    var selectedChatTurnNum = 2//当前lesson有很多chatturn，测试时只使用这么多
    
    let lowScoreBound = 60
    
    init(lesson: ScenarioLesson, dict: VideoSentenceDictionary) {
        self.lesson = lesson
        self.sentenceDict = dict
        self.selectedChatTurnNum = lesson.ChatTurn!.count
    //    self.selectedChatTurnNum = 1
        self.userAudioRecords = Array<(Int, URL?)>(repeating: (Int(-1), nil), count: self.selectedChatTurnNum)
        if let comments = self.lesson.Comments {
            self.comments = comments.sorted(){
                item1, item2 in
                return item1.score! > item2.score!//从大到小排序
            }
        }
        for turn in self.lesson.ChatTurn! {
            let temp = ChineseDictionary()
            let quiz = ChineseDictionary()
            if let tokens = turn.AnswerOptions![0].Tokens {
                for token in tokens {
                    if let tokenText = token.Text, let ipa = token.IPA {
                        temp.addToDict(hanzi: tokenText, pinyin: ipa)
                    }
                }
            }
            
            if let tokens = turn.Tokens {
                for token in tokens {
                    if let tokenText = token.Text, let ipa = token.IPA {
                        quiz.addToDict(hanzi: tokenText, pinyin: ipa)
                    }
                }
            }
            self.dictionarys.append(temp)
            self.quizPinyin.append(quiz)
        }
    }

    //学以致用数据
    init(lesson: ScenarioLesson) {
        self.lesson = lesson
        self.selectedChatTurnNum = lesson.ChatTurn!.count
        self.userAudioRecords = Array<(Int, URL?)>(repeating: (Int(-1), nil), count: self.selectedChatTurnNum)
        if let comments = self.lesson.Comments {
            self.comments = comments.sorted(){
                item1, item2 in
                return item1.score! > item2.score!//从大到小排序
            }
        }
        for turn in self.lesson.ChatTurn! {
            let temp = ChineseDictionary()
            let quiz = ChineseDictionary()
            if let tokens = turn.AnswerOptions![0].Tokens {
                for token in tokens {
                    if let tokenText = token.Text, let ipa = token.IPA {
                        temp.addToDict(hanzi: tokenText, pinyin: ipa)
                    }
                }
            }
            
            if let tokens = turn.Tokens {
                for token in tokens {
                    if let tokenText = token.Text, let ipa = token.IPA {
                        quiz.addToDict(hanzi: tokenText, pinyin: ipa)
                    }
                }
            }
            self.dictionarys.append(temp)
            self.quizPinyin.append(quiz)
        }
    }
    
    func getNextChat() -> ChatTurn? {
        if let turn = self.lesson.ChatTurn {
            if currentChatTurnIndex >= self.selectedChatTurnNum - 1 {
                return nil
            }
            self.currentChatTurnIndex += 1
            self.lowScoreCount = 0//到下一题的时候清空状态
            self.currentScore = -1
            return turn[self.currentChatTurnIndex]
        }
        return nil
    }
    
    func getComment(score: Int) -> String? {
        return CommentManager.getRemarkByScore(score: score)
    }
    
    func getDictAudioUrl(audioString: String) -> String? {
        return self.sentenceDict.TextDictionary![audioString]?.AudioUrl
    }
    
    func getHelpAudioUrl() -> String? {
        let text = self.lesson.ChatTurn?[self.currentChatTurnIndex].AnswerOptions?[0].HelpInfo
        if nil == text {
            return nil
        }
        return self.sentenceDict.TextDictionary![text!]?.AudioUrl
    }
    
    func getQuizPinyin(index: Int, str: String) -> String {
        return self.quizPinyin[index].getTextPinyin(str: str)
    }
    
    
    func getTextPinyin(index: Int, str: String) -> String {
        return self.dictionarys[index].getTextPinyin(str: str)
    }
    
    func getChatTurnCount() -> Int {
        return self.selectedChatTurnNum// self.lesson.ChatTurn!.count
    }
    
    func getChatTurnReview(index: Int) -> (question: String, correctAudio: String, userAudio: String, score: Int) {
        let turn = self.lesson.ChatTurn![index]
        let question = turn.Question!
        let answer = turn.AnswerOptions![0].Text!
        let correctAudio = self.sentenceDict.TextDictionary![answer]?.AudioUrl
        let userAudio = self.userAudioRecords[index].1?.absoluteString
        let userScore = self.userAudioRecords[index].0
        return (question, correctAudio!, userAudio!, userScore)
    }
    
    func getChatTurnTempAudioName() -> String {
        return "scenario_audio_temp"
    }
    
    func getChatTurnAudioName() -> String {
        return "scenario_\(self.lesson.Id!)_chat_turn_\(self.currentChatTurnIndex)"
    }
    
    func getCurrentChatTurn() -> ChatTurn? {
        if self.currentChatTurnIndex < 0 {
            return nil
        }
        if let turn = self.lesson.ChatTurn {
            if self.currentChatTurnIndex >= turn.count {
                return nil
            }
            return turn[self.currentChatTurnIndex]
        }
        return nil
    }
    
    //得到当前chatturn的帮助信息
    func getCurrentChatTipWordInfo(index: Int) -> (String, String, String?) {
        let turn = self.getCurrentChatTurn()
        //   let pinyin = turn?.AnswerOptions![0].HintDetails![index].Text
        let text = turn?.AnswerOptions![0].HintDetails![index].Text!
        let hanzis = text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let pinyin = self.dictionarys[self.currentChatTurnIndex].getTextPinyin(str: hanzis)
        let audio = self.getDictAudioUrl(audioString: turn!.AnswerOptions![0].HintDetails![index].Text!)
        return (pinyin, (turn?.AnswerOptions![0].HintDetails![index].NativeText!)!, audio)
    }
    
    //获取当前做了多少个chatturn
    func getProgress() -> (Int, Int) {
        return (currentChatTurnIndex + 1, self.lesson.ChatTurn!.count)
    }
    
    
    //获取当前最高分音频
    func getCurrentBestChatRecord() -> String? {
        return self.userAudioRecords[self.currentChatTurnIndex].1?.absoluteString
    }
    
    //根据录音文件进行打分
    func getScore(fileName: String, complete: @escaping (_ score: Int, _ comment: String?) -> ()) {
        let managerComplete : (_ score: Int, _ comment: String?) -> () = {
            score, comment in
            if score >= 0 {
                self.currentScore = score
                if self.currentScore < self.lowScoreBound {
                    self.lowScoreCount += 1
                }
                
                if score > self.userAudioRecords[self.currentChatTurnIndex].0 {
                    let audioName = self.getChatTurnAudioName() + ".m4a"
                    self.userAudioRecords[self.currentChatTurnIndex].0 = score
                    
                    DocumentManager.renameFile(oldName: self.getChatTurnTempAudioName() + ".m4a", newName: audioName)
                    self.userAudioRecords[self.currentChatTurnIndex].1 = DocumentManager.urlFromFilename(filename: audioName)
                }
            }
            complete(score, comment)
        }
        
      //  getScoreFromTest(complete: managerComplete)
        getScoreFromServer(filename: fileName, complete: managerComplete)
    }
    
    func getScoreFromTest(complete: (_ score: Int, _ comment: String? ) -> ()) {
        let temp = scores[scoresIndex]
        scoresIndex = (scoresIndex + 1) % scores.count
        complete(temp, self.getComment(score: temp))
    }
    
    func getScoreFromServer(filename: String, complete: @escaping (_ score: Int, _ comment: String?) -> ()) {
        let url = DocumentManager.urlFromFilename(filename: filename)
        let audioData = try! Data(contentsOf: url)
        let byteData = [Byte](audioData)
        let turn = self.lesson.ChatTurn?[currentChatTurnIndex]
        var keywords = [String]()
        for word in turn!.AnswerOptions![0].HintDetails! {
            keywords.append(word.Text!)
        }
        self.rateSpeech(lessonId: lesson.Id!, text: turn!.Question!, keywords: keywords , answerExp: turn!.AnswerOptions![0].Text!, data: byteData) {
            model in
            if model != nil {
                let rate = model!.Score!
                complete(rate, self.getComment(score: rate))
            }
            else {
                complete(-1, "")
            }
        }
    }

    //是否可以进行下一个chatturn
    func canGoToNext() -> Bool {
        if currentScore >= lowScoreBound {
            return true
        }
        if self.lowScoreCount >= maxLowScoreCount {
            return true
        }
        return false
    }
    
   
    func rateSpeech(lessonId: String, text:String, keywords:[String], answerExp:String, data:[Byte]?, completion:@escaping (_ model: ScenarioChatRateResult?)->()) {
        if(UIApplication.topViewController()?.isKind(of: LessonScenarioViewController))!{
            ToastAlertView.show("Uploading...")
        }
        let speechInput = chatRateInput(text:"", question: text, keywords: keywords, expectedAnswer: answerExp, data: data, speechMimeType: "audio/amr", sampleRate: RecordManager.sharedInstance.sampleRate, lessonId: lessonId, language: AppData.lang)
        var options = [String:String]()
        options["rate-chat.submit"] = ""
        let callback:(JobInfo?, Error?, String?)->() = {
            data, error, raw in
            if(UIApplication.topViewController()?.isKind(of: LessonScenarioViewController))!{
                ToastAlertView.show("Scoring...")
            }
            if data == nil {
                ToastAlertView.hide()
                UIApplication.topViewController()?.presentUserToast(message: "The network is not available. Please check your internet connection.")
            }
            if data != nil {
                let jobId = data!.Id
                var ticker = 0
                if self.timer != nil {
                    self.timer.invalidate()
                }
                let rateClosure:(Timer) -> Void = {
                    _ in
                    ticker  += 1
                    if ticker > 12 {
                        self.timer.invalidate()
                        self.timer = nil
                        ToastAlertView.hide()
                        completion(nil)
                        return
                    }
                    var rOptions = [String:String]()
                    rOptions["rate-chat.receive"] = ""
                    
                    let receiveCompletion:(JobOutput<ScenarioChatRateResult>?, Error?, String?)->() = {
                        receiveData, receiveError, raw in
                        if let rData = receiveData {
                            if self.timer != nil {
                                self.timer.invalidate()
                                self.timer = nil
                                
                                var result = rData.Result
                                
                                ToastAlertView.hide()
                                completion(result)
                            }
                        }
                        ToastAlertView.hide()
                    }
                    RequestManager.shared.performRequest(urlRequest: Router.GetScenarioLesson(JobInput(id:jobId!), rOptions), completionHandler: receiveCompletion)
                }
                if #available(iOS 10.0, *) {
                    self.timer = Timer(timeInterval: 1, repeats: true, block: rateClosure)
                } else {
                    self.timer = Timer.schedule(timeInterval: 1, repeats: true, block: rateClosure)
                    // Fallback on earlier versions
                }
                RunLoop.current.add(self.timer, forMode: .commonModes)
            }
        }
        RequestManager.shared.performRequest(urlRequest: Router.GetScenarioLesson(speechInput, options), completionHandler: callback)
        
    }
    
    //更新课程进度
//    func updateProgress(completion: @escaping (_ success:Bool?) ->()) {
//        let lessonId = self.lesson.Id!
//        var options = [String:String]()
//        options["update-scenario-lesson-progress"] = ""
//
//        let callback2: (UpdateScenarioLessonProgressResult?, Error?, String?)->() = {
//            data, error, raw in
//            if error == nil {
//                completion(true)
//            }
//            else {
//                completion(false)
//            }
//        }
//        RequestManager.shared.performRequest(LessonManager.scenarioEngine, method: Alamofire.HTTPMethod.post, dataIn: updateScenarioLessonProgressPara(delta:1, lessonId: lessonId, language: AppData.lang), options: options, completionHandler: callback2)
//    }
}
