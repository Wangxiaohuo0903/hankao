import Foundation
import ObjectMapper

class GetScenarioLessonHistoryResult : SpeakingResult
{
var History : [ScenarioLessonHistory]?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
History <- map["history"]
}
}

