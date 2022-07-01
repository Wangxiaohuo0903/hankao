import Foundation
import ObjectMapper
//题型
enum QuizType : Int
{
case QATextText = 0
case SingleTextText = 1
case MultipleTextText = 2
case SingleImageWord = 3
case MultipleImageWord = 4
case SingleWordImage = 5
case MultipleWordImage = 6
case SingleWordText = 7
case SingleImageAudio = 8
case SingleAudioImage = 10
case SpeakTextAudio = 12
case ListenAudioText = 13
case SpeakAudioAudio = 14
case ReadAfterme = 15
case Single_TextAudio_Text = 16
case Single_ImageAudio_Text = 17
case Single_AudioWord_Text = 18
case TF_ImageAudioMultiText = 19
case TF_ImageAudioText = 20
 
//图片匹配题
case SingleImageText = 9
//听力匹配题
case SingleAudioText = 11
//补全对话题
case SingContentText = 21
//文本翻译题
case SingleT_Text_Text = 22
//补全句子题
case SingF_Text_Text = 23
//理解题
case SingO_Text_Text = 24
//选词成句题
case SortingT_Text_World = 25
//连词成句排序题
case SortingS_Text_World = 26
//多空题
case Fillin_Text_Word = 27
//配对题
case Matching_Text_Text = 28
//判断对错题
case TF_Text_TF = 29
    
}


