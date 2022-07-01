import Foundation
import ObjectMapper

class ListSpeakingTestsHistoryResult : ResultContract
{
var Results : [SpeakingTestResult]?

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

