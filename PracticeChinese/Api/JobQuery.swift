import Foundation
import ObjectMapper

class JobQuery : Mappable
{
var Id : String?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Id <- map["id"]
}
}

