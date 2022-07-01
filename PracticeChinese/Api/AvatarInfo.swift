import Foundation
import ObjectMapper

class AvatarInfo : ResultContract
{
var Avatar : [Byte]?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Avatar <- map["avatar"]
}
}

