import Foundation
import ObjectMapper

class LessonAbstract : ResultContract
{
var Id : String?

var LessonType : LessonType?

var ParentId : String?

var Name : String?

var NativeName : String?

var Tags : [String]?

var QuizzesCount : Int?

var Version : String?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Id <- map["id"]
LessonType <- map["type"]
ParentId <- map["pid"]
Name <- map["name"]
NativeName <- map["nativeName"]
Tags <- map["tags"]
QuizzesCount <- map["count"]
Version <- map["version"]
}
}

