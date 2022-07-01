import Foundation
import ObjectMapper

class RecitingGetTestPaperResult : ResultContract
{
var TestId : String?

var Quizzes : [RecitingQuizDefinition]?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
TestId <- map["testId"]
Quizzes <- map["quizzes"]
}
}

