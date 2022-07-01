import Foundation
import ObjectMapper

class RecitingListPlansResult : ResultContract
{
var Plans : [RecitingPlan]?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Plans <- map["plans"]
}
}

