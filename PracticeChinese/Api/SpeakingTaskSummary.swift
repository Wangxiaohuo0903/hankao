import Foundation
import ObjectMapper

class SpeakingTaskSummary : Mappable
{
var Date : Date?

var Duration : TimeInterval?

var Checkin : Bool?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Date <- map["date"]
Duration <- map["duration"]
Checkin <- map["checkin"]
}
}

