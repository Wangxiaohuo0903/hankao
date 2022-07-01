import Foundation
import ObjectMapper

class QuizItemOrigin : Mappable
{
var a : String?

var level : String?

var text : String?

var detail_a : String?

var type : String?

var q : QuizOption?

required init?(map: Map)
{
}

func mapping(map: Map)
{
a <- map[""]
level <- map[""]
text <- map[""]
detail_a <- map[""]
type <- map[""]
q <- map[""]
}
}

