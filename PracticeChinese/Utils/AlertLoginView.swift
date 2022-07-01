//
//  AlertLoginView.swift
//  PracticeChinese
//
//  Created by Intern on 18/07/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

protocol AlertLoginDelegate {
    func loginTapped(type: LoginAccountType)
    func CloseAlertLoginView()
}

class AlertLoginView: UIView, AlertLoginDelegate {
    
    var loginView: LoginCoreView!
    var headImage: UIImageView!
    var blurView: UIView!
    var isShown:Bool = false
    
    public class var shared: AlertLoginView {
        struct Singleton {
            static let instance = AlertLoginView(frame: CGRect.zero)
        }
        return Singleton.instance
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func containerView() -> UIView? {
        return UIApplication.shared.keyWindow
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public class func show() {
      

        let footer = AlertLoginView.shared
        if (footer.isShown == true) {
            return
        }
        footer.setupContent()
        footer.isShown = true
        footer.containerView()?.addSubview(footer.blurView)

    }
    
    public class func showfrist() {
        let footer = AlertLoginView.shared
        if (footer.isShown == true) {
            return
        }
        footer.setupContent()
        footer.isShown = true
        footer.loginView.subTitleLabel.text = "You have to be logged in for your progress to be saved."
        footer.containerView()?.addSubview(footer.blurView)
        
    }

    
    func setupContent() {
        
        blurView = UIView(frame: CGRect(x:0, y:0, width:ScreenUtils.width, height:ScreenUtils.height))
        blurView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        blurView.isUserInteractionEnabled = true
        
        var loginWidth = UIAdjust().adjustByWidthScale(0.75)
        var loginHeight = UIAdjust().adjustByWidthScale(0.80)
        if(AdjustGlobal().isiPad){
            loginHeight = UIAdjust().adjustByWidthScale(0.54)
            loginWidth = UIAdjust().adjustByWidthScale(0.5)
        }
        let loginX = (ScreenUtils.width - loginWidth) / 2
        let loginY = ScreenUtils.heightByRate(y: 0.2)
        loginView = LoginCoreView(frame: CGRect(x: loginX, y: loginY, width: loginWidth, height: loginHeight))
        loginView.backgroundColor = UIColor(0xcedcee)
        loginView.delegate = self
        blurView.addSubview(loginView)
        
        var headImgHeight = UIAdjust().adjustByWidthScale(0.143)
        var headImgWidth = UIAdjust().adjustByWidthScale(0.2)
        if(AdjustGlobal().isiPad){
            headImgHeight = UIAdjust().adjustByWidthScale(0.1)
            headImgWidth = UIAdjust().adjustByWidthScale(0.14)
        }
        let headImgX = (ScreenUtils.width - headImgWidth) / 2
        let headImgY = loginView.frame.minY - headImgHeight + headImgHeight * 0.23
        headImage = UIImageView(frame: CGRect(x: headImgX, y: headImgY, width: headImgWidth, height: headImgHeight))
        headImage.image = ChBundleImageUtil.loginPopHead.image
        blurView.addSubview(headImage)
        
        loginView.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(blurView)
            make.centerY.equalTo(blurView)
            if(AdjustGlobal().isiPad){
                make.width.equalTo(UIAdjust().adjustByWidthScale(0.5))
                make.height.equalTo(UIAdjust().adjustByWidthScale(0.54))
            }else{
                make.width.equalTo(UIAdjust().adjustByWidthScale(0.75))
                make.height.equalTo(UIAdjust().adjustByWidthScale(0.80))
            }
        }
        
        headImage.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(blurView)
            make.bottom.equalTo(loginView.snp.top).offset(UIAdjust().adjustByWidthScale(0.025))
            if(AdjustGlobal().isiPad){
                make.width.equalTo(UIAdjust().adjustByWidthScale(0.14))
                make.height.equalTo(UIAdjust().adjustByWidthScale(0.1))
            }else{
                make.width.equalTo(UIAdjust().adjustByWidthScale(0.2))
                make.height.equalTo(UIAdjust().adjustByWidthScale(0.143))
            }
        }
        
    }

