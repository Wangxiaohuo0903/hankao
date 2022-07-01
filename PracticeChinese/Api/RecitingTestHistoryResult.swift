import Foundation
import ObjectMapper

class RecitingTestHistoryResult : ResultContract
{
var History : [RecitingTestResult]?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
History <- map["history"]
}
}

