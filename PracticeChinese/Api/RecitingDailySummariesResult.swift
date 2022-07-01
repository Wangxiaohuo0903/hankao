import Foundation
import ObjectMapper

class RecitingDailySummariesResult : ResultContract
{
var Summaries : [[RecitingDailySummary]]?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Summaries <- map["summaries"]
}
}

