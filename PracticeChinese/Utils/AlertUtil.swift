//
//  AlertUtil.swift
//  ChineseLearning
//
//  Created by ThomasXu on 15/05/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func alertUserInner(message: String) {
        let alertController: UIAlertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "YES", style: .default, handler: nil)
        alertController.addAction(yesAction)
        alertController.modalPresentationStyle = .fullScreen
        self.present(alertController, animated: true)
    }
    
    func alertUserNetworkError(logMessage: String) {
        alertUserInner(message: "There is something wrong with the network.... ...")
    }
    
    func presentUserNetworkError(logMessage: String) {
        
    }
    
    func presentUserToast(message: String) {
        let toastWidth = ScreenUtils.widthByRate(x: 0.725)
        let toastX = (ScreenUtils.width - toastWidth) / 2
        let toastY = ScreenUtils.heightByRate(y: 0.45) - 64
        let tipFont = FontUtil.getFont(size: 16, type: .Medium)
        let toastView = AppUtil.getSharedToastView(frame: CGRect(x: toastX, y: toastY, width: toastWidth, height: 10))
        toastView.font = tipFont
        toastView.text = message
        toastView.textColor = UIColor.white
        toastView.textAlignment = .center
        toastView.lineBreakMode = .byWordWrapping
        toastView.numberOfLines = 0
        toastView.sizeToFit()
        toastView.frame = CGRect(x: toastX, y: toastY, width: toastWidth, height: toastView.frame.height+10)
        toastView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        toastView.layer.cornerRadius = 8
        toastView.layer.masksToBounds = true
        toastView.alpha = 1.0
        toastView.layer.removeAllAnimations()
        self.view.addSubview(toastView)

        UIView.animate(withDuration: 0.5, delay: 2.2, options: .curveEaseOut , animations: {
            toastView.alpha = 0.0
        }, completion: {(isCompleted) in
            if isCompleted {
            UIView.animate(withDuration: 0.1, delay: 0, options:  .curveEaseOut, animations: { () -> Void in
                    toastView.removeFromSuperview()
                })
            }
        })
    }
    
    func presentUserToast(message: String,toastView:UILabel) {
        if(!self.view.subviews.contains(toastView)){
            let toastWidth = ScreenUtils.widthByRate(x: 0.725)
            let toastX = (ScreenUtils.width - toastWidth) / 2
            let toastY = ScreenUtils.heightByRate(y: 0.45) - 64
            let tipFont = FontUtil.getFont(size: 16, type: .Medium)
            toastView.frame = CGRect(x: toastX, y: toastY, width: toastWidth, height: 10)
            toastView.font = tipFont
            toastView.text = message
            toastView.textColor = UIColor.white
            toastView.textAlignment = .center
            toastView.lineBreakMode = .byWordWrapping
            toastView.numberOfLines = 0
            toastView.sizeToFit()
            toastView.frame = CGRect(x: toastX, y: toastY, width: toastWidth, height: toastView.frame.height+10)
            toastView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            toastView.layer.cornerRadius = 8
            toastView.layer.masksToBounds = true
            toastView.alpha = 1.0
            self.view.addSubview(toastView)
            
            UIView.animate(withDuration: 0.5, delay: 2.5, options: .curveEaseOut , animations: {
                toastView.alpha = 0.0
            }, completion: {(isCompleted) in
                toastView.removeFromSuperview()
            })
        }
    }
    
    func presentUserToast(message: String,toastView:UILabel,range: String) {
        if(!self.view.subviews.contains(toastView)){
            let toastWidth = ScreenUtils.widthByRate(x: 0.725)
            let toastX = (ScreenUtils.width - toastWidth) / 2
            let toastY = ScreenUtils.heightByRate(y: 0.45)
            
            let attributedStrM : NSMutableAttributedString = NSMutableAttributedString()
            
            let rangestring : NSAttributedString = NSAttributedString(string:range, attributes: convertToOptionalNSAttributedStringKeyDictionary([ convertFromNSAttributedStringKey(NSAttributedString.Key.font) : FontUtil.getFont(size: 16, type: .Regular)]))
            let messagestring : NSAttributedString = NSAttributedString(string:message, attributes: convertToOptionalNSAttributedStringKeyDictionary([ convertFromNSAttributedStringKey(NSAttributedString.Key.font) : FontUtil.getFont(size: 16, type: .Regular)]))
            
            attributedStrM.append(rangestring)
            attributedStrM.append(messagestring)
            
            toastView.frame = CGRect(x: toastX, y: toastY, width: toastWidth, height: 10)
            toastView.attributedText = attributedStrM
            toastView.textColor = UIColor.white
            toastView.textAlignment = .center
            toastView.lineBreakMode = .byWordWrapping
            toastView.numberOfLines = 0
            toastView.sizeToFit()
            toastView.frame = CGRect(x: toastX, y: toastY, width: toastWidth, height: toastView.frame.height+10)
            toastView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            toastView.layer.cornerRadius = 8
            toastView.layer.masksToBounds = true
            toastView.alpha = 1.0
            self.view.addSubview(toastView)
            
            UIView.animate(withDuration: 0.5, delay: 2.5, options: .curveEaseOut , animations: {
                toastView.alpha = 0.0
            }, completion: {(isCompleted) in
                toastView.removeFromSuperview()
            })
        }
        
    }
    
    
    func presentUserErrorMessage() {
        var toastView = UILabel()
        presentUserToast(message: "Sorry, there is something wrong with the data...")
    }

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
