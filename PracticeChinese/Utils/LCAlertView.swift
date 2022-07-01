//
//  LCAlertView.swift
//  ChineseLearning
//
//  Created by feiyue on 30/03/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView


enum LCAlertStyle {
    case bottom
    case center
    case signout
    case leftred
    case oneButton
}

class LCAlertView:UIView {
    var titleLabel: UILabel!
    var msgLabel: UITextView!
    var blueButton: UIButton!
    var grayButton: UIButton!
    var blurView:UIView!
    var canvasView:UIView!
    var indicatorView:NVActivityIndicatorView!
    var leftAction:()->() = {}
    var rightAction:()->() = {}
    
    public class var shared: LCAlertView {
        struct Singleton {
            static let instance = LCAlertView(frame: CGRect.zero)
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
    
    public class func show(title:String, message:String, leftTitle:String, rightTitle:String, style:LCAlertStyle, leftAction:@escaping ()->(), rightAction:@escaping ()->()) {
        let footer = LCAlertView.shared
        footer.leftAction = leftAction
        footer.rightAction = rightAction
        footer.setupContent(title: title, message: message, leftTitle: leftTitle, rightTitle: rightTitle, style: style)
        footer.containerView()?.addSubview(footer.blurView)
        
    }
    
    func setupContent(title:String, message:String, leftTitle:String, rightTitle:String, style:LCAlertStyle) {
        
        blurView = UIView(frame:CGRect(x:0, y:0, width:ScreenUtils.width, height:ScreenUtils.height))
        blurView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        blurView.isUserInteractionEnabled  = true
        
        if style == .bottom {
            canvasView = UIView(frame:CGRect(x:0, y:ScreenUtils.heightByRate(y: 0.75), width:ScreenUtils.width, height:ScreenUtils.heightByRate(y: 0.25)))
        }
        else if(style == .signout){
            if(AdjustGlobal().isiPad){
                canvasView = UIView(frame:CGRect(x:ScreenUtils.widthByRate(x: 0.25), y:ScreenUtils.heightByRate(y: 0.5) - 300, width:ScreenUtils.widthByRate(x: 0.5), height:320))
            }else{
                if(AdjustGlobal().CurrentScale == AdjustScale.iPhone4){
                    canvasView = UIView(frame:CGRect(x:ScreenUtils.widthByRate(x: 0.1), y:ScreenUtils.heightByRate(y: 0.5) - 135, width:ScreenUtils.widthByRate(x: 0.8), height:UIAdjust().adjustByHeight(270)))
                }else{
                    canvasView = UIView(frame:CGRect(x:ScreenUtils.widthByRate(x: 0.1), y:ScreenUtils.heightByRate(y: 0.5) - 135, width:ScreenUtils.widthByRate(x: 0.8), height:240))
                }
            }
            canvasView.layer.cornerRadius = 10
            canvasView.layer.masksToBounds = true
        }else {
            if(AdjustGlobal().isiPad){
                canvasView = UIView(frame:CGRect(x:ScreenUtils.widthByRate(x: 0.25), y:ScreenUtils.heightByRate(y: 0.4) - 64, width:ScreenUtils.widthByRate(x: 0.5), height:270))
            }else{
                canvasView = UIView(frame:CGRect(x:ScreenUtils.widthByRate(x: 0.1), y:ScreenUtils.heightByRate(y: 0.4) - 64, width:ScreenUtils.widthByRate(x: 0.8), height:220))
            }
            canvasView.layer.cornerRadius = 10
            canvasView.layer.masksToBounds = true
        }
        canvasView.backgroundColor = UIColor.white
        
        let baseFrame = canvasView.frame
        var msgY = CGFloat(10.0)
        if title != "" {
        titleLabel = UILabel(frame: CGRect(x: 0, y: 20, width: baseFrame.width, height: FontUtil.getTextFont().lineHeight))
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.black
        titleLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(16), type:.Bold)
        canvasView.addSubview(titleLabel)
        msgY = CGFloat(titleLabel.frame.maxY)

        }
        
        
        let msgLabelWidth = baseFrame.width  - 30
         msgLabel = UITextView(frame: CGRect(x: 15, y: msgY, width: msgLabelWidth, height: baseFrame.height * 0.5))
         msgLabel.text = message
         msgLabel.textAlignment = .center
         msgLabel.textColor = UIColor.black
         msgLabel.isScrollEnabled = false
         msgLabel.isEditable = false
         msgLabel.isSelectable = false
         msgLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(14), type:.Regular)
        
