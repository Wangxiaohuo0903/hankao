import Foundation
import ObjectMapper

class ScenarioTestResult : Mappable
{
var Time : Date?

var Score : Int?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Time <- map["time"]
Score <- map["score"]
}
}

