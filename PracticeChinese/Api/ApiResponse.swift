import Foundation
import ObjectMapper
import SwiftyJSON

class ApiResponse : Mappable
{
var ErrorCode : ReplyErrorCode?

var ErrorMessage : String?

var Data : JSON?

var RequestId : String?

var Success : Bool?

required init?(map: Map)
{
}

func mapping(map: Map)
{
ErrorCode <- map["errcode"]
ErrorMessage <- map["errmsg"]
Data <- map["data"]
RequestId <- map["RequestId"]
Success <- map["Success"]
}
}

