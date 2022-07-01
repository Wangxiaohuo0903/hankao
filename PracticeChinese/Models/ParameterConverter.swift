//
//  ParameterConverter.swift
//  PracticeChinese
//
//  Created by feiyue on 20/06/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import ObjectMapper

class lessonPara:Mappable {
    var lessonId:String?
    var language:String?
    required init?(map: Map) {
    }
    func mapping(map: Map) {
        lessonId <- map["lid"]
        language <- map["lang"]
    }
    init(_ lid:String, lang:String) {
        self.lessonId = lid
        self.language = lang
    }
}

class updateScenarioLessonProgressPara : Mappable {
    var Delta: Int?
    var LessonId: String?
    var language: String?
    
    init(delta:Int, lessonId: String, language:String) {
        self.Delta = delta
        self.LessonId = lessonId
        self.language = language
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        Delta <- map["delta"]
        LessonId <- map["lid"]
        language <- map["lang"]
    }
}

class learnedWords : Mappable {
    var lessonCount: Int?
    var language: String?
    
    init(lessonCount:Int, language:String) {
        self.lessonCount = lessonCount
        self.language = language
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        lessonCount <- map["lessonCount"]
        language <- map["lang"]
    }
}

class UpdateScenarioCourseFavoritePara : Mappable {
    
    var PlanId: String?
    var PlanName: String?
    var AddLessons: [String]?
    var DeleteLessons: [String]?
    var language: String?
    
    init(addIds: [String], deleteIds: [String], language: String) {
        self.PlanId = "favorite"
        self.PlanName = "favorite"
        self.AddLessons = addIds
        self.DeleteLessons = deleteIds
        self.language = language
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        
        PlanId <- map["pid"]
        PlanName <- map["pname"]
        AddLessons <- map["addLessons"]
        DeleteLessons <- map["deleteLessons"]
        language <- map["lang"]
    }
}


class JobInput:Mappable {
    var Id:String?
    
    required init?(map: Map) {
    }
    
    init(id:String) {
        self.Id = id
    }
    
    func mapping(map: Map) {
        Id <- map["id"]
    }
}

class chatRateInput : Mappable
{
    var Text : String?
    
    var Question : String?
    
    var Keywords : [String]?
    
    var ExpectedAnswer : String?
    
    var Speech : [Byte]?
    
    var SpeechMimeType : String?
    
    var SampleRate : Int?
    
    var LessonId : String?
    
    var language: String?
    
    required init?(map: Map)
    {
    }
    
    init(text:String, question:String, keywords:[String], expectedAnswer:String, data:[Byte]?, speechMimeType:String, sampleRate:Int, lessonId:String, language:String) {
        self.Text = text
        self.Question = question
        self.Keywords = keywords
        self.ExpectedAnswer = expectedAnswer
        self.Speech = data
        self.SpeechMimeType = speechMimeType
        self.SampleRate = sampleRate
        self.LessonId = lessonId
        self.language = language
    }
    
    init(question:String, keywords:[String], expectedAnswer:String, data:[Byte]?, speechMimeType:String, sampleRate:Int, lessonId:String, language:String) {
        self.Question = question
        self.Keywords = keywords
        self.ExpectedAnswer = expectedAnswer
        self.Speech = data
        self.SpeechMimeType = speechMimeType
        self.SampleRate = sampleRate
        self.LessonId = lessonId
        self.language = language
    }
    
    func mapping(map: Map)
    {
        Text <- map["text"]
        Question <- map["question"]
        Keywords <- map["keywords"]
        ExpectedAnswer <- map["expectedAnswer"]
        Speech <- map["speech"]
        SpeechMimeType <- map["speechMimeType"]
        SampleRate <- map["sampleRate"]
        LessonId <- map["lid"]
        language <- map["lang"]
    }
}




class DictionaryWrapper: Mappable {
    var version:String?
    var timestamp:String?
    var data:[String:Any]?
    
    required init?(map: Map) {
    }
    func mapping(map: Map) {
        version     <- map["v"]
        timestamp   <- map["ts"]
        data        <- map["data"]
    }
    init(_ version:String, data:[String:Any]?) {
        self.version = version
        self.data = data
        let TSFormat = DateFormatter()
        TSFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        self.timestamp = TSFormat.string(from: Date())
    }
    init(_ version:String, data:[String:Int]?) {
        self.version = version
        self.data = data
        let TSFormat = DateFormatter()
        TSFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        self.timestamp = TSFormat.string(from: Date())
    }

}
