import Foundation
import ObjectMapper

class RecitingPlanTodaySummaryResult : ResultContract
{
var PlanId : String?

var Summary : RecitingPlanDailySummaryWithQuiz?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
PlanId <- map["pid"]
Summary <- map["summary"]
}
}

