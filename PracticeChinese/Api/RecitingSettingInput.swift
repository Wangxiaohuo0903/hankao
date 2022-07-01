import Foundation
import ObjectMapper

class RecitingSettingInput : RecitingSetting
{
var Language : String?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Language <- map["lang"]
}
}

