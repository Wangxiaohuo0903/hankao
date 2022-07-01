import Foundation
import ObjectMapper

class RecitingTestResult : Mappable
{
var Time : Date?

var EstimatedVocabularySize : Int?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Time <- map["time"]
EstimatedVocabularySize <- map["vocabSize"]
}
}

