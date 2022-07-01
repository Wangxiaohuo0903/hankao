//
//  LinkedInOauth.swift
//  PracticeChinese
//
//  Created by Intern on 18/07/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
class LinkedInOauth: NSObject {
    static let clientId = "77fo17dim5h6tc"
    static let redirectUri = "http://com.learnchinese.linkedin.oauth/oauth"
    static let state = "linkedin\(Int(Date().timeIntervalSince1970))"
    static var signinUrl: String {
        get {
            return "https://www.linkedin.com/uas/oauth2/authorization?response_type=code&client_id=\(clientId)&redirect_uri=\(redirectUri)&state=\(state)&scope=r_liteprofile"
        }
    }
}
