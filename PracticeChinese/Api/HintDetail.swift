import Foundation
import ObjectMapper

class HintDetail : Mappable
{
var Text : String?

var NativeText : String?
    
var Pinyin : String?

var ImageURL : String?

var AudioURL : String?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Text <- map["text"]
NativeText <- map["nativeText"]
Pinyin <- map["ipa"]
ImageURL <- map["imageUrl"]
AudioURL <- map["audioUrl"]
}
}

