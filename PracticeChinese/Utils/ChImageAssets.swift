//
//  ClImageAssets.swift
//  ChineseLearning
//
//  Created by feiyue on 15/03/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit

enum ChImageAssets:String {
    
    case startPageOne = "start_top_1"
    case startPageTwo = "start_top_2"
    case startPageThree = "start_top_3"
    case startPageWaves = "start_waves"
    
    case CheckIcon = "check"
    case VoiceIcon3 = "audio3"
    case VoiceIcon1 = "audio1"
    case VoiceIcon2 = "audio2"
    case VoiceIconSpeaker1 = "speaker01"
    case VoiceIconSpeaker2 = "speaker02"
    case VoiceIconSpeaker3 = "speaker03"
    case AudioBlue3 = "audioBlueSmall3"
    case AudioBlue1 = "audioBlueSmall1"
    case AudioBlue2 = "audioBlueSmall2"
    case VoiceIconWhite3 = "audiowhite3"
    case VoiceIconWhite1 = "audiowhite1"
    case VoiceIconWhite2 = "audiowhite2"
    
    case VoiceIconWhiteRight1 = "play01"
    case VoiceIconWhiteRight2 = "play02"
    case VoiceIconWhiteRight3 = "play03"
    case DuiIcon = "Dui"

    case CompletedIcon = "completed"
    case MoreIcon = "more"
    case MoreIconLearn = "moreLearn"
    case CloseIcon = "close_dark"
    case CloseIcon80 = "close_dark_80"
    case CloseIcon_light = "close_light"
    case Speak_More = "Speak_More"
    case More_Icon80 = "more_icon80"
    case quit = "quit"
    case sun = "sun"
    case SpeakIcon = "speak"
    case PlayIcon = "play"
    case Lock = "lock"
    case Mark = "mark"
    case Light = "light"
    case Light_big = "Light_big"
    case PlaceHolder = "placeholder"
    case HeartFull = "life-full"
    case HeartEmpty = "life-empty"
    
    case HeadPhone = "headphone"
    case HeadSet = "headset"
    case MeIcon1 = "meIcon1"
    case MeIcon2 = "meIcon2"
    case Fail = "fail"
    case Avatar = "default_avatar"
    case Placeholder_Avatar = "placeholder_avatar"
    case Home_page = "homepage"
    case Current_senten = "currentsenten"
    case Next_sentence = "nextsentence"
    case AvatarSystem = "Avatar-system"
    case SelectedGoal = "box_checked"
    case UnselectedGoal = "box_unChecked"
    case ShareAPP = "shareAPP"
    case HandsFreeIcon = "handsfreeIcon"
    case RightArrow2 = "right"
    case AppHeader = "lefthead"
    
    case FailFace = "fail_face"
    
    case MediaPlay = "play_icon"
    case MediaPause = "pause_icon"
    case MediaNext = "next_icon"

    case FailToPass = "fail_to_pass"
    case NotBad = "not-bad"
    case Perfect = "perfect"

    case Congratulations = "Congratulations"
    case CongratulationBackground = "Congratulation-background"
    case KeepTry = "keep-trying"
    
    case myAudioActive = "my_audio_active"
    case myAudioNotActive = "my_audio_not_active"
    case myAudioPlay = "my_audio_play"
    case myAudioMe = "my_audio_me"
    
    case cupScore = "cup_score"
    case startRecording = "start_recording"
    case inRecording = "in_recording"
    case recordingCancel = "recording_cancel"
    case recordGray = "record_gray"
    case audioPlayWord = "audio_play_word"
    case audioPlay = "audio_play"
    case audioPlaying = "audio_playing"
    case audioPlayCover = "audio_play_cover"
    
    case voiceLeft1 = "voice_left_1"
    case voiceLeft2 = "voice_left_2"
    case voiceLeft3 = "voice_left_3"
    
    case helpLeft = "help_left"
    case helpRight = "help_right"
    case helpMiddle = "help_mid"
    
    case scoreLess60 = "score_less_60"
    case score60To100 = "score_60_100"
    
    case trophyGray = "trophy_gray"
    case trophyGolden = "trophy_golden"
    case trophyGoldenStars = "trophy_golden_stars"
    
