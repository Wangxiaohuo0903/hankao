import Foundation
import ObjectMapper

class RecitingQuizzesResult : ResultContract
{
var PlanId : String?

var Quizzes : [RecitingQuizDefinition]?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
PlanId <- map["pid"]
Quizzes <- map["quizzes"]
}
}

