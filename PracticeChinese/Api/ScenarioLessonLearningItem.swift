import Foundation
import ObjectMapper

class ScenarioLessonLearningItem : Mappable
{
var Text : String?

var NativeText : String?

var Image : String?

var Description : String?

var Language : String?

var Accent : String?

var AudioMimeType : String?

var AudioUrl : String?

var IPA : String?
var ItemType: Int?
var Tags: [String]?//标签
var Tokens: [Token]?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Text <- map["text"]
NativeText <- map["nativeText"]
Image <- map["image"]
Description <- map["desc"]
Language <- map["lang"]
Accent <- map["accent"]
AudioMimeType <- map["type"]
AudioUrl <- map["audioUrl"]
IPA <- map["ipa"]
ItemType <- map["itemType"]
Tags <- map["tags"]
Tokens <- map["tokens"]
}
}

enum ScenarioLessonLearningItemType: Int {
    case Word = 0
    case Grammar = 1
}
