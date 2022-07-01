import Foundation
import ObjectMapper

class PronunciationRaterSyllableData : Mappable
{
var StartTime : Int?

var EndTime : Int?

var PronunciationScore : Int?

var PhonemeDetails : [PronunciationRaterPhonemeData]?

required init?(map: Map)
{
}

func mapping(map: Map)
{
StartTime <- map["startTime"]
EndTime <- map["endTime"]
PronunciationScore <- map["score"]
PhonemeDetails <- map["phonDetails"]
}
}

