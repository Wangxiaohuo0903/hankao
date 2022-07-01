import Foundation
import ObjectMapper

class UpdateScenarioLessonProgressResult : ResultContract
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

class AddScenarioCourseToFavoriteResult : ResultContract
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
