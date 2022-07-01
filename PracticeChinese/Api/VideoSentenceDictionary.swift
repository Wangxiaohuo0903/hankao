import Foundation
import ObjectMapper

class VideoSentenceDictionary : Mappable
{
var LessonId : String?

var Name : String?

var TextDictionary : Dictionary<String,SentenceDetail>?

required init?(map: Map)
{
}

func mapping(map: Map)
{
LessonId <- map["lessonId"]
Name <- map["name"]
TextDictionary <- map["textDict"]
}
}

