//
//  PlayerControlPanelView.swift
//  UIViewTest
//
//  Created by ThomasXu on 19/05/2017.
//  Copyright © 2017 ThomasXu. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol PlayerControlPanelDelegate: class {
    func controlButton()
}

class PlayerControlPanelView: UIView {
    
    var infoLabel: UILabel!
    var progress: UIProgressView!
    var stopButton: UIButton!
    static let infoLabelFont = FontUtil.getFont(size: FontAdjust().FontSize(16), type: .Regular)
    
    weak var delegate: PlayerControlPanelDelegate!
    
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
        infoLabel.font = PlayerControlPanelView.infoLabelFont
        infoLabel.text = "00:00/00:00"
        infoLabel.sizeToFit()
        let temp = infoLabel.frame
        infoLabel.frame = CGRect(x: temp.minX, y: temp.minY, width: temp.width + 6, height: temp.height)
        self.addSubview(infoLabel)
        
        stopButton = UIButton(type: .system)
        let buttonWidth: CGFloat = 40
        let buttonX = frame.width - buttonWidth
        stopButton.frame = CGRect(x: buttonX, y: infoLabel.frame.minY, width: buttonWidth, height: infoLabel.frame.height)
        stopButton.setTitle("start", for: .normal)
        stopButton.titleLabel?.font = PlayerControlPanelView.infoLabelFont
        stopButton.setTitleColor(UIColor.white, for: .normal)
        stopButton.addTarget(self, action: #selector(controlButton), for: .touchDown)
        self.addSubview(stopButton)
        
        let leftWidth = (stopButton.frame.minX - infoLabel.frame.maxX)
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
        self.stopButton.setTitle("Start", for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func controlButton() {
        self.delegate.controlButton()
    }
}
