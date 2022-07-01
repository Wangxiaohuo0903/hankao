//
//  LearnProgress.swift
//  PracticeChinese
//
//  Created by ThomasXu on 19/07/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import Alamofire
import UIKit
import ObjectMapper
import CocoaLumberjack
//这个类用来从全局上对所学课程进行管理

enum ClassType {
    case Repeat
    case Scenario
}

class CourseLearnStatus {
    var id: String!
    var addedIntoPlan: Bool!
    var finished: Bool!
}

class CourseManager: NSObject {
    static let shared = CourseManager()
    var prefetchCount = 0
    var beginnerLessonInfo: ScenarioSubLessonInfo!
    var mediumLessonInfo: ScenarioSubLessonInfo!
    var practicalLessonInfo: ScenarioSubLessonInfo!
    var ScenarioLesson = [GetScenarioLessonResult]()
    var SpeakLesson = [GetLessonResult]()
    var timer:Timer!
    var isLearnPage = false//是否首页
    //已经完成的课程的id
    var finishedMediumLessonIds = [String]()
    var finishedBeginnerLessonIds = [String]()
    var learnedWordMap = [learnedItemResult]()
    var finishedLessonInfo = [(ScenarioSubLessonInfo, Int)]()
    //已完成的土地课程
    var finishedPractiseLessonInfo = [(ScenarioSubLessonInfo, Int)]()
    //更新所有的课程数据，主要是针对重新登录的情况
    @objc func updateAllData() {
        RequestManager.shared.reLoad = true
        RequestManager.shared.refresh = false
        SetCoursesList(update:true)
    }
    

