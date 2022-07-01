import Foundation
import ObjectMapper

class IResultContract : Mappable
{
var ErrorCode : ReplyErrorCode?

var ErrorMessage : String?

required init?(map: Map)
{
}

func mapping(map: Map)
{
ErrorCode <- map["ErrorCode"]
ErrorMessage <- map["ErrorMessage"]
}
}

