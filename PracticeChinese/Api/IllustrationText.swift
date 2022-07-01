import Foundation
import ObjectMapper

class IllustrationText : Mappable
{
var Url : String?

var SourceUri : String?

var Text : String?

var IPA : String?
    
var IPA1 : String?

var AudioText : String?

var AudioUrl : String?
    
var Displaytext : String?
    
var Tags : [String]?
    
//FIXME: - : 添加了tokens
var Tokens: [Token]?

required init?(map: Map)
{
}

func mapping(map: Map)
{
    Url <- map["figureUrl"]
    SourceUri <- map["figureSourceUri"]
    Text <- map["text"]
    Displaytext <- map["displaytext"]
    IPA <- map["ipa"]
    IPA1 <- map["ipa1"]
    AudioText <- map["audioText"]
    AudioUrl <- map["audioUrl"]
    Tokens <- map["tokens"]
    Tags <- map["tags"]
//    if AudioUrl == nil || !(AudioUrl?.hasSuffix("mp3"))!{
//        AudioUrl = "https://mtutordev.blob.core.chinacloudapi.cn/system-audio/lesson/zh-CN/zh-CN/0342b5aff1e19bfaaa604e265278e317.mp3"
//    }
}
}

