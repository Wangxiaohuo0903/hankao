//
//  FacebookUserModel.swift
//  PracticeChinese
//
//  Created by Anika Huo on 8/22/17.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import ObjectMapper

class FacebookUserModel: UserModel
{
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        oauthRefreshToken <- map["facebook_refresh_token"]
        oauthAccessToken <- map["facebook_access_token"]
        oauthPictureUrl <- map["facebook_picture"]
        oauthFirstName <- map["facebook_name"]
        oauthLastName <- map["facebook_name"]
        oauthId <- map["facebook_id"]
    }
}
