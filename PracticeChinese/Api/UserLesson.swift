import Foundation
import ObjectMapper

class UserLesson : Mappable
{
var LessonInfo : LessonAbstract?

var SubLessonScores : [SubLessonScores]?

var ChallengeScores : [Int]?

var Progress : Int?

required init?(map: Map)
{
}

func mapping(map: Map)
{
LessonInfo <- map["info"]
SubLessonScores <- map["leafScores"]
ChallengeScores <- map["subChalScores"]
Progress <- map["progress"]
}
}

