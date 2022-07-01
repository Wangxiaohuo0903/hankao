import Foundation
import ObjectMapper

class PronunciationRaterPhonemeData : Mappable
{
var Phoneme : String?

var StartTime : Int?

var EndTime : Int?

var PronunciationScore : Int?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Phoneme <- map["phon"]
StartTime <- map["startTime"]
EndTime <- map["endTime"]
PronunciationScore <- map["score"]
}
}

