import Foundation
import ObjectMapper

class RecitingWordRecallStatesInput : MultilingualInput
{
var PlanId : String?

var States : [RecitingWordRecallState]?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
PlanId <- map["pid"]
States <- map["states"]
}
}

