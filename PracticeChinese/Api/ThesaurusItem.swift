import Foundation
import ObjectMapper

class ThesaurusItem : Mappable
{
var Word : String?

required init?(map: Map)
{
}

func mapping(map: Map)
{
Word <- map["word"]
}
}

