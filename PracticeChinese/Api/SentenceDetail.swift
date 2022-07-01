import Foundation
import ObjectMapper

class SentenceDetail : Mappable
{
var StartTime : Double?

var EndTime : Double?

var AudioUrl : String?

var VideoUrl : String?

var AudioDuration : Int?

var PictureUrl : String?

var WordsDetail : [SentenceWordLabled]?

required init?(map: Map)
{
}

func mapping(map: Map)
{
StartTime <- map["start"]
EndTime <- map["end"]
AudioUrl <- map["audioUrl"]
VideoUrl <- map["videoUrl"]
AudioDuration <- map["audioDuration"]
WordsDetail <- map["wordsDetail"]
PictureUrl <- map["chaUrl"]
}
}

