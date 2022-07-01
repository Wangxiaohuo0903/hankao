//
//  SpeakResultViewController.swift
//  PracticeChinese
//
//  Created by 费跃 on 10/12/17.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import SnapKit
import UIKit
class SpeakResultViewController: UIViewController {
    var clapButton: UIImageView!
    var textLabel: UILabel!
    var id: String = ""
    var firstTap = true
    var continueButton: UIButton!
    override func viewDidLoad() {
        view.backgroundColor = UIColor.lightBlueTheme
        if(AppData.userAssessmentEnabled && UserManager.shared.isLoggedIn()){
            CourseManager.shared.updateCourseProgress(classType:ClassType.Scenario,id: self.id) {
                success in
                if !success! {
                    CWLog("update progress failed \(self.id)")
                }
                else {
                    RequestManager.shared.refresh = false
                    CourseManager.shared.SetCoursesList(update: true)
                }
            }
            clapButton = UIImageView(frame: CGRect(x: ScreenUtils.widthByRate(x: 0.15), y: ScreenUtils.heightByRate(y: 0.15) - ScreenUtils.heightBySix(y: 100) , width: ScreenUtils.widthByRate(x: 0.7), height: ScreenUtils.heightByRate(y: 0.35)))
            clapButton.image = UIImage.gifImageWithName("give-me-five02")
            clapButton.isUserInteractionEnabled = true
            clapButton.contentMode = .scaleAspectFit
            //        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(clap))
            //        view.addGestureRecognizer(gestureRecognizer)
            view.addSubview(clapButton)

            textLabel = UILabel(frame: CGRect(x: ScreenUtils.widthByRate(x: 0.1), y: clapButton.frame.maxY + ScreenUtils.heightBySix(y: 60), width: ScreenUtils.widthByRate(x: 0.8), height: ScreenUtils.heightBySix(y: 200)))
            textLabel.font = FontUtil.getSubTitleFont()
            textLabel.textColor = UIColor.white
            textLabel.textAlignment = .center
            textLabel.text = "You have completed all speaking tasks for this lesson."
            textLabel.numberOfLines = 0
            view.addSubview(textLabel)

            continueButton = UIButton(frame:CGRect(x: ScreenUtils.widthByRate(x: 0.15), y: ScreenUtils.heightByRate(y: 0.9) - ScreenUtils.widthByRate(x: 0.16) - 64, width: ScreenUtils.widthByRate(x: 0.7), height: ScreenUtils.widthByRate(x: 0.12)))
            continueButton.layer.cornerRadius = ScreenUtils.widthByRate(x: 0.06)
            continueButton.backgroundColor = UIColor.blueTheme
            continueButton.setTitle("Continue", for: .normal)
            continueButton.setTitleColor(UIColor.white, for: .normal)
            continueButton.addTarget(self, action: #selector(continueButtonClick), for: .touchUpInside)
            view.addSubview(continueButton)


            textLabel.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(clapButton.snp.bottom).offset(30)
                make.width.equalTo(AdjustGlobal().CurrentScaleWidth*0.8)
                make.centerX.equalTo(view)
            }

            var buttonGap:CGFloat = 0
            if(AdjustGlobal().CurrentScale == AdjustScale.iPad){
                buttonGap = 60
                continueButton.layer.cornerRadius = 30
            }else{
                buttonGap = 44
                continueButton.layer.cornerRadius = 22
            }

            var  buttonheight:CGFloat = 0
            if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
                buttonheight = 34
            }else{
                buttonheight = UIAdjust().adjustByHeight(12)
            }
            continueButton.snp.makeConstraints { (make) -> Void in
                make.bottom.equalTo(view.snp.bottom).offset(-buttonheight * 2)
                make.width.equalTo(UIAdjust().adjustByWidthScale(0.7))
                make.height.equalTo(buttonGap)
                make.centerX.equalTo(view)
            }

        }else if(!AppData.userAssessmentEnabled && UserManager.shared.isLoggedIn()){
            let titleLabel = UILabel()
            textLabel = UILabel()
            clapButton = UIImageView()
            
            let alertText = "You have finished this session. However, you are unable to receive diagnosis about your learning performance, for Data Collection and Permission is disabled."
            titleLabel.text = alertText
            titleLabel.textColor = UIColor.white
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .center
            titleLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(16), type: .Regular)
            
            
//            let text = NSMutableAttributedString(string: alertText)
//            text.yy_setFont(FontUtil.getFont(size: FontAdjust().FontSize(16), type:.Regular), range: text.yy_rangeOfAll())
//            text.yy_setColor(UIColor.white, range: text.yy_rangeOfAll())
//            text.yy_setAlignment(.center, range: text.yy_rangeOfAll())
//            text.yy_setMaximumLineHeight(18, range: text.yy_rangeOfAll())
            
