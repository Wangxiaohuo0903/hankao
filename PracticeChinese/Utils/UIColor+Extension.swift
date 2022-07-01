//
//  UIColor+Extension.swift
//  ChineseLearning
//
//  Created by feiyue on 15/03/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    class var blueTheme:UIColor {
        return UIColor.hex(hex: "#4974CE")
    }
    class var grayTheme:UIColor {
        return UIColor.hex(hex: "#F4F4F4")
    }
    class var quizTheme:UIColor {
        return UIColor.hex(hex: "#FFFFFF")
    }
    class var quizTextBlack:UIColor {
        return UIColor.hex(hex: "#333333")
    }
    class var quizContinueColor:UIColor {
        return UIColor.hex(hex: "#4974CE")
    }
    class var quizButtonBgColor:UIColor {
        return UIColor.hex(hex: "#D6E2FB")
    }
    class var itemGrayColor:UIColor {
        return UIColor.hex(hex: "#F4F4F4")
    }
    class var itemDragingColor:UIColor {
        return UIColor.hex(hex: "A8BEEA")
    }
    class var loadingBgColor:UIColor {
        return UIColor.hex(hex: "F4F4F4")
    }
    class var loadingTextColor:UIColor {
        return UIColor.hex(hex: "999999")
    }
    class var learingColor:UIColor {
//        if(AppData.colorBlindnessEnabled){
//            return UIColor.black
//        }else{
            return UIColor.hex(hex: "#4974CE")
//        }
    }
    class var headerGary: UIColor {
        return UIColor.hex(hex: "#5E5E5E")
    }
    class var textBlack: UIColor {
        return UIColor.hex(hex: "#2b2b2b")
    }
    class var textLightBlack: UIColor {
        return UIColor.hex(hex: "#222222")
    }
    class var textBlack333: UIColor {
        return UIColor.hex(hex: "#333333")
    }
    class var textGray: UIColor {
        return UIColor.hex(hex: "#666666")
    }
    class var lightText: UIColor {
        return UIColor.hex(hex: "#999999")
    }
    class var textLightGray: UIColor {
        return UIColor.hex(hex: "#bbbbbb")
    }
    
    class var toolightBlueTheme:UIColor {
        return UIColor.hex(hex: "#D7E2F3")
    }
    
    class var lightBlueTheme:UIColor {
        return UIColor.hex(hex: "#99C0EA")
    }
    class var lightPupleTheme:UIColor {
        return UIColor.hex(hex: "#CEDCED")
    }
    class var backgroundTheme:UIColor {
        return UIColor.hex(hex: "#EFEFF4")
    }

    class var placeholderImageColor:UIColor {
        return UIColor.hex(hex: "#AECDED")
    }
    
    class var speakscoreRed:UIColor {
        return UIColor.hex(hex: "#FF6868")
    }
    
    class var speakscoreGreen:UIColor {
        return UIColor.hex(hex: "#83BB56")
    }
    
    class var speakscoreWhite:UIColor {
        return UIColor.hex(hex: "#FFFFFF")
    }
    
    class var speakscoreBlack:UIColor {
        return self.quizTextBlack
    }
    class var correctColor:UIColor {
        if AppData.colorBlindnessEnabled {
            return UIColor.hex(hex: "67ABF5")
        }
        return UIColor.hex(hex: "#83BB56")
    }
    class var wrongColor:UIColor {
        if AppData.colorBlindnessEnabled {
            return UIColor.hex(hex: "EBA740")
        }

        return UIColor.hex(hex: "#FF5745")
    }
//   
//    class var gradientBgColor:[CGColor] {
//        return [UIColor(red: 36/256, green: 198/256, blue: 220/256, alpha: 1).cgColor,
//                UIColor(red: 81/256, green: 74/256, blue: 157/256, alpha: 1).cgColor]
//        //return [UIColor(red: 52/256, green: 34/256, blue: 46/256, alpha: 1).cgColor,
//         //       UIColor(red: 79/256, green: 65/256, blue: 67/256, alpha: 1).cgColor,
//          //      UIColor(red: 26/256, green: 6/256, blue: 26/256, alpha: 1).cgColor]
//
//
//    }
    
    class func hex(hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    static func colorFromRGB(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha:CGFloat) -> UIColor {
        let r = red / 255
        let g = green / 255
        let b = blue / 255
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }

}

extension UIImage {
    static func fromColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    static func fromColor(color: UIColor, alpha:CGFloat) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.setAlpha(alpha)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}


extension NSMutableAttributedString{
    func setColorForText(_ textToFind: String, with color: UIColor) {
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        }
    }
    func setFontForText(_ textToFind: String, with font: UIFont) {
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            addAttribute(NSAttributedString.Key.font, value: font, range: range)
        }
    }

    
}
