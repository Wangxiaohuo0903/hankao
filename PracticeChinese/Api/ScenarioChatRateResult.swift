import Foundation
import ObjectMapper

class ScenarioChatRateResult : SpeakingResult
{
var PronunciationScore : Int?

//var TextScore : Int?

var Score : Int?

var SRResult : String?

var Details : SpeechRateData?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
PronunciationScore <- map["pronScore"]
//TextScore <- map["textScore"]
Score <- map["score"]
SRResult <- map["srResult"]
Details <- map["speechDetails"]
}
}


