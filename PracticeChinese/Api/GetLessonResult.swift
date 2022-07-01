import Foundation
import ObjectMapper

class GetLessonResult : SpeakingResult
{
var Lesson : Lesson?

required init?(map: Map)
{
super.init(map: map)
}

    /*
override func mapping(map: Map)
{
super.mapping(map: map)
Lesson <- map["lesson"]
}
}
*/

override func mapping(map: Map)
{
    super.mapping(map: map)
    Lesson <- (map["lesson"], PhonemeLessonConverter())
    
}
}
