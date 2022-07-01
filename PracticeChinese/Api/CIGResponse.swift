import Foundation
import ObjectMapper

class CIGResponse : Mappable
{
var Score : Double?

var F0Data : [Float]?

var Words : [CIGWords]?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Score <- map["score"]
F0Data <- map["f0data"]
Words <- map["words"]
}
}

