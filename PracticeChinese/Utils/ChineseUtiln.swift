//
//  ChinesePinyin.swift
//  ChineseLearning
//
//  Created by ThomasXu on 26/04/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation


class ChineseUtil {
    static let pinyinToToneChars: [Character: String] =
        ["a": "aāáǎà",//增加了轻声
            "o": "oōóǒò",
            "e": "eēéěè",
            "i": "iīíǐì",
            "u": "uūúǔù",
            "ü": "uǖǘǚǜ"]
    static let punctuationMap: [Character: Character] = [
        ",": ",",
        ".": ".",
        "？": "?",
        "?": "?",
        "!": "!",
        ":": ":",
        ";": ";",
        "，": ",",
        "。": ".",
        "：": ":",
        "！": "!",
        "；": ";"]
    static let basicYunmus: [Character] = ["a", "o", "e", "i", "u", "ü"]
    
    static let shengmu: [String] = ["b", "p", "m", "f",
                                    "d", "t", "n", "l",
                                    "g", "k", "h", "j",
                                    "q", "x", "y", "w",
                                    "zh", "ch", "sh", "r",
                                    "z", "c", "s"]
    static let chinesePunctuations: [Character] = [",", ".", "?", "!", "，", "。", "？", "！", "|", "—", "—", "+", "-"]
    static let maxToneIndex = 4
    
    static func isPunctuation(_ c: Character) -> Bool {
        if chinesePunctuations.contains(c) {
            return true
        }
        return false
    }
    
    static func getEnglishPunctuationFromChinese(_ c: Character) -> Character? {
        if let en = punctuationMap[c] {
            return en
        }
        return nil
    }
    
    //获取打了音标的字母
    static func getToneChar(char: Character, toneIndex: Int) -> Character? {
        if toneIndex < 0 || toneIndex > maxToneIndex {
            return nil
        }
        
        let temp = pinyinToToneChars[char]
        if nil == temp {
            return nil
        }
        let index = temp!.index(temp!.startIndex, offsetBy: toneIndex)
        return temp![index]
    }
    
    //获取韵母音标应该打在哪里
    private static func getToneCharIndex(str: String) -> Int {
        var chars = Array(str.characters)
        var index = -1
        if str == "iu" || str == "ie" || str == "üe" || str == "ui" {
            index = 1
        } else {
            for i in 0...chars.count - 1 {
                if basicYunmus.contains(chars[i]) {
                    index = i
                    break
                }
            }
        }
        return index
    }
    
    //获取打了音标的韵母
    static func getToneString(str: String, toneIndex: Int) -> String {
        let index = getToneCharIndex(str: str)
        if -1 == index {
            return str
        }
        var chars = Array(str.characters)
        chars[index] = getToneChar(char: chars[index], toneIndex: toneIndex)!
        return String(chars)
    }
    
    //给韵母打上4个音标，返回带有4个音标的字符串
    static func getStringToneStrings(str: String) -> String? {
        var result = ""
        for i in 0...maxToneIndex {
            if i > 0 {
                result.append(" ")
            }
            result.append(getToneString(str: str, toneIndex: i))
            
        }
        return result
    }
    
    //解析 quiz 中的 HighLight 字段，在第一版中文 使用
    static func parseHighlightText(str: String?) -> String {
        if let str = str {
            let start = str.range(of: "*")
            let end = str.range(of: "*", options: .backwards)
            let range = Range<String.Index>(uncheckedBounds: (lower: start!.upperBound, upper: end!.lowerBound))//如果找不到怎么办?
            return str.substring(with: range)
        }
        return ""
    }
    
    //分离字符串中的拼音部分 和 数字 部分，这里 数字 应该只有一位，且在 0-4之间（包含）
    static func parseAudioText(_ text: String?) -> (String?, UInt32?) {
        if nil == text {
            return (nil, nil)
        }
        let real = text!
        if real.characters.count == 0 {
            return (real, nil)
        }
        var tone: UInt32?
        let numIndex = real.index(before: real.endIndex)
        let usZero = UnicodeScalar("0")!.value
        let usNine = UnicodeScalar("9")!.value
        var endIndex = real.endIndex
        let num = UnicodeScalar("\(real[numIndex])")!.value
        if num >= usZero && num <= usNine {
            tone = num - usZero
            endIndex = real.index(before: real.endIndex)
        }
        let range = Range<String.Index>(uncheckedBounds: (lower: real.startIndex, upper: endIndex))
        return (real.substring(with: range), tone)
    }
    
