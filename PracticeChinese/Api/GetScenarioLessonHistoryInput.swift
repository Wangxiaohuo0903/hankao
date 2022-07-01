import Foundation
import ObjectMapper

class GetScenarioLessonHistoryInput : MultilingualInput
{
var Start : Date?

var End : Date?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Start <- map["start"]
End <- map["end"]
}
}

