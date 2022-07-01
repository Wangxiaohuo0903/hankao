//
//  LoginViewController.swift
//  PracticeChinese
//
//  Created by Intern on 18/07/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import ObjectMapper
import Alamofire
import CocoaLumberjack
import Reachability

class LoginViewController: UIViewController, NetworkRequestFailedLoadDelegate {
    func reloadData() {
        loadWebView()
    }
    
    func backClick() {
        
    }
    
    var loginAccountType: LoginAccountType!
    var loginView: UIWebView!
    var request: URLRequest!
    var redirectUrl: String!
    let alertView = AlertNetworkRequestFailedView.init(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height - 60))
    override func viewDidLoad() {
        super.viewDidLoad()
        alertView.delegate = self
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
        
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        let natiHeight = self.ch_getStatusNavigationHeight()
        loginView = UIWebView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height - natiHeight))
        loginView.delegate = self
        self.view.addSubview(loginView)
        loadWebView()
    }
    func loadWebView (){
        switch loginAccountType.rawValue {
        case LoginAccountType.LinkedInLogin.rawValue:
            self.title = ""
            redirectUrl = LinkedInOauth.redirectUri
            request = URLRequest(url: URL(string: LinkedInOauth.signinUrl)!)
        case LoginAccountType.LiveLogin.rawValue:
            self.title = ""
            redirectUrl = LiveOauth.redirectUrl
            request = URLRequest(url: URL(string: LiveOauth.signinUrl)!)
        default:
            self.title = ""
            redirectUrl = FacebookOauth.redirectUri
            request = URLRequest(url: URL(string: FacebookOauth.signinUrl)!)
        }
        loginView.loadRequest(request)
    }
    @objc func cancelLogin() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.fromColor(color: UIColor.blueTheme), for: .default)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelLogin))
    }
}


extension LoginViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        ChActivityView.hide(ActivityViewType.ShowNavigationbar)
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        ChActivityView.hide(ActivityViewType.ShowNavigationbar)
        if let reachability = Reachability() {
            if reachability.connection == .none {
                showErrorView(NetworkRequestFailedText.NetworkError)
            }
            
        }
        ChActivityView.hide(ActivityViewType.ShowNavigationbar)
        //showErrorView()
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        ChActivityView.show(.ShowNavigationbar, self.view, UIColor.hex(hex: "f2f2f2"), "")
        let url = request.url!
        if url.absoluteString.hasPrefix(redirectUrl) {
            
            if url.absoluteString.contains("error=") {
                self.navigationController?.dismiss(animated: true, completion: nil)
                return true
            }
            // Extract the authorization code.
            let urlParts = url.absoluteString.components(separatedBy: "?")
            let part2 = urlParts[1].components(separatedBy: "=")[1]
            let code = part2.components(separatedBy: "&")[0]
            var urlRequest: URLRequestConvertible!

            switch loginAccountType!{
                case .LinkedInLogin:
                    urlRequest = Router.LinkedInLogIn(code)
                    let callback: (LinkedInUserModel?, Error?, String?)->() = {
                        result, error, raw in
                        ChActivityView.hide(ActivityViewType.ShowNavigationbar)
                        if result != nil{
                            CourseManager.shared.isLearnPage = true
                            if result?.accessToken != nil {
                                UserManager.shared.signInUser(result!, self.loginAccountType)
                                NotificationCenter.default.post(name: ChNotifications.UpdateSunNumber.notification, object: nil)
                            }
                            self.navigationController?.dismiss(animated: true) {
                            }
                        }else{
                            self.showErrorView()
                        }
                    }
                    RequestManager.shared.performRequest(urlRequest: urlRequest, completionHandler: callback)
                case .LiveLogin:
                    urlRequest = Router.LiveLogIn(code)
                    let callback: (LiveUserModel?, Error?, String?)->() = {
                        result, error, raw in
                        ChActivityView.hide(ActivityViewType.ShowNavigationbar)
                        if result != nil{
                            CourseManager.shared.isLearnPage = true
                            if result?.accessToken != nil {
                                UserManager.shared.signInUser(result!, self.loginAccountType)
                                NotificationCenter.default.post(name: ChNotifications.UpdateSunNumber.notification, object: nil)
                            }
                            self.navigationController?.dismiss(animated: true) {
                            }
                        }else{
                            self.showErrorView()
                        }
                    }
                    RequestManager.shared.performRequest(urlRequest: urlRequest, completionHandler: callback)
                case .FacebookLogin:
                    urlRequest = Router.FacebookLogIn(code)
                    let callback: (FacebookUserModel?, Error?, String?)->() = {
                        result, error, raw in
                        ChActivityView.hide(ActivityViewType.ShowNavigationbar)
                        if result != nil{
                            if result?.accessToken != nil {
                                CourseManager.shared.isLearnPage = true
                                UserManager.shared.signInUser(result!, self.loginAccountType)
                                NotificationCenter.default.post(name: ChNotifications.UpdateSunNumber.notification, object: nil)
                            }
                            self.navigationController?.dismiss(animated: true) {
                            }
                        }else{
                            self.showErrorView()
                        }
                    }
                    RequestManager.shared.performRequest(urlRequest: urlRequest, completionHandler: callback)
            }
        }
        else {
        }
        return true
    }
    func showErrorView(_ text: String = NetworkRequestFailedText.DataError) {
        ChActivityView.hide(ActivityViewType.ShowNavigationbar)
        if loginView.subviews.contains(alertView) {
            alertView.removeFromSuperview()
        }
        alertView.show(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height - self.ch_getStatusBarHeight()),superView:self.view,alertText:text,textColor:UIColor.loadingTextColor,bgColor: UIColor.loadingBgColor)
    }
}
