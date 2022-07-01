import Foundation
import ObjectMapper

class JobOutput<TOut:Mappable> : ResultContract
{
var JobId : String?

var Cost : TimeInterval?

var Result : TOut?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
JobId <- map["id"]
Cost <- map["Cost"]
Result <- map["result"]
}
}

