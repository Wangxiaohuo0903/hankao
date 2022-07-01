import Foundation
import ObjectMapper

class PronunciationRaterResult : ResultContract
{
var Score : Int?

var Detail : PronunciationRaterData?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Score <- map["score"]
Detail <- map["detail"]
}
}

