import Foundation
import ObjectMapper

class RecitingGetGlossaryWordsInput : MultilingualInput
{
var GlossaryId : String?

var StartIndex : Int?

var PageCount : Int?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
GlossaryId <- map["gid"]
StartIndex <- map["start"]
PageCount <- map["takeCount"]
}
}