    //从类似  hang2（音调以数字形式出现在末尾的的）的拼音获得 háng
    static func getPinyinFromFlatForm(flatStr: String) -> String? {
        let (temp, tone) = parseAudioText(flatStr)
        if nil == temp || nil == tone {
            return nil
        }
        let untemp = temp!
        for i in 0 ... self.shengmu.count - 1 {
            if untemp.hasPrefix(self.shengmu[i]) {
                let left = untemp.substring(from: self.shengmu[i].characters.count)
                return shengmu[i] + getPinyinWithoutShengmu(noshengmu: left, tone: Int(tone!))
            }
        }
        return nil
    }
    
    static func getPinyinFromFlatFormStrings(flatStr: String) -> [String?] {
        var result = [String!]()
        let chars = Array(flatStr.characters)
        
        let usZero = UnicodeScalar("0")!.value
        let usNine = UnicodeScalar("9")!.value
        let usSpace = UnicodeScalar(" ")!.value
        
        var temp = [Character]()
        for i in 0 ..< chars.count {
            let num = UnicodeScalar(String(chars[i]))!.value
            if num == usSpace {
                continue
            }
            temp.append(chars[i])
            if num >= usZero && num <= usNine {
                if (temp.count > 0) {
                    let single = getPinyinFromFlatForm(flatStr: String(temp))
                    result.append(single)
                    temp.removeAll()
                }
            }
        }
        return result
        //最后一定是以空格或者数字结尾
    }
    
    //这个函数是为了获取 去掉 声母 剩下的部分音标应该打在哪个位置， 有一些特殊情况需要处理，如轻声， yuan，下雨（yu）
    static func getPinyinWithoutShengmu(noshengmu: String, tone: Int) -> String {
        var chars = Array(noshengmu.characters)
        var index: Int? = nil
        if noshengmu == "iu" || noshengmu == "ie" || noshengmu == "üe" || noshengmu == "ui" {
            index = 1
        } else {
            for i in 0...basicYunmus.count - 1 {//接下来找到最靠前的那一个
                if let ti = chars.index(of: basicYunmus[i]) {
                    index = ti
                    break
                }
            }
        }
        if let unIndex = index {
            if let newChar = getToneChar(char: chars[unIndex], toneIndex: tone) {
                chars[unIndex] = newChar
            }
        }
        return String(chars)
    }
    
    
    
    //从正在学习的单词word中提取出声调，toneYunmus为当前正在学习的韵母（带有声调组成的字符串，如 āáǎà ）
    static func getTone(word: String, tones: String) -> Int {
        
        if word.characters.count <= 0 {
            return -1
        }
        
        let la = UnicodeScalar("a")!
        let lz = UnicodeScalar("z")!
        let ua = UnicodeScalar("A")!
        let uz = UnicodeScalar("Z")!
        let uu = UnicodeScalar("ü")!
        var temp: UnicodeScalar!    //带有声调的字母
        for us in word.unicodeScalars {
            temp = us
            if (us >= la && us <= lz) || (us >= ua && us <= uz) || us == uu {
                continue
            }
            break
        }
        if nil == temp {
            return 0
        }
        
        if let range = tones.range(of: String(temp)) {//优先从指定的里面找
            return tones.distance(from: tones.startIndex, to: range.lowerBound)
        }
        //如果在指定的韵母里面没有找到，从其他的韵母里面找
//        print("getTone data error: \(word)")
        for (_, value) in pinyinToToneChars {
            if let range = value.range(of: String(temp)) {//如果没有找到该怎么处理？？？
                return value.distance(from: value.startIndex, to: range.lowerBound)
            }
        }
        return 0 // 默认返回 0
    }
    
    func testParseAudioText() {
        let strs = [nil, "", "abc", "4", "abc4", "a4"]
        for str in strs {
            print(ChineseUtil.parseAudioText(str))
        }
    }
    
    
    static func test() {
        let cases = ["wang2", "da4", "wei4", "wang2da4 wei4wang3"]
        for c in cases {
            print(getPinyinFromFlatFormStrings(flatStr: c))
        }
    }
}
