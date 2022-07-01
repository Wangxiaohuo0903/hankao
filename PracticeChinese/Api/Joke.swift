import Foundation
import ObjectMapper

class Joke : Mappable
{
var Text : String?

var Link : String?

var Rank : String?

var Category : String?

var Level : String?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Text <- map["t"]
Link <- map["ol"]
Rank <- map["r"]
Category <- map["c"]
Level <- map["l"]
}
}

