import Foundation
import ObjectMapper

class PhraseItem : Mappable
{
var Phrase : String?

var Definition : String?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Phrase <- map["phrase"]
Definition <- map["def"]
}
}

