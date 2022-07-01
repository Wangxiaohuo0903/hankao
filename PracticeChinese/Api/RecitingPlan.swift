import Foundation
import ObjectMapper

class RecitingPlan : Mappable
{
var PlanId : String?

var GlossaryId : String?

var DailyCount : Int?

var FinishedCount : Int?

var LearningCount : Int?

var TotalCount : Int?

required init?(map: Map)
{
}

func mapping(map: Map)
{
PlanId <- map["pid"]
GlossaryId <- map["gid"]
DailyCount <- map["dailyCount"]
FinishedCount <- map["finishedCount"]
LearningCount <- map["learningCount"]
TotalCount <- map["totalCount"]
}
}

