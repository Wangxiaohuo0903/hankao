import Foundation
import ObjectMapper

class UserScenarioLessonAbstract : ScenarioLessonAbstract
{
var Score : Int?

var Progress : Int?
    
var isFinished : Bool?
    
required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Score <- map["score"]
Progress <- map["progress"]
}
}

