import Foundation
import ObjectMapper

class ResultContract : Mappable
{
var ErrorCode : ReplyErrorCode?

var ErrorMessage : String?

required init?(map: Map)
{
}

func mapping(map: Map)
{
ErrorCode <- map["errcode"]
ErrorMessage <- map["errmsg"]
}
}

