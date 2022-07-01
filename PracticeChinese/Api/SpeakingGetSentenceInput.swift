import Foundation
import ObjectMapper

class SpeakingGetSentenceInput : MultilingualInput
{
var Text : String?

var Accent : String?

var MimeType : String?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Text <- map["text"]
Accent <- map["accent"]
MimeType <- map["mimeType"]
}
}

