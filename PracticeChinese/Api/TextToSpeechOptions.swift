import Foundation
import ObjectMapper

class TextToSpeechOptions : AudioFormatConverterOptions
{
var Model : String?

var Accent : String?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Model <- map["model"]
Accent <- map["accent"]
}
}

