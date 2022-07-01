import Foundation
import ObjectMapper

class ScenarioLessonAbstractConverter : TransformType {
    public typealias Object = ScenarioLessonAbstract
    public typealias JSON = String
    
    public init() {}
    
    func transformFromJSON(_ value: Any?) -> ScenarioLessonAbstract? {
        
        if let dictionaryObject = value as? Dictionary<String, Any?>  {
            if let type = dictionaryObject["type"] as? Int {
                switch type {
                case ScenarioLessonType.LearningLesson.rawValue:
                    return Mapper<UserScenarioLessonAbstract>().map(JSONObject: dictionaryObject)
                case ScenarioLessonType.PracticeLesson.rawValue:
                    return Mapper<UserScenarioLessonAbstract>().map(JSONObject: dictionaryObject)
                case ScenarioLessonType.ChapterLesson.rawValue:
                    return Mapper<UserScenarioLessonAbstract>().map(JSONObject: dictionaryObject)
                case ScenarioLessonType.PartLesson.rawValue:
                    return Mapper<PartLesson>().map(JSONObject: dictionaryObject)
                default:
                    return Mapper<UserScenarioLessonAbstract>().map(JSONObject: dictionaryObject)
                }
            }
            else {
                return nil
            }
        }
        return nil
        
    }
    func transformToJSON(_ value: ScenarioLessonAbstract?) -> String? {
        return value?.toJSONString()
    }

    
}

