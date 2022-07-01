//
//  SunView.swift
//  PracticeChinese
//
//  Created by Temp on 2019/6/13.
//  Copyright © 2019 msra. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class SunView: UIView {
    var sunButton = UIButton()
    var animateView: NVActivityIndicatorView!
    var sunNum = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.animateView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 25, height: 25), type: .ballSpinFadeLoader, color: UIColor.hex(hex: "FFAC1A"), padding: 0)
        sunButton.frame = CGRect(x: 0, y: 0, width:25, height: 25)
        sunButton.setImage(UIImage(named: "sunNew"), for: .normal)
        sunButton.setTitleColor(UIColor.hex(hex: "FFC543"), for: .normal)
        sunButton.titleLabel?.font = FontUtil.getFont(size: 18, type: .Bold)
        sunButton.imageView?.contentMode = .scaleAspectFit
        self.addSubview(animateView)
        self.addSubview(sunButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showSunNumber(sunValue:Int = 0) {
        self.sunNum = sunValue
        //如果传过来的是-1，说明没登录，或者没有权限，总之就是不显示
        if self.sunNum == -1 {
            self.isHidden = true
            self.animateView.stopAnimating()
        }else {
            self.isHidden = false
            self.sunButton.setTitle(" \(self.sunNum)", for: .normal)
            
        }
    }
    /**
     Start animating.
     */
    func startAnimating() {
        self.animateView.startAnimating()
    }
    
    /**
     Stop animating.
     */
    func stopAnimating() {
        self.animateView.stopAnimating()
    }
}
