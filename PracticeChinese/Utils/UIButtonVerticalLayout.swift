//
//  UIButtonVerticalLayout.swift
//  PracticeChinese
//
//  Created by ThomasXu on 28/06/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation

class UIButtonVerticalLayout: UIButton {
    
    var shouldVerticalLayout:Bool = true
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !shouldVerticalLayout {
            return
        }
        if let img = self.imageView, let title = self.titleLabel, let text = title.text {
            let titleHeight = title.font.lineHeight
            let titleY = frame.height - titleHeight
            
            let imgTitleDis: CGFloat = 1
            let imgHeight = frame.height - imgTitleDis - titleHeight
            let realWidth = min(imgHeight, frame.width)
            let imgX = (frame.width - realWidth) / 2
            img.frame = CGRect(x: imgX, y: 0, width: realWidth, height: realWidth)
            
            title.frame = CGRect(x: 0, y: titleY, width: frame.width, height: titleHeight)
            title.textAlignment = .center
        }
    }
}