        if message != "" {
            let text = NSMutableAttributedString(string: message)
            text.yy_setFont(FontUtil.getFont(size: FontAdjust().FontSize(14), type:.Regular), range: text.yy_rangeOfAll())
            //字体
//            text.yy_lineSpacing = -3;
            text.yy_setAlignment(.center, range: text.yy_rangeOfAll())
            text.yy_setMaximumLineHeight(18, range: text.yy_rangeOfAll())
            msgLabel.attributedText = text
        }
         msgLabel.sizeToFit()
         msgLabel.frame = CGRect(x: msgLabel.frame.minX, y: msgLabel.frame.minY, width: msgLabelWidth, height: msgLabel.frame.height)
         canvasView.addSubview(msgLabel)
        
        
        var buttonY = msgLabel.frame.maxY + 5
        let buttonHeight:CGFloat = 44
        blueButton = UIButton(frame:CGRect(x: baseFrame.width * 0.06 , y: buttonY, width: baseFrame.width * 0.4, height: buttonHeight))
        blueButton.backgroundColor = UIColor.white
        blueButton.titleLabel?.font = FontUtil.alertTitleFont()
        
        blueButton.setBackgroundImage(UIImage.fromColor(color: UIColor.colorFromRGB(71, 114, 209, 1)), for: .normal)
//        blueButton.setBackgroundImage(UIImage.fromColor(color: UIColor.colorFromRGB(50, 80, 145)), for: .selected)
        blueButton.setTitle(leftTitle, for: .normal)
        blueButton.setTitleColor(UIColor.white, for: .normal)
        blueButton.setTitleColor(UIColor.white, for: .highlighted)
        blueButton.layer.borderColor = UIColor.clear.cgColor
        blueButton.setBackgroundImage(UIImage.fromColor(color: UIColor.colorFromRGB(50, 80, 145, 1)), for: .highlighted)
        blueButton.layer.borderWidth = 1

