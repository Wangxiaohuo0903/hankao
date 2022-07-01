import Foundation
import ObjectMapper

class SpeechRecognizerInput : MultilingualInput
{
var Data : [Byte]?

var MimeType : String?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Data <- map[""]
MimeType <- map["mimeType"]
}
}

