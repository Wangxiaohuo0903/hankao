import Foundation
import ObjectMapper

class RecitingSubmitTestPaperInput : MultilingualInput
{
var TestId : String?

var States : [RecitingQuizState]?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
TestId <- map["testId"]
States <- map["states"]
}
}

