//
//  NetworkRequestFailedViewController.swift
//  PracticeChinese
//
//  Created by Intern on 17/07/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit

protocol NetworkRequestFailedViewDelegate {
    func reloadTapped()
}
protocol NetworkRequestFailedLoadDelegate {
    /**
     加载失败后，点击重新加载
     */
    func reloadData()
    /**
     加载失败的返回
     */
    func backClick()
}
class AlertNetworkRequestFailedView: UIView, NetworkRequestFailedViewDelegate {
    
    var networkRequestFailedView = NetworkRequestFailedView()
    var blurView = UIView()
    var backButton: UIButton!
    var delegate: NetworkRequestFailedLoadDelegate?
    var showHidenButton: Bool = false
    public typealias BackBlock = () -> Void
    var backClosure: BackBlock?
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func containerView() -> UIView? {
        return UIApplication.shared.keyWindow
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func show(frame: CGRect, superView: UIView, alertText:String = NetworkRequestFailedText.NetworkError, textColor:UIColor = UIColor.loadingTextColor, bgColor:UIColor = UIColor.loadingTextColor, showHidenButton:Bool = false) {
        self.showHidenButton = showHidenButton
        self.setUpContentLocation(frame: frame,alertText:alertText, textColor:textColor,bgColor:bgColor)
        superView.addSubview(self.blurView)
        superView.bringSubviewToFront(self.blurView)
    }
    public func hide() {
        self.blurView.removeFromSuperview()
    }
    
    func isLoad()->Bool{
        let ishas = UIApplication.topViewController()?.view.subviews.contains(self)
        return ishas!
    }
    @objc func backClick () {
        hide()
        self.delegate?.backClick()
    }
    func setUpContentLocation(frame: CGRect,alertText:String = NetworkRequestFailedText.NetworkError, textColor:UIColor = UIColor.gray,bgColor:UIColor = UIColor.blueTheme) {
        blurView = UIView(frame: frame)

        networkRequestFailedView = NetworkRequestFailedView()
        networkRequestFailedView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        networkRequestFailedView.textColor = textColor
        networkRequestFailedView.bgColor = bgColor
        networkRequestFailedView.alertText = alertText
        networkRequestFailedView.setSubviews()
        networkRequestFailedView.delegate = self
        networkRequestFailedView.backgroundColor = bgColor
        blurView.addSubview(networkRequestFailedView)
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
            backButton = UIButton(frame: CGRect(x: FontAdjust().quitButtonTop(), y: 34, width: 40, height: 40))
        }else{
            backButton = UIButton(frame: CGRect(x: FontAdjust().quitButtonTop(), y: FontAdjust().quitButtonTop(), width: 40, height: 40))
        }
        backButton.setImage(ChImageAssets.CloseIcon.image, for: .normal)
        backButton.addTarget(self, action: #selector(backClick), for: .touchUpInside)
        backButton.isHidden = !showHidenButton
        blurView.addSubview(backButton)
    }
    
    func reloadTapped() {
        self.delegate?.reloadData()
        self.blurView.removeFromSuperview()
//        NotificationCenter.default.post(name: ChNotifications.ReloadPageInfos.notification, object: nil)
    }
}

class NetworkRequestFailedView: UIView {
    
    var imgView: UIImageView!
    var messageLabel: UITextView!
    var reLoadButton: UIButton!
    var textColor: UIColor = UIColor.loadingTextColor
    var alertText: String = "The network is not available \n Please check your internet connection"
    var delegate: NetworkRequestFailedViewDelegate?
    var bgColor:UIColor = UIColor.loadingTextColor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSubviews() {

        var imgWidth = CGFloat(104.0)
        let imgX = (frame.width - imgWidth) / 2
        let imgY = frame.height * 0.5 - 140
        let imgHeight = CGFloat(104.0)
        if textColor == UIColor.gray {
            imgWidth = CGFloat(98.0)
        }
        imgView = UIImageView(frame: CGRect(x: imgX, y: imgY, width: imgWidth, height: imgHeight))
        imgView.isUserInteractionEnabled = false
        if textColor == UIColor.gray {
            imgView.image = ChBundleImageUtil.noNetwork.image
        }else {
            imgView.image = ChBundleImageUtil.noNetworkCircle.image
        }
        self.addSubview(imgView)
        
        let messageY = imgView.frame.maxY + 10
        let messageFont = FontUtil.getFont(size: 16, type: .Regular)
        
        messageLabel = UITextView(frame: CGRect(x: (ScreenUtils.width - frame.width)/2, y: messageY, width: frame.width, height: 120))
        messageLabel.text = alertText
        messageLabel.textColor = textColor
        messageLabel.textAlignment = .center
        messageLabel.isScrollEnabled = false
        messageLabel.font = messageFont
        messageLabel.isUserInteractionEnabled = false
        messageLabel.backgroundColor = UIColor.clear
        messageLabel.isEditable = false
        if alertText != "" {
            let text = NSMutableAttributedString(string: alertText)
            text.yy_setFont(FontUtil.getFont(size: FontAdjust().FontSize(16), type:.Regular), range: text.yy_rangeOfAll())
            text.yy_setColor(textColor, range: text.yy_rangeOfAll())
            //字体
//            text.yy_lineSpacing = -6;
            text.yy_setAlignment(.center, range: text.yy_rangeOfAll())
            text.yy_setMaximumLineHeight(18, range: text.yy_rangeOfAll())
            messageLabel.attributedText = text
        }
        messageLabel.sizeToFit()
        self.addSubview(messageLabel)
        messageLabel.frame = CGRect(x: (ScreenUtils.width - messageLabel.frame.width)/2, y: messageY, width: messageLabel.frame.width, height: messageLabel.frame.height)
        
        reLoadButton = UIButton(frame: CGRect(x: 0, y: messageLabel.frame.maxY, width: frame.width, height: 40))
        reLoadButton.addTarget(self, action: #selector(reloadAction(sender:)), for: .touchDown)
        reLoadButton.setTitleColor(textColor, for: .normal)
        reLoadButton.setTitle("Tap to retry", for: .normal)
        reLoadButton.titleLabel?.font = FontUtil.getFont(size: 16, type: .Regular)
        if bgColor == UIColor.blueTheme {
            reLoadButton.setTitleColor(UIColor.blueTheme, for: .normal)
        }else {
            reLoadButton.setTitleColor(UIColor.blueTheme, for: .normal)
           
        }
        self.addSubview(reLoadButton)

    }

    @objc func reloadAction(sender:AnyClass) {
        self.delegate?.reloadTapped()
    }
    
}
class NetworkRequestFailedText {
    static let NetworkTimeout = "The network is not available\n Please check your internet connection."
    static let NetworkError = "The network is not available\n Please check your internet connection."
    static let DataError = "An error occurred."
}
