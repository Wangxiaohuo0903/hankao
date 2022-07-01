//
//  FontUtil.swift
//  ChineseLearning
//
//  Created by ThomasXu on 02/05/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit

class FontUtil {
    
    enum FontUtilFontType {
        case Regular
        case Medium
        case Bold
        case Thin
    }
    
    //attention
    
    static let fontName = "PingFangSC-Regular"
    
    static func getFontDescriptor(fontName: String, bold: Bool) -> UIFontDescriptor {
        var attributes: [String: Any] = ["NSFontNameAttribute": fontName]
        var boldStr = "CTFontBoldUsage"
        if false == bold {
            boldStr = "CTFontRegularUsage"
        }
        attributes["NSCTFontUIUsageAttribute"] = boldStr
        return UIFontDescriptor(fontAttributes: convertToUIFontDescriptorAttributeNameDictionary(attributes))
     //   let font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
     //   print(font.fontDescriptor.fontAttributes)
    }
    
    static func getFontDescriptor(bold: Bool) -> UIFontDescriptor{
        if #available(iOS 9.0, *) {
            return getFontDescriptor(fontName: fontName, bold: bold)
        }
        else {
            return getFontDescriptor(fontName: "Avenir Light", bold: bold)
        }
    }
    static func alertTitleFont() -> UIFont {
        return FontUtil.getFont(size: FontAdjust().FontSize(16), type:.Regular)
    }
    static func getTitleFont() -> UIFont {
        return FontUtil.getFont(size: FontAdjust().FontSize(18), type:.Regular)
    }
    static func getSubTitleFont() -> UIFont {
        return FontUtil.getFont(size: FontAdjust().FontSize(16), type:.Regular)
    }
    static func getTextFont() -> UIFont {
        return FontUtil.getFont(size: FontAdjust().FontSize(14), type:.Regular)
    }

    static func getDescFont() -> UIFont {
        return FontUtil.getFont(size: FontAdjust().FontSize(12), type:.Regular)
    }

    static func getFont(size: CGFloat, type: FontUtilFontType) -> UIFont {
        var fontStr = "PingFangSC-Regular"
        switch type {
        case .Bold:
            fontStr = "PingFangSC-Semibold"
            break
        case .Regular:
            fontStr = "PingFangSC-Regular"
            break
        case .Medium:
            fontStr = "PingFangSC-Medium"
            break
        case .Thin:
            fontStr = "PingFangSC-Thin"
            break
        default:
            break
        }

        if #available(iOS 9.0, *) {
//            if(ScreenUtils.width == 320){
//                return UIFont(name: fontStr, size: size - 2)!
//            }else{
                return UIFont(name: fontStr, size: FontAdjust().FontSize(Double(size)))!
//            }
        }
        else {
            if(ScreenUtils.width == 320){
                return UIFont.systemFont(ofSize: size-2)
            }else{
                return UIFont(name: fontStr, size: size)!
            }
        }
    }
    
    static func getBeginnerGuideAttributedString(content: String) -> NSAttributedString {
        return NSAttributedString(string: content, attributes: convertToOptionalNSAttributedStringKeyDictionary(getBeginnerGuideAttribute()))
    }
    
    private static func getBeginnerGuideAttribute() -> [String: Any] {
        var temp: [String: Any] = [convertFromNSAttributedStringKey(NSAttributedString.Key.font): FontUtil.getFont(size: 14, type: .Regular)]
        temp[convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor)] = UIColor.blueTheme
        return temp
    }
}

class NetworkUtil {
    
    static func getPronunciationAudioUrlString(_ urlString: String?) -> String? {
        if let urlString = urlString {
            if urlString.hasPrefix("http") {
                return urlString
            }
            else {
                return "https://mtutordev.blob.core.chinacloudapi.cn/system-audio/lesson/zh-CN/zh-CN/audio/\(urlString)"
            }
        }
        return nil
    }
    
    static func getPronunciationAudioURL(_ urlString: String?) -> URL? {
        if let urlString = getPronunciationAudioUrlString(urlString) {
            return URL(string: urlString)
        }
        return nil
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIFontDescriptorAttributeNameDictionary(_ input: [String: Any]) -> [UIFontDescriptor.AttributeName: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIFontDescriptor.AttributeName(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
