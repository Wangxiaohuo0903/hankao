import Foundation
import ObjectMapper

class RecitingDailySummary : RecitingPlanDailySummary
{
var PlanId : String?

var GlossaryId : String?

var GlossaryName : String?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
PlanId <- map["pid"]
GlossaryId <- map["gid"]
GlossaryName <- map["glosName"]
}
}

