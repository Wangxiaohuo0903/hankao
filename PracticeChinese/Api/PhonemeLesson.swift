import Foundation
import ObjectMapper

class PhonemeLesson : Lesson
{
var PhonemeVideo : String?

var LearningText : String?

var Tones : [IllustrationText]?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
PhonemeVideo <- map["videoUrl"]
LearningText <- map["learnText"]
Tones <- map["tones"]
}
}

