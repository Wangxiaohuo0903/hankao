//
//  GlobalSettings.swift
//  ChineseDev
//
//  Created by summer on 2017/11/20.
//  Copyright © 2017年 msra. All rights reserved.
//

import Foundation
import UIKit

//colorSettings



//stringSettings
extension String{
    static var scenarioEngine:String{
        return "8A369EFE-F68B-4615-825C-7D2B07B44934"
    }
    
    static var speakEngine:String{
        return "F0380421-86E5-43AE-91B2-F29062ADB024"
    }
    
    static var liveOauth:String{
        return "https://login.live.com/oauth20_token.srf"
    }
    
    static var baseEndpoint:String{
        #if DEV
            return "https://app-dev.mtutor.engkoo.com/proxy/"
        #elseif PROD
            return "https://service.mtutor.engkoo.com/"
        #else
            return "http://mtutor-prod-dev.cloudapp.net/"
        #endif
    }
    
    static var baseEndpointServices:String{
        #if DEV
            return "https://app-dev.mtutor.engkoo.com/proxy/services/"
        #elseif PROD
            return "https://service.mtutor.engkoo.com/services/"
        #else
            return "http://mtutor-prod-dev.cloudapp.net/services/"
        #endif
    }
    
    static var UserEndpoint:String{
        #if DEV
            return "https://app-dev.mtutor.engkoo.com/proxy/api/account/userinfo"
        #elseif PROD
            return "https://service.mtutor.engkoo.com/api/account/userinfo"
        #else
            return "http://mtutor-prod-dev.cloudapp.net/api/account/userinfo"
        #endif
    }
    
    static var PrivacyConsent: String {
        return "Microsoft Learn Chinese will collect data about your learning progress to personalize your lesson plan. You can disable collection at any time and delete any collected data by going to Privacy in the Setting menu."
    }
    static var PrivacyTitle: String {
        return "Data Collection and Permission"
    }
    static var PrivacySetting: String {
        return "Microsoft Learn Chinese will collect data about your learning progress to personalize your lesson plan. You can disable collection and erase all the recorded data."
    }
}

//urlSettings
extension URL{
    
}

extension Array {
    public func shuffle() -> Array {
        var list = self
        for index in 0..<list.count {
            let newIndex = Int(arc4random_uniform(UInt32(list.count-index))) + index
            if index != newIndex {
                list.swapAt(index, newIndex)
            }
        }
        return list
    }
}
