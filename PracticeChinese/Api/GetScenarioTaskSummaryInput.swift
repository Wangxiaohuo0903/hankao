import Foundation
import ObjectMapper

class GetScenarioTaskSummaryInput : MultilingualInput
{
var Start : String?

var End : String?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Start <- map["start"]
End <- map["end"]
}
}

