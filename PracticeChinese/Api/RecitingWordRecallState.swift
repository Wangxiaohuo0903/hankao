import Foundation
import ObjectMapper

class RecitingWordRecallState : Mappable
{
var Word : String?

var Action : RecitingWordRecallAction?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Word <- map["word"]
Action <- map["action"]
}
}

