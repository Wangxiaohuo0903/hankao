import Foundation
import ObjectMapper

class RecitingWordBatchResult : ResultContract
{
var PlanId : String?

var Progress : RecitingPlanTodayProgress?

var Words : [RecitingWordDefinition]?

var States : [RecitingWordCategory]?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
PlanId <- map["pid"]
Progress <- map["progress"]
Words <- map["words"]
States <- map["states"]
}
}

