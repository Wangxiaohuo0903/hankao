import Foundation
import ObjectMapper

class Quiz : Mappable
{
var Answer : Int?

var Level : String?

var Body : TextAndImage?

var Detail : String?

var QuizType : String?

var Option : [TextAndImage]?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Answer <- map["a"]
Level <- map["l"]
Body <- map["b"]
Detail <- map["d"]
QuizType <- map["t"]
Option <- map["o"]
}
}

