import Foundation
import ObjectMapper

class GetScenarioTestPaperResult : ResultContract
{
var TestLessonId : String?

var LessonInfo : ScenarioLessonAbstract?

var CreateDate : Date?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
TestLessonId <- map["lid"]
LessonInfo <- map["lessonInfo"]
CreateDate <- map["creationDate"]
}
}

