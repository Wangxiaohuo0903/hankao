import Foundation
import ObjectMapper

class TextToSpeechResult : ResultContract
{
var Model : String?

var Accent : String?

var MimeType : String?

var Speech : [Byte]?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Model <- map["model"]
Accent <- map["accent"]
MimeType <- map["mimeType"]
Speech <- map["speech"]
}
}

