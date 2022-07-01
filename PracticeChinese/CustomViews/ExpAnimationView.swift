//
//  ExpAnimationView.swift
//  PracticeChinese
//
//  Created by feiyue on 06/07/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit


enum ExpType {
    case easy //2
    case medium //3
    case hard //4

}

class ExpAnimationView: UIImageView, CAAnimationDelegate{
    var smallFrame:CGRect!
    var bigFrame:CGRect!
    // position animating
    var posAnimate:CABasicAnimation! = CABasicAnimation(keyPath: "position")
    // scale animating
    var sizeAnimate:CABasicAnimation! = CABasicAnimation(keyPath: "transform.scale")

    
    static let shared = ExpAnimationView()
    
    private init() {
        super.init(frame: CGRect.zero)
        smallFrame = CGRect(x: ScreenUtils.widthByRate(x: 0.8), y: ScreenUtils.height/2, width: ScreenUtils.widthByRate(x: 0.05), height: ScreenUtils.heightByRate(y: 0.007))
        posAnimate.duration = 3.0
        posAnimate.repeatCount = 1
        posAnimate.isRemovedOnCompletion = false
        posAnimate.fromValue = CGPoint(x:ScreenUtils.widthByRate(x: 0.8), y:ScreenUtils.height/2)
        posAnimate.delegate = self
        posAnimate.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        
        sizeAnimate.duration = 3.0
        sizeAnimate.repeatCount = 1
        sizeAnimate.isRemovedOnCompletion = false
        sizeAnimate.fromValue = 1
        sizeAnimate.toValue = 6
        sizeAnimate.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)

        sizeAnimate.fillMode = CAMediaTimingFillMode.forwards

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func show(_ type:ExpType) {
        let expView = ExpAnimationView.shared
        expView.frame = expView.smallFrame
        expView.alpha = 0.5
        switch type {
        case .easy: expView.image = ChImageAssets.exp2.image
        case .medium: expView.image = ChImageAssets.exp3.image
        default: expView.image = ChImageAssets.exp4.image
        }
        UIApplication.topViewController()?.view.addSubview(expView)
        expView.layer.position = CGPoint(x:ScreenUtils.widthByRate(x: 0.8), y:100)

        expView.layer.add(expView.posAnimate, forKey: "positionAnimate")
        expView.layer.add(expView.sizeAnimate, forKey: "sizeAnimate")
        
        UIView.animate(withDuration: 0.5, delay: 3, options: .allowAnimatedContent, animations: {
            expView.alpha = 1
        }, completion: { _ in
            expView.removeFromSuperview()
        })
        
    }
    class func showSunValue(_ value:Int,combo:Int = -1) {
        let expView = ExpAnimationView.shared
        expView.frame = expView.smallFrame
        expView.alpha = 0.9
        
        expView.image = UIImage(named: "+\(value > 10 ? 10 : value)")
        UIApplication.topViewController()?.view.addSubview(expView)
        expView.layer.position = CGPoint(x:ScreenUtils.widthByRate(x: 0.8), y:100)
        
        expView.layer.add(expView.posAnimate, forKey: "positionAnimate")
        expView.layer.add(expView.sizeAnimate, forKey: "sizeAnimate")
        
        UIView.animate(withDuration: 0.5, delay: 1, options: .allowAnimatedContent, animations: {
            expView.alpha = 1
        }, completion: { _ in
            expView.removeFromSuperview()
        })
        
    }
    class func quit(){
        let expView = ExpAnimationView.shared
        let ishas = UIApplication.topViewController()?.view.subviews.contains(expView)
        if(ishas!){
            expView.removeFromSuperview()
        }
    }
    
    class func hide() {
        ExpAnimationView.shared.removeFromSuperview()
    }
    /*
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        var expView = ExpAnimationView.shared
        expView.layer.position = expView.posAnimate.toValue as! CGPoint

        UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .allowAnimatedContent, animations: {
            expView.alpha = 0
        }, completion: { _ in
            expView.removeFromSuperview()
        })

    }
 */
    
}
class SunAnimationView: UIView, CAAnimationDelegate{
    var smallFrame:CGRect!
    var bigFrame:CGRect!
    // position animating
    var posAnimate:CABasicAnimation! = CABasicAnimation(keyPath: "position")
    // scale animating
    var sizeAnimate:CABasicAnimation! = CABasicAnimation(keyPath: "transform.scale")
    var imageCombo: UIImageView!
    var imageSun: UIImageView!
    
    static let shared = SunAnimationView()
    
    private init() {
        super.init(frame: CGRect.zero)
        smallFrame = CGRect(x: ScreenUtils.widthByRate(x: 0.8), y: ScreenUtils.height * 0.65, width: 36, height: 34)
        posAnimate.duration = 0.5
        posAnimate.repeatCount = 1
        posAnimate.isRemovedOnCompletion = false
        posAnimate.fromValue = CGPoint(x:ScreenUtils.widthByRate(x: 0.8), y:ScreenUtils.height * 0.65)
        posAnimate.delegate = self
        posAnimate.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        
        sizeAnimate.duration = 0.5
        sizeAnimate.repeatCount = 1
        sizeAnimate.isRemovedOnCompletion = false
        sizeAnimate.fromValue = 0.5
        sizeAnimate.toValue = 3.5
        sizeAnimate.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        
        sizeAnimate.fillMode = CAMediaTimingFillMode.forwards
        
        imageCombo = UIImageView()
        imageCombo.frame = CGRect(x: 0, y: 0, width: 36, height: 6)
        self.addSubview(imageCombo)
        imageSun = UIImageView()
        imageSun.frame = CGRect(x: 3, y: imageCombo.frame.maxY, width: 30, height: 15)
        self.addSubview(imageSun)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
    class func showSunValue(_ value:Int,combo:Int = -1) {
        let expView = SunAnimationView.shared
        expView.frame = expView.smallFrame
        expView.alpha = 0.9
        
        expView.imageSun.image = UIImage(named: "+\(value > 10 ? 10 : value)")
        if combo > 0 {
            expView.imageCombo.image = UIImage(named: "combo")
        }else {
            expView.imageCombo.image = UIImage(named: "")
        }
        UIApplication.topViewController()?.view.addSubview(expView)
        expView.layer.position = CGPoint(x:ScreenUtils.widthByRate(x: 0.8), y:ScreenUtils.height * 0.45)
        
        expView.layer.add(expView.posAnimate, forKey: "positionAnimate")
        expView.layer.add(expView.sizeAnimate, forKey: "sizeAnimate")
        
        UIView.animate(withDuration: 0.3, delay: 1, options: .allowAnimatedContent, animations: {
            expView.alpha = 1
        }, completion: { _ in
            expView.removeFromSuperview()
        })
        
    }
    class func quit(){
        let expView = SunAnimationView.shared
        let ishas = UIApplication.topViewController()?.view.subviews.contains(expView)
        if(ishas!){
            expView.removeFromSuperview()
        }
    }
    
    class func hide() {
        SunAnimationView.shared.removeFromSuperview()
    }
    
}
