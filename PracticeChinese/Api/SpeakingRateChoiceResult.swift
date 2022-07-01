import Foundation
import ObjectMapper

class SpeakingRateChoiceResult : ResultContract
{
var Score : Int?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Score <- map["score"]
}
}

