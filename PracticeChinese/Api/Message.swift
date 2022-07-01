import Foundation
import ObjectMapper

class Message : Mappable
{
var Id : String?

var SourceEngineId : String?

var CreationTime : Date?

var Data : NSObject?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Id <- map["id"]
SourceEngineId <- map["source"]
CreationTime <- map["time"]
Data <- map[""]
}
}

