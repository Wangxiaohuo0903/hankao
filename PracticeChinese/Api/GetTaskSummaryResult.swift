import Foundation
import ObjectMapper

class GetTaskSummaryResult : SpeakingResult
{
var Date : Date?

var StreakCheckinDays : Int?

var Checkin : Bool?

var TargetDuration : TimeInterval?

var Duration : TimeInterval?

var TotalSpeakSentences : Int?

var FinishedLessons : [String]?

var TriedLessons : [String]?

var TotalDuration : TimeInterval?

var CheckinDays : Int?

var HistoryTasks : [SpeakingTaskSummary]?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Date <- map["date"]
StreakCheckinDays <- map["streakCheckinDays"]
Checkin <- map["checkin"]
TargetDuration <- map["tarDuration"]
Duration <- map["duration"]
TotalSpeakSentences <- map["triedSentenceCount"]
FinishedLessons <- map["finishedLessons"]
TriedLessons <- map["triedLessons"]
TotalDuration <- map["totalDuration"]
CheckinDays <- map["checkinDays"]
HistoryTasks <- map["history"]
}
}

