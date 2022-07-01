import Foundation
import ObjectMapper

class QuizSample : Mappable
{
    var QuizType : QuizType?

    var Body : IllustrationText?

    var Options : [IllustrationText]?

    var Answer : Int?

    var AnswerExplanation : String?
    
    var Tags : [String]?
    
    var Tokens : [Token]?

    required init?(map: Map)
    {
    }

    func mapping(map: Map)
    {
        QuizType <- map["type"]
        Body <- map["body"]
        Options <- map["options"]
        Answer <- map["answer"]
        AnswerExplanation <- map["answerExpl"]
        Tags <- map["tags"]
        Tokens <- map["tokens"]
    }
}

