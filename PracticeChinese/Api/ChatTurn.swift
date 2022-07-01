import Foundation
import ObjectMapper

class ChatTurn : Mappable
{
var TurnType : Int?

var Question : String?

var NativeQuestion : String?
    
var Displayquestion : String?
    
var Tokens: [Token]?

var AnswerOptions : [Answer]?
    
var ChaUrl: String?

var IPA: String?
    
var AudioUrl: String?
//学以致用，用户录音
var userAudioUrl: URL?
    
required init?(map: Map)
{
}

func mapping(map: Map)
{
TurnType <- map["type"]
Question <- map["question"]
NativeQuestion <- map["nativeQuestion"]
Displayquestion <- map["displayquestion"]
AnswerOptions <- map["answers"]
ChaUrl <- map["chaUrl"]
IPA <- map["ipa"]
Tokens <- map["tokens"]
AudioUrl <- map["audioUrl"]
}
}

