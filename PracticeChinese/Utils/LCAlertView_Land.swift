//
//  LCAlertView_Land.swift
//  ChineseLearning
//
//  Created by feiyue on 30/03/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView
import YYText

enum LCAlertLandStyle {
    case center
    case oneButton
    case image
    case imageBack
}

class LCAlertView_Land:UIView {
    var titleLabel: UILabel!
    var msgLabel: UITextView!
    var blueButton: UIButton!
    var grayButton: UIButton!
    var centerImage: UIImageView!
    var label: YYLabel!
    
    var blurView:UIView!
    var canvasView:UIView!
    var indicatorView:NVActivityIndicatorView!
    var leftAction:()->() = {}
    var rightAction:()->() = {}
    var disapperAction:()->() = {}
    
    public class var shared: LCAlertView_Land {
        struct Singleton {
            static let instance = LCAlertView_Land(frame: CGRect.zero)
        }
        return Singleton.instance
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func containerView() -> UIView? {
        return UIApplication.shared.keyWindow
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public class func show(title:String, message:String, leftTitle:String, rightTitle:String, style:LCAlertLandStyle, leftAction:@escaping ()->(), rightAction:@escaping ()->(), disapperAction:@escaping ()->()) {
        let footer = LCAlertView_Land.shared
        footer.leftAction = leftAction
        footer.rightAction = rightAction
        footer.disapperAction = disapperAction
        footer.setupContent(title: title, message: message, leftTitle: leftTitle, rightTitle: rightTitle, style: style)
        footer.containerView()?.addSubview(footer.blurView)
        
    }
    
    func setupContent(title:String, message:String, leftTitle:String, rightTitle:String, style:LCAlertLandStyle) {
        
        //蒙版
        blurView = UIView(frame:CGRect(x:0, y:0, width:ScreenUtils.width, height:ScreenUtils.height))
        blurView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        blurView.isUserInteractionEnabled  = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.disappearTapped(gesture:)))
        blurView.addGestureRecognizer(tap)

        //白色提示框
        if(AdjustGlobal().isiPad){
            canvasView = UIView(frame:CGRect(x:ScreenUtils.widthByRate(x: 0.25), y:ScreenUtils.heightByRate(y: 0.4) - 64, width:ScreenUtils.widthByRate(x: 0.5), height:270))
        }else{
            canvasView = UIView(frame:CGRect(x:ScreenUtils.widthByRate(x: 0.1), y:ScreenUtils.heightByRate(y: 0.4) - 64, width:ScreenUtils.widthByRate(x: 0.8), height:220))
        }
        canvasView.layer.cornerRadius = 12.5
        canvasView.layer.masksToBounds = true
        canvasView.backgroundColor = UIColor.white
        blurView.addSubview(canvasView)
        var baseFrame = canvasView.frame
        
        if style == .image || style == .imageBack {
            canvasView.frame = CGRect(x:(ScreenUtils.width - 275)/2, y:ScreenUtils.heightByRate(y: 0.4) - 100, width:275, height:275 * 1503 / 1650)
            centerImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 275, height: 275 * 1503 / 1650))
            
            if style == .imageBack {
                centerImage.image = UIImage(named: "popupBack")
            }else {
                centerImage.image = UIImage(named: "popup")
            }
            canvasView.addSubview(centerImage)
            canvasView.backgroundColor = UIColor.clear
            let labelWidth = getLabelWidth(labelStr: "You earned \(message) point.", font: FontUtil.getFont(size: FontAdjust().FontSize(Double(16)), type: .Regular)) + 40
            self.label = YYLabel()
            label.isUserInteractionEnabled = false
            label.numberOfLines = 0
            label.textVerticalAlignment = .center
            label.frame = CGRect(x: (275 - labelWidth)/2, y: 275 * 1503 / 1650 - 55, width: labelWidth, height: 30)
            
