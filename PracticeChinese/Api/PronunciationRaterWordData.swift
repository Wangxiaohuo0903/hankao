import Foundation
import ObjectMapper

class PronunciationRaterWordData : Mappable
{
var Word : String?

var StartTime : Int?

var EndTime : Int?

var PronunciationScore : Int?

var SyllableDetails : [PronunciationRaterSyllableData]?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Word <- map["word"]
StartTime <- map["startTime"]
EndTime <- map["endTime"]
PronunciationScore <- map["score"]
SyllableDetails <- map["syllDetails"]
}
}

