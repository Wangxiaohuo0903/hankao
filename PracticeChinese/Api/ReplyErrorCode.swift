import Foundation
import ObjectMapper

enum ReplyErrorCode : Int
{
case Ok = 0
case BadRequest = 400
case Unauthorized = 401
case Forbidden = 403
case NotFound = 404
case Timeout = 408
case InternalError = 500
case CustomErrorStart = 10000

}


