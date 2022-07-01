import Foundation
import ObjectMapper

class RecitingWordSearchResult : ResultContract
{
var State : RecitingWordCategory?

var AddableState : RecitingWordAddableState?

var Definition : RecitingWordDefinition?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
State <- map["state"]
AddableState <- map["addableState"]
Definition <- map["word"]
}
}

