//
//  LiveOauth.swift
//  ChineseLearning
//
//  Created by feiyue on 05/04/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
class LiveOauth:NSObject {
    static var clientId = "0372c82d-326a-418f-8f1d-e3bf876eb5e0"
    static var redirectUrl = "https://login.live.com/oauth20_desktop.srf"
    
    static var signinUrl:String {
        get {
            return "https://login.live.com/oauth20_authorize.srf?client_id=\(clientId)&scope=wl.signin&response_type=code&redirect_uri=\(redirectUrl)"

        }
    }
}
