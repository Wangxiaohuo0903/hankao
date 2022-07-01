//
//  LinkedInUserModel.swift
//  PracticeChinese
//
//  Created by Anika Huo on 8/22/17.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import ObjectMapper

class LinkedInUserModel: UserModel
{
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        oauthRefreshToken <- map["linkedin_refresh_token"]
        oauthAccessToken <- map["linkedin_access_token"]
        oauthPictureUrl <- map["linkedin_pictureUrl"]
        oauthFirstName <- map["linkedin_localizedFirstName"]
        oauthLastName <- map["linkedin_localizedLastName"]
        oauthId <- map["linkedin_id"]
    }
}
