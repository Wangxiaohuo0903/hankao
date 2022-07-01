import Foundation
import ObjectMapper

class ReadAfterMeLesson : Lesson
{
var LearningItems : [ScenarioLessonLearningItem]?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
LearningItems <- map["learningItem"]
}
}

