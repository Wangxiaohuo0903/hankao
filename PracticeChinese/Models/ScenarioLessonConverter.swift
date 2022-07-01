//
//  ScenarioLessonConverter.swift
//  ChineseLearning
//
//  Created by feiyue on 19/04/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import ObjectMapper

class ScenarioLessonConverter : TransformType {
    public typealias Object = ScenarioLesson
    public typealias JSON = String
    
    public init() {}
    
    func transformFromJSON(_ value: Any?) -> ScenarioLesson? {
        
        if let dictionaryObject = value as? Dictionary<String, Any?>  {
            if let type = dictionaryObject["type"] as? Int {
                switch type {
                case ScenarioLessonType.LearningLesson.rawValue:
                    return Mapper<LearningScenarioLesson>().map(JSONObject: dictionaryObject)
                case ScenarioLessonType.PracticeLesson.rawValue:
                    return Mapper<PracticeScenarioLesson>().map(JSONObject: dictionaryObject)
                case ScenarioLessonType.ChapterLesson.rawValue:
                    return Mapper<ChapterLesson>().map(JSONObject: dictionaryObject)
                case ScenarioLessonType.PartLesson.rawValue:
                    return Mapper<PartLesson>().map(JSONObject: dictionaryObject)
                default:
                    return Mapper<ScenarioLesson>().map(JSONObject: dictionaryObject)
                }
            }
            else {
                return nil
            }
        }
        return nil
        
    }
    func transformToJSON(_ value: ScenarioLesson?) -> String? {
        return value?.toJSONString()
    }
    
    
}

