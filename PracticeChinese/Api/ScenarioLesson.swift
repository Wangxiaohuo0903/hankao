import Foundation
import ObjectMapper

class CommentItem: ResultContract {
    var score: Int?
    var sentence: VideoSentence?
    required init?(map: Map)
    {
        super.init(map: map)
    }
    
    override func mapping(map: Map)
    {
        super.mapping(map: map)
        score <- map["Item1"]
        sentence <- map["Item2"]
    }
    
}

class ScenarioLesson : ScenarioLessonAbstract
{
//学以致用，添加背景介绍
var Introducation : VideoSentence?

var Comments: [CommentItem]?

var Summary : VideoSentence?

var LearningItems : [ScenarioLessonLearningItem]?

var VideoURL : String?

var VideoBackgroundImg : String?

var ChatTurn : [ChatTurn]?

var ModelType : String?
var BackgroundImage : String?
required init?(map: Map)
{
super.init(map: map)
}

override func mapping(map: Map)
{
super.mapping(map: map)
Introducation <- map["intro"]
Comments <- map["comments"]
Summary <- map["summary"]
LearningItems <- map["learningItem"]
VideoURL <- map["videoUrl"]
VideoBackgroundImg <- map["videoBackgroundImg"]
ChatTurn <- map["chatTurn"]
ModelType <- map["modelType"]
BackgroundImage <- map["backgroundImage"]
}
}

