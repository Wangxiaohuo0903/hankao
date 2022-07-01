//
//  CornerAngleView.swift
//  PracticeChinese
//
//  Created by 费跃 on 9/21/17.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit

class CornerAngleView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        let cropedX = ScreenUtils.heightBySix(y: 75)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.minY))

        context.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cropedX))
        context.addLine(to: CGPoint(x: rect.maxX - cropedX , y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        context.closePath()
        
        context.setFillColor(UIColor.white.cgColor)
        context.fillPath()
    }
}
