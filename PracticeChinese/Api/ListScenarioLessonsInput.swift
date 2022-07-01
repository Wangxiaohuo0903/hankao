import Foundation
import ObjectMapper

class ListScenarioLessonsInput : MultilingualInput
{
var LessonId : String?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
LessonId <- map["lid"]
}
}

