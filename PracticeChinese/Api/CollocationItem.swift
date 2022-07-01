import Foundation
import ObjectMapper

class CollocationItem : Mappable
{
var Term1 : String?

var Term2 : String?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Term1 <- map["term1"]
Term2 <- map["term2"]
}
}

