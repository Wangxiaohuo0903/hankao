import Foundation
import ObjectMapper

class RecitingWordStateChangedInfo : Mappable
{
var Word : String?

var OldFavorability : Int?

var NewFavorability : Int?

var OldFamiliarity : Int?

var NewFamiliarity : Int?

var OldLearnedTime : Date?

var OldLearnedDateMark : Int?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Word <- map["Word"]
OldFavorability <- map["OldFavorability"]
NewFavorability <- map["NewFavorability"]
OldFamiliarity <- map["OldFamiliarity"]
NewFamiliarity <- map["NewFamiliarity"]
OldLearnedTime <- map["OldLearnedTime"]
OldLearnedDateMark <- map["OldLearnedDateMark"]
}
}

