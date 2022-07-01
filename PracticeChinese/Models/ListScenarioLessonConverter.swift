//
//  ListScenarioLessonConverter.swift
//  ChineseLearning
//
//  Created by feiyue on 19/04/2017.
//  Copyright © 2017 msra. All rights reserved.
//


import Foundation
import ObjectMapper

class ListScenarioLessonConverter : TransformType {
    
    public typealias Object = [ScenarioLesson]
    public typealias JSON = String
    
    public init() {}
    
    func transformFromJSON(_ value: Any?) -> [ScenarioLesson]? {
        var result = [ScenarioLesson]()
        if let dictionaryList = value as? [Dictionary<String, Any?>]  {
            for dictionaryObject in dictionaryList {
                
                if let type = dictionaryObject["type"] as? Int {
                        switch type {
                        case ScenarioLessonType.LearningLesson.rawValue:
                            result.append(Mapper<LearningScenarioLesson>().map(JSONObject: dictionaryObject)!)
                        case ScenarioLessonType.PracticeLesson.rawValue:
                            result.append(Mapper<PracticeScenarioLesson>().map(JSONObject: dictionaryObject)!)
                        case ScenarioLessonType.ChapterLesson.rawValue:
                            result.append(Mapper<ChapterLesson>().map(JSONObject: dictionaryObject)!)
                        case ScenarioLessonType.PartLesson.rawValue:
                            result.append(Mapper<PartLesson>().map(JSONObject: dictionaryObject)!)
                        default:
                            result.append(Mapper<ScenarioLesson>().map(JSONObject: dictionaryObject)!)
                        }
                }
            }
        }
        return result
        
    }
    func transformToJSON(_ value: [ScenarioLesson]?) -> String? {
        return value?.toJSONString()
    }
}

