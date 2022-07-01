//
//  UserExpManager.swift
//  PracticeChinese
//
//  Created by summer on 2017/9/18.
//  Copyright © 2017年 msra. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire
import SwiftyJSON

class UserExpManager: NSObject {
    var scenarioTaskSummary:GetScenarioTaskSummaryResult!
    var nowDateFrame:DateFrame!
    var totalDateFrame:DateFrame!
    
    var dailySpeakDuration:Int!
    var totalSpeakDuration:Int!
    var lastspeakDurationLevelBar:Int!
    var nextspeakDurationLevelBar:Int!
    var speakDurationLevel:Int!
    var currentTotalSpeakDuration:Int!

    
    var lastExpLevelBar:Int!
    var nextExpLevelBar:Int!
    var exp:Int!
    var expLevel:Int!
    var coin:Int!
    static var shared = UserExpManager()
    
    func initUserExp(completion: @escaping (Bool?)->()){
        CacheDataManager.shared.initUser(finish: {
            (finish) in
            if(finish)!{
                var totalDuration = CacheDataManager.shared.userSummary.TotalDuration?.characters.split(separator: ":").map(String.init)
                var duration = CacheDataManager.shared.userSummary.Duration?.characters.split(separator: ":").map(String.init)
                if(totalDuration?.count == 3){
                    var sec = (totalDuration?[2] as! NSString).integerValue
                    var min = (totalDuration?[1] as! NSString).integerValue
                    var hor = (totalDuration?[0] as! NSString).integerValue
                    self.totalSpeakDuration = sec + 60*(min+60*hor)
                }else{
                    self.totalSpeakDuration = 0
                }
                
                if(duration?.count == 3){
                    var sec = (duration?[2] as! NSString).integerValue
                    var min = (duration?[1] as! NSString).integerValue
                    var hor = (duration?[0] as! NSString).integerValue
                    self.dailySpeakDuration = sec + 60*(min+60*hor)
                }else{
                    self.dailySpeakDuration = 0
                }
                self.exp = CacheDataManager.shared.userInfo.Exp
                self.expLevel = CacheDataManager.shared.userInfo.ExpLevel
                self.coin = CacheDataManager.shared.userInfo.Coin
                self.lastExpLevelBar = CacheDataManager.shared.userInfo.LastExpLevelBar
                self.nextExpLevelBar = CacheDataManager.shared.userInfo.NextExpLevelBar
                self.getSpeakLevel()
//                self.logExp()
                completion(true)
            }else{
                self.coin = 0
                self.exp = 0
                self.expLevel = 0
                self.lastExpLevelBar = 0
                self.nextExpLevelBar = 0
                self.speakDurationLevel = 0
                self.lastspeakDurationLevelBar = 0
                self.nextspeakDurationLevelBar = 0
                self.dailySpeakDuration = 0
                self.totalSpeakDuration = 0
//                print("intExpError!!!")
                completion(false)
            }
        })
    }
    
    func getSpeakLevel(){
        var temp = self.totalSpeakDuration/30 + 1
        self.speakDurationLevel = -1
        while(temp>0){
            temp = temp/2
            self.speakDurationLevel = self.speakDurationLevel+1
        }
        if(self.speakDurationLevel == 0){
            self.lastspeakDurationLevelBar = 0
        }else{
            self.lastspeakDurationLevelBar = Int((pow(Double(2), Double(self.speakDurationLevel))-1)*30)
        }
        self.nextspeakDurationLevelBar = Int((pow(Double(2), Double(self.speakDurationLevel)+1)-1)*30)
        self.currentTotalSpeakDuration = self.totalSpeakDuration - self.lastspeakDurationLevelBar
    }
    
    func logExp(){
//        print("getExpSuccess!!")
//        print("exp:"+String(self.exp))
//        print("expLevel:"+String(self.expLevel))
//        print("lastExpLevelBar:"+String(self.lastExpLevelBar))
//        print("nextExpLevelBar:"+String(self.nextExpLevelBar))
//        print("dailySpeakSentences:"+String(self.dailySpeakDuration))
//        print("totalSpeakSentences:"+String(self.totalSpeakDuration))
//        print("dailySpeakSentences:"+String(self.nextspeakDurationLevelBar))
//        print("totalSpeakSentences:"+String(self.lastspeakDurationLevelBar))
//        print("totalSpeakSentences:"+String(self.speakDurationLevel))
    }
}
