import Foundation
import ObjectMapper

class SentenceSample : Mappable
{
var Language : String?

var Sentence : String?

var AudioUrl : String?

var VideoUrl : String?

var SourceUri : String?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Language <- map["lang"]
Sentence <- map["sent"]
AudioUrl <- map["audioUrl"]
VideoUrl <- map["videoUrl"]
SourceUri <- map["sourceUri"]
}
}

