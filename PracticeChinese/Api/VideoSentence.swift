import Foundation
import ObjectMapper

class VideoSentence : Mappable
{
var Text : String?

var NativeText : String?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Text <- map["text"]
NativeText <- map["nativeText"]
}
}

