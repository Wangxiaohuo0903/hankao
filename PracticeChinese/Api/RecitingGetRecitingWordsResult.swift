import Foundation
import ObjectMapper

class RecitingGetRecitingWordsResult : ForwardPagedResultContract<RecitingWordState>
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

