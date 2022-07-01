import Foundation
import ObjectMapper

class SenseGroup : Mappable
{
var PartOfSpeech : String?

var Senses : [Sense]?

required init?(map: Map)
{
}

func mapping(map: Map)
{
PartOfSpeech <- map["pos"]
Senses <- map["senses"]
}
}

