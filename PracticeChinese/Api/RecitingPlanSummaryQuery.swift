import Foundation
import ObjectMapper

class RecitingPlanSummaryQuery : MultilingualInput
{
var PlanId : String?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
PlanId <- map["pid"]
}
}

