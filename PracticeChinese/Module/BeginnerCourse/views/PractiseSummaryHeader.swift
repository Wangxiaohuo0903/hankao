//
//  PractiseSummaryHeader.swift
//  PracticeChinese
//
//  Created by Temp on 2018/9/10.
//  Copyright © 2018年 msra. All rights reserved.
//

import UIKit

class PractiseSummaryHeader: UIView {
    @IBOutlet weak var header: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
    func setData(score:Int) {
        let circleWidth = CGFloat(156.0)
        let headerCircle = MLMCircleView(frame: CGRect(x: 0 , y: 0, width: circleWidth, height: circleWidth), startAngle: 270, endAngle: 630)
        headerCircle?.center = CGPoint(x: circleWidth/2, y: circleWidth/2)
        headerCircle?.bottomWidth = 4
        headerCircle?.progressWidth = 8
        headerCircle?.fillColor = UIColor.hex(hex: "4E80D9")
        headerCircle?.bgColor = UIColor.hex(hex: "E2E2E2")
        headerCircle?.dotDiameter = 20;
        headerCircle?.edgespace = 5;
        headerCircle?.drawProgress()
        headerCircle?.setProgress(CGFloat(Double(score) / Double(100.0)))
        header.addSubview(headerCircle!)
        
        let imageWidth = CGFloat(102.0)
        let userImage = UIImageView(frame: CGRect(x: (circleWidth - imageWidth)/2, y: (circleWidth - imageWidth)/2, width: imageWidth, height: imageWidth))
        userImage.image = UIImage(named: "circle")
        header.addSubview(userImage)
        
        let scoreLabel = UILabel(frame: CGRect(x: (circleWidth - imageWidth)/2, y: (circleWidth - imageWidth)/2, width: imageWidth, height: imageWidth))
        scoreLabel.text = String(score)
        scoreLabel.textColor = UIColor.white
        scoreLabel.textAlignment = .center
        scoreLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(40), type: .Bold)
        header.addSubview(scoreLabel)
        
    }
}
