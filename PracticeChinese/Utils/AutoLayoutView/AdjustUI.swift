//
//  AdjustUI.swift
//  ChineseDev
//
//  Created by summer on 2017/12/5.
//  Copyright © 2017年 msra. All rights reserved.
//

import Foundation

enum AdjustScale {
    //for iPad 3:4
    case iPad
    //for iPhone X,XS
    case iPhoneX_XS
    //for iPhone XR,XMax
    case iPhoneXR_XSMax
    //for iPhone 6, 6s, 7, 8
    case iPhone
    //for iPhonePlus
    case iPhonePlus
    //for iPhone 4&4s
    case iPhone4
    //for iPhone 5, 5s, 5c, SE
    case iPhone5
}

enum AdjustResolution{
}

class AdjustGlobal:NSObject{
    var CurrentScale:AdjustScale!
    var CurrentScaleWidth:CGFloat!
    var CurrentScaleHeight:CGFloat!
    var ModelScale:AdjustScale!
    var ModelScaleWidth:CGFloat!
    var ModelScaleHeight:CGFloat!
    var UserDeviceModel:String!
    var UserDeviceVersion:String!
    var isiPad:Bool!
    
    override init() {
        super.init()
        //用于作为基准的比例
        self.ModelScale = AdjustScale.iPhone
        self.ModelScaleWidth = getModelScaleWidthandHeight(self.ModelScale).width
        self.ModelScaleHeight = getModelScaleWidthandHeight(self.ModelScale).height
        //当前自身比例
        self.CurrentScale = getDeviceScale()
        self.CurrentScaleWidth = UIScreen.main.bounds.width
        self.CurrentScaleHeight = UIScreen.main.bounds.height
        //当前设备信息，详细版本号与系统版本
        self.UserDeviceModel = getDeviceModel()
        self.UserDeviceVersion = getDeviceVersion()
        //判断是否为iPad
        self.isiPad = isModeliPad()
    }
    
    func isModeliPad() -> Bool{
        return (UIDevice.current.model == "iPad")
    }
    
    func getModelScaleWidthandHeight(_ ModelScale:AdjustScale) -> (width:CGFloat,height:CGFloat) {
        switch ModelScale {
        case .iPad:
            return (CGFloat(768),CGFloat(1024))
        case .iPhoneX_XS:
            return (CGFloat(375),CGFloat(812))
        case .iPhoneXR_XSMax:
            return (CGFloat(414),CGFloat(896))
        case .iPhoneX_XS:
            return (CGFloat(414),CGFloat(896))
        case .iPhoneXR_XSMax:
            return (CGFloat(414),CGFloat(896))
        case .iPhone4:
            return (CGFloat(320),CGFloat(480))
        case .iPhone5:
            return (CGFloat(320),CGFloat(568))
        case .iPhone:
            return (CGFloat(375),CGFloat(667))
        case .iPhonePlus:
            return (CGFloat(414),CGFloat(736))
        default:
            return (CGFloat(375),CGFloat(667))
        }
    }
    
    func getDeviceScale()->AdjustScale{
        let deviceModel = getDeviceScaleModel()
        
        
        if(deviceModel == "Simulator"){
            if(UIScreen.main.bounds.height == 480){
                return AdjustScale.iPhone4
            }else if (UIScreen.main.bounds.height == 812){
                return AdjustScale.iPhoneX_XS
            }else if (UIScreen.main.bounds.height == 896){
                return AdjustScale.iPhoneXR_XSMax
            }else if (UIScreen.main.bounds.height == 1024){
                return AdjustScale.iPad
            }else if (UIScreen.main.bounds.height == 568){
                return AdjustScale.iPhone5
            }
            else if (UIScreen.main.bounds.height == 736){
                return AdjustScale.iPhonePlus
            }else{
                return AdjustScale.iPhone
            }
        }else if(deviceModel == "iPad"){
            return AdjustScale.iPad
        }else if(deviceModel == "iPhoneX" || deviceModel == "iPhoneXS"){
            return AdjustScale.iPhoneX_XS
        }else if(deviceModel == "iPhoneXR" || deviceModel == "iPhoneXSMaX"){
            return AdjustScale.iPhoneXR_XSMax
        }else if(deviceModel == "iPhone4"){
            return AdjustScale.iPhone4
        }else if(deviceModel == "iPhone+"){
            return AdjustScale.iPhonePlus
        }else if(deviceModel == "iPhone5"){
            return AdjustScale.iPhone5
        }else{
            return AdjustScale.iPhone
        }
    }
    
