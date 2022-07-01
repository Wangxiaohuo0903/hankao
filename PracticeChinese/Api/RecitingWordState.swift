import Foundation
import ObjectMapper

class RecitingWordState : Mappable
{
var State : RecitingWordCategory?

var Word : RecitingWordDefinition?

required init?(map: Map)
{
}

func mapping(map: Map)
{
State <- map["state"]
Word <- map["word"]
}
}

