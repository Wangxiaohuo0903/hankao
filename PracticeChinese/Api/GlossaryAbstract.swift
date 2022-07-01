import Foundation
import ObjectMapper

class GlossaryAbstract : Mappable
{
var Id : String?

var Name : String?

var Language : String?

var Tags : [String]?

var WordCount : Int?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Id <- map["id"]
Name <- map["name"]
Language <- map["lang"]
Tags <- map["tags"]
WordCount <- map["count"]
}
}

