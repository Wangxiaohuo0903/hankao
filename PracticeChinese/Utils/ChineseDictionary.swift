//
//  ChineseDictionary.swift
//  PracticeChinese
//
//  Created by ThomasXu on 12/07/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import CocoaLumberjack

class ChineseDictionary {
    var tokensMap = [Character: String]()
    
    
    func addToDict(hanzi: String, pinyin: String) {
        let pinyin2 = ChineseUtil.getPinyinFromFlatFormStrings(flatStr: pinyin)
        let ttoken = hanzi.trimmingCharacters(in: .whitespacesAndNewlines)
        if pinyin2.count != ttoken.characters.count {
            DDLogInfo("ERROR: \(ttoken), \(pinyin), \(pinyin2)")
        }
        for i in 0 ..< ttoken.characters.count {
            let key = Array(ttoken.characters)[i]
            if (i < pinyin2.count) {
                tokensMap[key] = pinyin2[i]
            } else {
                tokensMap[key] = " "/////////////////使用空格
            }
        }
    }
    
    func getTextPinyin(str: String) -> String {
        let hanzis = Array(str.characters)
        var pinyin = ""
        for hanzi in hanzis {
            var py = String(hanzi)
            if false == ChineseUtil.isPunctuation(hanzi) {//如果不是标点符号
                var py = self.tokensMap[hanzi]
                if nil == py {
                    py = ""
                }
                if pinyin.characters.count > 0 {
                    pinyin += " "
                }
                pinyin += py!
            } else {//如果是标点符号，则进行映射
                if let char = ChineseUtil.getEnglishPunctuationFromChinese(hanzi) {
                    pinyin += String(char)//这里不需要添加空格
                }
            }
        }

        
        return pinyin
    }
    
    static func replaceChinesePunctuationWithEnglish(text: String) -> String {
        var result = ""
        let chars = Array(text.characters)
        for char in chars {
            if let char = ChineseUtil.getEnglishPunctuationFromChinese(char) {
                result.append("\(char)")//标点符号后面添加空格
            } else {
                result.append(char)
            }
        }
        return result
    }
}
