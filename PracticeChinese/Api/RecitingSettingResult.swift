import Foundation
import ObjectMapper

class RecitingSettingResult : RecitingSetting
{
var ErrorCode : ReplyErrorCode?

var ErrorMessage : String?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
ErrorCode <- map["errcode"]
ErrorMessage <- map["errmsg"]
}
}

