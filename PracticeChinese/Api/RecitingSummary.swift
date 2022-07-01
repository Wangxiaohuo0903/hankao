import Foundation
import ObjectMapper

class RecitingSummary : Mappable
{
var FinishedCount : Int?

var LearningCount : Int?

var CheckinDays : Int?

var ConsecutiveCheckinDays : Int?

var StreakCheckinDays : Int?

var LastCheckinDateMark : Int?

required init?(map: Map)
{
}

func mapping(map: Map)
{
FinishedCount <- map["finishedCount"]
LearningCount <- map["learningCount"]
CheckinDays <- map["checkinDays"]
ConsecutiveCheckinDays <- map["ConsCheckinDays"]
StreakCheckinDays <- map["streakCheckinDays"]
LastCheckinDateMark <- map["lastCheckinDateMark"]
}
}

