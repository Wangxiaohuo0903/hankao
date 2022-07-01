import Foundation
import ObjectMapper

class RecitingWordDefinition : DictionaryDefinition
{
var Figures : [WordIllustration]?

var JokeSamples : [JokeSample]?

var QuizSamples : [QuizSample]?

var VideoSamples : [VideoSample]?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Figures <- map["figures"]
JokeSamples <- map["jokes"]
QuizSamples <- map["quizzes"]
VideoSamples <- map["videos"]
}
}

