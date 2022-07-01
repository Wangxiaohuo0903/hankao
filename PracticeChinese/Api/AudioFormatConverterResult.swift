import Foundation
import ObjectMapper

class AudioFormatConverterResult : ResultContract
{
var MimeType : String?

var Duration : TimeInterval?

var Data : [Byte]?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
MimeType <- map["mimeType"]
Duration <- map["duration"]
Data <- map[""]
}
}

