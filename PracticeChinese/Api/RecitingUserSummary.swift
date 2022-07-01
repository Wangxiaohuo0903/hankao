import Foundation
import ObjectMapper

class RecitingUserSummary : Mappable
{
var UserSummary : RecitingSummary?

var Plans : [RecitingPlan]?

required init?(map: Map)
{
}

func mapping(map: Map)
{
UserSummary <- map["summary"]
Plans <- map["plans"]
}
}

