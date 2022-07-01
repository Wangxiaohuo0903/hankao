import Foundation
import ObjectMapper

class RecitingListGlossariesResult : ResultContract
{
var Glossaries : [GlossaryAbstract]?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Glossaries <- map["gloss"]
}
}

