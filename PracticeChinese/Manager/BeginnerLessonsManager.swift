//
//  BeginnerLessons.swift
//  PracticeChinese
//
//  Created by summer on 2017/9/12.
//  Copyright © 2017年 msra. All rights reserved.
//

import Foundation
import Alamofire

class BeginnerLessonsManager: NSObject {
    var learningCard = [ScenarioLessonLearningItem]()
    var quizCard = [QuizSample]()
    var allCard = [Any]()
    var voice = Dictionary<String,SentenceDetail>()
    var id = "L3-1-1-s-CN"
    
    static var shared = BeginnerLessonsManager()

    func getCourse(id:String, completion:@escaping (Bool?,Error?)->()){
        var options = [String:String]()
        options["get-scenario-lesson"] = ""
        options["multi-round"] = ""
        CourseManager.shared.getScenarioLessonInfo(id: id) {
            (data,error) in
            
            if(data != nil){
                let course:PracticeScenarioLesson = data!.ScenarioLesson as! PracticeScenarioLesson
                self.learningCard = course.LearningItems!
                self.quizCard = course.Quizzes!
                self.allCard = []
                if let videoDic = (data?.VideoSentenceDictionary?.TextDictionary){
                    self.voice = videoDic
                }
                self.id = data!.ScenarioLesson!.Id!
                completion(true,error)
            }else{
                completion(false,error)
            }
            self.log()
        }
    }
    
    func log(){
    }

}
