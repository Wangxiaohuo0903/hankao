import Foundation
import ObjectMapper

class ListScenarioLessonsResult : SpeakingResult
{
var ScenarioLessonInfo : UserScenarioLessonAbstract?

var SubLessons : [ScenarioSubLesson]?

var RootLessonInfo : ScenarioSubLessonInfo?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
//ScenarioLessonInfo <- (map["lessonInfo"], ScenarioLessonAbstractConverter())
ScenarioLessonInfo <- map["lessonInfo"]
SubLessons <- map["subLessons"]
RootLessonInfo <- map["rootLesson"]
}
}

