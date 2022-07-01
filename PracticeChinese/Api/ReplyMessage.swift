import Foundation
import ObjectMapper

class ReplyMessage : Message
{
var ErrorCode : ReplyErrorCode?

var ErrorMessage : String?

var Success : Bool?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
ErrorCode <- map["errcode"]
ErrorMessage <- map["errmsg"]
Success <- map["Success"]
}
}

