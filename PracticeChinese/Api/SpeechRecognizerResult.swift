import Foundation
import ObjectMapper

class SpeechRecognizerResult : ResultContract
{
var Text : String?

var Language : String?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Text <- map["text"]
Language <- map["lang"]
}
}