    func loadData(_ update:Bool = false) {
        RequestManager.shared.reLoad = true
        RequestManager.shared.refresh = false
        SetCoursesList(update:update)
        NotificationCenter.default.addObserver(self, selector: #selector(updateAllData), name: ChNotifications.UserSignedOut.notification, object: nil)
    }
    
    func getLearnedWordMapList() ->  [learnedItemResult]
    {
        return  self.learnedWordMap
    }
    func getFinishedLessonList() ->  [(ScenarioSubLessonInfo, Int)]
    {
        return  self.finishedLessonInfo
    }
    func getFinishedLessonCount() -> Int
    {
        return  self.finishedLessonInfo.count
    }
    
    func getFinishedPractiseLesson() -> [(ScenarioSubLessonInfo, Int)]
    {
        return  self.finishedPractiseLessonInfo
    }
    
    func getFinishedPractiseLessonCount() -> Int
    {
        return  self.finishedPractiseLessonInfo.count
    }
    func getFinishedWordCount() -> Int
    {
        return self.learnedWordMap.count
    }
    
    //isPassed: 是否答对，第一次答对才传true，其他全部false
    func rateQuiz(lid:String, question:String, answer:Int, passed: Bool, completion:@escaping (_ result:ScenarioRateChoiceResult?)->())
    {
        if(AppData.userAssessmentEnabled && UserManager.shared.isLoggedIn()){
            var options = [String:String]()
            options["rate-choice-quiz"] = ""
            let callback:(ScenarioRateChoiceResult?, Error?, String?)->() = {
                data, error, raw in
                completion(data)
            }
            RequestManager.shared.performRequest(urlRequest: Router.GetScenarioLesson(ScenarioRateChoiceInput(question: question, answer: answer, lid: lid, isPassed: passed, lang: AppData.lang), options), completionHandler: callback)
        }
    }
    
    // 移植LessonManager.shared.updateLearnProgress
    func updateCourseProgress(classType:ClassType, id: String, completion: @escaping (_ success:Bool?) ->()) {
        //未登录不上传进度
        if !UserManager.shared.isLoggedIn() {
            completion(false)
            return
        }
        
        var options = [String:String]()
        
        switch classType {
        case .Repeat:
            options["update-lesson-progress"] = ""
        case .Scenario:
            options["update-scenario-lesson-progress"] = ""
            
        }
        
        let callback: (ResultContract?, Error?, String?)->() = {
            data, error, raw in
            if data != nil {
                NotificationCenter.default.post(name: ChNotifications.UpdateCourseProgress.notification, object: nil)
                completion(true)
            }
            else {
                completion(false)
            }
        }
        RequestManager.shared.performRequest(urlRequest: Router.GetScenarioLesson(updateScenarioLessonProgressPara(delta:1, lessonId: id, language:AppData.lang), options), completionHandler: callback)
    }
    
    
    func getBeginnerScenarioLessons() -> [GetScenarioLessonResult?]{
        let resultList = [GetScenarioLessonResult?]()
        if self.beginnerLessonInfo == nil {
            return [GetScenarioLessonResult]()
        }
        return resultList

    }
    
    func getMediumScenarioLessons() -> [GetScenarioLessonResult?]{
        let resultList = [GetScenarioLessonResult?]()
        if self.mediumLessonInfo == nil {
            return [GetScenarioLessonResult]()
        }
        return resultList
    }
    
    
    func getBeginnerPracticeCourseId(_ lessonList: [ScenarioSubLessonInfo]) -> String {
        if let lesson = lessonList.first(where: {$0.ScenarioLessonInfo!.LessonType == .PracticeLesson}) {
            return lesson.ScenarioLessonInfo!.Id!
        }
        return ""
        
    }
    func getBeginnerChatCourseId(_ lessonList: [ScenarioSubLessonInfo]) -> String {
        if let lesson = lessonList.first(where: {$0.ScenarioLessonInfo!.LessonType == .ChatLesson}) {
            return lesson.ScenarioLessonInfo!.Id!
        }
        return ""
        
    }

    //获取分数
    func getCourseScore(_ courseId: String) -> Int {
        for lesson in self.beginnerLessonInfo.SubLessons! {
            for subLesson in lesson.SubLessons! {
                if subLesson.ScenarioLessonInfo?.Id == courseId {
                    return (subLesson.ScenarioLessonInfo?.Score)!
                }
            }
        }

        for lesson in self.practicalLessonInfo.SubLessons! {
            for subLesson in lesson.SubLessons! {
                if subLesson.ScenarioLessonInfo?.Id == courseId {
                    return (subLesson.ScenarioLessonInfo?.Score)!
                }
            }
        }
        return -1
    }

    
    func SetCoursesList(update:Bool = false, completion:(()->())? = nil) {
        self.getCourseList(id: "scenario", update:update) {
            success in
            if !success {
                // attention 刷新失败弹窗
                DispatchQueue.main.async {
                    ChActivityView.hide(.HomePage)
                    NotificationCenter.default.post(name: ChNotifications.UpdateHomePage.notification, object: nil)
                }
                return
            }
            self.setFinishedLessons() {
                
                DispatchQueue.main.async {
                    ChActivityView.hide(.HomePage)
                }
            
                NotificationCenter.default.post(name: ChNotifications.FinishOneLesson.notification, object: nil)
                NotificationCenter.default.post(name: ChNotifications.UpdateHomePage.notification, object: nil)
                NotificationCenter.default.post(name: ChNotifications.UpdateMePage.notification, object: nil)
                if completion != nil {
                    completion!()
                }
            }
        }
        UserManager.shared.getUserInfo { (coin) in
            NotificationCenter.default.post(name: ChNotifications.UpdateHomePageCoin.notification, object: nil)
        }
        CourseManager.shared.GetScenarioLearnedItem { (data, error) in
            CWLog("学过的c单词")
        }
    }
    //获取解锁的课程列表
    func getRecommendLessons(completion: @escaping (_ lessons: [ScenarioSubLesson])->()) {
       let lid = "recommend"
        listScenarioLesson(id: lid) {
            lesson in
            if lesson != nil && lesson?.SubLessons != nil {
                completion(lesson!.SubLessons!)
            }
            else {
                completion([ScenarioSubLesson]())
            }
        }
    }
    //获取指定课程的信息
    func listScenarioLesson(id: String, completion: @escaping (_ lesson:ListScenarioLessonsResult?) -> ()) {
        var options = [String:String]()
        options["list-scenario-lessons"] = ""
        let callback:(ListScenarioLessonsResult?, Error?, String?)->() = {
            result, error, raw in
            completion(result)
        }
        RequestManager.shared.performRequest(urlRequest: Router.GetScenarioLesson(lessonPara(id, lang: AppData.lang), options), completionHandler: callback)
    }
    
    func getCourseList(id: String, update: Bool, completion: @escaping (_ success:Bool) -> ()) {
        DispatchQueue.main.async {
            //如果是HomePage ,发送通知在HomePage里面显示，不在这里调用
            if CourseManager.shared.isLearnPage == true {
                //如果是Homepage的刷新，不显示loading
                if (!RequestManager.shared.refresh) {
                    NotificationCenter.default.post(name: ChNotifications.ShowActivityViewInHomePage.notification, object: nil)
                }
                RequestManager.shared.refresh = false
            }else {
                //ChActivityView.show()
            }
        }
        
        /*
         pre-set lesson from local json
         beginnerLessonInfo
         mediumLessonInfo
        */
        
        let beginnerjsonData:Data = beginnerLessonJsonString.data(using: .utf8)!
        let mediumjsonData:Data = mediumLessonJsonString.data(using: .utf8)!
        var options = [String:String]()
        options["list-scenario-lessons"] = ""
        options["depth"] = "10"
        
        var lid = id
        if id == "" {
            lid = "scenario"
        }
        let callback:(ListScenarioLessonsResult?, Error?, String?)->() = {
            result, error, raw in
            if let scenarioLesson = result
            {
                //beginner lesson
                if scenarioLesson.RootLessonInfo?.SubLessons != nil && scenarioLesson.RootLessonInfo!.SubLessons!.count > 2 {
                    let bLesson = scenarioLesson.RootLessonInfo!.SubLessons![2].SubLessons![0]
                    self.beginnerLessonInfo = bLesson
//                    for lesson in self.beginnerLessonInfo.SubLessons!.reversed() {
//                        var start = ""
//                        var end = ""
//                        
//                        if lesson.ScenarioLessonInfo!.Id!.length > 5 {
//                            start = lesson.ScenarioLessonInfo!.Id!.substring(from: 5)
//                        }
//                        if lesson.ScenarioLessonInfo!.Id!.length > 2 {
//                            end = start.substring(to: 2)
//                        }
//                        if Int(end) ?? 0 >= 29 {
//                            self.beginnerLessonInfo.SubLessons!.removeLast()
//                        }else {
//                            break
//                        }
//                    }
                }
                //medium lesson
                if scenarioLesson.RootLessonInfo?.SubLessons != nil && scenarioLesson.RootLessonInfo!.SubLessons!.count > 1 {
                    let mLesson = scenarioLesson.RootLessonInfo!.SubLessons![1].SubLessons![0]
                    self.mediumLessonInfo = mLesson
                }
                
                if scenarioLesson.RootLessonInfo?.SubLessons != nil && scenarioLesson.RootLessonInfo!.SubLessons!.count > 1 {
                    let mLesson = scenarioLesson.RootLessonInfo!.SubLessons![3].SubLessons![0]
                    self.practicalLessonInfo = mLesson
                }
                completion(true)
            }
            else {
                completion(false)
            }
        }
        
        
        RequestManager.shared.performRequest(urlRequest: Router.GetScenarioLesson(lessonPara(lid, lang: AppData.lang), options), completionHandler: callback)

    }
    
    
    
    func setFinishedLessons(_ completion:@escaping ()->()) {
        self.finishedLessonInfo.removeAll()
        self.finishedPractiseLessonInfo.removeAll()
//        self.learnedWordMap.removeAll()
        self.finishedBeginnerLessonIds.removeAll()
        self.finishedMediumLessonIds.removeAll()
        if self.beginnerLessonInfo == nil {
            return
        }
        
        for lesson in self.beginnerLessonInfo.SubLessons! {
            var finishFlag = false
            var score = 0
            for sub in lesson.SubLessons! {
                if !sub.ScenarioLessonInfo!.Tags!.contains("ChallengeLesson") && (sub.ScenarioLessonInfo!.Progress! > 0 || sub.ScenarioLessonInfo!.LearnRate! >= 1){
                    self.finishedBeginnerLessonIds.append(sub.ScenarioLessonInfo!.Id!)
                    if sub.ScenarioLessonInfo!.LessonType! == .PracticeLesson {
                        finishFlag = true
                        score = sub.ScenarioLessonInfo!.Score!
                        if score < 0 {
                            score = 0
                        }
                    }
                }
            }
            if finishFlag {
                self.finishedLessonInfo.append((lesson, score))
            }

        }
        if self.mediumLessonInfo == nil {
            return
        }
//        for lesson in self.mediumLessonInfo.SubLessons! {
//            for sub in lesson.SubLessons! {
//                if sub.ScenarioLessonInfo!.Progress! >= 0{
//                    self.finishedMediumLessonIds.append(sub.ScenarioLessonInfo!.Id!)
//                    var score = 0
//                    if sub.ScenarioLessonInfo!.Score! > 0 {
//                        score = sub.ScenarioLessonInfo!.Score!
//                    }
//                    var newSub = sub
//                    newSub.ScenarioLessonInfo!.ImageUrl = lesson.ScenarioLessonInfo!.ImageUrl
//                    self.finishedLessonInfo.append((sub, score))
//
//                }
//            }
//        }
//        
        for lesson in self.practicalLessonInfo.SubLessons! {
            //四个
            for sub in lesson.SubLessons! {
                if sub.ScenarioLessonInfo!.Progress! > 0 && sub.ScenarioLessonInfo!.Score! >= 60{
                    var score = 0
                    if sub.ScenarioLessonInfo!.Score! > 0 {
                        score = sub.ScenarioLessonInfo!.Score!
                    }
                    self.finishedPractiseLessonInfo.append((sub, score))
                }
            }
        }
        
//        let dp = DispatchGroup()
        
//        for id in finishedBeginnerLessonIds {
////            dp.enter()
//            getScenarioLessonInfo(id: id) {
//                lesson,error in
//                if lesson != nil {
//                    for item in lesson!.ScenarioLesson!.LearningItems! {
//                        for token in item.Tokens! {
//                            if token.IPA == nil || token.IPA == "" {
//                                //标点或者特殊符号不添加
//                            }else {
//                                self.learnedWordMap[token.Text!] = token
//                            }
//                        }
//                    }
//                }
////                dp.leave()
//            }
//        }
//        for id in finishedMediumLessonIds {
//            dp.enter()
//            getScenarioLessonInfo(id: id) {
//                (lesson,error) in
//                if lesson != nil {
//                    for item in lesson!.ScenarioLesson!.LearningItems!.filter({$0.ItemType! == ScenarioLessonLearningItemType.Word.rawValue})
//                    {
//                        var token = Token()
//                        token.Text = item.Text
//                        token.IPA = item.IPA
//
//                        token.NativeText = item.NativeText
//                        self.learnedWordMap[token.Text!] = token
//                    }
//                }
//                dp.leave()
//            }
//        }
//        dp.notify(queue: DispatchQueue.main) {
//            completion()
//        }
        completion()
    }
    
    func getBeginnerLessonName(_ id : String) -> String{
        for lesson in beginnerLessonInfo!.SubLessons! {
            if lesson.ScenarioLessonInfo!.Id! == id {
                return lesson.ScenarioLessonInfo!.NativeName!
            }
        }
        return ""
    }
    
    //移植repeatlessonmanager.getRepeatLesson
    func getSpeakLessonInfo(id:String, completion:@escaping (_ lesson: GetLessonResult?,_ error:Error?) -> ()) {

        var options = [String:String]()
        options["get-lesson"] = ""
        let callback:(GetLessonResult?, Error?, String?)->() = {
            data, error, raw in
            if data == nil || raw == nil {
                completion(data,error)
                return
            }
            var urls = [String?]()
            
            for quiz in data!.Lesson!.QuizzesList! {
                if quiz.Quiz!.AudioUrl != nil {
                    urls.append(quiz.Quiz!.AudioUrl)
                }
            }
            AppUtil.downloadUrls(urls: urls) {
                success in
                
                completion(data,nil)
                
                if success {
                }
                else {
                    
                    DDLogInfo("cache url error!")
                }
            }
        }
        RequestManager.shared.performRequest(urlRequest: Router.GetSpeakLesson(lessonPara(id, lang: AppData.lang), options), completionHandler: callback)
    }
    //移植 lessonmanager.getScenarioLesson
    func getScenarioLessonInfo(id:String, completion:@escaping (_ lesson: GetScenarioLessonResult?, _ error: Error?) -> ()) {
       
        var options = [String:String]()
        options["get-scenario-lesson"] = ""
        options["multi-round"] = ""
        let callback:(GetScenarioLessonResult?, Error?, String?)->() = {
            data, error, raw in
            if data == nil || raw == nil {
                completion(data, error)
                return
            }
            
            if data?.VideoSentenceDictionary?.TextDictionary == nil {
                completion(data, nil)
                return
            }
            
//            var urls = [String?]()
//            for (key, value) in data!.VideoSentenceDictionary!.TextDictionary! {
//                if value.AudioUrl != nil {
//                    urls.append(value.AudioUrl)
//                }
//            }
            completion(data, nil)
//            AppUtil.downloadUrls(urls: urls) {
//                success in
//
//                completion(data, nil)
//
//                if success {
//                }
//                else {
//
//                    DDLogInfo("cache url error!")
//                }
//            }
            
        }
        
        RequestManager.shared.performRequest(urlRequest: Router.GetScenarioLesson(lessonPara(id, lang:AppData.lang), options), completionHandler: callback)

    }
    //获取学过的单词
    func GetScenarioLearnedItem(completion:@escaping (_ lesson: GetScenarioLearnedItemResult?, _ error: Error?) -> ()) {
        
        var options = [String:String]()
        options["get-scenario-learned-items"] = ""
        let callback:(GetScenarioLearnedItemResult?, Error?, String?)->() = {
            data, error, raw in
            if data == nil || raw == nil {
                completion(data, error)
                return
            }
            self.learnedWordMap.removeAll()
            self.learnedWordMap = data!.items ?? [learnedItemResult]()
            completion(data, nil)
        }
        
        RequestManager.shared.performRequest(urlRequest: Router.GetScenarioLesson(learnedWords(lessonCount: 5, language:AppData.lang), options), completionHandler: callback)
        
    }
    
    func getBasicLessonLockStatus() -> [Bool] {
        var result = [Bool]()
        if self.beginnerLessonInfo != nil {
            //默认第一组是已解锁的
            let lessons = self.beginnerLessonInfo.SubLessons!
            var lock = false
            for lesson in lessons {
                for sub in lesson.SubLessons! {
                    if sub.ScenarioLessonInfo?.LessonType == .PracticeLesson {
                        //判断learn
                        
                    }else {
                        //不是speak 就是 ChallengeLesson
                        if sub.ScenarioLessonInfo!.Tags!.contains("ChallengeLesson") {
                            if sub.ScenarioLessonInfo!.Progress! <= 0{
                                //CC 没做过
                                lock = true
                            }else {
                                //CC挑战成功了，前面的全部解锁
                                result = result.map({_ in false})
                                lock = false
                            }
                        }
                    }
                }
                result.append(lock)
            }
        }
        return result
    }
    func getBasicLessonCompletedStatus(index:Int) -> CompletedStatus {
        //未登录不显示进度
        if !UserManager.shared.isLoggedIn() {
            return .none
        }
        if self.beginnerLessonInfo == nil {
            return .none
        }
        let lesson = beginnerLessonInfo.SubLessons![index]
        var speak = -1
        var scenario = -1
        for sub in lesson.SubLessons! {
            if sub.ScenarioLessonInfo!.LessonType! == .PracticeLesson {
                speak = sub.ScenarioLessonInfo!.Progress!
            }
            if sub.ScenarioLessonInfo!.LessonType! == .ChatLesson
            {
                scenario = sub.ScenarioLessonInfo!.Progress!
            }
        }
        if speak >= 0 && scenario >= 0 {
            return CompletedStatus.both
        }
        if speak >= 0 {
            return .onlyLearn
        }
        if scenario >= 0 {
            return .onlySpeak
        }
        return .none
    }
 
    func prefetchLesson(completion:@escaping (_ success: Bool) -> ()) {
        if self.prefetchCount <= 0 {
            completion(true)
            return
        }
        //flaten 初级课和中级课 一起缓存
        var cacheScenarioList = [String]()
        for lesson in self.beginnerLessonInfo.SubLessons!.prefix(self.prefetchCount) {
            for sub in lesson.SubLessons! {
                cacheScenarioList.append(sub.ScenarioLessonInfo!.Id!)
            }
        }
        for lesson in self.mediumLessonInfo.SubLessons!.prefix(self.prefetchCount) {
            for sub in lesson.SubLessons! {
                cacheScenarioList.append(sub.ScenarioLessonInfo!.Id!)
            }
        }
        var cacheSpeakList = cacheScenarioList.map({$0.replacingOccurrences(of: "s-CN", with: "r-CN")})
        let group = DispatchGroup()
        for (i, lid) in cacheScenarioList.enumerated() {
            group.enter()
            getScenarioLessonInfo(id: lid) {
                data,error in
                if data == nil {
                    group.leave()
                    return
                }
                //cache urls
                var urls = [String?]()
                for (_, value) in data!.VideoSentenceDictionary!.TextDictionary! {
                    if value.AudioUrl != nil {
                        urls.append(value.AudioUrl)
                    }
                }
                
                AppUtil.downloadUrls(urls: urls) {
                    success in
                    group.leave()
                    if !success {
                        DDLogInfo("cache url error!")
                    }
                }
                
            }
            let speakId = cacheSpeakList[i]
            group.enter()
            getSpeakLessonInfo(id: speakId) {
                (data,error) in
                if (data == nil) {
                    group.leave()
                    return
                }
                var urls = [String?]()
                let quizs = data!.Lesson!.QuizzesList!
                for quiz in quizs {
                    if quiz.Quiz != nil {
                        urls.append(quiz.Quiz!.AudioUrl)
                    }
                }
                AppUtil.downloadUrls(urls: urls) {
                    success in
                    group.leave()
                    if !success {
                        DDLogInfo("cache url error!")
                    }
                    
                }
            }
        
        }
        group.notify(queue: DispatchQueue.main) {
            completion(true)
        }

    }
    
    //对录音进行打分,合并了repeat和Scenariod的打分

    func rateSpeechRepeat(lid:String, text:String, data:[Byte]?,completion:@escaping (_ model: SpeakingSpeechRatingResult?)->()) {
        let speechInput = SpeakingSpeechRatingInput(text: text, data: data, speechMimeType: "audio/amr", sampleRate: RecordManager.sharedInstance.sampleRate, lessonId: lid, lang: AppData.lang)
        
        var options = [String:String]()
        options["rate-speech.submit"] = ""
        options["without-audio"] = ""
        let callback:(JobInfo?, Error?, String?)->() = {
            data, error, raw in
            
            if data != nil {
                let jobId = data!.Id
                var ticker = 0
                if self.timer != nil {
                    self.timer.invalidate()
                }
                let rateClosure:(Timer) -> Void = {
                    _ in
                    ticker  += 1
                    if ticker > 20 {
                        self.timer.invalidate()
                        self.timer = nil
                        completion(nil)
                        return
                    }
                    var rOptions = [String:String]()
                    rOptions["rate-speech.receive"] = ""
                    
                    let receiveCompletion:(JobOutput<SpeakingSpeechRatingResult>?, Error?, String?)->() = {
                        receiveData, receiveError, raw in
                        if let rData = receiveData {
                            if self.timer != nil {
                                self.timer.invalidate()
                                self.timer = nil
                                var result = rData.Result
                                result!.SpeechScore! = result!.SpeechScore! < 90 ? result!.SpeechScore! + 10 : result!.SpeechScore!
                                completion(result)
                            }
                        }
                    }
                    RequestManager.shared.performRequest(urlRequest: Router.GetSpeakLesson(JobInput(id:jobId!), rOptions), completionHandler: receiveCompletion)
                }
                if #available(iOS 10.0, *) {
                    self.timer = Timer(timeInterval: 1, repeats: true, block: rateClosure)
                } else {
                    self.timer = Timer.schedule(timeInterval: 1, repeats: true, block: rateClosure)
                    // Fallback on earlier versions
                }
                RunLoop.current.add(self.timer, forMode: RunLoop.Mode.common)
            }
            else {
                completion(nil)
            }
        }
        RequestManager.shared.performRequest(urlRequest: Router.GetSpeakLesson(speechInput, options), completionHandler: callback)

    }
    
