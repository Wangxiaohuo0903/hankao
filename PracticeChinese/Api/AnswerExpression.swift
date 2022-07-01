import Foundation
import ObjectMapper

class AnswerExpression : Mappable
{
var Text : String?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Text <- map["text"]
}
}

