import Foundation
import ObjectMapper

class Collocation : Mappable
{
var Relation : String?

var Items : [CollocationItem]?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Relation <- map["rel"]
Items <- map["items"]
}
}

