import Foundation
import ObjectMapper

class GetScenarioTestHistoryResult : ResultContract
{
var Results : [ScenarioTestResult]?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Results <- map["history"]
}
}

