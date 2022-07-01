import Foundation
import ObjectMapper

class CIGWords : Mappable
{
var Score : Double?

var Word : String?

var StartTime : Int?

var EndTime : Int?

var Phonemes : [CIGPhonemes]?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Score <- map["score"]
Word <- map["word"]
StartTime <- map["startTime"]
EndTime <- map["endTime"]
Phonemes <- map["phonemes"]
}
}

