//
//  CardSuper.swift
//  PracticeChinese
//
//  Created by summer on 2017/9/13.
//  Copyright © 2017年 msra. All rights reserved.
//

import Foundation
import AVFoundation
import DCAnimationKit

protocol SelectCorrectDelegate {
    //回答正确，这如下一页
    func gotoNextpage()
    //回答错误，如果有备用的题，则插入备用的
    func showSamepage(tag: [String]?)
    //加阳光值
    func addSunValue(value: Int)
    
}
class QuizCardSuper: UIView {
    
    var buttons = [OptionButton]()
    var continueButton:UIButton!
    let continueWidth = 150
    var answer:Int!
    var order:Int!
    var gotoNextTime = 2
    var toPlayTime = 1
    var videoButton:CircularProgressView!
    var videoButtonView:UIView!
    var player:AVPlayer!
    var selectDelegate:SelectCorrectDelegate?
    var audioRightPlayer:AVAudioPlayer!
    var audioWrongPlayer:AVAudioPlayer!
    var myIndex: Int = 0//当前view的位置
    var timer:Timer!
    var Lessionid: String = ""
    //第一次答对加阳光值
    var firstRight: Bool = true
    var quizViewWidth = 0.0
    //只根据第一次的选择来决定如何上传状态
    var firstClickRight = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        audioRightPlayer = try? AVAudioPlayer(contentsOf: ChBundleAudioUtil.successquizRight.url)
        audioRightPlayer?.prepareToPlay()
        audioWrongPlayer = try? AVAudioPlayer(contentsOf: ChBundleAudioUtil.successquizWrong.url)
        audioWrongPlayer?.prepareToPlay()
    }
    func makeContinuButton() {
        continueButton = UIButton(type: .custom)
        continueButton.frame = CGRect(x:(Int(self.frame.width) - continueWidth) / 2 , y:Int(self.frame.height - 75), width: continueWidth, height: 44)
        continueButton.setBackgroundImage(UIImage.fromColor(color: UIColor.quizContinueColor), for: .normal)
        continueButton.setTitle("Continue", for: UIControl.State.normal)
        continueButton.titleLabel?.textAlignment = .center
        continueButton.titleLabel?.font = FontUtil.getFont(size: FontAdjust().FontSize(18), type: .Regular)
        continueButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        continueButton.layer.cornerRadius = 22
        continueButton.layer.masksToBounds = true
        self.continueButton.alpha = 0
        self.addSubview(continueButton)
        continueButton.isHidden = false
    }
    
    func setData(quiz:QuizSample,voice:Dictionary<String,SentenceDetail>){
    
        
    }
    
    func updateQuizSelectStatus(lid:String, question:String, answer:Int, passed: Bool, completion:@escaping (_ result:ScenarioRateChoiceResult?)->()) {
//        if passed {
//            UIApplication.topViewController()?.presentUserToast(message: "第一次答对")
//        }else {
//            UIApplication.topViewController()?.presentUserToast(message: "第一次答错")
//        }
        CourseManager.shared.rateQuiz(lid: lid, question: question, answer: answer, passed:passed ) { (result) in
            
        }
    }
    func refreshPageValue(){
        if buttons.count == 0 {
            return
        }
        for i in 0...buttons.count-1{
            buttons[i].refreshButtonValue()
        }
    }
    
    @objc dynamic func refreshPage(){
        continueButton.isHidden = true
        continueButton.isEnabled = true
        if buttons.count == 0 {
            return
        }
        for i in 0...buttons.count-1{
            buttons[i].refreshButton()
        }
    }
    
    func setOrder(order:Int){
        self.order = order
    }
    func showContinue() {
        
    }
    @objc dynamic func tappedOptionButton(button:OptionButton){
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
