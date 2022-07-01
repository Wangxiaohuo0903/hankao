import Foundation
import ObjectMapper

class SpeakingTTSResult : SpeakingResult
{
var Model : String?

var Accent : String?

var Url : String?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Model <- map["model"]
Accent <- map["accent"]
Url <- map["url"]
}
}

