import Foundation
import ObjectMapper

class SpeakingGetSentenceResult : SpeakingResult
{
var Sentence : Sentence?

var Details : SpeechRateData?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Sentence <- map["sentence"]
Details <- map["details"]
}
}