    func loginTapped(type: LoginAccountType) {
        self.blurView.removeFromSuperview()
        AlertLoginView.shared.isShown = false
        let vc = LoginViewController()
        vc.loginAccountType = type
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        UIApplication.topViewController()?.present(nav, animated: true, completion: nil)
    }
    
    func CloseAlertLoginView() {
        AlertLoginView.shared.isShown = false
        self.blurView.removeFromSuperview()
    }
    
}

class LoginCoreView: UIView {

    var titleLabel: UILabel!
    var hintLabel: UILabel!
    var subTitleLabel:UILabel!
    var SignInLabel: UILabel!
    var backImage: UIImageView!
    var linkedInLoginButton: UIButton!
    var liveLoginButton: UIButton!
    var facebookLoginButton: UIButton!
    var SkipButton: UIButton!
    
    var delegate: AlertLoginDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 9
        self.layer.masksToBounds = true
        setSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSubviews() {
        let titleHeight = ScreenUtils.heightByRate(y: 0.12)
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: titleHeight))
        titleLabel.text = "Sign in"
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.blueTheme
        titleLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(23), type: .Regular)
        self.addSubview(titleLabel)
        
        subTitleLabel = UILabel(frame: CGRect(x: frame.width*0.1, y: ScreenUtils.heightByRate(y: 0.09), width: frame.width*0.8, height: 40))
        subTitleLabel.text = "Social Login will not post anything to your timeline."
        subTitleLabel.textAlignment = .center
        subTitleLabel.numberOfLines = 0
        subTitleLabel.textColor = UIColor.blueTheme
        subTitleLabel.font = FontUtil.getFont(size: 30, type: .Regular)
        self.addSubview(subTitleLabel)
        
        let imgY = frame.height * 0.35
        backImage = UIImageView(frame: CGRect(x: -1, y: imgY, width: frame.width+2, height: frame.height - imgY))
        let path = Bundle.main.path(forResource: "login-wave", ofType: "png", inDirectory: "png")
        backImage.image = UIImage(contentsOfFile: path!)
        self.addSubview(backImage)
        
        
        let linkedInButtonY = frame.height / 1.8
        let linkedInButtonX = ScreenUtils.widthByRate(x: 0.06)
        let linkedInButtonWidth = ScreenUtils.widthByRate(x: 0.18)
        linkedInLoginButton = UIButton(frame: CGRect(x: linkedInButtonX, y: linkedInButtonY, width: linkedInButtonWidth, height: linkedInButtonWidth))
        let li_path = Bundle.main.path(forResource: "LinkedIn", ofType: "png", inDirectory: "png")
        linkedInLoginButton.setImage(UIImage(contentsOfFile: li_path!), for: .normal)
        linkedInLoginButton.tag = LoginAccountType.LinkedInLogin.rawValue
        linkedInLoginButton.addTarget(self, action: #selector(loginTapped(sender:)), for: .touchUpInside)
        self.addSubview(linkedInLoginButton)
        
        let liveButtonY = frame.height / 1.8
        let liveButtonX = linkedInLoginButton.frame.maxX + ScreenUtils.widthByRate(x: 0.045)
        let liveButtonWidth = ScreenUtils.widthByRate(x: 0.18)
        liveLoginButton = UIButton(frame: CGRect(x: liveButtonX, y: liveButtonY, width: liveButtonWidth, height: liveButtonWidth))
        let live_path = Bundle.main.path(forResource: "login-pop-microsoft", ofType: "png", inDirectory: "png")
        liveLoginButton.setImage(UIImage(contentsOfFile: live_path!), for: .normal)
        liveLoginButton.tag = LoginAccountType.LiveLogin.rawValue
        liveLoginButton.addTarget(self, action: #selector(loginTapped(sender:)), for: .touchUpInside)
        self.addSubview(liveLoginButton)
        
        let facebookButtonY = frame.height / 1.8
        let facebookButtonX = liveLoginButton.frame.maxX + ScreenUtils.widthByRate(x: 0.045)
        let facebookButtonWidth = ScreenUtils.widthByRate(x: 0.18)
        facebookLoginButton = UIButton(frame: CGRect(x: facebookButtonX, y: facebookButtonY, width: facebookButtonWidth, height: facebookButtonWidth))
        let facebook_path = Bundle.main.path(forResource: "Facebook", ofType: "png", inDirectory: "png")
        facebookLoginButton.setImage(UIImage(contentsOfFile: facebook_path!), for: .normal)
        facebookLoginButton.tag = LoginAccountType.FacebookLogin.rawValue
        facebookLoginButton.addTarget(self, action: #selector(loginTapped(sender:)), for: .touchUpInside)
        self.addSubview(facebookLoginButton)
        
        let skipButtonY = frame.height * 0.9
        let skipButtonX = frame.width * 0.8
        let skipButtonWidth = frame.width * 0.2
        let skipeButtonHeight = frame.height * 0.05
        
        SkipButton = UIButton(frame: CGRect(x: skipButtonX, y: skipButtonY, width: skipButtonWidth, height: skipeButtonHeight))
        SkipButton.setTitle("Later", for: .normal)
        SkipButton.setTitleColor(UIColor.white, for: .normal)
        SkipButton.backgroundColor = UIColor.clear
        SkipButton.contentVerticalAlignment = .center
        SkipButton.contentHorizontalAlignment = .center
        SkipButton.titleLabel?.font = FontUtil.getFont(size: FontAdjust().FontSize(15), type: .Regular)
        SkipButton.titleLabel?.textColor = UIColor.white
        SkipButton.addTarget(self, action: #selector(SkipButtonClick(sender:)), for: .touchUpInside)
        self.addSubview(SkipButton)
        
        SkipButton.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(self.frame.height*0.12)
            make.width.equalTo(self.frame.width/5)
            make.right.equalTo(self)
            make.bottom.equalTo(self)
        }
        
        
        liveLoginButton.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(self)
            make.height.width.equalTo(self.frame.width/4)
            make.bottom.equalTo(SkipButton.snp.top).offset(-self.frame.height/40)
        }
        
        facebookLoginButton.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(liveLoginButton)
            make.height.width.equalTo(self.frame.width/4)
            make.left.equalTo(liveLoginButton.snp.right).offset(self.frame.width/16)
        }
        
        linkedInLoginButton.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(liveLoginButton)
            make.height.width.equalTo(self.frame.width/4)
            make.right.equalTo(liveLoginButton.snp.left).offset(-self.frame.width/16)
        }
        
        backImage.snp.makeConstraints { (make) -> Void in
            make.left.right.equalTo(self)
            make.top.equalTo(liveLoginButton.snp.top).offset((-1)*Double(self.frame.width*0.2 + self.frame.height/40 ))
            make.height.equalTo(self.frame.width*2.16)
        }
        
        
        subTitleLabel.adjustsFontSizeToFitWidth = true
        subTitleLabel.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(self.frame.width*0.8)
            make.height.equalTo(self.frame.height/7)
            make.centerX.equalTo(self)
            make.bottom.equalTo(backImage.snp.top).offset(-self.frame.height/20)
        }
        
        titleLabel.sizeToFit()
        titleLabel.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(self)
            make.top.equalTo(self).offset(UIAdjust().adjustByWidthScale(0.025))
            make.bottom.equalTo(subTitleLabel.snp.top)
        }
        
        
    }
    @objc func loginTapped(sender: AnyObject) {
        
        var type: LoginAccountType!
        switch sender.tag {
        case LoginAccountType.LinkedInLogin.rawValue:
            type = LoginAccountType.LinkedInLogin
        case LoginAccountType.LiveLogin.rawValue:
            type = LoginAccountType.LiveLogin
        case LoginAccountType.FacebookLogin.rawValue:
            type = LoginAccountType.FacebookLogin
        default:
            print("error")
        }
        self.delegate?.loginTapped(type: type)
    }
    @objc func SkipButtonClick(sender: AnyObject) {
        self.delegate?.CloseAlertLoginView()
    }
}
