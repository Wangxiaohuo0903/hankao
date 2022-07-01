import Foundation
import ObjectMapper

class RecitingGetRecitingWordsInput : MultilingualInput
{
var ContinuationToken : String?

var Filter : RecitingVocabularyFilterType?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
ContinuationToken <- map["contToken"]
Filter <- map["filter"]
}
}

