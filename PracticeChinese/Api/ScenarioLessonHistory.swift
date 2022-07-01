import Foundation
import ObjectMapper

class ScenarioLessonHistory : Mappable
{
var Lesson : ScenarioLessonAbstract?

var UpdateTime : Date?

var BestScore : Int?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Lesson <- (map["lessonInfo"], ScenarioLessonAbstractConverter())
UpdateTime <- map["updateTime"]
BestScore <- map["bestScore"]
}
}

