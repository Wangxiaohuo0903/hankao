import Foundation
import ObjectMapper

class CIGPhonemes : Mappable
{
var Score : Double?

var Phoneme : String?

var StartTime : Int?

var EndTime : Int?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Score <- map["score"]
Phoneme <- map["phoneme"]
StartTime <- map["startTime"]
EndTime <- map["endTime"]
}
}