    func getDeviceVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        switch identifier {
        case "iPod1,1":  return "iPod Touch 1"
        case "iPod2,1":  return "iPod Touch 2"
        case "iPod3,1":  return "iPod Touch 3"
        case "iPod4,1":  return "iPod Touch 4"
        case "iPod5,1":  return "iPod Touch (5 Gen)"
        case "iPod7,1":   return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":  return "iPhone 4"
        case "iPhone4,1":  return "iPhone 4s"
        case "iPhone5,1":   return "iPhone 5"
        case  "iPhone5,2":  return "iPhone 5 (GSM+CDMA)"
        case "iPhone5,3":  return "iPhone 5c (GSM)"
        case "iPhone5,4":  return "iPhone 5c (GSM+CDMA)"
        case "iPhone6,1":  return "iPhone 5s (GSM)"
        case "iPhone6,2":  return "iPhone 5s (GSM+CDMA)"
        case "iPhone7,2":  return "iPhone 6"
        case "iPhone7,1":  return "iPhone 6 Plus"
        case "iPhone8,1":  return "iPhone 6s"
        case "iPhone8,2":  return "iPhone 6s Plus"
        case "iPhone8,4":  return "iPhone SE"
        case "iPhone9,1":   return "国行、日版、港行iPhone 7"
        case "iPhone9,2":  return "港行、国行iPhone 7 Plus"
        case "iPhone9,3":  return "美版、台版iPhone 7"
        case "iPhone9,4":  return "美版、台版iPhone 7 Plus"
        case "iPhone10,1","iPhone10,4":   return "iPhone 8"
        case "iPhone10,2","iPhone10,5":   return "iPhone 8 Plus"
        case "iPhone10,3","iPhone10,6":   return "iPhone X"
        case "iPhone11,2":   return "iPhoneXS"
        case "iPhone11,8":   return "iPhoneXR"
        case "iPhone11,4","iPhone11,6":   return "iPhoneXSMaX"
            
        case "iPad1,1":   return "iPad"
        case "iPad1,2":   return "iPad 3G"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":   return "iPad 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":  return "iPad Mini"
        case "iPad3,1", "iPad3,2", "iPad3,3":  return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":   return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":   return "iPad Air"
        case "iPad4,4", "iPad4,5", "iPad4,6":  return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":  return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":  return "iPad Mini 4"
        case "iPad5,3", "iPad5,4":   return "iPad Air 2"
        case "iPad6,3", "iPad6,4":  return "iPad Pro 9.7"
        case "iPad6,7", "iPad6,8":  return "iPad Pro 12.9"
        case "AppleTV2,1":  return "Apple TV 2"
        case "AppleTV3,1","AppleTV3,2":  return "Apple TV 3"
        case "AppleTV5,3":   return "Apple TV 4"
        case "i386", "x86_64":   return "Simulator"
        default:  return "null"
        }
    }
    
    func getDeviceScaleModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        switch identifier {
            
        case "iPod1,1":  return "iPhone4"
        case "iPod2,1":  return "iPhone4"
        case "iPod3,1":  return "iPhone4"
        case "iPod4,1":  return "iPhone4"
        case "iPod5,1":  return "iPhone"
        case "iPod7,1":   return "iPhone"
            
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":  return "iPhone4"
        case "iPhone4,1":  return "iPhone4"
        case "iPhone5,1":   return "iPhone5"
        case  "iPhone5,2":  return "iPhone5"
        case "iPhone5,3":  return "iPhone5"
        case "iPhone5,4":  return "iPhone5"
        case "iPhone6,1":  return "iPhone5"
        case "iPhone6,2":  return "iPhone5"
        case "iPhone7,2":  return "iPhone"
        case "iPhone7,1":  return "iPhone+"
        case "iPhone8,1":  return "iPhone"
        case "iPhone8,2":  return "iPhone+"
        case "iPhone8,4":  return "iPhone5"
        case "iPhone9,1":  return "iPhone"
        case "iPhone9,2":  return "iPhone+"
        case "iPhone9,3":  return "iPhone"
        case "iPhone9,4":  return "iPhone+"
        case "iPhone10,1","iPhone10,4":   return "iPhone"
        case "iPhone10,2","iPhone10,5":   return "iPhone+"
        case "iPhone10,3","iPhone10,6":   return "iPhoneX"
        case "iPhone11,2":   return "iPhoneXS"
        case "iPhone11,8":   return "iPhoneXR"
        case "iPhone11,4","iPhone11,6":   return "iPhoneXSMaX"
            
        case "iPad1,1":   return "iPad"
        case "iPad1,2":   return "iPad"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":   return "iPad"
        case "iPad2,5", "iPad2,6", "iPad2,7":  return "iPad"
        case "iPad3,1", "iPad3,2", "iPad3,3":  return "iPad"
        case "iPad3,4", "iPad3,5", "iPad3,6":   return "iPad"
        case "iPad4,1", "iPad4,2", "iPad4,3":   return "iPad"
        case "iPad4,4", "iPad4,5", "iPad4,6":  return "iPad"
        case "iPad4,7", "iPad4,8", "iPad4,9":  return "iPad"
        case "iPad5,1", "iPad5,2":  return "iPad"
        case "iPad5,3", "iPad5,4":   return "iPad"
        case "iPad6,3", "iPad6,4":  return "iPad"
        case "iPad6,7", "iPad6,8":  return "iPad"
        case "AppleTV2,1":  return "AppleTV"
        case "AppleTV3,1","AppleTV3,2":  return "AppleTV"
        case "AppleTV5,3":   return "AppleTV"
        case "i386", "x86_64": return "Simulator"
        default:  return "null"
        }
    }
    
}

