//
//  PractiseIntroHeaderView.swift
//  PracticeChinese
//
//  Created by Temp on 2018/11/27.
//  Copyright © 2018 msra. All rights reserved.
//

import UIKit

class PractiseIntroHeaderView: UIView {
    
    @IBOutlet weak var header: UIView!
    
    @IBOutlet weak var name_chinese: UILabel!
    
    @IBOutlet weak var name_English: UILabel!
    
    @IBOutlet weak var background_Chinese: UILabel!
    
    @IBOutlet weak var background_English: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var nameTop: NSLayoutConstraint!
    
    @IBOutlet weak var introTop: NSLayoutConstraint!
    
    @IBOutlet weak var HeightScore: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
    func setData(score:Int,nameC:String = "",nameE:String = "",introC:String = "",introE:String = "") {
        let circleWidth = CGFloat(140.0)
        let headerCircle = MLMCircleView(frame: CGRect(x: 0 , y: 0, width: circleWidth, height: circleWidth), startAngle: 270, endAngle: 630)
        headerCircle?.center = CGPoint(x: circleWidth/2, y: circleWidth/2)
        headerCircle?.bottomWidth = 4
        headerCircle?.progressWidth = 8
        headerCircle?.fillColor = UIColor.white
        headerCircle?.bgColor = UIColor.colorFromRGB(255, 255, 255, 0.2)
        headerCircle?.dotDiameter = 20;
        headerCircle?.edgespace = 5;
        headerCircle?.drawProgress()
        headerCircle?.setProgress(CGFloat(Double(score) / Double(100.0)))
        header.addSubview(headerCircle!)
        
        let imageWidth = CGFloat(102.0)
        let userImage = UIImageView(frame: CGRect(x: (circleWidth - imageWidth)/2, y: (circleWidth - imageWidth)/2, width: imageWidth, height: imageWidth))
        userImage.backgroundColor = UIColor.colorFromRGB(255, 255, 255, 0.2)
        userImage.layer.cornerRadius = imageWidth / 2
        userImage.layer.masksToBounds = true
//        userImage.image = UIImage(named: "circle")
        header.addSubview(userImage)
        
        let scoreLabel = UILabel(frame: CGRect(x: (circleWidth - imageWidth)/2, y: (circleWidth - imageWidth)/2, width: imageWidth, height: imageWidth))
        scoreLabel.text = String(score)
        scoreLabel.textColor = UIColor.white
        scoreLabel.textAlignment = .center
        scoreLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(40), type: .Bold)
        header.addSubview(scoreLabel)
        
        //开始按钮，如果低于60分，或者没做过，先进行跟读练习，否则直接进入跟读
        startButton.layer.cornerRadius = 22
        startButton.layer.masksToBounds = true
        
        name_chinese.text = nameC
        name_English.text = nameE
        background_Chinese.text = introC
        background_English.text = introE
        
        nameTop.constant = 280
        introTop.constant = ScreenUtils.heightByM(y: 60)
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhone){
            nameTop.constant = 250
            
        }else if(AdjustGlobal().CurrentScale == AdjustScale.iPhone4){
            nameTop.constant = 280
        }else if(AdjustGlobal().CurrentScale == AdjustScale.iPhone5){
            nameTop.constant = 220
        }
        
        header.isHidden = false
        HeightScore.isHidden = false
        if score == -1 {
           //没做过
            nameTop.constant = ScreenUtils.heightByM(y: 200)
            header.isHidden = true
            HeightScore.isHidden = true
            startButton.setImage(UIImage(named: "more_down"), for: .normal)
            startButton.backgroundColor = UIColor.clear
            startButton.setTitle("", for: .normal)
        }else if (score < 60) {
           //没及格
            startButton.setImage(UIImage(named: "more_down"), for: .normal)
            startButton.backgroundColor = UIColor.clear
            startButton.setTitle("", for: .normal)
        }else {
            //已经成功了
            startButton.setTitleColor(UIColor.blueTheme, for: .normal)
            startButton.backgroundColor = UIColor.white
            startButton.setTitle("Review", for: .normal)
        }
    }

}
