import Foundation
import ObjectMapper

class RecitingSummaryResult : ResultContract
{
var FinishedCount : Int?

var LearningCount : Int?

var CheckinDays : Int?

var StreakCheckinDays : Int?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
FinishedCount <- map["finishedCount"]
LearningCount <- map["learningCount"]
CheckinDays <- map["checkinDays"]
StreakCheckinDays <- map["streakCheckinDays"]
}
}

