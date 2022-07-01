import Foundation
import ObjectMapper

class Inflection : Mappable
{
var InflectionType : InflectionType?

var Value : String?

required init?(map: Map)
{
}

func mapping(map: Map)
{
InflectionType <- map["type"]
Value <- map["value"]
}
}

