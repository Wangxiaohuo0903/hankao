//
//  AlertFooterView.swift
//  ChineseLearning
//
//  Created by feiyue on 30/03/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol AlertFooterDelegate {
    func continueTapped(correct: Bool)
}

class AlertFooterView:UIView {
    var titleLabel: UILabel!
    var pyTopLabel: UILabel!
    var pyBottomLabel: UILabel!
    var enTopLabel: UILabel!
    var enBottomLabel: UILabel!
    var correct: Bool!

    var topVoiceButton: LCVoiceButton!
    var bottomVoiceButton:LCVoiceButton!
    
    var continueButton: UIButton!
    var blurView:UIView!
    
    var delegate:AlertFooterDelegate?

    
    public class var shared: AlertFooterView {
        struct Singleton {
            static let instance = AlertFooterView(frame: CGRect.zero)
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
        
    public class func show(correct:Bool, pyTopText:String, voiceUrl:URL?) {
        let footer = AlertFooterView.shared
        footer.setupContent(correct:correct, pyTopText:pyTopText, voiceUrl:voiceUrl)
        footer.containerView()?.addSubview(footer.blurView)

    }
    
    func setVoiceContent() {
        
    }
    
    var resultPlayer: AVPlayer!
    func setupContent(correct:Bool, pyTopText:String, voiceUrl:URL?) {
        
        blurView = UIView(frame:CGRect(x:0, y:0, width:ScreenUtils.width, height:ScreenUtils.height))
        blurView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        blurView.isUserInteractionEnabled  = true
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hide))
        //blurView.addGestureRecognizer(tapGesture)
        var canvasView = UIView(frame:CGRect(x:0, y:ScreenUtils.heightByRate(y: 0.75), width:ScreenUtils.width, height:ScreenUtils.heightByRate(y: 0.25)))
        canvasView.backgroundColor = correct ? UIColor.correctColor : UIColor.wrongColor
        
        let title = correct ? "You are correct!" : "The correct answer is"
        let titleLabel = UILabel(frame: CGRect(x: 10, y: ScreenUtils.heightByRate(y: 0.026), width: ScreenUtils.width-20, height: ScreenUtils.heightByRate(y: 0.026)))
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        titleLabel.font = FontUtil.getFont(size: 20, type: .Regular)

        canvasView.addSubview(titleLabel)
        
        pyTopLabel = UILabel(frame: CGRect(x: 10, y: ScreenUtils.heightByRate(y: 0.06), width: ScreenUtils.width-20, height: ScreenUtils.heightByRate(y: 0.1)))
        pyTopLabel.text = pyTopText
        pyTopLabel.numberOfLines = 2
        pyTopLabel.textAlignment = .center
        pyTopLabel.textColor = UIColor.white
        pyTopLabel.font = FontUtil.getFont(size: 18, type: .Regular)

        let textSize:CGSize = pyTopLabel.intrinsicContentSize
        self.correct = correct

        if voiceUrl != nil {
        
            topVoiceButton = LCVoiceButton(frame: CGRect(x: ScreenUtils.widthByRate(x: 0.567) + (textSize.width * 0.5) - 10, y: ScreenUtils.heightByRate(y: 0.10), width: ScreenUtils.heightByRate(y: 0.04), height: ScreenUtils.heightByRate(y: 0.04)))
            topVoiceButton.audioUrl = voiceUrl?.absoluteString
   //         topVoiceButton.style = .white
            
            canvasView.addSubview(topVoiceButton)
            canvasView.bringSubviewToFront(topVoiceButton)

        }
        var audioName = "right_answer"
        if false == correct {
            audioName = "wrong_answer"
        }
        let path = Bundle.main.path(forResource: audioName, ofType: ".mp3", inDirectory: "Sound")!
        let soundUrl = NSURL.fileURL(withPath: path)
        resultPlayer = AVPlayer(url: soundUrl)
        resultPlayer.play()
        canvasView.addSubview(pyTopLabel)
        
        /*
        enTopLabel = UILabel(frame: CGRect(x: 10, y: ScreenUtils.heightByRate(y: 0.092), width: ScreenUtils.width-20, height: ScreenUtils.heightByRate(y: 0.02)))
        enTopLabel.text = enTopText
        enTopLabel.textAlignment = .center
        enTopLabel.textColor = UIColor.white
        enTopLabel.font = UIFont(name: "PingFangSC-Regular", size: 18)
        blurView.addSubview(enTopLabel)
        */
        
        continueButton = UIButton(frame:CGRect(x: 25, y: ScreenUtils.heightByRate(y: 0.17), width: ScreenUtils.width-50, height: ScreenUtils.heightByRate(y: 0.066)))
        continueButton.backgroundColor = UIColor.white
        continueButton.titleLabel?.font = FontUtil.getFont(size: 22, type: .Regular)

        continueButton.setTitle("Continue", for: .normal)
        continueButton.setTitleColor(correct ? UIColor.correctColor : UIColor.wrongColor, for: .normal)
        continueButton.layer.cornerRadius = ScreenUtils.heightByRate(y: 0.033)
        continueButton.layer.masksToBounds = false
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        canvasView.addSubview(continueButton)
        blurView.addSubview(canvasView)
    }
    
    @objc func continueTapped() {
   //     AlertFooterView.shared.blurView.removeFromSuperview()
        self.blurView.removeFromSuperview()
        delegate?.continueTapped(correct: self.correct)
    }
}
