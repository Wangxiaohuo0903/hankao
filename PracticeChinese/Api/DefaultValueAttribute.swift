import Foundation
import ObjectMapper

class DefaultValueAttribute : Mappable
{
var DefaultValue : NSObject?

required init?(map: Map)
{
}

func mapping(map: Map)
{
DefaultValue <- map["DefaultValue"]
}
}

