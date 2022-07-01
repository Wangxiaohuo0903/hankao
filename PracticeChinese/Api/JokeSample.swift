import Foundation
import ObjectMapper

class JokeSample : Mappable
{
var Text : String?

var SourceUri : String?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Text <- map["text"]
SourceUri <- map["sourceUri"]
}
}

