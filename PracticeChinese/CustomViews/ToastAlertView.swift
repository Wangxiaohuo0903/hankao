//
//  ToastAlertView.swift
//  PracticeChinese
//
//  Created by feiyue on 06/07/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit

class ToastAlertView: UIView {
    var toastView:UILabel!
    static let shared = ToastAlertView()
    private init() {
        
        super.init(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height))
        backgroundColor = UIColor.clear
        let toastWidth = ScreenUtils.widthByRate(x: 0.725)
        let toastX = (ScreenUtils.width - toastWidth) / 2
        let toastY = ScreenUtils.heightByRate(y: 0.5) - 40
        let tipFont = FontUtil.getFont(size: 16, type: .Medium)
        toastView = UILabel(frame: CGRect(x: toastX, y: toastY, width: toastWidth, height: 40))
        toastView.font = tipFont
        toastView.textColor = UIColor.white
        toastView.textAlignment = .center
        toastView.lineBreakMode = .byWordWrapping
        toastView.numberOfLines = 0
        toastView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        toastView.layer.cornerRadius = 8
        toastView.layer.masksToBounds = true
        toastView.alpha = 1.0
    }
    func setText(_ msg:String) {
        toastView.text = msg
        addSubview(toastView)
        bringSubviewToFront(toastView)

    }
    func getLabelWidth(labelStr:String,font:UIFont)->CGFloat{
        let maxSie:CGSize = CGSize(width:ScreenUtils.widthByRate(x: 0.725),height:100)
        return (labelStr as NSString).boundingRect(with: maxSie, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):font]), context: nil).size.width
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    class func show(_ msg:String) {
        let toast = ToastAlertView.shared
        let toastWidth = ToastAlertView.shared.getLabelWidth(labelStr: msg, font: FontUtil.getFont(size: 16, type: .Medium)) + 60
        let toastX = (ScreenUtils.width - toastWidth) / 2
        let toastY = ScreenUtils.heightByRate(y: 0.5) - 40
        toast.toastView.frame = CGRect(x: toastX, y: toastY, width: toastWidth, height: 40)
        toast.setText(msg)
        UIApplication.topViewController()?.view.addSubview(toast)
    }
    
    class func showWillHidden(_ msg:String) {
        let toast = ToastAlertView.shared
        toast.setText(msg)
        UIApplication.topViewController()?.view.addSubview(toast)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.hide()
        }
    }
    class func hide() {
        let toast = ToastAlertView.shared
        var ishas = UIApplication.topViewController()?.view.subviews.contains(toast)
        if(ishas)!{
            toast.removeFromSuperview()
        }
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
