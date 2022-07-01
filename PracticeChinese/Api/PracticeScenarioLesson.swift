import Foundation
import ObjectMapper

class PracticeScenarioLesson : ScenarioLesson
{
var Quizzes : [QuizSample]?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Quizzes <- map["quizzes"]
}
}

