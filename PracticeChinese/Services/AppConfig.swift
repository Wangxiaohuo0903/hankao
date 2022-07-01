//
//  AppConfig.swift
//  ChineseLearning
//
//  Created by feiyue on 10/05/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import CocoaLumberjack
import SwiftyJSON

class AppData: NSObject {
    static var needUpdate = false
    static let appId = "1312951936"
    static var colorBlindnessEnabled:Bool = false //色盲模式
    static var handsfreeModelEnabled:Bool = false
    
    static var userExperienceEnabled:Bool = false
    static var userAssessmentEnabled:Bool = false
    static var versionNumber:String = "1.16.1216.0"
    //global lesson indicator for driving
    static var chatScenarioId:String = ""
    
   // static var lang = ""
    static var lang = "zh-CN"
    static var isCurrentChinese: Bool {
        return lang == "zh-CN"
    }
    
    static var coursesId: String {
        if isCurrentChinese {
            return "L2-1-s-CN"
        }
        return "L3-s-V2"
    }
    
    class func setHandsFreeSessionInfo(sid:String) {
        AppData.chatScenarioId = sid
        LCConfigManager.shared.updateConfig()
    }
    
    class func setColorBlindness(blind:Bool) {
        AppData.colorBlindnessEnabled = blind
        LCConfigManager.shared.updateConfig()

    }
    class func setUserAssessment(_ set: Bool, _ update:Bool = true) {
        if update {
            updatePrivacySetting(set, AppData.userExperienceEnabled)
        }
        AppData.userAssessmentEnabled = set
        LCConfigManager.shared.updateConfig()
        NotificationCenter.default.post(name: ChNotifications.UpdateHomePageCoin.notification, object: nil)
    }
    
    class func setUserExperience(_ set: Bool, _ update:Bool = true) {
        if update {
            updatePrivacySetting(AppData.userAssessmentEnabled, set)
        }
        AppData.userExperienceEnabled = set
        LCConfigManager.shared.updateConfig()
        NotificationCenter.default.post(name: ChNotifications.UpdateHomePageCoin.notification, object: nil)
    }
    
    class func updatePrivacySetting(_ assessBool:Bool, _ expBool:Bool) {
        var privacy = 3
        if !assessBool {
            privacy &= 1
        }
        if !expBool {
            privacy &= 2
        }
        ChActivityView.show()
        let callback: (ApiResponse?, Error?, String?)->() = {
            data, error, raw in
            ChActivityView.hide()
            if data == nil {
                DDLogDebug("update failed")
                return
            }
            else {
                DDLogDebug("update success")
            }
        }
        RequestManager.shared.performRequest(urlRequest: Router.setUserInfo(["privacyLevel":privacy+1]), completionHandler: callback)
    }
    class func setDefault() {
        AppData.userExperienceEnabled = false
        AppData.handsfreeModelEnabled = false
        AppData.userAssessmentEnabled = false
        AppData.colorBlindnessEnabled = false
    }
    class func getVersion() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
//        let build = dictionary["CFBundleVersion"] as! String
        return "\(version)"
    }
    class func checkVersion() {
        let callback: (ApiResponse?, Error?, String?)->() = {
            data, error, raw in
            if (raw ?? "") == "" {
                DDLogDebug("check failed")
                return
            }
            else {
                DDLogDebug("check success")
                if let dataFromString = raw!.data(using: .utf8, allowLossyConversion: false) {
                    let json = try! JSON(data: dataFromString)
                    let configString = json["configJson"].string
                    if let configData = configString?.data(using: .utf8, allowLossyConversion: false) {
                        let configJson = try! JSON(data: configData)
                        if let minversion = configJson["minVersion"].string {
                            //print(minversion)
                            UserDefaults.standard.set(minversion, forKey: "mini_version");
                            UserDefaults.standard.synchronize();
                            checkUpdates()
                        }
                    }
                }
            }
        }
        RequestManager.shared.performRequest(urlRequest: Router.VersionCheck(), completionHandler: callback)
    }
    class func checkUpdates() {
        if needUpdate {
            return
        }
        if let mini_version = UserDefaults.standard.string(forKey: "mini_version") {
            print(mini_version, AppData.getVersion())
            if mini_version > AppData.getVersion() {
                needUpdate = true
                let alert = UIAlertController(title: "Update Available", message: "To use the application, you need to upgrade it to the latest version available on Apple Store.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Update", comment: "Default action"), style: .default, handler: { _ in
                    needUpdate = false
                    UIApplication.shared.open(URL(string: "itms-apps://itunes.apple.com/app/viewSoftware?id=\(AppData.appId)")!, options: [:], completionHandler: nil)
                }))
                UIApplication.topViewController()!.present(alert, animated: true, completion: nil)

            }
        }
    }

}
