//
//  transitionPage.swift
//  PracticeChinese
//
//  Created by summer on 2017/9/11.
//  Copyright © 2017年 msra. All rights reserved.
//

import Foundation
class transitionPage: UIView {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = 10.0
        
        self.setSubviews()
    }
    
    func setSubviews(){
        
        let textLabel = UILabel(frame: CGRect(x:0 , y:self.frame.height*0.5-CGFloat(20), width:200, height: 20))
        textLabel.text = "--------->"
        textLabel.textColor = UIColor.white
        textLabel.textAlignment = .center
        textLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(17), type: .Regular)
        
        self.addSubview(textLabel)

        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