            view.addSubview(titleLabel)
            
            
            let imageView = UIImageView(image: UIImage(named: "logopic"))
            imageView.backgroundColor = UIColor.clear
            imageView.frame = CGRect.zero
            imageView.layer.masksToBounds = false
            imageView.clipsToBounds = false
            imageView.isUserInteractionEnabled = true
            
            view.addSubview(imageView)
            
            
            continueButton = UIButton(frame:CGRect(x: ScreenUtils.widthByRate(x: 0.15), y: self.view.frame.size.height - 100, width: ScreenUtils.widthByRate(x: 0.7), height: 64))
            continueButton.layer.cornerRadius = ScreenUtils.widthByRate(x: 0.06)
            continueButton.backgroundColor = UIColor.blueTheme
            continueButton.setTitle("Done", for: .normal)
            continueButton.setTitleColor(UIColor.white, for: .normal)
            continueButton.addTarget(self, action: #selector(continueButtonClick), for: .touchUpInside)
            view.addSubview(continueButton)
            
            titleLabel.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(imageView.snp.bottom).offset(30)
                make.width.equalTo(AdjustGlobal().CurrentScaleWidth*0.8)
                make.centerX.equalTo(view)
            }
            
            imageView.snp.makeConstraints { (make) -> Void in
                make.centerY.equalTo(view).offset(-120)
                make.centerX.equalTo(view)
                make.width.height.equalTo(AdjustGlobal().CurrentScaleWidth*0.4)
            }
            
