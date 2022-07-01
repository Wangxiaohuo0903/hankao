import Foundation
import ObjectMapper

class QuizOption : Mappable
{
var a : String?

var b : String?

var c : String?

var d : String?

required init?(map: Map)
{
}

func mapping(map: Map)
{
a <- map[""]
b <- map[""]
c <- map[""]
d <- map[""]
}
}

