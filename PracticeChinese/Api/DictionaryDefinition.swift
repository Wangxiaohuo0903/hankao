import Foundation
import ObjectMapper

class DictionaryDefinition : ResultContract
{
var Text : String?

var OneLineDefinition : String?

var Pronunciations : [Pronunciation]?

var Inflections : [Inflection]?

var SenseGroups : [SenseGroup]?

var HomoSenseGroups : [SenseGroup]?

var Collocations : [Collocation]?

var Thesauruses : [Thesaurus]?

var BilingualSamples : [BilingualSample]?

var Phrases : [PhraseItem]?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Text <- map["text"]
OneLineDefinition <- map["oneLineDef"]
Pronunciations <- map["prons"]
Inflections <- map["infls"]
SenseGroups <- map["senseGroups"]
HomoSenseGroups <- map["homoSenseGroups"]
Collocations <- map["colls"]
Thesauruses <- map["thess"]
BilingualSamples <- map["bilSents"]
Phrases <- map["phrases"]
}
}

