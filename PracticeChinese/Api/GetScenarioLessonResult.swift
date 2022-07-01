import Foundation
import ObjectMapper

class GetScenarioLessonResult : SpeakingResult
{
var ScenarioLesson : ScenarioLesson?

var VideoSentenceDictionary : VideoSentenceDictionary?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
ScenarioLesson <- (map["lesson"], ScenarioLessonConverter())
VideoSentenceDictionary <- map["sentenceDict"]
}
}

