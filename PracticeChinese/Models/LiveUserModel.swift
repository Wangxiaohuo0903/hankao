//
//  LiveUserModel.swift
//  PracticeChinese
//
//  Created by Anika Huo on 8/22/17.
//  Copyright © 2017 msra. All rights reserved.
//


import Foundation
import ObjectMapper

class LiveUserModel: UserModel
{
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        oauthRefreshToken <- map["live_refresh_token"]
        oauthAccessToken <- map["live_access_token"]
        oauthPictureUrl <- map["live_picture"]
        oauthFirstName <- map["live_first_name"]
        oauthLastName <- map["live_last_name"]
        oauthId <- map["live_id"]
    }
}

















