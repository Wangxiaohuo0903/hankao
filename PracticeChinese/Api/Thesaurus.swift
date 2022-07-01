import Foundation
import ObjectMapper

class Thesaurus : Mappable
{
var PartOfSpeech : String?

var Synonyms : [ThesaurusItem]?

var Antonyms : [ThesaurusItem]?

required init?(map: Map)
{
}

func mapping(map: Map)
{
PartOfSpeech <- map["pos"]
Synonyms <- map["synonyms"]
Antonyms <- map["antonyms"]
}
}

