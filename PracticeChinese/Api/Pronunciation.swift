import Foundation
import ObjectMapper

class Pronunciation : Mappable
{
var Locale : String?

var IPA : String?

var AudioUrl : String?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Locale <- map["locale"]
IPA <- map["ipa"]
AudioUrl <- map["audioUrl"]
}
}

