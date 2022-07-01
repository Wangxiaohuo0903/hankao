//
//  PinyinFormatter.swift
//  ChineseLearning
//
//  Created by feiyue on 19/04/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation


/*
 Tone Rule:
 1. if 'a' exists, put tone on 'a', return
 2. if 'e' or 'o' exists, put tone on 'e' or 'o', return
 3. if no a/e/o exists, put tone on the last i/u
 */

extension String {
    
    var length: Int {
        return self.characters.count
    }
    
    subscript (i: Int) -> String {
        return self[Range(i ..< i + 1)]
    }
        
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
}


var ToneDictionary = [
"a":"āáǎàa",
"e":"ēéěèe",
"o":"ōóǒòo",
"u":"ūúǔùu",
"i":"īíǐìi",
"v":"ǖǘǚǜü"
]

func PinyinFormat(_ rawString:String?) -> [String] {
    if rawString == nil {
        return []
    }
    var result = [String]()
    for str in rawString!.components(separatedBy: " ") {
    
        if str == "" {
            continue
        }
        guard let tone = Int(str.substring(from: str.characters.count-1)) else {
            result.append(str)
            continue
        }
        let pinyinStr = str.substring(to: str.characters.count-1)
        if let idx = pinyinStr.characters.index(of: "a") {
            result.append(pinyinStr.replacingOccurrences(of: "a", with: ToneDictionary["a"]![tone-1]))
        }
        else if let idx = pinyinStr.characters.index(of: "e") {
            result.append(pinyinStr.replacingOccurrences(of: "e", with: ToneDictionary["e"]![tone-1]))
        }
        else if let idx = pinyinStr.characters.index(of: "o") {
            result.append(pinyinStr.replacingOccurrences(of: "o", with: ToneDictionary["o"]![tone-1]))
        }
        else if let idx = pinyinStr.characters.index(of: "v") {
            result.append(pinyinStr.replacingOccurrences(of: "v", with: ToneDictionary["v"]![tone-1]))
        }

        else if let idx = pinyinStr.characters.index(of: "i") {
            if let idx2 = pinyinStr.characters.index(of: "u") {
                if idx > idx2 {
                    result.append(pinyinStr.replacingOccurrences(of: "i", with: ToneDictionary["i"]![tone-1]))
                }
                else {
                    result.append(pinyinStr.replacingOccurrences(of: "u", with: ToneDictionary["u"]![tone-1]))
                }
            }
            else {
                result.append(pinyinStr.replacingOccurrences(of: "i", with: ToneDictionary["i"]![tone-1]))
            }
        }
        else if let idx = pinyinStr.characters.index(of: "u") {
            result.append(pinyinStr.replacingOccurrences(of: "u", with: ToneDictionary["u"]![tone-1]))
        }
        else {
            result.append(pinyinStr)
        }
    }
    return result
}

