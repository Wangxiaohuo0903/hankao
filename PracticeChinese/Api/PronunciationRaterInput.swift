import Foundation
import ObjectMapper

class PronunciationRaterInput : MultilingualInput
{
var Text : String?

var Arpabet : String?

var Speech : [Byte]?

var MimeType : String?

var SampleRate : Int?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Text <- map["text"]
Arpabet <- map["arpabet"]
Speech <- map["speech"]
MimeType <- map["mimeType"]
SampleRate <- map["sampleRate"]
}
}

