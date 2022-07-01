import Foundation
import ObjectMapper

class RecitingAddPlanInput : MultilingualInput
{
var GlossaryId : String?

var DailyCount : Int?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
GlossaryId <- map["gid"]
DailyCount <- map["dailyCount"]
}
}

