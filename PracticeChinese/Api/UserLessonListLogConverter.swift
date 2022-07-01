import Foundation
import ObjectMapper

class UserLessonListLogConverter : UserLesson
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

