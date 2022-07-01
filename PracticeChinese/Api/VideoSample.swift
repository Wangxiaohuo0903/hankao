import Foundation
import ObjectMapper

class VideoSample : Mappable
{
var Title : String?

var Url : String?

var SourceUri : String?

var Script : String?

var ScriptSourceUri : String?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Title <- map["title"]
Url <- map["url"]
SourceUri <- map["sourceUri"]
Script <- map["script"]
ScriptSourceUri <- map["scriptSourceUri"]
}
}

