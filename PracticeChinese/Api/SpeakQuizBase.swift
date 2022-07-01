import Foundation
import ObjectMapper

class SpeakQuizBase : Mappable
{
var QuizType : SpeakQuizType?

var Quiz : Sentence?

required init?(map: Map)
{
}

func mapping(map: Map)
{
QuizType <- map["type"]
 //   Quiz <- (map["quiz"], PhonemeQuizConverter())
    let object = map["quiz"].currentValue
    switch QuizType! {
    case SpeakQuizType.LearningWord:
        Quiz = Mapper<Sentence>().map(JSONObject: object)
        
    case SpeakQuizType.SingleChoice:
        Quiz = Mapper<SpeakChoice>().map(JSONObject: object)
        
    case SpeakQuizType.SpeakSentence:
        Quiz = Mapper<Sentence>().map(JSONObject: object)
    }
    
    }
}