            self.addSubview(label)
            let attributedString1 =  NSMutableAttributedString(string: "You earned ", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.textGray, convertFromNSAttributedStringKey(NSAttributedString.Key.font) : FontUtil.getFont(size: 16, type: .Regular)]))
            let attributedString2 =  NSMutableAttributedString(string: " \(message) ", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.hex(hex: "FFAC1A"), convertFromNSAttributedStringKey(NSAttributedString.Key.font) : FontUtil.getFont(size: 16, type: .Regular)]))
            let attributedString3 =  NSMutableAttributedString(string: " point.", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.textGray, convertFromNSAttributedStringKey(NSAttributedString.Key.font) : FontUtil.getFont(size: 16, type: .Regular)]))
            
            let text = NSMutableAttributedString()
            let font = FontUtil.getFont(size: 16, type: .Regular)
            let attachment: NSMutableAttributedString?
            
            let image = UIImage(named: "sunNew")
            attachment = NSMutableAttributedString.yy_attachmentString(withContent: image, contentMode: UIView.ContentMode.center, attachmentSize: (image?.size)!, alignTo: font, alignment: .center)
            text.append(attributedString1)
            text.append(attributedString2)
            text.append(attachment!)
            text.append(attributedString3)
            label.attributedText = text
            canvasView.addSubview(label)
            
            return
        }
        
        
        //title
        var msgY = CGFloat(15.0)
        if title != "" {
            titleLabel = UILabel(frame: CGRect(x: 0, y: 20, width: baseFrame.width, height: FontUtil.getTextFont().lineHeight))
            titleLabel.text = title
            titleLabel.textAlignment = .center
            titleLabel.textColor = UIColor.textBlack333
            titleLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(16), type:.Bold)
            canvasView.addSubview(titleLabel)
            msgY = CGFloat(titleLabel.frame.maxY)
        }
        
        //提示内容
        let msgLabelWidth = baseFrame.width  - 30
         msgLabel = UITextView(frame: CGRect(x: 15, y: msgY, width: msgLabelWidth, height: baseFrame.height * 0.5))
         msgLabel.text = message
         msgLabel.textAlignment = .center
         msgLabel.textColor = UIColor.textBlack333
         msgLabel.isScrollEnabled = false
         msgLabel.isEditable = false
         msgLabel.isSelectable = false
         msgLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(14), type:.Regular)
        if message != "" {
            let text = NSMutableAttributedString(string: message)
            text.yy_setFont(FontUtil.getFont(size: FontAdjust().FontSize(14), type:.Regular), range: text.yy_rangeOfAll())
            //字体
            text.yy_lineSpacing = 5;
            text.yy_setAlignment(.center, range: text.yy_rangeOfAll())
            text.yy_setMaximumLineHeight(18, range: text.yy_rangeOfAll())
            text.yy_color = UIColor.textBlack333
            msgLabel.attributedText = text
        }
         msgLabel.sizeToFit()
         msgLabel.frame = CGRect(x: msgLabel.frame.minX, y: msgLabel.frame.minY, width: msgLabelWidth, height: msgLabel.frame.height)
         canvasView.addSubview(msgLabel)
        
        //按钮
        var buttonY = msgLabel.frame.maxY + 5
        let buttonHeight:CGFloat = 44
        blueButton = UIButton(frame:CGRect(x: baseFrame.width * 0.06 , y: buttonY, width: baseFrame.width * 0.4, height: buttonHeight))
        blueButton.backgroundColor = UIColor.white
        blueButton.titleLabel?.font = FontUtil.alertTitleFont()
        
        blueButton.setBackgroundImage(UIImage.fromColor(color: UIColor.blueTheme), for: .normal)
        blueButton.setTitle(leftTitle, for: .normal)
        blueButton.setTitleColor(UIColor.white, for: .normal)
        blueButton.setTitleColor(UIColor.white, for: .highlighted)
        blueButton.layer.borderColor = UIColor.clear.cgColor
        blueButton.layer.borderWidth = 1

        blueButton.layer.cornerRadius = buttonHeight / 2
        blueButton.layer.masksToBounds = true
        blueButton.addTarget(self, action: #selector(leftTapped), for: .touchUpInside)
        canvasView.addSubview(blueButton)
        
        
        //取消按钮
        grayButton = UIButton(frame:CGRect(x: baseFrame.width * 0.54 , y: buttonY, width: baseFrame.width * 0.4, height: buttonHeight))
        grayButton.backgroundColor = UIColor.white
        grayButton.titleLabel?.font = FontUtil.alertTitleFont()
        
        grayButton.layer.borderColor = UIColor.clear.cgColor
        grayButton.setBackgroundImage(UIImage.fromColor(color: UIColor.colorFromRGB(224, 224, 224, 1)), for: .normal)

        grayButton.setTitle(rightTitle, for: .normal)
        grayButton.setTitleColor(UIColor.darkGray, for: .normal)
        grayButton.setTitleColor(UIColor.white, for: .highlighted)
        grayButton.layer.borderWidth = 1

        grayButton.layer.cornerRadius = buttonHeight / 2
        grayButton.layer.masksToBounds = true
        grayButton.addTarget(self, action: #selector(rightTapped), for: .touchUpInside)
        canvasView.addSubview(grayButton)
        blueButton.frame = CGRect(x: baseFrame.width * 0.54 , y: buttonY, width: baseFrame.width * 0.4, height: buttonHeight)
        grayButton.frame = CGRect(x: baseFrame.width * 0.06 , y: buttonY, width: baseFrame.width * 0.4, height: buttonHeight)
        
        if style == .center {
            let alertHeight = buttonY + buttonHeight + 20
            canvasView.frame = CGRect(x: canvasView.frame.minX, y: (ScreenUtils.height - alertHeight)/2, width: canvasView.frame.width, height: alertHeight)
        }

        if(style == .oneButton){
            let alertHeight = buttonY + buttonHeight + 20
            canvasView.frame = CGRect(x: canvasView.frame.minX, y: (ScreenUtils.height - alertHeight)/2, width: canvasView.frame.width, height: alertHeight)
            grayButton.isHidden = true
            blueButton.frame = CGRect(x: baseFrame.width * 0.29 , y: buttonY, width: baseFrame.width * 0.4, height: buttonHeight)
        }
       
    }
    func getLabelWidth(labelStr:String,font:UIFont)->CGFloat{
        let labelHeight = ScreenUtils.height
        let maxSie:CGSize = CGSize(width:ScreenUtils.width,height:labelHeight)
        return (labelStr as String).boundingRect(with: maxSie, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):font]), context: nil).size.width
    }
    @objc func leftTapped() {
        self.leftAction()
    }
    
    @objc func rightTapped() {
        self.rightAction()
    }
    
    @objc func disappearTapped(gesture: UITapGestureRecognizer) {
        self.disapperAction()
    }
    
    class func hide() {
        let footer = LCAlertView_Land.shared

        footer.blurView.removeFromSuperview()
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
