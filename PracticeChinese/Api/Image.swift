import Foundation
import ObjectMapper

class Image : Mappable
{
var Uri : String?

var OriginalLink : String?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Uri <- map["l"]
OriginalLink <- map["ol"]
}
}


