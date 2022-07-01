import Foundation
import ObjectMapper

class RecitingWordProgress : Mappable
{
var Word : String?

var LastLearnedTime : Date?

var LastLearnedDateMark : Int?

var OldFamiliarity : Int?

var NewFamiliarity : Int?

var Favorability : Int?

var IsTestPassed : Bool?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Word <- map["w"]
LastLearnedTime <- map["t"]
LastLearnedDateMark <- map["d"]
OldFamiliarity <- map["o"]
NewFamiliarity <- map["n"]
Favorability <- map["f"]
IsTestPassed <- map["p"]
}
}

