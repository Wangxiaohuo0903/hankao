import Foundation
import ObjectMapper

class ScenarioSubLessonInfo : Mappable
{
var ScenarioLessonInfo : UserScenarioLessonAbstract?

var SubLessons : [ScenarioSubLessonInfo]?

required init?(map: Map)
{
}

func mapping(map: Map)
{
    ScenarioLessonInfo <- map["lessonInfo"]
    SubLessons <- map["subLessons"]
}
}



class GetScenarioLearnedItemResult : Mappable
{
    var items : [learnedItemResult]?
    
    required init?(map: Map)
    {
    }
    
    func mapping(map: Map)
    {
        items <- map["items"]
    }
}

class learnedItemResult : Mappable{
    var Text: String?
    var IPA: String?
    var NativeText: String?
    var DifficultyLevel: Int?
    var IPA1: String?
    var RelatedLessons: [String]?
    required init?(map: Map) {
    }
    init() {
    }
    func mapping(map: Map) {
        Text <- map["text"]
        IPA <- map["ipa"]
        IPA1 <- map["ipa1"]
        DifficultyLevel <- map["difficultyLevel"]
        NativeText <- map["nativeText"]
        RelatedLessons <- map["relatedLessons"]
    }
}
