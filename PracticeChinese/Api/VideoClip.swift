import Foundation
import ObjectMapper

class VideoClip : Mappable
{
var Uri : String?

var AudioUri : String?

var ImageUri : String?

var SourceUri : String?

var Length : Int?

var Title : String?

var Script : String?

var Category : String?

var Rank : Int?

var MatchLevel : Float?

var Difficulty : Float?

var QueryPos : [(Int,Int)]?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Uri <- map["uri"]
AudioUri <- map["audio"]
ImageUri <- map["image"]
SourceUri <- map["source"]
Length <- map["length"]
Title <- map["title"]
Script <- map["script"]
Category <- map["category"]
Rank <- map["rank"]
MatchLevel <- map["match"]
Difficulty <- map["difficulty"]
QueryPos <- map["pos"]
}
}

