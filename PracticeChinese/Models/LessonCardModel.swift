//
//  LessonCard.swift
//  ChineseLearning
//
//  Created by feiyue on 16/03/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation

enum CardStatus {
    case Locked
    case Unlocking
    case Unlocked
    case Done
}

class LessonCard:NSObject {
    var cardType:CardStatus!
    var sid:String
    var learnId:String
    var practiseId:String
    var chatId:String
    var cardText:String
    var id:Int
    
    init(id:Int = 0,sid:String = "", lid:String = "", cid:String = "", pid:String = "", type:CardStatus = .Locked, text:String = "测试data") {
        self.id = id
        self.sid = sid
        self.learnId = lid
        self.practiseId = pid
        self.chatId = cid
        self.cardType = type
        self.cardText = text
    }
    
}
