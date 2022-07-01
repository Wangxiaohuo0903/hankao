import Foundation
import ObjectMapper

class SpeechRateData : Mappable
{
var Duration : Int?

var AudioGraphUrl : String?

var PronunciationScore : Int?

var WordDetails : [PronunciationRaterWordData]?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Duration <- map["duration"]
AudioGraphUrl <- map["audioGraphUrl"]
PronunciationScore <- map["score"]
WordDetails <- map["wordDetails"]
}
}

