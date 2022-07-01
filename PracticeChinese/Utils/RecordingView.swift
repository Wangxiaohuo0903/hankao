//
//  RecordingView.swift
//  ChineseLearning
//
//  Created by feiyue on 26/04/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import NVActivityIndicatorView
import UIKit

class RecordingView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        let indicatorView = NVActivityIndicatorView(frame: CGRect(x: ScreenUtils.widthByRate(x: 0.4), y: ScreenUtils.heightByRate(y: 0.5) - ScreenUtils.widthByRate(x: 0.1), width: ScreenUtils.widthByRate(x: 0.2), height: ScreenUtils.widthByRate(x: 0.2)) , type: NVActivityIndicatorType.lineScale, color: UIColor.white, padding: 4)
        addSubview(indicatorView)
        indicatorView.startAnimating()
        
        let textLabel = UILabel(frame: CGRect(x: ScreenUtils.widthByRate(x: 0.1), y: ScreenUtils.heightByRate(y: 0.5) + ScreenUtils.widthByRate(x: 0.1) , width: ScreenUtils.widthByRate(x: 0.8), height: 25))
        textLabel.textColor = UIColor.white
        textLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(18), type: .Regular)
        textLabel.text = "Release or slide up to submit"
        textLabel.textAlignment = .center
        addSubview(textLabel)


    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class RatingView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        let indicatorView = NVActivityIndicatorView(frame: CGRect(x: ScreenUtils.widthByRate(x: 0.4), y: ScreenUtils.heightByRate(y: 0.5) - ScreenUtils.widthByRate(x: 0.1) - 20, width: ScreenUtils.widthByRate(x: 0.2), height: ScreenUtils.widthByRate(x: 0.2)) , type: NVActivityIndicatorType.ballSpinFadeLoader, color: UIColor.white, padding: 4)
        addSubview(indicatorView)
        indicatorView.startAnimating()

        let textLabel = UILabel(frame: CGRect(x: ScreenUtils.widthByRate(x: 0.1), y: ScreenUtils.heightByRate(y: 0.5) + ScreenUtils.widthByRate(x: 0.1) - 20, width: ScreenUtils.widthByRate(x: 0.8), height: 25))
        textLabel.textColor = UIColor.white
        textLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(18), type: .Regular)
        textLabel.text = "Rating..."
        textLabel.textAlignment = .center
        addSubview(textLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
