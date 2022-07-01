import Foundation
import ObjectMapper

class RecitingSetting : BinarySettingBase
{
var IsExperiencedUser : UserSettingYesNo?

var Inflections : RecitingSettingWordOption?

var Collocations : RecitingSettingWordOption?

var Thesauruses : RecitingSettingWordOption?

var Sentences : RecitingSettingWordOption?

var Figures : RecitingSettingWordOption?

var Jokes : RecitingSettingWordOption?

var Videos : RecitingSettingWordOption?

var WarningOnMastered : RecitingSettingWordOption?

var FigureQuiz : RecitingSettingQuizOption?

var RealQuiz : RecitingSettingQuizOption?

required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
IsExperiencedUser <- map["newUser"]
Inflections <- map["infl"]
Collocations <- map["coll"]
Thesauruses <- map["thes"]
Sentences <- map["bilsent"]
Figures <- map["figure"]
Jokes <- map["joke"]
Videos <- map["video"]
WarningOnMastered <- map["masterWarning"]
FigureQuiz <- map["figureQuiz"]
RealQuiz <- map["realQuiz"]
}
}

