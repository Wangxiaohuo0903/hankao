import Foundation
import ObjectMapper

class RecitingWordFamiliarityChangedInfo : Mappable
{
var Word : String?

var NewFamiliarity : Int?

var OldFamiliarity : Int?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Word <- map["Word"]
NewFamiliarity <- map["NewFamiliarity"]
OldFamiliarity <- map["OldFamiliarity"]
}
}

