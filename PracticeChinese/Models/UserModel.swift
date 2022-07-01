//
//  UserModel.swift
//  ChineseLearning
//
//  Created by feiyue on 06/04/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import ObjectMapper

class UserModel: Mappable {
    
    var accessToken:String?
    var tokenType:String?
    var expiresIn:Int? = 0
    var oauthRefreshToken:String?
    var oauthAccessToken:String?
    var oauthPictureUrl:String?
    var oauthFirstName:String?
    var oauthLastName:String?
    var oauthId:String?

    init (_ accessToken:String, tokenType:String?, expiresIn:Int, _ picture:String = "" , _ firstName:String = "" ,_ lastName:String = "" , _ userId:String = "") {
        self.accessToken = accessToken
        self.tokenType = tokenType
        self.expiresIn = expiresIn
        self.oauthRefreshToken = ""
        self.oauthAccessToken = ""
        self.oauthPictureUrl = picture
        self.oauthFirstName = firstName
        self.oauthLastName = lastName
        self.oauthId = userId
        
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        accessToken <- map["access_token"]
        tokenType   <- map["token_type"]
        expiresIn   <- map["expires_in"]
    }
}