class UIAdjust{
    //根据当前标准的UI返回换算后的UI
    func adjustByWidth(_ width:Double) -> CGFloat {
        let widthFit = CGFloat(width)/AdjustGlobal().ModelScaleWidth*AdjustGlobal().CurrentScaleWidth
        return widthFit
    }
    
    func adjustByHeight(_ height:Double) -> CGFloat {
        let heightFit = CGFloat(height)/AdjustGlobal().ModelScaleHeight*AdjustGlobal().CurrentScaleHeight
        return heightFit
    }
    //根据百分比适配UI
    func adjustByWidthScale(_ scale:Double) -> CGFloat {
        return AdjustGlobal().CurrentScaleWidth*CGFloat(scale)
    }
    
    func adjustByHeightScale(_ scale:Double) -> CGFloat {
        return AdjustGlobal().CurrentScaleHeight*CGFloat(scale)
    }
}

class FontAdjust {
    func FontSize(_ size:Double) -> CGFloat {
        if(AdjustGlobal().isiPad){
            //iPad默认加5，1.4版本再说吧
            return CGFloat(size)
        }else{
            return CGFloat(size)
        }
    }
    //通用16
    func HeaderTitleFont() -> CGFloat {
        return 18.0
    }
    //通用18
    func RegularFont() -> Double {
        return 18.0
    }
    //type 15 22 中文
    func ChineseAndPinyin_C_Big() -> Double {
        return 27.0
    }
    //题干中拼模式里面的中文
    func ChineseAndPinyin_C() -> Double {
        return 22.0
    }
    
    //type 15 22 拼音
    func ChineseAndPinyin_P_Big() -> Double {
        return 14.0
    }
    //题干中拼模式里面的拼音
    func ChineseAndPinyin_P() -> Double {
        return 12.0
    }
    
    //选项中拼模式里面的中文
    func Option_ChineseAndPinyin_C() -> Double {
        return 18.0
    }
    //中拼模式里面的拼音
    func Option_ChineseAndPinyin_P() -> Double {
        return 12.0
    }
    //Speak中拼模式里面的中文
    func Speak_ChineseAndPinyin_C() -> Double {
        return 24.0
    }
    //Speak中拼模式里面的拼音
    func Speak_ChineseAndPinyin_P() -> Double {
        return 13.0
    }
    //按钮宽度
    func buttonWidth() -> CGFloat {
        return CGFloat(150.0)
    }
    //按钮高度
    func buttonHeight() -> CGFloat {
        return CGFloat(44.0)
    }
    //按钮字体大小
    func ButtonTitleFont() -> CGFloat {
        return 18.0
    }
    //返回按钮到边界的距离
    func quitButtonTop() -> CGFloat {
        return 3.0
    }
    

    func FontSizeScale(_ size:Double) -> CGFloat {
        return CGFloat(size)/AdjustGlobal().ModelScaleWidth*AdjustGlobal().CurrentScaleWidth
    }
    
    func FontSizeForiPhone4(_ size:Double,_ addition:Double) -> CGFloat {
        if(AdjustGlobal().isiPad){
            //iPad默认加5，1.4版本再说吧
            return CGFloat(size)
        }else if(AdjustGlobal().CurrentScale == AdjustScale.iPhone4){
            return CGFloat(size + addition)
        }else{
            return CGFloat(size)
        }
    }
    
    func FontSizeForiPad(_ size:Double,_ addition:Double) -> CGFloat {
        if(AdjustGlobal().isiPad){
            return CGFloat(size + addition)
        }else{
            return CGFloat(size)
        }
    }
}
//做学以致用消耗土地
class SunValueManager {

    private static var sharedSunValueManager: SunValueManager = {
        let sunValueManager = SunValueManager(sun: 30)
        return sunValueManager
    }()

    var sunValue: Int

    // Initialization

    private init(sun: Int) {
        self.sunValue = sun
    }
    class func shared() -> SunValueManager {
        return sharedSunValueManager
    }

}
