import Foundation
import ObjectMapper

class ForwardPagedResultContract<T> : ResultContract
{
var ContinuationToken : String?

var Items : [T]?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
ContinuationToken <- map["contToken"]
Items <- map["items"]
}
}

