import Foundation
import ObjectMapper

class IMultilingualInput : Mappable
{
var Language : String?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Language <- map["Language"]
}
}

