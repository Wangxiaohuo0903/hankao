import Foundation
import ObjectMapper

class TextAndImage : Image
{
var Text : String?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Text <- map["t"]
}
}

