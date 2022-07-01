//
//  ActionSheet+Extension.swift
//  ChineseLearning
//
//  Created by feiyue on 30/03/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showAnswerSheet(message:String, correct: Bool) {
        
        let alertView = UIView(frame: CGRect(x: 0, y: ScreenUtils.height - 128, width: ScreenUtils.width, height: 128))
        alertView.backgroundColor = correct ? UIColor.correctColor : UIColor.wrongColor
        
        let titleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: ScreenUtils.width-20, height: 30))
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        titleLabel.font = FontUtil.getFont(size: 20, type: .Regular)

        alertView.addSubview(titleLabel)
        
        let msgLabel = UILabel(frame: CGRect(x: 10, y: 40, width: ScreenUtils.width-20, height: 20))
        msgLabel.text = message
        msgLabel.textAlignment = .center
        msgLabel.textColor = UIColor.white
        msgLabel.font = FontUtil.getFont(size: 18, type: .Regular)
        alertView.addSubview(msgLabel)
        
        let continueButton = UIButton(frame:CGRect(x: 30, y: 70, width: ScreenUtils.width-60, height: 40))
        continueButton.backgroundColor = UIColor.white
        continueButton.setTitle("Continue", for: .normal)
        continueButton.setTitleColor(correct ? UIColor.correctColor : UIColor.wrongColor, for: .normal)
        continueButton.layer.cornerRadius = 20
        continueButton.layer.masksToBounds = false
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        alertView.addSubview(continueButton)
        self.view.addSubview(alertView)
        self.view.bringSubviewToFront(alertView)
    }
    
    @objc func continueTapped() {
    }
}
