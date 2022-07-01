import Foundation
import ObjectMapper

class MultilingualInput : Mappable
{
var Language : String?

required init?(map: Map)
{
}

    init(lang: String) {
        self.Language = lang
    }
    
func mapping(map: Map)
{
Language <- map["lang"]
}
}

