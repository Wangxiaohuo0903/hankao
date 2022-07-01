import Foundation
import ObjectMapper

class SpeakingSetting : BinarySettingBase
{
var Language : String?

var IsNewUser : UserSettingYesNo?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Language <- map["lang"]
IsNewUser <- map["newUser"]
}
}

