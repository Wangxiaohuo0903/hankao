//
//  LCProgressBar.swift
//  PracticeChinese
//
//  Created by ThomasXu on 21/07/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit

class LCProgressBar: UIView {
    var topView: UIView!
    var progress: CGFloat = 0 {
        didSet {
            self.setProgress()
        }
    }
    var topColor = UIColor.blueTheme {
        didSet {
            topView.backgroundColor = topColor
        }
    }
    
    var bgColor = UIColor.blueTheme {
        didSet {
            self.backgroundColor = bgColor
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.topView = UIView(frame: CGRect.zero)
        topView.backgroundColor = UIColor.blueTheme
        self.addSubview(topView)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.2)
    }
    
    func setProgress() {
        let total = self.frame.width
        let viewWidth = total * progress
        self.topView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: frame.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = frame.height / 2
        self.layer.masksToBounds = true
        
        topView.layer.cornerRadius = frame.height / 2
        topView.layer.masksToBounds = true
        
        self.setProgress()//重新更新进度条
    }
    
}
