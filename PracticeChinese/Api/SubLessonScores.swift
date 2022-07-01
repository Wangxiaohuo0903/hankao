import Foundation
import ObjectMapper

class SubLessonScores : Mappable
{
var Id : String?

var LessonType : LessonType?

var QuizzesCount : Int?

var ScoreList : [Int]?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Id <- map["id"]
LessonType <- map["type"]
QuizzesCount <- map["count"]
ScoreList <- map["scores"]
}
}

