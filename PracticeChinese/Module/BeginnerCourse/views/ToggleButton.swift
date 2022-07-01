//
//  ToggleButton.swift
//  ChineseDev
//
//  Created by Temp on 2018/7/10.
//  Copyright © 2018年 msra. All rights reserved.
//

//import UIKit
//
class ToggleButton: UIButton {
    var toggleEnabled = false
    //开关是否有效
    var onImage: UIImage?
    //"开"状态图片
    var offImage: UIImage?
    //"关"状态图片
    var onBackgroundImage: UIImage?
    //"开"状态背景图片
    var offBackgroundImage: UIImage?
    //"关"状态背景图片
    var onTitle = ""
    //"开"状态标题
    var offTitle = ""
    //"关"状态标题
    var onTitleColor: UIColor?
    //"开"状态标题颜色
    var offTitleColor: UIColor?
    
    //"关"状态标题颜色
    //代码生成开关按钮类方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setSubviews()
    }
    
    func setSubviews() {
        self.onImage = UIImage(named: "in_recording")
        self.offImage = UIImage(named: "start_playing")
        self.setImage(offImage, for: .normal)
        self.setImage(onImage, for: .selected)
        self.toggleEnabled = true
        self.isUserInteractionEnabled = true
    }

    override var isSelected: Bool {
        didSet {
            /*
             if isSelected {
             UIView.animate(withDuration: 0.5, delay: 0.00, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: .allowUserInteraction, animations: {
             self.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
             }) { finished in
             }
             }else {
             UIView.animate(withDuration: 0.5, delay: 0.00, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: .allowUserInteraction, animations: {
             self.transform = CGAffineTransform(rotationAngle: 0)
             }) { finished in
             }
             }
             */
        }
    }

    //  Converted to Swift 4 by Swiftify v4.1.6759 - https://objectivec2swift.com/
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        toggleEnabled = true
        setBackgroundImage(nil, for: .selected)
        setImage(nil, for: .selected)
        
    }
    
    // MARK: - Toggle Support
    func toggle() {
        self.isSelected = !isSelected
    }
    
    //Detect a touchUpInside event and perform toggle if toggleEnabled = YES
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
//        if isTouchInside && toggleEnabled {
//            toggle()
//        }
    }


}
