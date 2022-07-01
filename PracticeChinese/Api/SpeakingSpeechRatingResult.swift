import Foundation
import ObjectMapper

class SpeakingSpeechRatingResult : SpeakingResult
{
var SpeechScore : Int?

var TextScore : Int?

var Details : SpeechRateData?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
SpeechScore <- map["speechScore"]
TextScore <- map["textScore"]
Details <- map["speechDetails"]
}
}

