import Foundation
import ObjectMapper

class SpeakingRateChoiceInput : MultilingualInput
{
var Text : String?

var LessonId : String?

var IsPassed : Bool?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Text <- map["text"]
LessonId <- map["lid"]
IsPassed <- map["passed"]
}
}

