//
//  VoiceButton.swift
//  ChineseLearning
//
//  Created by ThomasXu on 21/04/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit


//左边为一个标签，显示需要发声的内容，右边一个图片
class VoiceButtonView: UIView {
    
    var contentLabel: UILabel!
    var voiceView: LCVoiceButton!
    var viewIndex: Int!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.clipsToBounds = false
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.red
        self.setSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSubviews() {
        let voiceWidth: CGFloat = 14
        let temp = ScreenUtils.widthByRate(x: 0.024)
        let voiceX = self.frame.width - temp - voiceWidth
        
        let frame = self.frame
        if nil != self.contentLabel {
            self.contentLabel.removeFromSuperview()
        }
        
        let contentWidth = voiceX
        let contentHeight = frame.height
        let contentTop = (frame.height - contentHeight) / 2
        contentLabel = UILabel(frame: CGRect(x: 0, y: contentTop, width: contentWidth, height: contentHeight))
        contentLabel.font = FontUtil.getFont(size: 22, type: .Regular)
        contentLabel.textColor = UIColor.blueTheme
        contentLabel.textAlignment = .center
        self.addSubview(self.contentLabel)
        
        if nil != self.voiceView {
            self.voiceView.removeFromSuperview()
        }
        let imgTop = (frame.height - voiceWidth) / 2
        voiceView = LCVoiceButton(frame: CGRect(x: voiceX, y: imgTop, width: voiceWidth, height: voiceWidth))
        voiceView.isUserInteractionEnabled = false
        self.addSubview(self.voiceView)
        self.updateToUnselected()
    }
    
    func updateToUnselected() {
        self.backgroundColor = UIColor(0xd4dce9)
        self.contentLabel.textColor = UIColor.blueTheme
     //   self.voiceView.style = .blue
    }
    
    func updateToSelected() {
        self.backgroundColor = UIColor.blueTheme
        self.contentLabel.textColor = UIColor.white
     //   self.voiceView.style = .white
    }
    
}

class VoiceButtonContainer: UIView {
    
    var buttonWidth: CGFloat!
    var buttonHeight: CGFloat!
    var buttonDis: CGFloat!
    var buttonRowDis: CGFloat!
    var layout: [[String]]! {
        didSet {
            self.setButtonWidth()
        }
    }
    
    static var curSelectedIndex: Int! = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setButtonWidth() {
        for row in layout {
            var max = 0
            if row.count > max {
                max = row.count
            }
            if 0 == max {
                return
            }
            if 1 == max {
                max = 4
            }
            buttonWidth = (frame.width - buttonDis * CGFloat(max - 1)) / CGFloat(max)
        }
    }
    
    func setSubviews() -> [VoiceButtonView] {
        var views = [VoiceButtonView]()
        var curY: CGFloat = 0
        var curIndex = 0
        for row in layout {
            var curX :CGFloat = (frame.width - (CGFloat(row.count) * buttonWidth + CGFloat(row.count - 1) * buttonDis)) / 2
            for col in row {
                let button = VoiceButtonView(frame: CGRect(x: curX, y: curY, width: buttonWidth, height: buttonHeight))
                button.contentLabel.text = col
                views.append(button)
                curX += (buttonWidth + buttonDis)
                button.viewIndex = curIndex
                curIndex += 1
                self.addSubview(button)
            }
            curY += (buttonHeight + buttonRowDis)
        }
        return views
    }
    
    func getNewHeight() -> CGFloat {
        let row = self.layout.count
        return CGFloat(row) * buttonHeight + CGFloat(row - 1) * buttonRowDis
    }
}
