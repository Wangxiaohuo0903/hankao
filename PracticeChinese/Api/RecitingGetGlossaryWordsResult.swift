import Foundation
import ObjectMapper

class RecitingGetGlossaryWordsResult : RandomPagedResultContract<String>
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

