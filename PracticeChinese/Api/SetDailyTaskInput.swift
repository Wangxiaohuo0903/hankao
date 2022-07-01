import Foundation
import ObjectMapper

class SetDailyTaskInput : MultilingualInput
{
var TargetSeconds : Int?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
TargetSeconds <- map["tarSeconds"]
}
}

