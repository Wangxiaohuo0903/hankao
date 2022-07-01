import Foundation
import ObjectMapper

class WordImage : Mappable
{
var Language : String?

var Name : String?

var Word : String?

var OriginalLink : String?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Language <- map["l"]
Name <- map["n"]
Word <- map["w"]
OriginalLink <- map["ol"]
}
}