        blueButton.layer.cornerRadius = 22
        blueButton.layer.masksToBounds = true
        blueButton.addTarget(self, action: #selector(leftTapped), for: .touchUpInside)
        canvasView.addSubview(blueButton)
        
        grayButton = UIButton(frame:CGRect(x: baseFrame.width * 0.54 , y: buttonY, width: baseFrame.width * 0.4, height: buttonHeight))
        grayButton.backgroundColor = UIColor.white
        grayButton.titleLabel?.font = FontUtil.alertTitleFont()
        
        grayButton.layer.borderColor = UIColor.clear.cgColor
        grayButton.setBackgroundImage(UIImage.fromColor(color: UIColor.colorFromRGB(224, 224, 224, 1)), for: .normal)
//        grayButton.setBackgroundImage(UIImage.fromColor(color: UIColor.colorFromRGB(130, 130, 130)), for: .selected)
        grayButton.setTitle(rightTitle, for: .normal)
        grayButton.setTitleColor(UIColor.darkGray, for: .normal)
        grayButton.setTitleColor(UIColor.white, for: .highlighted)
        grayButton.setBackgroundImage(UIImage.fromColor(color: UIColor.colorFromRGB(130, 130, 130, 1)), for: UIControl.State.highlighted)
        grayButton.layer.borderWidth = 1

        grayButton.layer.cornerRadius = 22
        grayButton.layer.masksToBounds = true
        grayButton.addTarget(self, action: #selector(rightTapped), for: .touchUpInside)
        canvasView.addSubview(grayButton)
        blueButton.frame = CGRect(x: baseFrame.width * 0.54 , y: buttonY, width: baseFrame.width * 0.4, height: buttonHeight)
        grayButton.frame = CGRect(x: baseFrame.width * 0.06 , y: buttonY, width: baseFrame.width * 0.4, height: buttonHeight)
        if style == .center ||  style == .leftred ||  style == .oneButton{
            var alertHeight = buttonY + buttonHeight + 20
//            if alertHeight < 134 {
//                alertHeight = 134
//                blueButton.frame = CGRect(x: baseFrame.width * 0.54 , y: alertHeight - 64, width: baseFrame.width * 0.4, height: buttonHeight)
//                grayButton.frame = CGRect(x: baseFrame.width * 0.06 , y: alertHeight - 64, width: baseFrame.width * 0.4, height: buttonHeight)
//            }
            canvasView.frame = CGRect(x: canvasView.frame.minX, y: (ScreenUtils.height - alertHeight)/2, width: canvasView.frame.width, height: alertHeight)
        }
        blurView.addSubview(canvasView)
        if(style == .leftred){
            blueButton.setBackgroundImage(UIImage.fromColor(color: UIColor.colorFromRGB(224, 224, 224, 1)), for: .normal)
            blueButton.setTitle(leftTitle, for: .normal)
            blueButton.setTitleColor(UIColor.darkGray, for: .normal)
            blueButton.setTitleColor(UIColor.white, for: .highlighted)
            blueButton.setBackgroundImage(UIImage.fromColor(color: UIColor.colorFromRGB(130, 130, 130, 1)), for: UIControl.State.highlighted)
            grayButton.setTitleColor(UIColor.white, for: .normal)
            grayButton.setBackgroundImage(UIImage.fromColor(color: UIColor.colorFromRGB(192, 70, 70, 1)), for: UIControl.State.highlighted)
            grayButton.setBackgroundImage(UIImage.fromColor(color: UIColor.colorFromRGB(235, 87, 87, 1)), for: .normal)
        }
        if(style == .oneButton){
            grayButton.isHidden = true
            blueButton.frame = CGRect(x: baseFrame.width * 0.29 , y: buttonY, width: baseFrame.width * 0.4, height: buttonHeight)
            var alertHeight = buttonY + buttonHeight + 20
//            if alertHeight < 134 {
//                alertHeight = 134
//                blueButton.frame = CGRect(x: baseFrame.width * 0.29 , y: alertHeight - 64, width: baseFrame.width * 0.42, height: buttonHeight)
//                msgLabel.frame = CGRect(x: msgLabel.frame.minX, y: 20, width: msgLabelWidth, height: 60)
//
//            }
        }
        if(style == .signout){
            var pic = UIImageView(frame:CGRect(x: baseFrame.width * 0.325, y: baseFrame.height * 0.05, width: baseFrame.width * 0.35, height: baseFrame.width * 0.35))
            pic.image = UIImage(named: "cry")
            
            canvasView.addSubview(pic)
            
            titleLabel.isHidden = true
            msgLabel.frame = CGRect(x: 15, y: baseFrame.height * 0.49, width: msgLabelWidth, height: baseFrame.height * 0.2)
            msgLabel.font = FontUtil.getFont(size: 14, type: .Regular)
            buttonY = msgLabel.frame.maxY+20
            grayButton.frame = CGRect(x: baseFrame.width * 0.06 , y: buttonY, width: baseFrame.width * 0.4, height: buttonHeight)
            blueButton.frame   = CGRect(x: baseFrame.width * 0.52 , y: buttonY, width: baseFrame.width * 0.4, height: buttonHeight)
            blueButton.layer.cornerRadius = 22
            grayButton.layer.cornerRadius = 22
            
            blueButton.titleLabel?.font = FontUtil.alertTitleFont()
            grayButton.titleLabel?.font = FontUtil.alertTitleFont()
            grayButton.setTitle(rightTitle, for: .normal)
            blueButton.setTitle(leftTitle, for: .normal)
            msgLabel.frame = CGRect(x: 15, y: baseFrame.height * 0.49, width: msgLabelWidth, height: baseFrame.height * 0.3)
            
        }
    }
    
    @objc func leftTapped() {

        self.leftAction()
    }
    
    @objc func rightTapped() {
        self.rightAction()
    }
    
    class func hide() {
        let footer = LCAlertView.shared

        footer.blurView.removeFromSuperview()
    }
    
    class func showActivityIndicator() {
        let footer = LCAlertView.shared

        if footer.indicatorView == nil {
            footer.indicatorView = NVActivityIndicatorView(frame: CGRect(x: ScreenUtils.widthByRate(x: 0.4), y: ScreenUtils.heightByRate(y: 0.5) - ScreenUtils.widthByRate(x: 0.1) - 20, width: ScreenUtils.widthByRate(x: 0.2), height: ScreenUtils.widthByRate(x: 0.2)) , type: NVActivityIndicatorType.ballSpinFadeLoader, color: UIColor.white, padding: 4)
        }
        footer.blurView.addSubview(footer.indicatorView)
        footer.indicatorView.startAnimating()

    }
    class func hideActivityIndicator() {
        let footer = LCAlertView.shared
        footer.indicatorView.stopAnimating()
    }
 
}
