import Foundation
import ObjectMapper

class RandomPagedResultContract<T> : ResultContract
{
var TotalCount : Int?

var StartIndex : Int?

var Items : [T]?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
TotalCount <- map["total"]
StartIndex <- map["start"]
Items <- map["items"]
}
}

