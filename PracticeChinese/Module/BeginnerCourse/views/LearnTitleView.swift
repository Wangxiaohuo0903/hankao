//
//  LearnTitleView.swift
//  PracticeChinese
//
//  Created by Temp on 2018/11/14.
//  Copyright © 2018 msra. All rights reserved.
//

import UIKit

class LearnTitleView: UIView {
    let titleLabel = UILabel()
    let leftMask = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        titleLabel.font = FontUtil.getFont(size: 16, type: .Medium)
        titleLabel.textColor = UIColor.blueTheme
        titleLabel.textAlignment = .center
        leftMask.frame = CGRect(x: 0, y: -(self.frame.height - self.frame.origin.y) , width: 30, height: frame.height)
        leftMask.isHidden = true
        addSubview(titleLabel)
        addSubview(leftMask)
        
    }
    func setData(title:String = "") {
        titleLabel.text = title
        let titleWidth = title.wdith(withConstrainedWidth: CGFloat(MAXFLOAT), font: FontUtil.getFont(size: 16, type: .Medium))
        if titleWidth > frame.width {
            titleLabel.frame = CGRect(x: -(titleWidth - frame.width), y: 0 , width: titleWidth, height: self.titleLabel.frame.height)
            leftMask.isHidden = false
            gradientColor(gradientView: leftMask)
            titleLabel.textAlignment = .right
        }else {
            titleLabel.frame = CGRect(x: (frame.width - titleWidth + 30)/2, y: 0 , width: titleWidth, height: self.titleLabel.frame.height)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //渐变色
    func gradientColor(gradientView : UIView) {
        let colorOne = UIColor(red: 229.0 / 255.0, green: 229.0 / 255.0, blue: 229.0 / 255.0, alpha: 1.0)
        let colorTwo = UIColor(red: 229.0 / 255.0, green: 229.0 / 255.0, blue: 229.0 / 255.0, alpha: 0.0)
        let colors = [colorOne.cgColor, colorTwo.cgColor]
        let gradient = CAGradientLayer()
        //设置开始和结束位置(设置渐变的方向)
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        gradient.colors = colors
        gradient.frame = CGRect(x: 0, y: 0, width: 30, height: 45)
        gradientView.layer.insertSublayer(gradient, at: 0)
    }
}
