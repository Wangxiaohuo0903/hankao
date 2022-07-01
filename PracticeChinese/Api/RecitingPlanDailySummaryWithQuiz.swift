import Foundation
import ObjectMapper

class RecitingPlanDailySummaryWithQuiz : RecitingPlanDailySummary
{
var QuizzedCount : Int?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
QuizzedCount <- map["qizzedCount"]
}
}

