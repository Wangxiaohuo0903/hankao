import Foundation
import ObjectMapper

class SetScenarioDailyTaskInput : MultilingualInput
{
var TargetLessonCount : Int?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
TargetLessonCount <- map["tarLessonCount"]
}
}

