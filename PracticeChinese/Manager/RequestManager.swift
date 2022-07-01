//
//  RequestManager.swift
//  ChineseLearning
//
//  Created by feiyue on 05/04/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import ObjectMapper
import SwiftyJSON
import CocoaLumberjack

extension UIApplication {
    class func topViewController(controller:UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

class RequestWrapper<Data:Mappable>: Mappable {
    var version:String?
    var timestamp:String?
    var data:Data?
    
    required init?(map: Map) {
    }
    func mapping(map: Map) {
        version     <- map["v"]
        timestamp   <- map["ts"]
        data        <- map["data"]
    }
    init(_ version:String, data:Data?) {
        self.version = version
        self.data = data
        let TSFormat = DateFormatter()
        TSFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        self.timestamp = TSFormat.string(from: Date())
    }
}

class RequestManager: NSObject {
    public static let shared = RequestManager()
//    static let baseEndpoint = "\(SERVICE_URL)/services/"
//    static let versionCheck = "\(SERVICE_URL)/api/versioncheck"
    var reLogin = false
    var reLoad = false //请求失败重新请求
    var refresh = false //刷新
    var isNetworkSuccessRequest = false
    var alamoFireManager : SessionManager! // this line

    override init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10 // seconds
        configuration.timeoutIntervalForResource = 10
        self.alamoFireManager = Alamofire.SessionManager(configuration: configuration)
    }
    
    func createURL(baseUrl:String, engineId:String, options:Dictionary<String, String>?) -> URL {
        let urlString =  "\(baseUrl)\(engineId)"
        if options == nil {
            return URL(string: urlString)!
        }
        var queryString = "?"
        for (key, value) in options! {
            queryString += key
            if !value.isEmpty {
                queryString += "="
                queryString += value
            }
            queryString += "&"
        }
        
        return URL(string:"\(urlString)\(queryString)")!
    }
    
    func performRequest<DataOut:Mappable>(urlRequest: URLRequestConvertible, completionHandler: @escaping (DataOut?, Error?, String?) -> ()) -> Void{
        alamoFireManager.request(urlRequest).validate().responseJSON() {
            response in
            switch response.result {
            case .success(let data):
//                CWLog(data)
                self.reLogin = false
                let ret = Mapper<ApiResponse>().map(JSONObject: data)!
                if (ret.ErrorCode ?? ReplyErrorCode.Ok ) != ReplyErrorCode.Ok {
                        completionHandler(nil, NSError(domain: "", code: 404, userInfo: nil), "")
                        return
                }
                if(ret.toJSONString() == "{}"){
                    let json = JSON(data)
                    if let dataOut = Mapper<DataOut>().map(JSONObject:json.dictionaryObject) {
                        completionHandler(dataOut, nil, nil)
                        if self.isNetworkSuccessRequest {
                            return
                        }
                        self.isNetworkSuccessRequest = true
                        NotificationCenter.default.post(name: ChNotifications.NetWorkSuccessRequest.notification, object: nil)
                        return
                    }
                    else {
                        completionHandler(nil, nil, "")
                        return
                    }
                }else{
                    if let retData = ret.Data {
                        if let dataOut = Mapper<DataOut>().map(JSONObject: retData.dictionaryObject) {
                            completionHandler(dataOut, nil, retData.rawString())
                            if self.isNetworkSuccessRequest {
                                return
                            }
                            self.isNetworkSuccessRequest = true
                            NotificationCenter.default.post(name: ChNotifications.NetWorkSuccessRequest.notification, object: nil)
                            return
                        }
                        else {
                            completionHandler(nil, nil, "")
                            return
                        }
                    }
                    else {
                        completionHandler(nil, nil, "")
                        return
                    }
                }
                
            case .failure(let error):
                NotificationCenter.default.post(name: ChNotifications.NetworkEndLoading.notification, object: nil)
                // 登录信息已过期
                if response.response?.statusCode == 401 {
                    if self.reLogin {
                        return
                    }
                    self.reLogin = true
                    UserManager.shared.logInAsVisitor(relogin: true)
                    completionHandler(nil, error, "")
                    return
                }
                    
                    // 断网
                else if !NetworkReachabilityManager()!.isReachable || (response.response?.statusCode ?? -1009) == -1009 {
                    completionHandler(nil, error, "")
                    if self.reLoad {
                        self.performRequest(urlRequest: urlRequest, completionHandler: completionHandler)
                        self.reLoad = false
                        return
                    }
                    self.reLoad = false
                    if let str = response.request?.url?.absoluteString {
                        let requestStr = NSMutableString(string: str)
                        let range = requestStr.range(of: "list-scenario-lesson")
                        if range.location == NSNotFound {
                            NotificationCenter.default.post(name: ChNotifications.NetworkFailedRequest_HomePage.notification, object: [ "text" : NetworkRequestFailedText.NetworkError ])
                        }
                    }
                    NotificationCenter.default.post(name: ChNotifications.NetworkFailedRequest.notification, object: nil)
                    return
                }else {
                    //虽然有网络，但是没有数据
                    if response.request?.url?.absoluteString.contains("list-scenario-lessons") ?? false {
                        NotificationCenter.default.post(name: ChNotifications.NetworkFailedRequest_HomePage.notification, object: [ "text" : NetworkRequestFailedText.DataError ])
                    }
                    
                }
                
                DDLogError("Request Error: \(error.localizedDescription) \(response.description)")
                
                completionHandler(nil, error, "")
                return
            }
        }
    }
}
