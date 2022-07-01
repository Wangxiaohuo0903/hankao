import Foundation
import ObjectMapper

class GetScenarioTaskSummaryResult : SpeakingResult
{
var Date : String?

var StreakCheckinDays : Int?

var Checkin : Bool?

var TargetLessonCount : Int?

var Duration : String?

var TotalSpeakSentences : Int?

var FinishedLessons : [String]?

var TriedLessons : [String]?

var TotalDuration : String?

var CheckinDays : Int?

var TotalFinishedLessonCount : Int?

var HistoryTasks : [ScenarioTaskSummary]?

required init?(map: Map)
{
super.init(map: map)
}

func setDefault(){
    self.Date = ""
    self.StreakCheckinDays = 0
    self.Checkin = false
    self.TargetLessonCount = 0
    self.Duration = ""
    self.TotalSpeakSentences = 0
    self.FinishedLessons = []
    self.TriedLessons = []
    self.TotalDuration = ""
    self.CheckinDays = 0
    self.TotalFinishedLessonCount = 0
    self.HistoryTasks = []
    self.ErrorMessage = ""
    self.ErrorCode = ReplyErrorCode.Ok
}

override func mapping(map: Map)
{
super.mapping(map: map)
Date <- map["date"]
StreakCheckinDays <- map["streakCheckinDays"]
Checkin <- map["checkin"]
TargetLessonCount <- map["tarLessonCount"]
Duration <- map["duration"]
TotalSpeakSentences <- map["triedSentenceCount"]
FinishedLessons <- map["finishedLessons"]
TriedLessons <- map["triedLessons"]
TotalDuration <- map["totalDuration"]
CheckinDays <- map["checkinDays"]
TotalFinishedLessonCount <- map["totalFinishedLessonCount"]
HistoryTasks <- map["history"]
}
}

