import Foundation
import ObjectMapper

class TextToSpeechInput : MultilingualInput
{
var Text : String?

var OutputOptions : TextToSpeechOptions?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Text <- map["text"]
OutputOptions <- map["outputOptions"]
}
}

