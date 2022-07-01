//
//  ListScenarioLessonAbstractConverter.swift
//  ChineseLearning
//
//  Created by feiyue on 18/04/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import ObjectMapper

class ListScenarioLessonAbstractConverter : TransformType {

    public typealias Object = [ScenarioLessonAbstract]
    public typealias JSON = String
    
    public init() {}
    
    func transformFromJSON(_ value: Any?) -> [ScenarioLessonAbstract]? {
        var result = [ScenarioLessonAbstract]()
        if let dictionaryList = value as? [Dictionary<String, Any?>]  {
            for dictionaryObject in dictionaryList {
            if let type = dictionaryObject["type"] as? Int {
                switch type {
                case ScenarioLessonType.LearningLesson.rawValue:
                    result.append(Mapper<UserScenarioLessonAbstract>().map(JSONObject: dictionaryObject)!)
                case ScenarioLessonType.PracticeLesson.rawValue:
                    result.append(Mapper<UserScenarioLessonAbstract>().map(JSONObject: dictionaryObject)!)
                case ScenarioLessonType.ChapterLesson.rawValue:
                    result.append(Mapper<UserScenarioLessonAbstract>().map(JSONObject: dictionaryObject)!)
                case ScenarioLessonType.PartLesson.rawValue:
                    result.append(Mapper<UserScenarioLessonAbstract>().map(JSONObject: dictionaryObject)!)
                default:
                    result.append(Mapper<UserScenarioLessonAbstract>().map(JSONObject: dictionaryObject)!)
                }
                }
            }
        }
        return result

    }
    func transformToJSON(_ value: [ScenarioLessonAbstract]?) -> String? {
        return value?.toJSONString()
    }
}

