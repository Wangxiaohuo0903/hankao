import Foundation
import ObjectMapper

class ScenarioLessonAbstract : ResultContract
{
var Id : String?

var LessonType : ScenarioLessonType?

var ParentId : String?

var Name : String?

var NativeName : String?

var ImageUrl : String?

var Tags : [String]?
    
var TriedCount : Int?
    
var LearnRate : Double?
    
var ItemLearnRateDict: String?
    
var DifficultyLevel : Int?

var Version : String?
    
var LessonIcons : [String]? = [""]

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
    super.mapping(map: map)
    Id <- map["id"]
    LessonType <- map["type"]
    ParentId <- map["pid"]
    Name <- map["name"]
    NativeName <- map["nativeName"]
    ImageUrl <- map["backgroundImage"]
    Tags <- map["tags"]
    DifficultyLevel <- map["difficultyLevel"]
    Version <- map["version"]
    TriedCount <- map["triedCount"]     //尝试过几轮
    LearnRate <- map["learnRate"]           //课程掌握情况
    ItemLearnRateDict <- map["itemLearnRateDict"]   //learning item掌握情况
    LessonIcons <- map["lessonIcons"]
}
}

