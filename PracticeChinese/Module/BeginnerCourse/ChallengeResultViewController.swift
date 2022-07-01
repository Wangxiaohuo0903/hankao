//
//  ChallengeResultViewController.swift
//  PracticeChinese
//
//  Created by 费跃 on 10/12/17.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit
class ChallengeResultViewController: UIViewController {
    
    var score:Int = 0
    var unlock: Bool = false//是否具有解锁功能
//    var bgImg: UIImageView!
    var scoreImg: UIImageView!
    var scoreLabel: UILabel!
    var textLabel: UILabel!
    var id: String = ""
    var redoButton: UIButton!
    var continueButton: UIButton!

    override func viewDidLoad() {
        
        var  bottomheight:CGFloat = 0
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
            bottomheight = 34
        }else{
            bottomheight = UIAdjust().adjustByHeight(12)
        }
        
        let buttonGap:CGFloat = FontAdjust().buttonHeight()
        
        if(AppData.userAssessmentEnabled && UserManager.shared.isLoggedIn()){
            //登录且授权
            if score >= 60 {
                ChActivityView.show(.EvaluatingLearn, UIApplication.shared.keyWindow!, UIColor.white, ActivityViewText.EvaluatingCC, UIColor.textGray, UIColor.white)
                CourseManager.shared.updateCourseProgress(classType:ClassType.Scenario,id: id) {
                    success in
                    if !success! {
                    }
                    else {
                         RequestManager.shared.refresh = true
                         CourseManager.shared.isLearnPage = false
                         CourseManager.shared.SetCoursesList(update: true)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        ChActivityView.hide()
                    })
                }
            }
            view.backgroundColor = UIColor.white
            scoreImg = UIImageView(frame: CGRect(x: 48.0, y: 118.0 , width: ScreenUtils.width - 96.0, height: 556.0 * (ScreenUtils.width - 96.0)/500.0 ))
            scoreImg.image = score >= 60 ? ChImageAssets.Congratulations.image : ChImageAssets.KeepTry.image
            scoreImg.contentMode = .scaleAspectFit

            var left = (ScreenUtils.width - 96.0) * 0.395
            var top = (ScreenUtils.width - 96.0) * 556 / 500 * 0.35
            
