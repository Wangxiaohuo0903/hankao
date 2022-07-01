import Foundation
import ObjectMapper

class WordIllustration : Mappable
{
var Url : String?

var SourceUri : String?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Url <- map["url"]
SourceUri <- map["sourceUri"]
}
}

