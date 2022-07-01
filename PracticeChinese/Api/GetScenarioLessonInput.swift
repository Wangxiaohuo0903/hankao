import Foundation
import ObjectMapper

class GetScenarioLessonInput : MultilingualInput
{
var ScenarioLessonId : String?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
ScenarioLessonId <- map["lid"]
}
}