    case exp2 = "plus_2_exp"
    case exp3 = "plus_3_exp"
    case exp4 = "plus_4_exp"
    
    case medalGray = "medal_gray"
    case medalGolden = "medal_golden"
    
    case arrowUp = "arrow_up"//在有更多内容展示的地方使用
    case arrowDown = "arrow_down"
    
    case lessonPartFinish = "lesson_part_finish"
    
    case countDown1 = "count_down_1"
    case countDown2 = "count_down_2"
    case countDown3 = "count_down_3"
    case countDown4 = "count_down_4"
    case countDown5 = "count_down_5"

    case planEdit = "plan-edit"

    case mePageBlue = "blue"
    case mePageGreen = "green"
    case mePageRed = "red"
    case mePageYellow = "yellow"
    case selectedColor = "selected_color"
    
    case mePageBlueBlackYellow = "blue-black-yellow"
    case mePageRedBlackGreen = "red-black-green"
    case mePageAchievementsGrey = "achievements-grey"
    case mePageAchievements = "achievements"
    

    case mePageSetting = "settings"
    case mePageLearnedWords = "learnedwords"
    case mePageLearnedWordsGray = "learnedwords-gray"

    case mePageCompletedLessons = "completedlessons"
    case mePageCompletedLessonsGray = "completedlessons-gray"

    case mePageMedal = "medal"

    case myRecordingTime = "time"

    case HomeLearn = "homelearn"
    case HomeSpeak = "homespeak"
    case PointGray = "point_gray"
    case PointYellow = "point-yellow"
    case NextChat = "next"
    case SpeakNextChat = "SpeakNextChat"
    case SpeakContinueChat = "SpeakContinue"
    case MicrophoneBlue = "microphone-blue"
    case MicrophoneGray = "microphone-gray"
    case MicrophoneRepeat = "microphone-repeat"
    case MicrophoneLightBlue = "microphone-lightBlue"
    case InRecording01 = "inRecording01"
    case BackArrow = "back"
    case left_BackArrow = "left_back"
    case BlueBackArrow = "BlueBack"

    var image:UIImage? {
        if let img = UIImage(named:self.rawValue) {
            return img
        }
        return nil
    }
}

enum ChBundleImageUtil: String {
    case loginPopClose = "login-pop-close"
    case loginPopHead = "login-pop-head"
    case loginPopMicrosoft = "login-pop-microsoft"
    case loginPrivacy = "login-privacy"
    case loginWave = "login-wave"
    case startImage = "start-image"
    case beginnerGuideArrow = "beginner-guide"
    case learnChinese = "learn-chinese"
    
    case startPageOneX = "start-page-1-x"
    case startPageTwoX = "start-page-2-x"
    case startPageThreeX = "start-page-3-x"
    
    case startPageOneiPad = "start-page-1-ipad"
    case startPageTwoiPad = "start-page-2-ipad"
    case startPageThreeiPad = "start-page-3-ipad"
    case startPageOneFour = "start-page-1-4"
    case startPageTwoFour = "start-page-2-4"
    case startPageThreeFour = "start-page-3-4"
    case noNetwork = "no-network"
    case noNetworkCircle = "no-network-circle"
    case inTravelAirplane = "in-travel-airplane"
    case beginnerGuideBird = "beginner-guide-bird"
    
    var image: UIImage? {
        if let path = Bundle.main.path(forResource: self.rawValue, ofType: "png", inDirectory: "png") {
            return UIImage(contentsOfFile: path)
        }
        return nil
    }
}

enum ChBundleAudioUtil: String {
    
    case successful = "successful"
    case successquizRight = "right_answer"
    case successquizWrong = "wrong_answer"
    
    var url: URL {
        var path:String
        if(self.rawValue == "successful"){
            path = Bundle.main.path(forResource: self.rawValue, ofType: ".mp3", inDirectory: "sound")!
        }else{
            path = Bundle.main.path(forResource: self.rawValue, ofType: ".mp3", inDirectory: "sound")!
        }
        let soundUrl = NSURL.fileURL(withPath: path)
        return soundUrl
    }
}
