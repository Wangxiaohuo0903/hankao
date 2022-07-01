//
//  LoginViewController.swift
//  ChineseDev
//
//  Created by summer on 2018/4/23.
//  Copyright © 2018年 msra. All rights reserved.
//

import Foundation
import UIKit
import YYText
import SnapKit
import FBSDKLoginKit
import Alamofire

class LoginFullViewController: UIViewController {
    var pic:UIImageView!
    var sloganLabel:UILabel!
    var laterLabel:UIButton!
    var suggestionLabel: YYLabel!
    var micButton:UIButton!
    var LinButton:UIButton!
    var FacButton:UIButton!
    var dissmis:Bool = false
    var offset:CGFloat = 20
    var willAppear = false
    
    override func setNeedsStatusBarAppearanceUpdate() {
        super.setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override var prefersStatusBarHidden: Bool {
        return willAppear
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(facebookDidLogin(nofitication:)), name: ChNotifications.faceBookDidLogin.notification, object: nil)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.fromColor(color: UIColor.clear), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        // 接收状态栏高度发生变化的通知
        NotificationCenter.default.addObserver(self, selector: #selector(adjustStatusBar), name: NSNotification.Name("UIApplicationDidChangeStatusBarFrameNotification"), object: nil)

        self.navigationItem.setHidesBackButton(true, animated: false)
        self.view.backgroundColor = UIColor.blueTheme
        pic = UIImageView()
        pic.contentMode = .scaleAspectFit
        pic.image = UIImage(named: "logopic")
        self.view.addSubview(pic)
        sloganLabel = UILabel()
        sloganLabel.textColor = UIColor.white
        sloganLabel.font = UIFont(name: "PingFang SC", size: FontAdjust().FontSizeForiPhone4(23,-7))
        sloganLabel.numberOfLines = 1
        sloganLabel.adjustsFontSizeToFitWidth = true
        sloganLabel.text = "Your Intelligent Chinese Tutor !"
        sloganLabel.textAlignment = .center
        self.view.addSubview(sloganLabel)
        micButton = UIButton()
        if(AdjustGlobal().isiPad){
            micButton.layer.cornerRadius = 25
            micButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 0)
        }else{
            micButton.layer.cornerRadius = 20
            micButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)
        }
        micButton.backgroundColor = UIColor.white
        micButton.setTitle("Sign in with Microsoft", for: .normal)
        micButton.setTitleColor(UIColor.blueTheme, for: .normal)
        micButton.imageView?.contentMode = .scaleAspectFit
        micButton.contentHorizontalAlignment = .left
        micButton.titleLabel?.font = FontUtil.getFont(size: FontAdjust().FontSize(15), type: .Regular)
        micButton.setImage(UIImage(named: "milogin"), for: .normal)
        micButton.setBackgroundImage(UIImage.fromColor(color: UIColor.white), for: .normal)
        micButton.layer.masksToBounds = true
        micButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
        self.view.addSubview(micButton)
        micButton.tag = LoginAccountType.LiveLogin.rawValue
        micButton.addTarget(self, action: #selector(Tapped(sender:)), for: .touchUpInside)
        LinButton = UIButton()
        if(AdjustGlobal().isiPad){
            LinButton.layer.cornerRadius = 25
            LinButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 0)
        }else{
            LinButton.layer.cornerRadius = 20
            LinButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)
        }
        LinButton.backgroundColor = UIColor.white
        LinButton.setTitle("Sign in with LinkedIn", for: .normal)
        LinButton.setTitleColor(UIColor.blueTheme, for: .normal)
        LinButton.imageView?.contentMode = .scaleAspectFit
        LinButton.contentHorizontalAlignment = .left
        LinButton.titleLabel?.font = FontUtil.getFont(size: FontAdjust().FontSize(15), type: .Regular)
        LinButton.setImage(UIImage(named: "lilogin"), for: .normal)
        LinButton.setBackgroundImage(UIImage.fromColor(color: UIColor.white), for: .normal)
        LinButton.layer.masksToBounds = true
        LinButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
        self.view.addSubview(LinButton)
        LinButton.tag = LoginAccountType.LinkedInLogin.rawValue
        LinButton.addTarget(self, action: #selector(Tapped(sender:)), for: .touchUpInside)
        FacButton = UIButton()
        if(AdjustGlobal().isiPad){
            FacButton.layer.cornerRadius = 25
            FacButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 0)
        }else{
            FacButton.layer.cornerRadius = 20
            FacButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)
        }
        FacButton.backgroundColor = UIColor.white
        FacButton.setTitle("Sign in with Facebook", for: .normal)
        FacButton.contentHorizontalAlignment = .left
        FacButton.titleLabel?.font = FontUtil.getFont(size: FontAdjust().FontSize(15), type: .Regular)
        FacButton.setTitleColor(UIColor.blueTheme, for: .normal)
        FacButton.imageView?.contentMode = .scaleAspectFit
        FacButton.setImage(UIImage(named: "fblogin"), for: .normal)
        FacButton.setBackgroundImage(UIImage.fromColor(color: UIColor.white), for: .normal)
        FacButton.layer.masksToBounds = true
        FacButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
        self.view.addSubview(FacButton)
        FacButton.tag = LoginAccountType.FacebookLogin.rawValue
        FacButton.addTarget(self, action: #selector(Tapped(sender:)), for: .touchUpInside)
        laterLabel = UIButton()
        laterLabel.setTitle("Later", for: .normal)
        laterLabel.setTitleColor(UIColor.white, for: .normal)
        laterLabel.addTarget(self, action: #selector(SkipButtonClick(sender:)), for: .touchUpInside)
        self.view.addSubview(laterLabel)
        

        let attributedStr = NSMutableAttributedString(string:"Privacy Policy and Terms of Use", attributes: convertToOptionalNSAttributedStringKeyDictionary([ convertFromNSAttributedStringKey(NSAttributedString.Key.font) : FontUtil.getFont(size: FontAdjust().FontSize(12), type: .Regular)]))
        
        attributedStr.yy_setFont(FontUtil.getFont(size: FontAdjust().FontSize(12), type: .Medium), range: NSMakeRange (0, 14))
        attributedStr.yy_setUnderlineStyle(NSUnderlineStyle.single, range: NSMakeRange (0, 14))
        attributedStr.yy_setFont(FontUtil.getFont(size: FontAdjust().FontSize(12), type: .Medium), range: NSMakeRange (19, 12))
        attributedStr.yy_setUnderlineStyle(NSUnderlineStyle.single, range: NSMakeRange (19, 12))
        
        attributedStr.yy_setTextHighlight(NSMakeRange (0, 14), color: UIColor.white, backgroundColor: UIColor.clear) {
            view, text, range, rect in
            self.openBrowser(urlStr: "https://go.microsoft.com/fwlink/?LinkId=521839")
        }
        
        attributedStr.yy_setTextHighlight(NSMakeRange (19, 12), color: UIColor.white, backgroundColor: UIColor.clear) {
            view, text, range, rect in
            self.openBrowser(urlStr: "http://go.microsoft.com/fwlink/?linkid=206977")
        }
        attributedStr.yy_color = UIColor.white
        attributedStr.yy_alignment = .center
        
        suggestionLabel = YYLabel()
        suggestionLabel.numberOfLines = 1
        suggestionLabel.sizeToFit()
        suggestionLabel.textAlignment = .center
        suggestionLabel.attributedText = attributedStr
        self.view.addSubview(suggestionLabel)
        
        
        if(UserManager.shared.isAppFirstOpened()){
            laterLabel.setTitle("Skip", for: .normal)
        }else{
            laterLabel.setTitle("Later", for: .normal)
        }
        
        suggestionLabel.snp.makeConstraints { (make) -> Void in
            make.left.right.equalTo(view)
            make.height.equalTo(50)
            if(AdjustGlobal().isiPad){
                make.bottom.equalTo(self.view.snp.bottom).offset(-30)
            }else if(AdjustGlobal().CurrentScale == AdjustScale.iPhone4){
                make.bottom.equalTo(self.view.snp.bottom).offset(-5)
            }else{
                make.bottom.equalTo(self.view.snp.bottom).offset(-10)
            }
        }
        pic.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.view)
            make.height.width.equalTo(160)
            if(AdjustGlobal().isiPad){
                make.top.equalTo(self.view).offset(190+offset)
            }else if(AdjustGlobal().CurrentScale == AdjustScale.iPhone4 || AdjustGlobal().CurrentScale == AdjustScale.iPhone5){
                make.height.width.equalTo(120)
                make.top.equalTo(self.view).offset(30 + offset)
            }else if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
                make.top.equalTo(self.view).offset(160+offset)
            }else if(AdjustGlobal().CurrentScale == AdjustScale.iPhonePlus){
                make.top.equalTo(self.view).offset(120+offset)
            }else{
                //6,7,8
                make.top.equalTo(self.view).offset(80+offset)
            }
        }
        sloganLabel.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.view)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
            make.top.equalTo(pic.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
        
    
        
        micButton.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.view)
            if(AdjustGlobal().isiPad){
                make.height.equalTo(50)
                make.width.equalTo(360)
                make.bottom.equalTo(LinButton.snp.top).offset(-28)
            }else{
                make.height.equalTo(40)
                make.width.equalTo(260)
                make.bottom.equalTo(LinButton.snp.top).offset(-18)
            }
        }
        LinButton.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.view)
            if(AdjustGlobal().isiPad){
                make.height.equalTo(50)
                make.width.equalTo(360)
                make.bottom.equalTo(FacButton.snp.top).offset(-28)
            }else{
                make.height.equalTo(40)
                make.width.equalTo(260)
                make.bottom.equalTo(FacButton.snp.top).offset(-18)
            }
        }
        FacButton.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.view)
            if(AdjustGlobal().isiPad){
                make.height.equalTo(50)
                make.width.equalTo(360)
                make.bottom.equalTo(laterLabel.snp.top).offset(-30)
            }else if(AdjustGlobal().CurrentScale == AdjustScale.iPhone4){
                make.height.equalTo(40)
                make.width.equalTo(260)
                make.bottom.equalTo(laterLabel.snp.top).offset(-10)
            }else{
                make.height.equalTo(40)
                make.width.equalTo(260)
                make.bottom.equalTo(laterLabel.snp.top).offset(-20)
            }
        }
        laterLabel.snp.makeConstraints { (make) -> Void in
            if(AdjustGlobal().isiPad){
                make.bottom.equalTo(self.view).offset(-80)
            }else if(AdjustGlobal().CurrentScale == AdjustScale.iPhone4){
                make.bottom.equalTo(self.view).offset(-50)
            }else{
                make.bottom.equalTo(self.view).offset(-70)
            }
            make.centerX.equalTo(self.view)
            make.height.equalTo(40)
            make.width.equalTo(60)
        }
        adjustStatusBar()
        
        
    }
    
    
    @objc func adjustStatusBar() {
        if (ch_getStatusBarHeight() > 20) {
            //可能开启了热点
            var statusH = 20.0
            if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
                statusH = 34.0
            }
            suggestionLabel.snp.remakeConstraints { (make) in
                make.left.right.equalTo(view)
                make.height.equalTo(50)
                if(AdjustGlobal().isiPad){
                    make.bottom.equalTo(self.view.snp.bottom).offset(-30 - CGFloat(ch_getStatusBarHeight()) + CGFloat(statusH))
                }else if(AdjustGlobal().CurrentScale == AdjustScale.iPhone4){
                    make.bottom.equalTo(self.view.snp.bottom).offset(-5  - CGFloat(ch_getStatusBarHeight()) + CGFloat(statusH))
                }else{
                    make.bottom.equalTo(self.view.snp.bottom).offset(-10  - CGFloat(ch_getStatusBarHeight()) + CGFloat(statusH))
                }
            }
        }else {
            suggestionLabel.snp.makeConstraints { (make) -> Void in
                make.left.right.equalTo(view)
                make.height.equalTo(50)
                if(AdjustGlobal().isiPad){
                    make.bottom.equalTo(self.view.snp.bottom).offset(-30)
                }else if(AdjustGlobal().CurrentScale == AdjustScale.iPhone4){
                    make.bottom.equalTo(self.view.snp.bottom).offset(-5)
                }else{
                    make.bottom.equalTo(self.view.snp.bottom).offset(-10)
                }
            }
            
        }
        view.layoutIfNeeded()
        
    }
    
    
    
    
    private func openBrowser(urlStr: String) {
        let url = URL(string: urlStr)!
        if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
                
                // Fallback on earlier versions
            }
        } else {
            self.presentUserToast(message: "cannot open url")
        }
        
    }
    //点击登录
    @objc func Tapped(sender: AnyObject) {
        var type: LoginAccountType!
        switch sender.tag {
        case LoginAccountType.LinkedInLogin.rawValue:
            type = LoginAccountType.LinkedInLogin
        case LoginAccountType.LiveLogin.rawValue:
            type = LoginAccountType.LiveLogin
        case LoginAccountType.FacebookLogin.rawValue:
            type = LoginAccountType.FacebookLogin
        default:
            CWLog("error")
        }
        CourseManager.shared.isLearnPage = true
        AlertLoginView.shared.isShown = false
        if(UserManager.shared.isAppFirstOpened()){
            UserManager.shared.setAppOpened()
            NotificationCenter.default.post(name: AppDelegate.appStartNotification, object: nil)
        }else if(self.dissmis){
            self.navigationController?.dismiss(animated: true, completion: {
                let vc = LoginViewController()
                vc.loginAccountType = type
                let nav = UINavigationController(rootViewController: vc)
                self.navigationController?.navigationBar.isHidden = false
                nav.modalTransitionStyle = .crossDissolve
                nav.modalPresentationStyle = .fullScreen
                UIApplication.topViewController()?.present(nav, animated: true, completion: nil)
            })
        }else{
            let mc = self.slideMenuController()?.mainViewController as! UINavigationController
            mc.popToRootViewController(animated: true)
        }
        if type == LoginAccountType.FacebookLogin {
            self.loginButtonClicked()
            return
        }
        let vc = LoginViewController()
        vc.loginAccountType = type
        let nav = UINavigationController(rootViewController: vc)
        self.navigationController?.navigationBar.isHidden = false
        nav.modalPresentationStyle = .fullScreen
        UIApplication.topViewController()?.present(nav, animated: true, completion: nil)
        
        
    }
    //faceBook登录

    func loginButtonClicked() {
        self.newLogin()
    }

    func newLogin() {
        let loginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: ["public_profile","email"], from: self) { (loginResult, error) in
            if loginResult != nil {
                if (loginResult?.isCancelled)! {
                    CWLog("取消登录")
                }else {
                    let idDict = ["tokenString": (loginResult?.token.tokenString)!]
                    NotificationCenter.default.post(name: ChNotifications.faceBookDidLogin.notification, object: nil, userInfo: idDict)
                }
            }
        }
    }
    @objc func facebookDidLogin(nofitication: Notification) {
        let notiDic = nofitication.userInfo as! Dictionary<String, Any>
            RequestManager.shared.reLoad = true
            var urlRequest: URLRequestConvertible!
            urlRequest = Router.FacebookLogInWithToken(notiDic["tokenString"] as! String)
            let callback: (FacebookUserModel?, Error?, String?)->() = {
                result, error, raw in
                ChActivityView.hide(ActivityViewType.ShowNavigationbar)
                if result != nil{
                    if result?.accessToken != nil {
                        CourseManager.shared.isLearnPage = true
                        UserManager.shared.signInUser(result!, LoginAccountType.FacebookLogin)
                        NotificationCenter.default.post(name: ChNotifications.UpdateSunNumber.notification, object: nil)
                    }
                }else{
                    UIApplication.topViewController()?.presentUserToast(message: "Please log in again")
                }
            }
            RequestManager.shared.performRequest(urlRequest: urlRequest, completionHandler: callback)
    }
    
    @objc func SkipButtonClick(sender: AnyObject) {
        
        if(UserManager.shared.isAppFirstOpened()){
            UserManager.shared.setAppOpened()
            NotificationCenter.default.post(name: AppDelegate.appStartNotification, object: nil)
        }else if(self.dissmis){
            self.navigationController?.dismiss(animated: true, completion: nil)
        }else{
            let mc = self.slideMenuController()?.mainViewController as! UINavigationController
            mc.navigationItem.setHidesBackButton(false, animated: false)
            mc.popToRootViewController(animated: true)
        }
    }
    func makeBackgroundColor() {
        self.view.backgroundColor = UIColor.lightBlueTheme
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
