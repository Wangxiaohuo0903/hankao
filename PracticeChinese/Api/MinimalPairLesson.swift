import Foundation
import ObjectMapper

class MinimalPairLesson : Lesson
{
var LearningText : String?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
LearningText <- map["learnText"]
}
}

