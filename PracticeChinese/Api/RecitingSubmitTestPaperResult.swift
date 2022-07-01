import Foundation
import ObjectMapper

class RecitingSubmitTestPaperResult : ResultContract
{
var TestId : String?

var EstimatedVocabularySize : Int?

var RecommendedGlossaries : [GlossaryAbstract]?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
TestId <- map["testId"]
EstimatedVocabularySize <- map["vocabSize"]
RecommendedGlossaries <- map["recGloss"]
}
}

