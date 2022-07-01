import Foundation
import ObjectMapper

class WritingRaterInput : MultilingualInput
{
var Text : String?

var Question : String?

var ExpectedAnswer : String?

var Keywords : [String]?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Text <- map["text"]
Question <- map["question"]
ExpectedAnswer <- map["expectedAnswer"]
Keywords <- map["keywords"]
}
}

