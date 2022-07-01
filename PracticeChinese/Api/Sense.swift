import Foundation
import ObjectMapper

class Sense : Mappable
{
var Definition : String?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Definition <- map["def"]
}
}

