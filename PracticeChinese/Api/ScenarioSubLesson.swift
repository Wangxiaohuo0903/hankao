import Foundation
import ObjectMapper

class ScenarioSubLesson : Mappable
{
var ScenarioLessonInfo : ScenarioLessonAbstract?

var SubLessons : [ScenarioLessonAbstract]?

required init?(map: Map)
{
}

func mapping(map: Map)
{
ScenarioLessonInfo <-  (map["lessonInfo"], ScenarioLessonAbstractConverter())
SubLessons <- (map["subLessons"], ListScenarioLessonAbstractConverter())
}
}

