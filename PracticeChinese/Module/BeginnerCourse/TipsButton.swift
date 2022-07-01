//
//  TipsButton.swift
//  PracticeChinese
//
//  Created by summer on 2017/10/13.
//  Copyright © 2017年 msra. All rights reserved.
//

import Foundation

class TipsButton: UIButton {
    
    var image:UIImageView!
    var leftLine:UIView!
    var rightLine:UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        image = UIImageView(image: UIImage(named: "tips"))
        image.frame = CGRect(x:((self.frame.width - 40) / 2.0) , y: 10, width: 40, height: 15)
        image.contentMode = .scaleAspectFit
        leftLine = UIView(frame: CGRect(x: 15, y: self.frame.height / 2.0 + 5, width: 0, height: 1))
        leftLine.backgroundColor = UIColor.hex(hex: "E7EBF3")
        self.addSubview(leftLine)
        
        rightLine = UIView(frame: CGRect(x: self.frame.width / 2 + 40, y: self.frame.height / 2.0 + 5, width: 0, height: 1))
        rightLine.backgroundColor = UIColor.hex(hex: "E7EBF3")
        self.addSubview(rightLine)
        self.addSubview(image)
    }
    //关闭，不带线
    func changeToArrow(){
        UIView.animate(withDuration: 0.2) {
            self.leftLine.frame = CGRect(x: self.frame.width / 2 - 40, y: self.frame.height / 2.0 + 5, width: 0, height: 1)
            self.rightLine.frame = CGRect(x: self.frame.width / 2 + 40, y: self.frame.height / 2.0, width: 0, height: 1)
        }
    }
    //打开，带线
    func changeToTips(){
        UIView.animate(withDuration: 0.2) {
            self.leftLine.frame = CGRect(x: 15, y: self.frame.height / 2.0 + 5, width: ((self.frame.width - 80 - 30) / 2.0), height: 1)
            self.rightLine.frame = CGRect(x: self.image.frame.maxX + 20, y: self.frame.height / 2.0 + 5, width: ((self.frame.width - 80 - 30) / 2.0 + 3), height: 1)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
