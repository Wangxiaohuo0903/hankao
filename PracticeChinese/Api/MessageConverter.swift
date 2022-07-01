import Foundation
import ObjectMapper

class MessageConverter : Message
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