            var buttonGap:CGFloat = 0
            if(AdjustGlobal().CurrentScale == AdjustScale.iPad){
                buttonGap = 60
                continueButton.layer.cornerRadius = 30
            }else{
                buttonGap = 44
                continueButton.layer.cornerRadius = 22
            }
            var  buttonheight:CGFloat = 0
            if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
                buttonheight = 34
            }else{
                buttonheight = UIAdjust().adjustByHeight(12)
            }
            
            continueButton.snp.makeConstraints { (make) -> Void in
                make.bottom.equalTo(view.snp.bottom).offset(-buttonheight * 2)
                make.width.equalTo(UIAdjust().adjustByWidthScale(0.7))
                make.height.equalTo(buttonGap)
                make.centerX.equalTo(view)
            }
            
        }else{
            let titleLabel = UILabel()
            textLabel = UILabel()
            clapButton = UIImageView()
            
            let alertText = "You are trying out Learn Chinese. \n Login can unlock more functions."
            titleLabel.text = alertText
            titleLabel.textColor = UIColor.white
            titleLabel.numberOfLines = 3
            titleLabel.textAlignment = .center
            titleLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(16), type: .Regular)

            view.addSubview(titleLabel)
            
            var buttonGap:CGFloat = 0
            
            var  buttonheight:CGFloat = 0
            if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
                buttonheight = 34
            }else{
                buttonheight = UIAdjust().adjustByHeight(12)
            }
            
            
            let imageView = UIImageView(image: UIImage(named: "logopic"))
            imageView.backgroundColor = UIColor.clear
            imageView.frame = CGRect.zero
            imageView.layer.masksToBounds = false
            imageView.clipsToBounds = false
            imageView.isUserInteractionEnabled = true
            
            view.addSubview(imageView)
            
            continueButton = UIButton(frame: CGRect(x:(view.frame.width - FontAdjust().buttonWidth())/2  , y:view.frame.height-ScreenUtils.heightByM(y: CGFloat(75)), width: FontAdjust().buttonWidth(), height: ScreenUtils.heightByM(y: CGFloat(44))))
            continueButton.backgroundColor = UIColor.blueTheme
            continueButton.setTitle("Sign in", for: UIControl.State.normal)
            continueButton.titleLabel?.textAlignment = .center
            continueButton.titleLabel?.font = FontUtil.getFont(size: FontAdjust().FontSize(18), type: .Regular)
            continueButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
            continueButton.layer.cornerRadius = ScreenUtils.heightByM(y:CGFloat(22))
            continueButton.addTarget(self, action: #selector(login), for: .touchUpInside)
            view.addSubview(continueButton)
            
            if(AdjustGlobal().CurrentScale == AdjustScale.iPad){
                buttonGap = 60
                continueButton.layer.cornerRadius = 30
            }else{
                buttonGap = 44
                continueButton.layer.cornerRadius = 22
            }
            
            let redoButton = UIButton(frame: CGRect(x:(view.frame.width - FontAdjust().buttonWidth())/2  , y:view.frame.height-ScreenUtils.heightByM(y:CGFloat(129)), width: FontAdjust().buttonWidth(), height: ScreenUtils.heightByM(y:CGFloat(44))))
            redoButton.backgroundColor = UIColor.blueTheme
            redoButton.setTitle("Later", for: UIControl.State.normal)
            redoButton.titleLabel?.textAlignment = .center
            redoButton.titleLabel?.font = FontUtil.getFont(size: FontAdjust().FontSize(18), type: .Regular)
            redoButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
            redoButton.layer.cornerRadius = buttonGap/2
            redoButton.addTarget(self, action: #selector(continueButtonClick), for: .touchUpInside)
            view.addSubview(redoButton)
            titleLabel.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(imageView.snp.bottom).offset(30)
                make.width.equalTo(AdjustGlobal().CurrentScaleWidth*0.9)
                make.centerX.equalTo(view)
            }
            redoButton.snp.makeConstraints { (make) -> Void in
                make.bottom.equalTo(view.snp.bottom).offset(-(buttonheight * 3.0 + buttonGap))
                make.width.equalTo(UIAdjust().adjustByWidthScale(0.7))
                make.height.equalTo(buttonGap)
                make.centerX.equalTo(view)
            }
            
            continueButton.snp.makeConstraints { (make) -> Void in
                make.bottom.equalTo(view.snp.bottom).offset(-buttonheight * 2)
                make.width.equalTo(UIAdjust().adjustByWidthScale(0.7))
                make.height.equalTo(buttonGap)
                make.centerX.equalTo(view)
            }
            
            imageView.snp.makeConstraints { (make) -> Void in
                make.centerY.equalTo(view).offset(-120)
                make.centerX.equalTo(view)
                make.width.height.equalTo(AdjustGlobal().CurrentScaleWidth*0.4)
            }
        }
    

    }
    
    @objc func login(){
        let vc = LoginFullViewController()
        vc.dissmis = true
//        vc.makeBackgroundColor()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
//    func redo(){
//        self.navigationController?.popToRootViewController(animated: true)
//    }
    
    func closeTapped() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    @objc func continueButtonClick() {
        NotificationCenter.default.post(name: ChNotifications.HasNewland.notification, object: nil)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.fromColor(color: UIColor.clear), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.hidesBackButton = true
    }
    
}
