import Foundation
import ObjectMapper

class RecitingPlanTodayProgress : Mappable
{
var FamiliarCount : Int?

var NotStartedCount : Int?

var UnfamiliarCount : Int?

var UnfamiliarButLearnedCount : Int?

required init?(map: Map)
{
}

func mapping(map: Map)
{
FamiliarCount <- map["familiarCount"]
NotStartedCount <- map["notStartedCount"]
UnfamiliarCount <- map["unfamiliarCount"]
UnfamiliarButLearnedCount <- map["halfLearnedCount"]
}
}

