import Foundation
import ObjectMapper

class ScenarioTaskSummary : Mappable
{
var Date : String?

var FinishedLessons : [String]?

var Checkin : Bool?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Date <- map["date"]
FinishedLessons <- map["finishedLessons"]
Checkin <- map["checkin"]
}
}

