import Foundation
import ObjectMapper

class RecitingPlanDailySummary : Mappable
{
var Date : Date?

var AssignedWordCount : Int?

var FinishedWordCount : Int?

var NewWordCount : Int?

var Checkin : Bool?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Date <- map["date"]
AssignedWordCount <- map["assignedCount"]
FinishedWordCount <- map["finishedCount"]
NewWordCount <- map["newCount"]
Checkin <- map["checkin"]
}
}

