import Foundation
import ObjectMapper

class AudioFormatConverterOptions : Mappable
{
var MimeType : String?

var Format : String?

var SampleRate : Int?

var Channel : Int?

var UseSox : Bool?

required init?(map: Map)
{
}

func mapping(map: Map)
{
MimeType <- map["mimeType"]
Format <- map["format"]
SampleRate <- map["sampleRate"]
Channel <- map["channel"]
UseSox <- map["sox"]
}
}

