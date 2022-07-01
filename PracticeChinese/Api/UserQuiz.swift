import Foundation
import ObjectMapper

class UserQuiz : SpeakQuizBase
{
var LastSpeakingTime : Date?

var HighScore : Int?

var LastScore : Int?

var IsPassed : Bool?

var IsSpeaked : Bool?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
LastSpeakingTime <- map["lastSpeakingTime"]
HighScore <- map["highScore"]
LastScore <- map["lastScore"]
IsPassed <- map["passed"]
IsSpeaked <- map["speaked"]
}
}