    func rateSpeechScenario(speechInput:Mappable, completion:@escaping (_ model: ScenarioChatRateResult?)->()) {
        var options = [String:String]()
        
        
        options["rate-chat.submit"] = ""
        options["without-audio"] = ""

        let callback:(JobInfo?, Error?, String?)->() = {
            data, error, raw in
            if data != nil {
                let jobId = data!.Id
                var ticker = 0
                if self.timer != nil {
                    self.timer.invalidate()
                }
                let rateClosure:(Timer) -> Void = {
                    _ in
                    ticker  += 1
                    var rOptions = [String:String]()
                    
                    if ticker > 12 {
                        self.timer.invalidate()
                        self.timer = nil
                        completion(nil)
                        return
                    }
                    
                    rOptions["rate-chat.receive"] = ""
                    
                    let receiveCompletion:(JobOutput<ScenarioChatRateResult>?, Error?, String?)->() = {
                        receiveData, receiveError, raw in
                        if let rData = receiveData {
                            if self.timer != nil {
                                self.timer.invalidate()
                                self.timer = nil
                                let result = rData.Result
                                completion(result)
                            }
                        }
                    }
                    RequestManager.shared.performRequest(urlRequest: Router.GetScenarioLesson(JobInput(id:jobId!), rOptions), completionHandler: receiveCompletion)
                }
                if #available(iOS 10.0, *) {
                    self.timer = Timer(timeInterval: 1, repeats: true, block: rateClosure)
                } else {
                    self.timer = Timer.schedule(timeInterval: 1, repeats: true, block: rateClosure)
                    // Fallback on earlier versions
                }
                RunLoop.current.add(self.timer, forMode: RunLoop.Mode.common)
            }
            else {
                completion(nil)
            }
        }
        RequestManager.shared.performRequest(urlRequest: Router.GetScenarioLesson(speechInput, options), completionHandler: callback)
    }

}


