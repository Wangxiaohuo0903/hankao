import Foundation
import ObjectMapper

class LessonQuery : Mappable
{
var LessonName : String?

required init?(map: Map)
{
}

func mapping(map: Map)
{
LessonName <- map["l"]
}
}

