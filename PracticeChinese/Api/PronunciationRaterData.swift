import Foundation
import ObjectMapper

class PronunciationRaterData : Mappable
{
var FrameCount : Int?

var Duration : TimeInterval?

var PronunciationScore : Int?

var WordDetails : [PronunciationRaterWordData]?

var AudioGraph : [Byte]?

var AudioGraphMimeType : String?

required init?(map: Map)
{
}

func mapping(map: Map)
{
FrameCount <- map["frameCount"]
Duration <- map["duration"]
PronunciationScore <- map["score"]
WordDetails <- map["wordDetails"]
AudioGraph <- map["audioGraph"]
AudioGraphMimeType <- map["audioGraphMimeType"]
}
}

