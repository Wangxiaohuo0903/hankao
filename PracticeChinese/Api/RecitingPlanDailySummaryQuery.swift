import Foundation
import ObjectMapper

class RecitingPlanDailySummaryQuery : MultilingualInput
{
var PlanId : String?

var Start : Date?

var End : Date?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
PlanId <- map["pid"]
Start <- map["start"]
End <- map["end"]
}
}

