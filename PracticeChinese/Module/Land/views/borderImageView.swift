//
//  borderImageView.swift
//  动画练习
//
//  Created by Temp on 2018/10/29.
//  Copyright © 2018年 Temp. All rights reserved.
//

import UIKit

@IBDesignable
class borderImageView: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBInspectable var borderWidth:CGFloat = 0 {
        
        didSet{
            
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor:UIColor = UIColor.black {
        
        didSet{
            
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var cornerRadius:CGFloat = 0{
        
        didSet{
            
            self.layer.cornerRadius = cornerRadius
        }
    }
}
