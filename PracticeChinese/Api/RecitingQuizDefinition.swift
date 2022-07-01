import Foundation
import ObjectMapper

class RecitingQuizDefinition : Mappable
{
var Text : String?

var Quiz : QuizSample?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Text <- map["text"]
Quiz <- map["quiz"]
}
}

