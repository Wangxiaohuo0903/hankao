//
//  FireWork.swift
//  动画练习
//
//  Created by Temp on 2018/10/29.
//  Copyright © 2018年 Temp. All rights reserved.
//

import UIKit
@IBDesignable
class FireWork: UIControl {
    var effectLayer: CAEmitterLayer!
    var effectCell:CAEmitterCell!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initBaseLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func initBaseLayout() {
        effectLayer = CAEmitterLayer()
        effectLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        self.layer.addSublayer(effectLayer)
        effectLayer.emitterShape = CAEmitterLayerEmitterShape.circle
        effectLayer.emitterMode = CAEmitterLayerEmitterMode.outline
        effectLayer.emitterPosition = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        effectLayer.emitterSize = CGSize(width: self.frame.size.width, height: self.frame.size.height)
        
        effectCell = CAEmitterCell()
        effectCell.name = "zanShape"
        effectCell.contents = UIImage(named: "star")?.cgImage
        effectCell.alphaSpeed = -1.0
        effectCell.lifetime = 1.0
        effectCell.birthRate = 0
        effectCell.velocity = 100
        effectCell.velocityRange = 100
        effectLayer.emitterCells = [effectCell]
    }
    func zanAnimationPlay()  {
        UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 5, options: .curveLinear, animations: {
            let effectLayerAnimation = CABasicAnimation()
            effectLayerAnimation.keyPath = "emitterCells.zanShape.birthRate"
            effectLayerAnimation.fromValue = 100
            effectLayerAnimation.toValue = 0
            effectLayerAnimation.duration = 0
            effectLayerAnimation.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeOut)
            self.effectLayer.add(effectLayerAnimation, forKey: "ZanCount")
            
        }) { (_) in
            
        }
    }
    
}