func PinyinFormatWithoutSpace(ipa:String) -> [String] {
    return [""]
    //swift convert
//    var ipaString = ipa.replacingOccurrences(of: " ", with: "")
//    let pattern = "[a-z]{1,}[0-9]{1}"
//    let regex = try! NSRegularExpression(pattern: pattern, options: [])
//
//    // NSRegularExpression works with objective-c NSString, which are utf16 encoded
//    let matches = regex.matches(in: ipaString, range: NSMakeRange(0, ipaString.utf16.count))
//
//    // the combination of zip, dropFirst and map to optional here is a trick
//    // to be able to map on [(result1, result2), (result2, result3), (result3, nil)]
//    let splitResults = zip(matches, matches.dropFirst().map { Optional.some($0) } + [nil]).map { current, next -> String in
//        let range = current.range(at: 0)
//        let start = String.utf16Index(range.location)
//        // if there's a next, use it's starting location as the ending of our match
//        // otherwise, go to the end of the searched string
//        let end = next.map { $0.range(at: 0) }.map { String.UTF16Index($0.location) } ?? String.UTF16Index(ipaString.utf16.count)
//
//        return String(ipaString.utf16[start..<end])!
//    }
//    var result = [String]()
//    for str in splitResults {
//
//        guard let tone = Int(str.substring(from: str.characters.count-1)) else {
//            result.append(str)
//            continue
//        }
//        let pinyinStr = str.substring(to: str.characters.count-1)
//        if let idx = pinyinStr.characters.index(of: "a") {
//            result.append(pinyinStr.replacingOccurrences(of: "a", with: ToneDictionary["a"]![tone-1]))
//        }
//        else if let idx = pinyinStr.characters.index(of: "e") {
//            result.append(pinyinStr.replacingOccurrences(of: "e", with: ToneDictionary["e"]![tone-1]))
//        }
//        else if let idx = pinyinStr.characters.index(of: "v") {
//            result.append(pinyinStr.replacingOccurrences(of: "v", with: ToneDictionary["v"]![tone-1]))
//        }
//        else if let idx = pinyinStr.characters.index(of: "o") {
//            result.append(pinyinStr.replacingOccurrences(of: "o", with: ToneDictionary["o"]![tone-1]))
//        }
//        else if let idx = pinyinStr.characters.index(of: "i") {
//            if let idx2 = pinyinStr.characters.index(of: "u") {
//                if idx > idx2 {
//                    result.append(pinyinStr.replacingOccurrences(of: "i", with: ToneDictionary["i"]![tone-1]))
//                }
//                else {
//                    result.append(pinyinStr.replacingOccurrences(of: "u", with: ToneDictionary["u"]![tone-1]))
//                }
//            }
//            else {
//                result.append(pinyinStr.replacingOccurrences(of: "i", with: ToneDictionary["i"]![tone-1]))
//            }
//        }
//        else if let idx = pinyinStr.characters.index(of: "u") {
//            result.append(pinyinStr.replacingOccurrences(of: "u", with: ToneDictionary["u"]![tone-1]))
//        }
//        else {
//            result.append(pinyinStr)
//        }
//    }
//    return result
//swift convert
}
//swift convert
//func GetPinyinGroup(tokens: [IllustrationText]) -> [String] {
//    if tokens.count == 0 {
//        return []
//    }
//    var pinyinGroup = [String]()
//    for token in tokens {
//        var ipaString = token.IPA!.replacingOccurrences(of: " ", with: "")
//        let pattern = "[a-z]{1,}[0-9]{1}"
//        let regex = try! NSRegularExpression(pattern: pattern, options: [])
//
//        // NSRegularExpression works with objective-c NSString, which are utf16 encoded
//        let matches = regex.matches(in: ipaString, range: NSMakeRange(0, ipaString.utf16.count))
//
//        // the combination of zip, dropFirst and map to optional here is a trick
//        // to be able to map on [(result1, result2), (result2, result3), (result3, nil)]
//        let splitResults = zip(matches, matches.dropFirst().map { Optional.some($0) } + [nil]).map { current, next -> String in
//            let range = current.range(at: 0)
//            let start = String.UTF16Index(range.location)
//            // if there's a next, use it's starting location as the ending of our match
//            // otherwise, go to the end of the searched string
//            let end = next.map { $0.range(at: 0) }.map { String.UTF16Index($0.location) } ?? String.UTF16Index(ipaString.utf16.count)
//
//            return String(ipaString.utf16[start..<end])!
//        }
//        var result = [String]()
//        for str in splitResults {
//
//            guard let tone = Int(str.substring(from: str.characters.count-1)) else {
//                result.append(str)
//                continue
//            }
//            let pinyinStr = str.substring(to: str.characters.count-1)
//            if let idx = pinyinStr.characters.index(of: "a") {
//                result.append(pinyinStr.replacingOccurrences(of: "a", with: ToneDictionary["a"]![tone-1]))
//            }
//            else if let idx = pinyinStr.characters.index(of: "e") {
//                result.append(pinyinStr.replacingOccurrences(of: "e", with: ToneDictionary["e"]![tone-1]))
//            }
//            else if let idx = pinyinStr.characters.index(of: "o") {
//                result.append(pinyinStr.replacingOccurrences(of: "o", with: ToneDictionary["o"]![tone-1]))
//            }
//            else if let idx = pinyinStr.characters.index(of: "v") {
//                result.append(pinyinStr.replacingOccurrences(of: "v", with: ToneDictionary["v"]![tone-1]))
//            }
//            else if let idx = pinyinStr.characters.index(of: "i") {
//                if let idx2 = pinyinStr.characters.index(of: "u") {
//                    if idx > idx2 {
//                        result.append(pinyinStr.replacingOccurrences(of: "i", with: ToneDictionary["i"]![tone-1]))
//                    }
//                else {
//                    result.append(pinyinStr.replacingOccurrences(of: "u", with: ToneDictionary["u"]![tone-1]))
//                }
//            }
//            else {
//                result.append(pinyinStr.replacingOccurrences(of: "i", with: ToneDictionary["i"]![tone-1]))
//            }
//        }
//        else if let idx = pinyinStr.characters.index(of: "u") {
//            result.append(pinyinStr.replacingOccurrences(of: "u", with: ToneDictionary["u"]![tone-1]))
//        }
//        else {
//            result.append(pinyinStr)
//        }
//        }
//        pinyinGroup.append(result.joined())
//    }
//    return pinyinGroup
//}

//swift convert
