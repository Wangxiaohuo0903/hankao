import Foundation
import ObjectMapper

class ParentLesson : Lesson
{
required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
}
}

