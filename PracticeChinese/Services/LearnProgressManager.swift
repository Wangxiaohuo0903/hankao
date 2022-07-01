//
//  LearnProgressManager.swift
//  PracticeChinese
//
//  Created by ThomasXu on 21/07/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation

//这个类主要负责对学习进度进行管理，如获取今天学习了多少课

class LearnProgressManager {
    private var year: Int!
    private var month: Int!
    private var day: Int!
    private var planLessonCount = 0
    private  var finishedLessonCount = 0
    private let mapKey = UserDefaultsKeyManager.learnProgress
    private let userDefault = UserDefaults.standard
    private let defaultLessonCount = 2
    
    static var shared: LearnProgressManager = {
        let instance = LearnProgressManager()
        return instance
    }()
    
    init() {
        self.updateDate()
        let (y, m, d, t, f) = self.getDataFromLocal()
        finishedLessonCount = 0//默认完成为0
        planLessonCount = t
        if year == y && month == m && day == d {
            finishedLessonCount = f
        }
    }
    
    func updateDate() {
        let (y, m, d) = getDate()
        self.year = y
        self.month = m
        self.day = d
    }
    
    //从本地加载之前保存的数据
    func getDataFromLocal() -> (year: Int, month: Int, day: Int, total: Int, finished: Int){
        var year = 0, month = 0, day = 0, total = defaultLessonCount, finished = 0
        if let rawValue = userDefault.object(forKey: mapKey) {
            let value = rawValue as! [Int]
            year = value[0]
            month = value[1]
            day = value[2]
            total = value[3]
            finished = value[4]
        }
        return (year, month, day, total, finished)
    }
    
    //添加已经完成的课程
    func addFinishedLesson() {
        let (y, m, d) = self.getDate()
        if y == year && m == month && day == day {
            self.finishedLessonCount += 1
            self.saveToLocal()
        } else {
            self.updateDate()
            self.finishedLessonCount = 1
            self.saveToLocal()
        }
    }
    
    func updateDailyPlan(count: Int) {
        self.planLessonCount = count
        self.saveToLocal()
    }
    
    func clearDailyPlan() {
        self.finishedLessonCount = 0
        self.planLessonCount = defaultLessonCount
        self.saveToLocal()
    }
    
    //
    func getCurrentProgress() -> CGFloat {
        let temp = CGFloat(self.finishedLessonCount) / CGFloat(self.planLessonCount)
        return temp
    }
    
    //根据当前剩下未完成的目标返回相应的字符串
    func getLeftDailyGoalString() -> String {
        let temp = self.planLessonCount - self.finishedLessonCount
        if (temp > 0) {
            return "You need to complete \(temp) more lessons to achieve your daily goal. Keep going!"
        }
        return "Daily goal achieved! Congratulations!"
    }
    
    func saveToLocal() {
        let array = [year, month, day, planLessonCount, finishedLessonCount]
        userDefault.set(array, forKey: mapKey)
        userDefault.synchronize()
    }

    
    func getDate() -> (year: Int, month: Int, day: Int) {
        let date = Date()
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        return (year, month, day)
    }
}

class UserDefaultsKeyManager {
    static let chineseandpinyin = "chineseandpinyin"
    static let learnProgress = "LearnDailyProgress"
    static let cacheManager = "CacheManagerCachedFiles"
    
    static let handsFreeModeBeginnerGuide = "bgHandsFree"
    static let homeBeginnerGuideDrive = "bgHomeDrive"
    static let homeBeginnerGuideSetPlan = "bgHomeSetPlan"
    static let homeBeginnerAlertLoginView = "bgHomeAlertLoginView"
    static let scenarioBeginnerGuideWordButton = "bgScenarioButton"
    static let scenarioBeginnerGuideRecording = "bgScenarioRecording"
    static let repeatBeginnerGuideRecording = "bgRepeatRecording"
    static let readBeginnerGuideRecording = "bgReadAfterMeRecording"
    static let hintBeginnerGuideRecording = "bghintView"
    static let readAudio = "readAudio"//选择正确选项之后读取语音
    
}
