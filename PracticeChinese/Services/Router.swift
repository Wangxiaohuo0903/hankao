//
//  Router.swift
//  ChineseLearning
//
//  Created by feiyue on 05/04/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import SwiftyJSON



enum Router: URLRequestConvertible {
    //用code换access_token
    case LinkedInLogIn(String)
    case LiveLogIn(String)
    case FacebookLogIn(String)
    case FacebookLogInWithToken(String)
    case getLiveToken(String)
    case getLiveUser(String)
    case getUserInfo
    case setUserInfo([String:Int])
    case LogInDemo(String, String)
    case ClickLog([String:String])
    case ClickLogInfo([String:Any])
    case DeleteAcount()
    case DeleteData()
    case UpdateCoin(Int, String, String) //coin, timestamp, sign
    case VersionCheck()
    case GetScenarioLesson(Mappable,[String:String])
    case GetSpeakLesson(Mappable,[String:String])
    case GetLessonOption(String,Mappable,[String:String])
    case GetScenarioLearnedItem(Mappable,[String:String])
    func asURLRequest() throws -> URLRequest {
        var method: Alamofire.HTTPMethod  {
            switch self {
            case .getLiveUser, .getUserInfo, .VersionCheck:
                return .get
            case .DeleteAcount, .DeleteData:
                return .delete
            case .setUserInfo:
                return .put
            default:
                return .post
            }
        }
        
        var params:([String:Any]?) {
            let TSFormat = DateFormatter()
            TSFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            let timestamp = TSFormat.string(from: Date())

            switch self {
            case .LinkedInLogIn(let code):
                 return ["grant_type":"LinkedInAccount", "code":code]
            case .LiveLogIn(let code):
                return ["grant_type":"MicrosoftAccount", "code":code]
            case .FacebookLogInWithToken(let token):
                return ["grant_type":"FacebookAccount", "access_token":token]
            case .getLiveToken(let code):
                return ["grant_type":"authorization_code", "code":code, "client_id":LiveOauth.clientId, "redirect_uri":LiveOauth.redirectUrl]
            case .LogInDemo(let id, let secret):
                return ["grant_type":"demonstrate", "id": id, "secret":secret]
            case .DeleteData():
                return [:]
            case .DeleteAcount():
                return [:]
            case .GetScenarioLesson(let dataIn, _):
                return ["v":AppData.versionNumber,"ts":timestamp,"data":dataIn.toJSON()]
            case .GetSpeakLesson(let dataIn, _):
                return ["v":AppData.versionNumber,"ts":timestamp,"data":dataIn.toJSON()]
            case .GetLessonOption( _,let dataIn, _):
                return ["v":AppData.versionNumber,"ts":timestamp,"data":dataIn.toJSON()]
            case .GetScenarioLearnedItem(let dataIn, _):
                return ["v":AppData.versionNumber,"ts":timestamp,"data":dataIn.toJSON()]
            default:
                return nil
            }
        }
        var url:URL {
            let relativePath:String?
            var _url:URL?
            switch self {
            case .LinkedInLogIn,.LiveLogIn,.LogInDemo,.FacebookLogIn,.FacebookLogIn,.FacebookLogInWithToken:
                relativePath = "oauth/login"
                _url = URL(string: String.baseEndpoint)
            case .getLiveToken( _):
                _url = URL(string: String.liveOauth)
                relativePath = nil
            case .getLiveUser(let token):
                _url = URL(string: "https://apis.live.net/v5.0/me?access_token=\(token)")
                relativePath = nil
            case .getUserInfo, .setUserInfo:
                relativePath = ""
                _url = URL(string: String.UserEndpoint)
            case .UpdateCoin(let coinDelta, let timestamp, let signature):
                relativePath = nil
                _url = URL(string: "\(String.UserEndpoint)/updatecoin?coin=\(coinDelta)&timestamp=\(timestamp)&sign=\(signature)")
            case .DeleteData, .DeleteAcount:
                relativePath = ""
                _url = URL(string: "\(String.UserEndpoint)?party=\(UserManager.shared.getAccountTypeString())")
            case .ClickLog:
                relativePath = nil
                _url = RequestManager.shared.createURL(baseUrl: String.baseEndpointServices,engineId: "FDC7633E-759A-473A-A993-6E346D980962", options: ["telemetry":"1"])
            case .ClickLogInfo:
                relativePath = nil
                _url = RequestManager.shared.createURL(baseUrl: String.baseEndpointServices,engineId: "FDC7633E-759A-473A-A993-6E346D980962", options: ["telemetry":"1"])
            case .GetScenarioLesson( _,let options):
                _url = RequestManager.shared.createURL(baseUrl: String.baseEndpointServices,engineId: String.scenarioEngine, options: options)
                relativePath = nil
            case .GetSpeakLesson( _,let options):
                _url = RequestManager.shared.createURL(baseUrl: String.baseEndpointServices,engineId: String.speakEngine, options: options)
                relativePath = nil
            case .GetLessonOption(let engine, _,let options):
                _url = RequestManager.shared.createURL(baseUrl: String.baseEndpointServices,engineId: engine, options: options)
                relativePath = nil
            case .VersionCheck:
                relativePath = "api/versioncheck/learnchineseios"
                _url = URL(string: String.baseEndpoint)
            case .GetScenarioLearnedItem( _,let options):
                _url = RequestManager.shared.createURL(baseUrl: String.baseEndpointServices,engineId: String.scenarioEngine, options: options)
                relativePath = nil
            default:
                relativePath = ""
            }
            if let relativePath = relativePath {
                _url = _url?.appendingPathComponent(relativePath)
            }
            return _url!
        }
        var request = URLRequest(url: url)
        
  
        request.httpMethod = method.rawValue
        switch self {
        case .LinkedInLogIn( _), .LiveLogIn( _), .FacebookLogIn( _), .getLiveToken( _), .LogInDemo, .FacebookLogInWithToken( _):
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        case .ClickLog(let data):
            if let model = UserManager.shared.getUserModel() {
                request.setValue("Bearer \(model.accessToken!)", forHTTPHeaderField: "Authorization")
            }
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let json = DictionaryWrapper(AppData.versionNumber, data: data).toJSONString()
            request.httpBody = json?.data(using: .utf8)
            
        case .ClickLogInfo(let data):
            if let model = UserManager.shared.getUserModel() {
                request.setValue("Bearer \(model.accessToken!)", forHTTPHeaderField: "Authorization")
            }
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let json = DictionaryWrapper(AppData.versionNumber, data: data).toJSONString()
            request.httpBody = json?.data(using: .utf8)
            
        case .DeleteAcount(), .DeleteData():
            if let model = UserManager.shared.getUserModel() {
                request.setValue("Bearer \(model.accessToken!)", forHTTPHeaderField: "Authorization")
            }
        case .setUserInfo(let data):
            if let model = UserManager.shared.getUserModel() {
                request.setValue("Bearer \(model.accessToken!)", forHTTPHeaderField: "Authorization")
            }
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let json = DictionaryWrapper(AppData.versionNumber, data: data).toJSONString()
            request.httpBody = json?.data(using: .utf8)
        case .getUserInfo, .UpdateCoin:
            if let model = UserManager.shared.getUserModel() {
                request.setValue("Bearer \(model.accessToken!)", forHTTPHeaderField: "Authorization")
            }
        case .GetScenarioLesson,.GetSpeakLesson,.GetLessonOption,.DeleteAcount(),.DeleteData(),.GetScenarioLearnedItem:
            if let model = UserManager.shared.getUserModel() {
                request.setValue("Bearer \(model.accessToken!)", forHTTPHeaderField: "Authorization")
            }
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.setValue("application/gzip", forHTTPHeaderField: "Accept-Encoding")
//            let json = DictionaryWrapper(AppData.versionNumber, data: dataIn.toJSON() as! [String : String]).toJSONString()
//            request.httpBody = json?.data(using: .utf8)
            
        default:
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        request.timeoutInterval = TimeInterval(10*1000)
        
        
        
        switch self {
        case .LinkedInLogIn, .LiveLogIn, .FacebookLogIn, .FacebookLogInWithToken, .getLiveToken, .LogInDemo:
            return try Alamofire.URLEncoding.default.encode(request, with: params)
            // attention
        default:
            let url = try Alamofire.JSONEncoding.default.encode(request, with: params)
            return url
        }
        
    }
}

