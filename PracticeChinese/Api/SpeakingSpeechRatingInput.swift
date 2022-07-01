import Foundation
import ObjectMapper

class SpeakingSpeechRatingInput : MultilingualInput
{
var Text : String?

var LessonId : String?

var Data : [Byte]?

var MimeType : String?

var SampleRate : Int?
    
    required init?(map: Map)
    {
        super.init(map: map)
    }

    init(text:String, data:[Byte]?, speechMimeType:String, sampleRate:Int, lessonId:String, lang: String) {
        super.init(lang: lang)
        
        Text = text
        LessonId = lessonId
        Data = data
        MimeType = speechMimeType
        SampleRate = sampleRate
    }
    
override func mapping(map: Map)
{
super.mapping(map: map)
Text <- map["text"]
LessonId <- map["lid"]
Data <- map["data"]
MimeType <- map["mimeType"]
SampleRate <- map["sampleRate"]
}
}

