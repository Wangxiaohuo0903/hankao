import Foundation
import ObjectMapper

class RecitingAssignExtraWordsInput : MultilingualInput
{
var PlanId : String?

var NewWordCount : Int?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
PlanId <- map["pid"]
NewWordCount <- map["count"]
}
}

