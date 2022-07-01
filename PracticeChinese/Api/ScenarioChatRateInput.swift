import Foundation
import ObjectMapper

class ScenarioChatRateInput : MultilingualInput
{
var Text : String?

var Question : String?

var Keywords : [String]?

var ExpectedAnswer : String?

var Speech : [Byte]?

var SpeechMimeType : String?

var SampleRate : Int?

var LessonId : String?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Text <- map["text"]
Question <- map["question"]
Keywords <- map["keywords"]
ExpectedAnswer <- map["expectedAnswer"]
Speech <- map["speech"]
SpeechMimeType <- map["speechMimeType"]
SampleRate <- map["sampleRate"]
LessonId <- map["lid"]
}
}

