import Foundation
import ObjectMapper

class AccountInfo : ResultContract
{
var UserName : String?

var RemindingTime : Int?
    
var Coin : Int?
    
var Exp : Int?
    
var ExpLevel : Int?
    
var LastExpLevelBar : Int?
    
var NextExpLevelBar : Int?

var VocabularyScore : Double?

var SpeakingScore : Double?

var WordingScore : Double?

var ZhuhaiInfo : ZhuhaiInfo?
    
var PrivacyLevel: Int?

required init?(map: Map)
{
super.init(map: map)
}

func setDefault(){
    self.UserName = ""
    self.RemindingTime = 0
    self.Coin = 0
    self.Exp = 0
    self.ExpLevel = 0
    self.LastExpLevelBar = 0
    self.NextExpLevelBar = 0
    self.VocabularyScore = 0
    self.SpeakingScore = 0
    self.WordingScore = 0
    self.PrivacyLevel = 0
    self.ZhuhaiInfo?.setDefault()
    self.ErrorMessage = ""
    self.ErrorCode = ReplyErrorCode.Ok
}

override func mapping(map: Map)
{
super.mapping(map: map)
UserName <- map["name"]
RemindingTime <- map["remTime"]
Exp <- map["exp"]
ExpLevel <- map["expLevel"]
Coin <- map["coin"]
VocabularyScore <- map["vocabScore"]
SpeakingScore <- map["speakingScore"]
WordingScore <- map["wordingScore"]
ZhuhaiInfo <- map["zhuhaiInfo"]
LastExpLevelBar <- map["lastExpLevelBar"]
NextExpLevelBar <- map["nextExpLevelBar"]
PrivacyLevel <- map["privacyLevel"]
}
    

    
}

