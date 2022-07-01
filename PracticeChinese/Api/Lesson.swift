import Foundation
import ObjectMapper

class Lesson : LessonAbstract
{
var VideoBackgroundImg : String?

var QuizzesList : [SpeakQuizBase]?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
VideoBackgroundImg <- map["videoBackgroundImg"]
QuizzesList <- (map["quizzes"], LessonQuizConverter())
}
}

class LessonQuizConverter: TransformType {
    public typealias Object = SpeakQuizBase
    public typealias JSON = String
    
    public init() {}
    
    func transformFromJSON(_ value: Any?) -> SpeakQuizBase? {
        
        if let dictionaryObject = value as? Dictionary<String, Any?>  {
            if let type = dictionaryObject["type"] as? Int {
                switch type {
                case 0:
                    return Mapper<UserQuiz>().map(JSONObject: dictionaryObject)
                default:
                    return Mapper<SpeakQuizBase>().map(JSONObject: dictionaryObject)
                }
            }
            else {
                return nil
            }
        }
        return nil
        
    }
    func transformToJSON(_ value: SpeakQuizBase?) -> String? {
        return value?.toJSONString()
    }
}

