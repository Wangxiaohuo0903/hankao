//
//  CacheManagerofUser.swift
//  PracticeChinese
//
//  Created by summer on 2017/9/26.
//  Copyright © 2017年 msra. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import SwiftyJSON
import CocoaLumberjack

class CacheDataManager: NSObject {
    
    var islogin:Bool!
    var loginAccountType:LoginAccountType!
    var userModel:UserModel!
    var userAvatar:URL!
    var userName:String!
    var userId:String!
    var userInfo:AccountInfo!
    var userSummary:GetScenarioTaskSummaryResult!
//    var userLearnedWords:
//    var userCompleteLessons:
//   var userRecordings:[LessonRecord]! = []
    
    static var shared = CacheDataManager()
    
    func initUser(finish: @escaping (Bool?)->()){
        self.userInfo = Mapper<AccountInfo>().map(JSON: [String:String]())
        self.userSummary = Mapper<GetScenarioTaskSummaryResult>().map(JSON: [String:String]())
        if(UserManager.shared.isLoggedIn()){
            self.setupUser(completion: {
                (completion) in
                if(completion)!{
                    self.log()
                    finish(completion)
                }else{
                    self.log()
                    finish(completion)
                }
            })
        }else{
            self.setupDefault(completion: {
                (completion) in
                self.log()
                finish(true)
                })
        }
    }
    
    func setupDefault(completion: @escaping (Bool?)->()){
        self.readUserModel()
        if(self.userInfo != nil){
            self.userInfo.setDefault()
        }
        if(self.userSummary != nil){
            self.userSummary.setDefault()
        }
        completion(true)
        
    }
    
    func setupUser(completion: @escaping (Bool?)->()){
        self.readUserModel()
        self.getUserInfo(completionInfo: {
            (completionInfo) in
            
            if(completionInfo)!{
                DDLogInfo("getInfoSuccess!")
                self.getUserSummary(completionSummary: {
                    (completionSummary) in
                    if(completionSummary)!{
                        self.setupWords()
                        self.setupLessons()
                    }else{
                        DDLogInfo("getSummaryError!")
                    }
                    completion(completionSummary)
                })
            }else{
                DDLogInfo("getInfoError!")
                completion(false)
            }
        })
    }
    
    func setupWords(){
        
    }
    
    func setupLessons(){
        
    }
    
    func readUserModel(){
        self.islogin = UserManager.shared.isLoggedIn()
        self.loginAccountType = UserManager.shared.getAccountType()
        self.userModel = UserManager.shared.getUserModel()
        self.userAvatar = UserManager.shared.getAvatarUrl()
        self.userName = UserManager.shared.getName()
        self.userId = UserManager.shared.getUserId()
    }
    
    func getUserInfo(completionInfo: @escaping (Bool?)->()){
        
        let callback: (AccountInfo?, Error?, String?)->() = {
            data, error, raw in
            if(data != nil){
                self.userInfo = data
                
                var privacy = self.userInfo!.PrivacyLevel ?? 0
                if privacy > 0 {
                    privacy -= 1
                }
                if (privacy & 2) == 2  {
                    AppData.setUserAssessment(true, false)
                }
                if (privacy & 1) == 1  {
                    AppData.setUserExperience(true, false)
                }
                completionInfo(true)
            }else{
                completionInfo(false)
            }
        }
        
        RequestManager.shared.performRequest(urlRequest: Router.getUserInfo, completionHandler: callback)
    }

    func getUserSummary(completionSummary: @escaping (Bool?)->()){
        var IndexesDaily = HistoryManager.shared.getDailyInfo(1)[0]
        var options = [String:String]()
        options["get-scenario-task-summary"] = ""
        
        let taskInputDaily = Mapper<GetScenarioTaskSummaryInput>().map(JSON: [String:String]())
        taskInputDaily?.Start = IndexesDaily.start
        taskInputDaily?.End = IndexesDaily.end
        taskInputDaily?.Language = AppData.lang
        
        let callback:(GetScenarioTaskSummaryResult?, Error?, String?)->() = {
            data, error, raw in
            if(data != nil){
                self.userSummary = data
                completionSummary(true)
            }else{
                completionSummary(false)
            }
        }
        RequestManager.shared.performRequest(urlRequest: Router.GetScenarioLesson(taskInputDaily!, options), completionHandler: callback)
    }
    
    func log(){
    }
    
    func userSignIn(){
        self.setupUser(completion: {
            (completion) in
            DDLogInfo("SignInSuccess")
        })
    }
    
    func userSignOut(){
        self.setupDefault(completion: {
            (completion) in
        })
    }
    
}
