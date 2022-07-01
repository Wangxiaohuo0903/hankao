//
//  FacebookOauth.swift
//  PracticeChinese
//
//  Created by Intern on 18/07/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation

class FacebookOauth: NSObject {
    static let clientId = "661584137380947"    
    static let redirectUri = "http://learnchinese.oauth.com/"

    static var signinUrl: String {
        get {
            return "https://www.facebook.com/dialog/oauth?client_id=\(clientId)&redirect_uri=\(redirectUri)&scope=public_profile,email"
        }
    }
}
