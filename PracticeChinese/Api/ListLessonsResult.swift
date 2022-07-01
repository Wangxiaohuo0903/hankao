import Foundation
import ObjectMapper

class ListLessonsResult : SpeakingResult
{
var Info : LessonAbstract?

var SubLessons : [UserLesson]?

var ChallengeScores : [Int]?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Info <- map["lessonInfo"]
SubLessons <- map["subLessons"]
ChallengeScores <- map["subChalScores"]
}
}

