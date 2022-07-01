import Foundation
import ObjectMapper

class SpeakChoice : Sentence
{
var Body : IllustrationText?

var Options : [IllustrationText]?

var Answer : Int?

var AnswerExplanation : String?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Body <- map["body"]
Options <- map["options"]
Answer <- map["answer"]
AnswerExplanation <- map["answerExpl"]
}
}

