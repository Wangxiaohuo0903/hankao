//
//  AnimationView.swift
//  动画练习
//
//  Created by Temp on 2018/10/30.
//  Copyright © 2018年 Temp. All rights reserved.
//

import UIKit

class AnimationView: UIView {
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var animationView1: borderImageView!
    
    @IBOutlet weak var animationView2: borderImageView!
    
    @IBOutlet weak var animationView3: borderImageView!
    
    @IBOutlet weak var animationView4: borderImageView!
    
    @IBOutlet weak var animationViewOld: borderImageView!
    
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var topViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var fruitImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var fruitImageWidth: NSLayoutConstraint!
    
    @IBOutlet weak var oldImageY: NSLayoutConstraint!
    
    private var animator = UIDynamicAnimator()
    var disapperAction:()->() = {}
    
    var oldImage = UIImage(named: "")
    var newImage: String = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func startAnimation(score: Int, oldImage: UIImage = UIImage(named: "")!, newImage: String, success: Bool,lostSunValue:Int,disapperAction:@escaping ()->()) {
        self.oldImage = oldImage
        self.newImage = newImage
        self.disapperAction = disapperAction
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.disappearTapped(gesture:)))
        bgView.addGestureRecognizer(tap)
        self.initViewStart()
        self.animationView3.alpha = 0
        
        if !success {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.failedView(lostSunValue: lostSunValue)
            }

            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.successView()
        }
        
        
    }
    func successView() {
        self.titleLabel.text = "You earned double points."
        self.fruitImageWidth.constant = 170
        self.fruitImageHeight.constant = 170
        self.topViewWidth.constant = 240
        self.topViewHeight.constant = 110
        self.layoutIfNeeded()
        self.HiddenJZStatusBar(alpha: 1)
        //动画画布，运动管理
        let animator = UIDynamicAnimator(referenceView: self)
        let center1 = CGPoint(x: self.center.x, y: self.center.y)
        let center2 = CGPoint(x: self.center.x, y: self.center.y + 30)
        let center3 = CGPoint(x: self.center.x, y: self.center.y - 80)
        let center4 = CGPoint(x: self.center.x, y: self.center.y + 80)
        let centerOld = CGPoint(x: self.center.x, y: self.center.y)
        //吸附行为
        let snap1 = UISnapBehavior(item: self.animationView1, snapTo: center1)
        let snap2 = UISnapBehavior(item: self.animationView2, snapTo: center2)
        let snap3 = UISnapBehavior(item: self.animationView3, snapTo: center3)
        let snap4 = UISnapBehavior(item: self.animationView4, snapTo: center4)
        let snapOld = UISnapBehavior(item: self.animationViewOld, snapTo: centerOld)
        //default 0.5这个值越大，震动的幅度越小  是从0.0～1.0当时当它为负数时 也震动，可以试试
        snap1.damping = 0.1
        snap2.damping = 0.1
        snap3.damping = 0.1
        snap4.damping = 0.1
        snapOld.damping = 0.1
        animator.addBehavior(snap1)
        animator.addBehavior(snap2)
        animator.addBehavior(snap3)
        animator.addBehavior(snap4)
        animator.addBehavior(snapOld)
        
        self.animator = animator
        animationView3.alpha = 0
        animationView4.alpha = 0
        
        self.animationReleaseView(finish: {
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
                self.animationView3.transform = self.animationView3.transform.scaledBy(x: 0, y: 0)
                self.animationView3.alpha = 1
            }, completion: nil)
            self.animationReleaseView(finish: {
                let fire1 = FireWork(frame: CGRect(x: 60, y: 250, width: 30, height: 30))
                
                let fire2 = FireWork(frame: CGRect(x: 80, y: 480, width: 30, height: 30))
                
                let fire3 = FireWork(frame: CGRect(x: 300, y: 450, width: 30, height: 30))
                self.bgView.addSubview(fire1)
                fire1.zanAnimationPlay()
                self.bgView.addSubview(fire2)
                fire2.zanAnimationPlay()
                self.bgView.addSubview(fire3)
                fire3.zanAnimationPlay()
            })
        })
    }
    @objc func disappearTapped(gesture: UITapGestureRecognizer) {
        self.disapperAction()
    }
    func failedView(lostSunValue:Int) {
        self.titleLabel.text = "Sorry, you lost \(lostSunValue) points.\n Keep trying!"
        self.topViewWidth.constant = 200
        self.topViewHeight.constant = 85
//        self.oldImageY.constant = 140
        self.layoutIfNeeded()
        self.animationView3.setBackgroundImage(UIImage(named: "failed_animation"), for: .normal)
        self.animationView4.alpha = 0
        //动画画布，运动管理
        let animator = UIDynamicAnimator(referenceView: self)
        let center1 = CGPoint(x: self.center.x, y: self.center.y)
        let center2 = CGPoint(x: self.center.x, y: self.center.y)
        let center3 = CGPoint(x: self.center.x, y: self.center.y - 60)
        let center4 = CGPoint(x: self.center.x, y: self.center.y + 80)
        let centerOld = CGPoint(x: self.center.x, y: self.center.y)
        //吸附行为
        let snap1 = UISnapBehavior(item: self.animationView1, snapTo: center1)
        let snap2 = UISnapBehavior(item: self.animationView2, snapTo: center2)
        let snap3 = UISnapBehavior(item: self.animationView3, snapTo: center3)
        let snap4 = UISnapBehavior(item: self.animationView4, snapTo: center4)
        let snapOld = UISnapBehavior(item: self.animationViewOld, snapTo: centerOld)
        //default 0.5这个值越大，震动的幅度越小  是从0.0～1.0当时当它为负数时 也震动，可以试试
        snap1.damping = 0.1
        snap2.damping = 0.1
        snap3.damping = 0.1
        snap4.damping = 0.1
        snapOld.damping = 0.1
        animator.addBehavior(snap1)
        animator.addBehavior(snap2)
        animator.addBehavior(snap3)
        animator.addBehavior(snap4)
        animator.addBehavior(snapOld)
        self.animator = animator
        self.animationReleaseView {
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
                self.animationView3.transform = self.animationView3.transform.scaledBy(x: 0, y: 0)
                self.animationView3.alpha = 1
            }, completion: nil)

            self.animationReleaseView(finish: {

            })
        }
        
        
        
    }
    private func animationReleaseView(finish:(()->Void)?) {
        self.animationViewOld.isHidden = true
        UIView.animate(withDuration: 1.2, delay: 0, usingSpringWithDamping: 0.35, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.animationView2.transform = CGAffineTransform.identity
            self.animationView3.transform = CGAffineTransform.identity
            self.animationView4.transform = CGAffineTransform.identity
        }) { (_) in
            if finish != nil {
                finish!()
            }
        }
    }
    ///获取状态栏
    private func HiddenJZStatusBar(alpha:CGFloat){
//        var object = UIApplication.shared,statusBar:UIView?
//        if object.responds(to: NSSelectorFromString("statusBar")) {
//            statusBar = object.value(forKey: "statusBar") as?UIView
//        }
//        UIView.animate(withDuration: 0.3) {
//            statusBar?.alpha = alpha
//        }
    }
    /// 没有动画的初始化所有的视图
    private func initViewStart(){
        self.animationView2.transform = self.animationView2.transform.scaledBy(x: 0, y: 0)
        self.animationView3.transform = self.animationView3.transform.scaledBy(x: 0, y: 0)
        self.animationView4.transform = self.animationView4.transform.scaledBy(x: 0, y: 0)
        if newImage == "drooping_success" || newImage == "farm_1" || !newImage.hasPrefix("http"){
            self.animationView2.setBackgroundImage(UIImage(named: newImage), for: .normal)
        }else {
            self.animationView2.sd_setBackgroundImage(with: URL(string: newImage), for: .normal, completed: nil)
        }
        self.animationViewOld.setBackgroundImage(oldImage, for: .normal)
    }
    /// 动画的初始化所有的视图
    private func animationInitViewStart(){

        UIView.animate(withDuration: 1.2, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.animationView2.transform = self.animationView2.transform.scaledBy(x: 0.5, y: 0.5)
            self.animationView3.transform = self.animationView3.transform.scaledBy(x: 0.5, y: 0.5)
            self.animationView4.transform = self.animationView4.transform.scaledBy(x: 0.5, y: 0.5)
        }) { (_) in
        }
    }
    func hide() {  
        self.removeFromSuperview()
    }
}
