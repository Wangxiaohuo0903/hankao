//
//  LearnProgressView.swift
//  PracticeChinese
//
//  Created by Temp on 2018/12/6.
//  Copyright © 2018 msra. All rights reserved.
//

import UIKit

class LearnProgressView: UIView {
    var beginnerCourse: ScenarioSubLessonInfo?
    var headerCircle : MLMCircleView!
    var circleBgView = UIView()
    var completedBgView = UIImageView()
    
    var centerImage = UIImageView()
    var nameLabel = UILabel()
    var index = 0
    var courseClick: ((ScenarioSubLessonInfo,Int) -> Void)?
    var lockStatus = true
    //是否有解锁能力，true表示有，false没有
    var isChallengeAble = false
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, course: ScenarioSubLessonInfo?) {
        self.init(frame: frame)
        self.beginnerCourse = course
        setupSubViews()
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapped(gesture:)))
        self.addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubViews() {
        if (self.beginnerCourse?.SubLessons![0].ScenarioLessonInfo!.Tags!.contains("ChallengeLesson"))! {
            //ChallengeLesson
            let circleWidth = CGFloat(150)
            let circleHeight = CGFloat(80)
            let midImageWidth = CGFloat(150)
            let midImageHeight = CGFloat(50)
            circleBgView.frame = CGRect(x: (self.frame.width - circleWidth)/2, y: 0, width: circleWidth, height: circleHeight)
            self.addSubview(circleBgView)
            //中间图片
            centerImage.frame = CGRect(x: (circleWidth - midImageWidth)/2, y: (circleHeight - midImageHeight), width: midImageWidth, height: midImageHeight)
            centerImage.image = UIImage(named: "Take a Shortcut")
            circleBgView.addSubview(centerImage)
            
        }else {
            let circleWidth = CGFloat(90)
            let midWidth = CGFloat(90)
            let maskWidth = CGFloat(80)
            let midImageWidth = CGFloat(66)
            circleBgView.frame = CGRect(x: (self.frame.width - circleWidth)/2, y: 20, width: circleWidth, height: circleWidth)
            circleBgView.backgroundColor = UIColor.white
            //背景圆形
            circleBgView.layer.cornerRadius = circleWidth / 2
            circleBgView.layer.masksToBounds = true
            circleBgView.layer.borderColor = UIColor.hex(hex: "E8F0FD").cgColor
            circleBgView.layer.borderWidth = 1
            //中间图片
            centerImage.frame = CGRect(x: (circleWidth - midImageWidth)/2, y: (circleWidth - midImageWidth)/2, width: midImageWidth, height: midImageWidth)
            if (self.beginnerCourse?.ScenarioLessonInfo?.LessonIcons)!.count >= 3 {
                if let urlStr = self.beginnerCourse?.ScenarioLessonInfo?.LessonIcons![1].explaceBlankSpace() {
                    centerImage.sd_setImage(with: URL(string: urlStr), placeholderImage: nil, options: .refreshCached) { (image, error, type, url) in
                        
                    }
                }else {
                    centerImage.image = ChImageAssets.PlaceHolder.image
                }
            }else {
                centerImage.image = UIImage(named: (self.beginnerCourse?.ScenarioLessonInfo?.NativeName)!)
            }
            circleBgView.addSubview(centerImage)
            
            //进度
            headerCircle = MLMCircleView(frame: CGRect(x: (circleWidth - midWidth)/2 , y: (circleWidth - midWidth)/2, width: midWidth, height: midWidth), startAngle: 270, endAngle: 630)
            headerCircle?.center = CGPoint(x: circleWidth/2, y: circleWidth/2)
            headerCircle?.bottomWidth = 6
            headerCircle?.progressWidth = 6
            headerCircle?.fillColor = UIColor.hex(hex: "FF9812")
            headerCircle?.bgColor = UIColor.hex(hex: "E8F0FD")
            headerCircle?.dotDiameter = 20;
            headerCircle?.edgespace = 5;
            headerCircle?.drawProgress()
            headerCircle.setProgress(0)
            circleBgView.addSubview(headerCircle!)
            
            self.addSubview(circleBgView)
            
            //完成的蒙版
            completedBgView.frame = CGRect(x: (circleWidth - maskWidth)/2 , y: (circleWidth - maskWidth)/2, width: maskWidth, height: maskWidth)
            completedBgView.image = UIImage(named: "completed")
            completedBgView.isHidden = true
            circleBgView.addSubview(completedBgView)
            
            //课程名
            if (AdjustGlobal().CurrentScale == AdjustScale.iPhone4 || AdjustGlobal().CurrentScale == AdjustScale.iPhone5) {
                nameLabel.font = FontUtil.getFont(size: 14, type: .Medium)
                nameLabel.frame = CGRect(x: (self.frame.width - 120)/2 , y: circleBgView.frame.maxY, width: 120, height: 40)
            }else {
                nameLabel.font = FontUtil.getFont(size: 16, type: .Medium)
                nameLabel.frame = CGRect(x: (self.frame.width - 120)/2 , y: circleBgView.frame.maxY, width: 120, height: 60)
            }
            nameLabel.textColor = UIColor.textBlack333
            nameLabel.textAlignment = .center
            nameLabel.numberOfLines = 0
            nameLabel.text = self.beginnerCourse?.ScenarioLessonInfo?.NativeName
            self.addSubview(nameLabel)
        }
        
    }
    
    @objc func tapped(gesture: UITapGestureRecognizer) {
        //        if self.lockStatus[index] {
        //            UIApplication.topViewController()?.presentUserToast(message: "Not yet available.\n Complete lessons or take a shortcut to unlock.")
        //        }else {
        courseClick?(self.beginnerCourse!,index)
        //        }
    }
    func refreshStatus(lockStatus: Bool) {
        self.lockStatus = lockStatus
        if (self.beginnerCourse?.SubLessons![0].ScenarioLessonInfo!.Tags!.contains("ChallengeLesson"))! {
            //挑战，未解锁
            if !UserManager.shared.isLoggedIn(){
                //蓝色
                self.isChallengeAble = false
                centerImage.image = UIImage(named: "Take a Shortcut")
            }else {
                if self.lockStatus == false {
                    self.isUserInteractionEnabled = false
                    self.isChallengeAble = false
                    centerImage.image = UIImage(named: "Take a Shortcut_g")
                }else {
                    self.isChallengeAble = true
                    self.isUserInteractionEnabled = true
                    centerImage.image = UIImage(named: "Take a Shortcut")
                }
            }
            return
        }
        if(!AppData.userAssessmentEnabled && !UserManager.shared.isLoggedIn()){
            if self.lockStatus {
                //灰色图片
                self.isUserInteractionEnabled = false
                headerCircle?.fillColor = UIColor.hex(hex: "F4F4F4")
                headerCircle?.bgColor = UIColor.hex(hex: "F4F4F4")
                self.isUserInteractionEnabled = false
                if (self.beginnerCourse?.ScenarioLessonInfo?.LessonIcons)!.count >= 3 {
                    if let urlStr = self.beginnerCourse?.ScenarioLessonInfo?.LessonIcons![0].explaceBlankSpace() {
                        centerImage.sd_setImage(with: URL(string: urlStr), placeholderImage: nil, options: .refreshCached) { (image, error, type, url) in
                            
                        }
                    }else {
                        centerImage.image = ChImageAssets.PlaceHolder.image
                    }
                }else {
                    centerImage.image = UIImage(named: "\((self.beginnerCourse?.ScenarioLessonInfo?.NativeName)!)_g")
                }
            }else {
                self.isUserInteractionEnabled = true
                //蓝色图片
                headerCircle?.fillColor = UIColor.hex(hex: "FF9812")
                headerCircle?.bgColor = UIColor.hex(hex: "E8F0FD")
                self.isUserInteractionEnabled = true
                if (self.beginnerCourse?.ScenarioLessonInfo?.LessonIcons)!.count >= 3 {
                    if let urlStr = self.beginnerCourse?.ScenarioLessonInfo?.LessonIcons![1].explaceBlankSpace() {
                        centerImage.sd_setImage(with: URL(string: urlStr), placeholderImage: nil, options: .refreshCached) { (image, error, type, url) in
                            
                        }
                    }else {
                        centerImage.image = ChImageAssets.PlaceHolder.image
                    }
                }else {
                    centerImage.image = UIImage(named: (self.beginnerCourse?.ScenarioLessonInfo?.NativeName)!)
                }
            }
            headerCircle?.drawProgress()
            headerCircle.setProgress(0)
            return
        }
        //未解锁，灰色
        if self.lockStatus {
            completedBgView.isHidden = true
            headerCircle?.fillColor = UIColor.hex(hex: "F4F4F4")
            headerCircle?.bgColor = UIColor.hex(hex: "F4F4F4")
            headerCircle?.drawProgress()
            headerCircle.setProgress(0)
            if (self.beginnerCourse?.ScenarioLessonInfo?.LessonIcons)!.count >= 3 {
                if let urlStr = self.beginnerCourse?.ScenarioLessonInfo?.LessonIcons![0].explaceBlankSpace() {
                    centerImage.sd_setImage(with: URL(string: urlStr), placeholderImage: nil, options: .refreshCached) { (image, error, type, url) in
                        
                    }
                }else {
                    centerImage.image = ChImageAssets.PlaceHolder.image
                }
            }else {
                centerImage.image = UIImage(named: "\((self.beginnerCourse?.ScenarioLessonInfo?.NativeName)!)_g")
            }
        }else {
            //判断是否完成
            if let sublessons = self.beginnerCourse?.SubLessons {
                for lessonData in sublessons {
                    //learn and quiz
                    if lessonData.ScenarioLessonInfo!.LessonType! == .PracticeLesson {
                        if lessonData.ScenarioLessonInfo?.LearnRate ?? 0 >= 1 || (lessonData.ScenarioLessonInfo?.Progress)! > 0{
                            //已经完成，黄色图片
                            //有蒙版，进度100
                            if (self.beginnerCourse?.ScenarioLessonInfo?.LessonIcons)!.count >= 3 {
                                if let urlStr = self.beginnerCourse?.ScenarioLessonInfo?.LessonIcons![2].explaceBlankSpace() {
                                    centerImage.sd_setImage(with: URL(string: urlStr), placeholderImage: nil, options: .refreshCached) { (image, error, type, url) in
                                        
                                    }
                                }else {
                                    centerImage.image = ChImageAssets.PlaceHolder.image
                                }
                            }else {
                                centerImage.image = UIImage(named: "\((self.beginnerCourse?.ScenarioLessonInfo?.NativeName)!)_o")
                            }
                            headerCircle?.fillColor = UIColor.hex(hex: "FFF5E9")
                            headerCircle?.bgColor = UIColor.hex(hex: "FFF5E9")
                            self.completedBgView.isHidden = false
                            headerCircle?.drawProgress()
                            headerCircle.setProgress(CGFloat((lessonData.ScenarioLessonInfo?.LearnRate) ?? 0))
                            
                        }else {
                            //解锁未完成
                            //有进度，蓝色图片
                            headerCircle?.fillColor = UIColor.hex(hex: "FF9812")
                            headerCircle?.bgColor = UIColor.hex(hex: "E8F0FD")
                            headerCircle?.drawProgress()
                            headerCircle.setProgress(CGFloat((lessonData.ScenarioLessonInfo?.LearnRate) ?? 0))
                            if (self.beginnerCourse?.ScenarioLessonInfo?.LessonIcons)!.count >= 3 {
                                if let urlStr = self.beginnerCourse?.ScenarioLessonInfo?.LessonIcons![1].explaceBlankSpace() {
                                    centerImage.sd_setImage(with: URL(string: urlStr), placeholderImage: nil, options: .refreshCached) { (image, error, type, url) in
                                        
                                    }
                                }else {
                                    centerImage.image = ChImageAssets.PlaceHolder.image
                                }
                            }else {
                                centerImage.image = UIImage(named: (self.beginnerCourse?.ScenarioLessonInfo?.NativeName)!)
                            }
                        }
                    }
                }
            }
        }
    }
}
