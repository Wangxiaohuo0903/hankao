import Foundation
import ObjectMapper

class RecitingPlanDailySummariesResult : ResultContract
{
var PlanId : String?

var Summaries : [RecitingPlanDailySummary]?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
PlanId <- map["pid"]
Summaries <- map["summaries"]
}
}

