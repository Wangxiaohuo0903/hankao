import Foundation
import ObjectMapper

class RecitingUpdatePlanInput : MultilingualInput
{
var PlanId : String?

var GlossaryId : String?

var DailyCount : Int?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
PlanId <- map["pid"]
GlossaryId <- map["gid"]
DailyCount <- map["dailyCount"]
}
}

