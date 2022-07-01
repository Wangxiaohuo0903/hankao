//
//  LCPlayerViewControlPanel.swift
//  ChineseLearning
//
//  Created by ThomasXu on 22/05/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit

class LCPlayerControlPanelView: UIView {
    
    var infoLabel: UILabel!
    var progress: UIProgressView!
    static let infoLabelFont = FontUtil.getFont(size: FontAdjust().FontSize(16), type: .Regular)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setSubviews()
    }
    
    private func setSubviews() {
        let labelWidth: CGFloat = 120
        let labelHeight = frame.height
        
        infoLabel = UILabel(frame: CGRect(x: 0, y: 0, width: labelWidth, height: labelHeight))
        infoLabel.textAlignment = .left
        infoLabel.textColor = UIColor.white
        infoLabel.font = LCPlayerControlPanelView.infoLabelFont
        infoLabel.text = "00:00/00:00"
        infoLabel.sizeToFit()
        let temp = infoLabel.frame
        infoLabel.frame = CGRect(x: temp.minX, y: temp.minY, width: temp.width + 6, height: temp.height)
        self.addSubview(infoLabel)
        
        
        let leftWidth = (frame.width - infoLabel.frame.maxX)
        let progressWidth = leftWidth * 0.9
        let progressHeight: CGFloat = 6
        let progressX = infoLabel.frame.maxX + (leftWidth - progressWidth) / 2
        let progressY = (frame.height - progressHeight) / 2
        progress = UIProgressView(frame: CGRect(x: progressX, y: progressY, width: progressWidth, height: progressHeight))
        self.addSubview(progress)
        
    }
    
    func initSubviewContent() {
        self.infoLabel.text = "00:00/00:00"
        self.progress.progress = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
