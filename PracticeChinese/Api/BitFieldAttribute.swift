import Foundation
import ObjectMapper

class BitFieldAttribute : Mappable
{
var Start : Int?

var End : Int?

required init?(map: Map)
{
}

 func mapping(map: Map)
{
Start <- map["Start"]
End <- map["End"]
}
}

