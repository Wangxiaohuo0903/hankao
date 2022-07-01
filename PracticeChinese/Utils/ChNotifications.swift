//
//  ChNotifications.swift
//  ChineseLearning
//
//  Created by feiyue on 09/05/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
enum ChNotifications: String {
    case LessonProgressUpdated = "LessonProgressUpdated"
    case LoadNextLessonCard = "LoadNextLessonCard"
    case CompleteLearnPart = "CompleteLearnPart"
    case PronunciationLessonProgressUpdated = "PronunciationLessonProgressUpdated"
    case UserSignedOut = "UserSignedOut"
    case UserSignedIn = "UserSignedIn"
    case Refresh = "Refresh"
    case HasNewland = "HasNewland"
    case AnonymousSignedIn = "AnonymousSignedIn"
    case UpdateHomePage = "UpdateHomePage"
    case UpdateHomePageCoin = "UpdateHomePageCoin"
    case UpdateSunNumber = "updateSunNumber"
    case UpdateMePage = "UpdateMePage"
    case UpdateCourseProgress = "UpdateCourseProgress"
    
    case UpdateAllCourses = "UpdateAllCourses"
    case UpdateCoursesAddedIntoPlan = "UpdateCoursesAddedIntoPlan"//把课程添加到学习计划中
    case FinishOneLesson = "FinishOneLesson"//更新完成的lesson
    case FinishLessonScenarioPart = "FinishLessonScenarioPart"//完成 一个 Scenario
    case FinishLessonRepeatPart = "FinishLessonRepeatPart"//完成 一个 Scenario
    
    case ReloadPageInfos = "ReloadPageInfos"
    
    case NetWorkSuccessRequest = "NetWorkSuccessRequest"
    case NetworkFailedRequest = "NetworkFailedRequest"
    case NetworkFailedRequest_HomePage = "NetworkFailedRequest_HomePage"
    case NetworkEndLoading = "NetworkEndLoading"
    case ShowActivityViewInHomePage = "ShowActivityViewInHomePage"
    case DismissPop = "DismissPop"
    case faceBookDidLogin = "FaceBookDidLogin"
    var notification:NSNotification.Name {
        return NSNotification.Name(rawValue: self.rawValue)
    }
}
