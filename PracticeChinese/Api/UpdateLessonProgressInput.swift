import Foundation
import ObjectMapper

class UpdateLessonProgressInput : MultilingualInput
{
var LessonId : String?

var Delta : Int?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
LessonId <- map["lid"]
Delta <- map["delta"]
}
}

