import Foundation
import ObjectMapper

typealias Byte = UInt8
class AudioFormatConverterInput : Mappable
{
var MimeType : String?

var Data : [Byte]?

var InputOptions : AudioFormatConverterOptions?

var OutputOptions : AudioFormatConverterOptions?

required init?(map: Map)
{
}

func mapping(map: Map)
{
MimeType <- map["mimeType"]
Data <- map[""]
InputOptions <- map["inputOptions"]
OutputOptions <- map["outputOptions"]
}
}

