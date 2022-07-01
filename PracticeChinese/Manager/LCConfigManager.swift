//
//  LCConfigManager.swift
//  PracticeChinese
//
//  Created by 费跃 on 9/18/18.
//  Copyright © 2018 msra. All rights reserved.
//

import Foundation

class LCConfigManager {
    static let shared = LCConfigManager()
    func loadConfig() {
        AppData.setDefault()
        
        AppData.colorBlindnessEnabled = UserDefaults.standard.bool(forKey: "colorBlindnessEnabled")
        AppData.handsfreeModelEnabled = UserDefaults.standard.bool(forKey: "handsfreeModelEnabled")
        AppData.userExperienceEnabled = UserDefaults.standard.bool(forKey: "userExperienceEnabled")
        AppData.userAssessmentEnabled = UserDefaults.standard.bool(forKey: "userAssessmentEnabled")
    }
    func updateConfig() {
        UserDefaults.standard.set(AppData.colorBlindnessEnabled, forKey: "colorBlindnessEnabled")
        UserDefaults.standard.set(AppData.handsfreeModelEnabled, forKey: "handsfreeModelEnabled")
        UserDefaults.standard.set(AppData.userExperienceEnabled, forKey: "userExperienceEnabled")
        UserDefaults.standard.set(AppData.userAssessmentEnabled, forKey: "userAssessmentEnabled")
    }
    func clearConfig() {
        UserDefaults.standard.removeObject(forKey: "colorBlindnessEnabled")
        UserDefaults.standard.removeObject(forKey: "handsfreeModelEnabled")
        UserDefaults.standard.removeObject(forKey: "userExperienceEnabled")
        UserDefaults.standard.removeObject(forKey: "userAssessmentEnabled")
    }
}
