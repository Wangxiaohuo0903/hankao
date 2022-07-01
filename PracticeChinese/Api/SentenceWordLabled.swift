import Foundation
import ObjectMapper

class SentenceWordLabled : Mappable
{
var Word : String?

var Start : Double?

var End : Double?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Word <- map["word"]
Start <- map["start"]
End <- map["end"]
}
}

