//
//  PhonemeLessonConverter.swift
//  ChineseLearning
//
//  Created by ThomasXu on 03/05/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import ObjectMapper

class PhonemeLessonConverter: TransformType {
    
    public typealias Object = Lesson
    public typealias JSON = String
    
    public init() {}
    
    func transformFromJSON(_ value: Any?) -> Lesson? {
        
        if let dictionaryObject = value as? Dictionary<String, Any?>  {
            if let type = dictionaryObject["type"] as? Int {
                switch type {
                case LessonType.PhonemeLesson.rawValue:
                    return Mapper<PhonemeLesson>().map(JSONObject: dictionaryObject)
                case LessonType.PracticeLesson.rawValue:
                    return Mapper<PracticeLesson>().map(JSONObject: dictionaryObject)
                case LessonType.ReadAfterMeLesson.rawValue:
                    return Mapper<ReadAfterMeLesson>().map(JSONObject: dictionaryObject)

                default:
                    return Mapper<Lesson>().map(JSONObject: dictionaryObject)
                }
            }
            else {
                return nil
            }
        }
        return nil
        
    }
    func transformToJSON(_ value: Lesson?) -> String? {
        return value?.toJSONString()
    }
}
