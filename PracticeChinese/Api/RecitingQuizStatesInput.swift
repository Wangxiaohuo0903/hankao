import Foundation
import ObjectMapper

class RecitingQuizStatesInput : MultilingualInput
{
var PlanId : String?

var States : [RecitingQuizState]?

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

