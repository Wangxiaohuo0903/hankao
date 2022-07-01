import Foundation
import ObjectMapper

class JobInfo : ResultContract
{
var Id : String?

var State : JobState?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Id <- map["id"]
State <- map["state"]
}
}

