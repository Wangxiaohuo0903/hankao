import Foundation
import ObjectMapper

class ScenarioRateChoiceInput : MultilingualInput
{
var Question : String?

var Answer : Int?

var LessonId : String?

var IsPassed : Bool?

required init?(map: Map)
{
super.init(map: map)
}
init(question: String, answer: Int, lid: String, isPassed: Bool, lang:String)
{
    super.init(lang: lang)
    self.Question = question
    self.Answer = answer
    self.LessonId = lid
    self.IsPassed = isPassed
}
override func mapping(map: Map)
{
super.mapping(map: map)
Question <- map["question"]
Answer <- map["answer"]
LessonId <- map["lid"]
IsPassed <- map["passed"]
}
}

