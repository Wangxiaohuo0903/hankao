//
//  ButtonWIthImageLeft.swift
//  PracticeChinese
//
//  Created by ThomasXu on 17/07/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation

class LCButtonWithImageLeft: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let img = self.imageView, let title = self.titleLabel{
            
            title.sizeToFit()
            let titleHeight = title.font.lineHeight
            let titleY = (frame.height - titleHeight) / 2
            
            let imgHeight = titleHeight
            let imgTitleDis = imgHeight * 0.8
            
            var imgX = (frame.width - imgHeight - imgTitleDis - title.frame.width) / 2
            img.frame = CGRect(x: imgX, y: titleY, width: imgHeight, height: imgHeight)
            
            let titleX = imgX + imgHeight + imgTitleDis
            title.frame = CGRect(x: titleX, y: titleY, width: title.frame.width, height: titleHeight);
            
            title.textAlignment = .center
        }
    }
}
