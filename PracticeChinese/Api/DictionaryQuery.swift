import Foundation
import ObjectMapper

class DictionaryQuery : MultilingualInput
{
var Text : String?

var TargetLanguage : String?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Text <- map["text"]
TargetLanguage <- map["tarLang"]
}
}

