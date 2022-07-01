import Foundation
import ObjectMapper

class Answer : Mappable
{
var Text : String?

var nativeText : String?

var Keywords : String?

var ImageURLs : [String]?
    
var ImageUrl : String?

var Expressions : [AnswerExpression]?

var HelpInfo : String?

var NativeHelpInfo : String?

var HintDetails : [HintDetail]?

var NextTurn : Int?

var Tokens: [Token]?
    
var AudioUrl: String?

var ChaUrl: String?
    
var IPA: String?
    
required init?(map: Map)
{
}

func mapping(map: Map)
{
Text <- map["text"]
nativeText <- map["nativeText"]
Keywords <- map["keywords"]
ImageURLs <- map["imageUrls"]
ImageUrl <- map["imageUrl"]
Expressions <- map["expressions"]
HelpInfo <- map["help"]
NativeHelpInfo <- map["nativeHelp"]
HintDetails <- map["hintDetail"]
NextTurn <- map["nextTurn"]
Tokens <- map["tokens"]
AudioUrl <- map["audioUrl"]
ChaUrl <- map["chaUrl"]
IPA <- map["ipa"]
Tokens <- map["tokens"]
}
}

class Token : Mappable {
    var Text: String?
    var IPA: String?
    var NativeText: String?
    var DifficultyLevel: Int?
    var IPA1: String?
    required init?(map: Map) {
    }
    init() {
    }
    func mapping(map: Map) {
        Text <- map["text"]
        IPA <- map["ipa"]
        IPA1 <- map["ipa1"]
        DifficultyLevel <- map["difficultyLevel"]
        NativeText <- map["nativetext"]
    }
}

