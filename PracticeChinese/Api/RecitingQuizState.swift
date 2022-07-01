import Foundation
import ObjectMapper

class RecitingQuizState : Mappable
{
var Word : String?

var IsPassed : Bool?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Word <- map["word"]
IsPassed <- map["passed"]
}
}

