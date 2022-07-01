import Foundation
import ObjectMapper

class Sentence : ResultContract
{
var Text : String?

var NativeText : String?

var HighlightText : String?

var TokenList : [String]?

var IPA : String?

var Language : String?

var WordCount : Int?

var Accent : String?

var AudioMimeType : String?

var Name : String?

var AudioUrl : String?

var ImageUrl : String?

var AudioDuration : Int?

var Data : [Byte]?
    
var CharacterUrl: String?
    
var Tokens: [IllustrationText]?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Text <- map["text"]
NativeText <- map["nativeText"]
HighlightText <- map["hilitText"]
TokenList <- map["tokenList"]
IPA <- map["ipa"]
Language <- map["lang"]
WordCount <- map["wordCount"]
Accent <- map["accent"]
AudioMimeType <- map["type"]
Name <- map["name"]
AudioUrl <- map["audioUrl"]
ImageUrl <- map["imageUrl"]
AudioDuration <- map["audioDuration"]
Data <- map[""]
CharacterUrl <- map["chaUrl"]
Tokens <- map["tokens"]
}
}

