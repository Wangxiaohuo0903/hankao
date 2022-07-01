import Foundation
import ObjectMapper

class BilingualSample : Mappable
{
var Lang1 : SentenceSample?

var Lang2 : SentenceSample?

var SourceUri : String?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Lang1 <- map["lang1"]
Lang2 <- map["lang2"]
SourceUri <- map["sourceUri"]
}
}

