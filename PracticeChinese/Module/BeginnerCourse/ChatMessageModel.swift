//
//  ChatMessageModel.swift
//  PracticeChinese
//
//  Created by 费跃 on 9/13/17.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation

enum ChatMessageType {
    case tip
    case text
    case audio
    case audiotext
    case picture
}

enum ChatDirect {
    case left
    case right
}


class ChatMessageTokenModel: NSObject, NSCopying {
    
    var text = NSAttributedString()
    //如果是标点，拼音就是""
    var pinyinText = NSAttributedString()
    
    //是否变调，变调显示颜色不同
    var multitone = false
    
    var direct = ChatDirect.left
    
    func copy(with zone: NSZone? = nil) -> Any {
        let model = ChatMessageTokenModel()
        model.text = self.text
        model.pinyinText = self.pinyinText
        model.multitone = self.multitone
        model.direct = self.direct
        return model
    }

    func copyWithZone(zone: NSZone) -> AnyObject {
        let model = ChatMessageTokenModel()
        model.text = self.text
        model.pinyinText = self.pinyinText
        model.multitone = self.multitone
        model.direct = self.direct
        return model
    }

}

class ChatMessageModel: NSObject {
    var type: ChatMessageType
    //分语块的数组
    var textArray = [ChatMessageTokenModel]()
    var text = NSMutableAttributedString()
    var pinyinText = NSMutableAttributedString()
    //带空格的
    var pinyinTextSpace = NSMutableAttributedString()
    var imageUrl = ""
    var avatarUrl = ""
    var audioUrl = ""
    var index = ""
    var position: BubblePosition!
    var score:Int = 0
    var en = NSMutableAttributedString()
    var CellHeight : Int = 0
    init(type: ChatMessageType, text: String?, pinyin:String?, imageUrl: String?, avatarUrl: String?, audioUrl: String?, position: BubblePosition, en:String = "", index:String = "" ,textArray:[ChatMessageTokenModel]?)
    {
        self.type = type
        self.text = NSMutableAttributedString(string: text != nil ? text! : "")
        self.pinyinText = NSMutableAttributedString(string: pinyin != nil ? pinyin! : "")
        self.imageUrl = imageUrl != nil ? imageUrl! : ""
        self.avatarUrl = avatarUrl != nil ? avatarUrl! : ""
        self.audioUrl = audioUrl != nil ? audioUrl! : ""
        self.position = position
        self.en = NSMutableAttributedString(string: en)
        self.index = index
        if textArray != nil {
          self.textArray = textArray!
        }
    }
    
    init(text:String, position: BubblePosition, avatar: String = "") {
        self.type = .text
        self.text = NSMutableAttributedString(string: text)
        self.position = position
        self.avatarUrl = avatar
    }
    
    init(imageUrl: String?, position: BubblePosition) {
        self.type = .picture
        self.imageUrl = imageUrl != nil ? imageUrl! : ""
        self.position = position
    }
    
    init(audioUrl:String, position: BubblePosition, score:Int = -100, avatar:String = "") {
        self.type = .audio
        self.audioUrl = audioUrl
        self.position = position
        self.score = score
        self.avatarUrl = avatar
    }
    
}

//　学以致用打分页面
class PractiseMessageModel: NSObject {
    //分语块的数组
    var tokens = [Token]()
    var question = ""
    var english = ""
    var chinese = NSMutableAttributedString()
    var pinyin = ""
    var audioUrl = ""
    var userAudioUrl = NSURL(string: "")
    var score:Int = -1
    var CellHeight : Int = 0
    var fileName = ""
    
    init(question: String = "",english:String = "",chinese:String = "",pinyin:String = "", audiourl: String = "", userAudio: NSURL = NSURL(string: "")!,score: Int = 0, tokens:[Token],_ fileName:String = ""
        ) {
        self.english = english
        self.chinese = NSMutableAttributedString(string: chinese)
        self.pinyin = pinyin
        
        self.tokens = tokens
        self.audioUrl = audiourl
        self.userAudioUrl = userAudio
        self.score = score
        self.question = question
        self.fileName = fileName
    }
    
    
   
}