            if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax) {
                top = (ScreenUtils.width - 96.0) * 556 / 500 * 0.35 + 10.0
            }else if (AdjustGlobal().CurrentScale == AdjustScale.iPad) {
                scoreImg.frame = CGRect(x: (ScreenUtils.width - 278)/2, y: 118.0 , width: 278, height:  250)
                top = 278 * 556 / 500 * 0.35 - 20.0
                left = 278 * 0.395
            }else if (AdjustGlobal().CurrentScale == AdjustScale.iPhone) {
                top = (ScreenUtils.width - 96.0) * 556 / 500 * 0.35 + 10.0
            }else if (AdjustGlobal().CurrentScale == AdjustScale.iPhonePlus) {
                top = (ScreenUtils.width - 96.0) * 556 / 500 * 0.35
            }else if (AdjustGlobal().CurrentScale == AdjustScale.iPhone4) {
                top = (ScreenUtils.width - 96.0) * 556 / 500 * 0.35 + 7.0
            }else if (AdjustGlobal().CurrentScale == AdjustScale.iPhone5) {
                top = (ScreenUtils.width - 96.0) * 556 / 500 * 0.35 + 7.0
            }
            let scoreWidth = CGFloat(scoreImg.frame.width * 160 / 629)
            
            scoreLabel = UILabel(frame: CGRect(x: left - scoreWidth / 2.0 , y:  top - scoreWidth / 2.0, width: scoreWidth, height: scoreWidth))
            scoreLabel.font =  UIFont(name: "ArialRoundedMTBold", size: FontAdjust().FontSize(50))
            scoreLabel.textColor = UIColor.white
            scoreLabel.textAlignment = .center
            scoreLabel.text = "\(score)"
            scoreLabel.adjustsFontSizeToFitWidth = true

            UIView.animate(withDuration: 0.01, delay: 0.00, usingSpringWithDamping: 0.0, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                self.scoreLabel.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 18))
            }) { finished in
                
            }
            scoreImg.addSubview(scoreLabel)

            if score >= 60 {
//                UserManager.shared.logUserClick(["AppClick":"Challenge Pass"])
            }
            else {
//                UserManager.shared.logUserClick(["AppClick":"Challenge Fail"])
            }
            
            view.addSubview(scoreImg)

            textLabel = UILabel(frame: CGRect(x: ScreenUtils.widthByRate(x: 0.1), y: scoreImg.frame.maxY + 40, width: ScreenUtils.widthByRate(x: 0.8), height: 20))
            textLabel.font = FontUtil.getSubTitleFont()
            textLabel.textAlignment = .center
            var text = score >= 60 ? "You have unlocked the next section." : "Oops, you can only unlock lessons after this with an average score over 60."
            if unlock == false {
                text = ""
            }
            if score >= 60 {
                unlock = false
            }
            textLabel.text = text
            textLabel.numberOfLines = 0
            textLabel.textColor = UIColor.hex(hex: "4D4D4D")
            textLabel.sizeToFit()
            view.addSubview(textLabel)
            
            continueButton = UIButton(frame:CGRect(x: ScreenUtils.widthByRate(x: 0.15), y: ScreenUtils.heightByRate(y: 0.9) - ScreenUtils.widthByRate(x: 0.16) - 64, width: FontAdjust().buttonWidth(), height: buttonGap))
            continueButton.setBackgroundImage(UIImage.fromColor(color: UIColor.blueTheme), for: .normal)
            continueButton.setTitle("Done", for: .normal)
            continueButton.setTitleColor(UIColor.white, for: .normal)
            continueButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
            continueButton.layer.cornerRadius = buttonGap/2
            continueButton.layer.masksToBounds = true
            view.addSubview(continueButton)
            continueButton.layer.cornerRadius = FontAdjust().buttonHeight()/2
            
            textLabel.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(scoreImg.snp.bottom).offset(30)
                make.width.equalTo(AdjustGlobal().CurrentScaleWidth*0.8)
                make.centerX.equalTo(view)
            }
            
            if score < 60 {
                redoButton = UIButton(frame:CGRect(x: ScreenUtils.widthByRate(x: 0.15), y: ScreenUtils.heightByRate(y: 0.9) - 64, width: FontAdjust().buttonWidth(), height: buttonGap))
                redoButton.layer.cornerRadius = ScreenUtils.widthByRate(x: 0.06)
                redoButton.setBackgroundImage(UIImage.fromColor(color: UIColor.hex(hex: "E0E0E0")), for: .normal)
                redoButton.setTitle("Redo", for: .normal)
                redoButton.setTitleColor(UIColor.hex(hex: "4F4F4F"), for: UIControl.State.normal)
                redoButton.setTitleColor(UIColor.white, for: UIControl.State.highlighted)
                redoButton.setTitleColor(UIColor.white, for: UIControl.State.selected)
                redoButton.addTarget(self, action: #selector(redo), for: .touchUpInside)
                redoButton.layer.cornerRadius = buttonGap/2
                redoButton.layer.masksToBounds = true
                view.addSubview(redoButton)
                
                
                continueButton.snp.makeConstraints { (make) -> Void in
                    make.bottom.equalTo(view.snp.bottom).offset(-bottomheight * 2)
                    make.width.equalTo(FontAdjust().buttonWidth())
                    make.height.equalTo(buttonGap)
                    make.centerX.equalTo(view).offset(90)
                }
                
                redoButton.snp.makeConstraints { (make) -> Void in
                    make.bottom.equalTo(view.snp.bottom).offset(-bottomheight * 2)
                    make.width.equalTo(FontAdjust().buttonWidth())
                    make.height.equalTo(buttonGap)
                    make.centerX.equalTo(view).offset(-90)
                }
                
            }else {

                continueButton.snp.makeConstraints { (make) -> Void in
                    make.bottom.equalTo(view.snp.bottom).offset(-bottomheight * 2)
                    make.width.equalTo(FontAdjust().buttonWidth())
                    make.height.equalTo(buttonGap)
                    make.centerX.equalTo(view)
                }
                
            }
        }else if(!AppData.userAssessmentEnabled && UserManager.shared.isLoggedIn()){
            //登录没授权
            scoreImg = UIImageView()
//            bgImg = UIImageView()
            scoreLabel = UILabel()
            textLabel = UILabel()
            view.backgroundColor = UIColor.white
            let titleLabel = UILabel()
            
            let alertText = "You have finished this session. However, you are unable to receive diagnosis about your learning performance, for Data Collection and Permission is disabled."

            titleLabel.text = alertText
            titleLabel.textColor = UIColor.textGray
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .center
            titleLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(16), type: .Regular)
            

            view.addSubview(titleLabel)
            
            let buttonGap:CGFloat = FontAdjust().buttonHeight()
            let imageView = UIImageView(image: UIImage(named: "logopic_blue"))
            imageView.frame = CGRect.zero
            imageView.layer.masksToBounds = false
            imageView.clipsToBounds = false
            imageView.isUserInteractionEnabled = true
            
            view.addSubview(imageView)
            
            continueButton = UIButton(frame: CGRect(x:(view.frame.width - FontAdjust().buttonWidth())/2 , y:view.frame.height-ScreenUtils.heightByM(y:CGFloat(129)), width: FontAdjust().buttonWidth()
                , height: ScreenUtils.heightByM(y:CGFloat(44))))
            continueButton.setBackgroundImage(UIImage.fromColor(color: UIColor.blueTheme), for: .normal)
            continueButton.setTitle("Done", for: UIControl.State.normal)
            continueButton.titleLabel?.textAlignment = .center
            continueButton.titleLabel?.font = FontUtil.getFont(size: FontAdjust().FontSize(18), type: .Regular)
            continueButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
            continueButton.layer.cornerRadius = buttonGap/2
            continueButton.layer.masksToBounds = true
            continueButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
            view.addSubview(continueButton)
            
            continueButton.layer.cornerRadius = buttonGap/2
            
            redoButton = UIButton(frame: CGRect(x:(view.frame.width - FontAdjust().buttonWidth())/2  , y:view.frame.height-ScreenUtils.heightByM(y: CGFloat(75)), width: FontAdjust().buttonWidth(), height: ScreenUtils.heightByM(y: CGFloat(44))))
            redoButton.setBackgroundImage(UIImage.fromColor(color: UIColor.hex(hex: "E0E0E0")), for: .normal)
            redoButton.setTitle("Redo", for: UIControl.State.normal)
            redoButton.titleLabel?.textAlignment = .center
            redoButton.titleLabel?.font = FontUtil.getFont(size: FontAdjust().FontSize(18), type: .Regular)
            redoButton.setTitleColor(UIColor.hex(hex: "4F4F4F"), for: UIControl.State.normal)
            redoButton.setTitleColor(UIColor.white, for: UIControl.State.highlighted)
            redoButton.setTitleColor(UIColor.white, for: UIControl.State.selected)
            redoButton.layer.cornerRadius = buttonGap/2
            redoButton.layer.masksToBounds = true
            redoButton.addTarget(self, action: #selector(redo), for: .touchUpInside)
            redoButton.isHidden = true
            view.addSubview(redoButton)

            titleLabel.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(imageView.snp.bottom).offset(30)
                make.width.equalTo(AdjustGlobal().CurrentScaleWidth*0.8)
                make.centerX.equalTo(self.view)
            }
            continueButton.snp.makeConstraints { (make) -> Void in
                make.bottom.equalTo(view.snp.bottom).offset(-bottomheight * 2)
                make.width.equalTo(FontAdjust().buttonWidth())
                make.height.equalTo(buttonGap)
                make.centerX.equalTo(view)
            }
            
            redoButton.snp.makeConstraints { (make) -> Void in
                make.bottom.equalTo(view.snp.bottom).offset(-(bottomheight * 2.0 + buttonGap))
                make.width.equalTo(FontAdjust().buttonWidth())
                make.height.equalTo(buttonGap)
                make.centerX.equalTo(view)
            }
            
            imageView.snp.makeConstraints { (make) -> Void in
                make.centerY.equalTo(view).offset(-120)
                make.centerX.equalTo(view)
                make.width.equalTo(AdjustGlobal().CurrentScaleWidth*0.4)
                make.height.equalTo(AdjustGlobal().CurrentScaleWidth*0.4 * 544 / 476)
            }
        }
        
        
    }
    
    
    @objc func redo() {
        NotificationCenter.default.post(name: ChNotifications.HasNewland.notification, object: nil)
        //埋点：点击redo
        let info = ["Scope" : "ConversationChallenge","Lessonid" : self.id,"Subscope" : "Summary","Event" : "Redo"]
        UserManager.shared.logUserClickInfo(info)
        
        CourseManager.shared.isLearnPage = true
        self.navigationController?.popToRootViewController(animated: true)
        
    }
    @objc func closeTapped() {
        //埋点：点击continue
        let info = ["Scope" : "ConversationChallenge","Lessonid" : self.id,"Subscope" : "Summary","Event" : "Continue"]
        UserManager.shared.logUserClickInfo(info)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.setBackgroundImage(UIImage.fromColor(color: UIColor.clear), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.hidesBackButton = true
    }
    
}

