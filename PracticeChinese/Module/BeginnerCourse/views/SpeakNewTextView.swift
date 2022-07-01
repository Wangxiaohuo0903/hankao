//
//  SpeakNewTextView.swift
//  ChineseDev
//
//  Created by summer on 2017/12/12.
//  Copyright © 2017年 msra. All rights reserved.
//

import Foundation
import SnapKit

protocol SpeakNewTextViewDelegate: class {
    func superViewConstraints()
    func tapped()
}

//SFProText-Regular
//PingFangSC-Regular
class SpeakNewTextView: UIView {
    var chineseFontSize:CGFloat = CGFloat(FontAdjust().Speak_ChineseAndPinyin_C())
    var pinyinFontSize:CGFloat = CGFloat(FontAdjust().Speak_ChineseAndPinyin_P())
    var frameHeight:CGFloat!
    var frameWidth:CGFloat!
    var chineseLabel:UILabel!
    var chineseLabelHeight:CGFloat!
    var pinyinLabel:UILabel!
    var pinyinLabelHeight:CGFloat!
    
    var isAblePut:Bool!
    var isChangeAble:Bool!
    var textStyle:newTextStyle!
    var maxFrame:CGRect!
    var delegate:SpeakNewTextViewDelegate!
    var pinyinFontname:String!
    var pinyinFontnameMedium:String!
    var chineseFontname:String!
    var EnglishEnable = false
    
    var chineseExHeight:CGFloat = 10.0
    var pinyinExHeight:CGFloat = 10.0
    var ignoreSetting = false
    
    // other模式下，使用chinese输入
    init(frame: CGRect,chinese: NSAttributedString,chineseSize:CGFloat , pinyin: NSAttributedString,pinyinSize:CGFloat,style:newTextStyle,changeAble:Bool,_ englishEnable:Bool,chineseEx: CGFloat, pinyinEx: CGFloat,_ ignoreSetting: Bool = false) {
        
        super.init(frame: frame)
        self.maxFrame = frame
        self.ignoreSetting = ignoreSetting
        if(changeAble){
            if ignoreSetting {
                self.textStyle = .chineseandpinyin
            }else {
                self.textStyle = newGetTheSystemType()
            }
        }else{
            self.textStyle = style
        }
        self.pinyinExHeight = pinyinEx
        self.chineseExHeight = chineseEx
        self.frameWidth = frame.width
        self.frameHeight = frame.height
        self.chineseFontSize = chineseSize
        self.pinyinFontSize = pinyinSize
        self.isChangeAble = changeAble
        self.EnglishEnable = englishEnable
        self.pinyinFontname = "PingFangSC-Regular"
        self.pinyinFontnameMedium = "PingFangSC-Regular"
        self.chineseFontname = "PingFangSC-Regular"
        chineseLabel = UILabel()
        pinyinLabel = UILabel()
        chineseLabel.attributedText = chinese
        chineseLabel.textAlignment = .center
        chineseLabel.numberOfLines = 0
        self.addSubview(chineseLabel)
        pinyinLabel.attributedText = pinyin

        pinyinLabel.textAlignment = .center
        pinyinLabel.numberOfLines = 0
        self.addSubview(pinyinLabel)

        self.isAblePut = checkFrame(style: self.textStyle)
        changeStyle(style: self.textStyle)
        
        let ges = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.addGestureRecognizer(ges)

    }
    
    init(frame: CGRect,chinese: NSAttributedString,chineseSize:CGFloat , pinyin: NSAttributedString,pinyinSize:CGFloat,style:newTextStyle,changeAble:Bool) {
        
        super.init(frame: frame)
        //print(self.frame)
        self.maxFrame = frame
        if(changeAble){
            if ignoreSetting {
                self.textStyle = .chineseandpinyin
            }else {
                self.textStyle = newGetTheSystemType()
            }
        }else{
            self.textStyle = style
        }
        self.frameWidth = frame.width
        self.frameHeight = frame.height
        self.chineseFontSize = chineseSize
        self.pinyinFontSize = pinyinSize
        self.isChangeAble = changeAble
        self.pinyinFontname = "PingFangSC-Regular"
        self.pinyinFontnameMedium = "PingFangSC-Regular"
        self.chineseFontname = "PingFangSC-Regular"
        chineseLabel = UILabel()
        pinyinLabel = UILabel()
        
        chineseLabel.attributedText = chinese
        chineseLabel.textAlignment = .center
        chineseLabel.numberOfLines = 0
        self.addSubview(chineseLabel)
        
        pinyinLabel.attributedText = pinyin
        pinyinLabel.textAlignment = .center
        pinyinLabel.numberOfLines = 0
        self.addSubview(pinyinLabel)

        self.isAblePut = checkFrame(style: self.textStyle)
        changeStyle(style: self.textStyle)
        
        let ges = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.addGestureRecognizer(ges)

        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    }
    func refresh(chinese: NSAttributedString,chineseSize:CGFloat , pinyin: NSAttributedString,pinyinSize:CGFloat,_ englishEnable:Bool) {
        chineseLabel.attributedText = chinese
        pinyinLabel.attributedText = pinyin
        EnglishEnable = englishEnable
        self.chineseFontSize = chineseSize
        self.pinyinFontSize = pinyinSize
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        
        systemAutoChangeWithoutFrame()
    }
    
    func refreshFont(chineseSize:CGFloat ,pinyinSize:CGFloat,chineseColor:UIColor,pinyinColor:UIColor) {
        self.chineseFontSize = chineseSize
        chineseLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(Double(self.chineseFontSize)), type: .Regular)
        self.pinyinFontSize = pinyinSize
        switch UserDefaults.standard.integer(forKey: UserDefaultsKeyManager.chineseandpinyin) {
        case 0:
            pinyinLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(Double(self.pinyinFontSize)), type: .Regular)
        case 1:
            pinyinLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(Double(self.pinyinFontSize)), type: .Regular)
        case 2:
            pinyinLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(Double(self.chineseFontSize)), type: .Regular)
        default:
            pinyinLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(Double(self.pinyinFontSize)), type: .Regular)
        }
        self.setLabelColor(chinese: chineseColor, pinyin: pinyinColor)
    }
    func systemAutoChangeWithoutFrame(){
        var style = newGetTheSystemType()
        if ignoreSetting {
            style = .chineseandpinyin
        }
        self.frame = self.maxFrame
        self.isAblePut = checkFrame(style:style)
        self.textStyle = style
        changeStyle(style:style)
    }
    
    func autoChangeWithoutFrame(style:newTextStyle) {
        self.frame = self.maxFrame
        self.isAblePut = checkFrame(style:style)
        self.textStyle = style
        changeStyle(style:style)
    }
    
    func checkFrame(style:newTextStyle) -> Bool{
        if EnglishEnable {
            pinyinLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(Double(pinyinFontSize)), type: .Regular)
            self.pinyinLabelHeight = getLabelheight(labelStr: pinyinLabel.text!, font: pinyinLabel.font)
            if(pinyinLabelHeight >= self.frame.height){
                self.frameHeight = self.frame.height
                return false
            }else{
                self.frameHeight = pinyinLabelHeight + pinyinExHeight
                return true
            }
        }
        switch style {
        case .chinese,.other:
            chineseLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(Double(chineseFontSize)), type: .Regular)
            var exHeight = chineseExHeight
            if chineseExHeight == 0 {
                exHeight = -4
            }
            self.chineseLabelHeight = getLabelheight(labelStr: chineseLabel.text!, font: chineseLabel.font) + exHeight
            self.frameHeight = chineseLabelHeight
            return true
        case .pinyin:
            pinyinLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(Double(pinyinFontSize)), type: .Regular)
            self.pinyinLabelHeight = getLabelheight(labelStr: pinyinLabel.text!, font: pinyinLabel.font) + pinyinExHeight
            self.frameHeight = pinyinLabelHeight
            return true
        
        case .chineseandpinyin:
            pinyinLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(Double(pinyinFontSize)), type: .Regular)
            chineseLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(Double(chineseFontSize)), type: .Regular)
            var exHeight = chineseExHeight/2
            var expinyinHeight = 2.0
            var exFrameHeight = chineseExHeight/2
            if chineseExHeight == 0 {
                exHeight = 6.0
                expinyinHeight = 2.0
                exFrameHeight = 3
            }
            self.chineseLabelHeight = getLabelheight(labelStr: chineseLabel.text!, font: chineseLabel.font) - exHeight
            self.pinyinLabelHeight = getLabelheight(labelStr: pinyinLabel.text!, font: pinyinLabel.font) - CGFloat(expinyinHeight)
            self.frameHeight = pinyinLabelHeight + chineseLabelHeight + pinyinExHeight + exFrameHeight
            return true
        }

    }
    
    func changeStyle(style:newTextStyle) {
        switch style {
        case .chinese,.other:
            pinyinLabel.isHidden = true
            chineseLabel.isHidden = false
            chineseLabel.snp.remakeConstraints { (make) -> Void in
                make.left.right.equalTo(self)
                make.top.bottom.equalTo(self).offset(0)
            }
            pinyinLabel.snp.remakeConstraints { (make) -> Void in
                make.left.right.equalTo(self)
                make.top.bottom.equalTo(self).offset(0)
            }
        case .pinyin:
            pinyinLabel.isHidden = false
            chineseLabel.isHidden = true
            chineseLabel.snp.remakeConstraints { (make) -> Void in
                make.left.right.equalTo(self)
                make.top.bottom.equalTo(self).offset(0)
            }
            pinyinLabel.snp.remakeConstraints { (make) -> Void in
                make.left.right.equalTo(self)
                make.top.bottom.equalTo(self).offset(0)
            }
        case .chineseandpinyin:
            pinyinLabel.isHidden = false
            chineseLabel.isHidden = false

            chineseLabel.snp.remakeConstraints { (make) -> Void in
                make.left.right.equalTo(self)
                if chineseExHeight == 0{
                    make.bottom.equalTo(self).offset(0)
                }else {
                    make.bottom.equalTo(self).offset(-chineseExHeight/2)
                }
                make.height.equalTo(chineseLabelHeight)
            }
            pinyinLabel.snp.remakeConstraints { (make) -> Void in
                make.top.equalTo(self).offset(pinyinExHeight/2)
                make.left.right.equalTo(self)
                make.height.equalTo(pinyinLabelHeight)
            }
        }
    }
    
    func getLabelWidth(labelStr:String,font:UIFont)->CGFloat{
        let maxSie:CGSize = CGSize(width:.greatestFiniteMagnitude,height:self.frame.height)
        return (labelStr as NSString).boundingRect(with: maxSie, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):font]), context: nil).size.width
    }
    
    func getLabelheight(labelStr:String,font:UIFont)->CGFloat{
        let maxSie:CGSize = CGSize(width:self.frame.width,height:.greatestFiniteMagnitude)
        return (labelStr as NSString).boundingRect(with: maxSie, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):font]), context: nil).size.height
    }
    
    func setLabelTextAli(chinese:NSTextAlignment,pinyin:NSTextAlignment) {
        chineseLabel.textAlignment = chinese
        pinyinLabel.textAlignment = pinyin
    }
    
    func setLabelFont(chinese:String,pinyin:String,textStyle:newTextStyle){
        self.chineseFontname = chinese
        self.pinyinFontname = pinyin
        if(self.isChangeAble){
            if ignoreSetting {
                self.textStyle = .chineseandpinyin
            }else {
                self.textStyle = newGetTheSystemType()
            }
        }else{
            self.textStyle = textStyle
        }
        self.autoChangeWithoutFrame(style: self.textStyle)
    }
    
    func setLabelText(chinese:String,pinyin:String,textStyle:newTextStyle){
        if(self.isChangeAble){
            if ignoreSetting {
                self.textStyle = .chineseandpinyin
            }else {
                self.textStyle = newGetTheSystemType()
            }
        }else{
            self.textStyle = textStyle
        }
        self.chineseLabel.text = chinese
        self.pinyinLabel.text = pinyin
        self.autoChangeWithoutFrame(style: self.textStyle)
    }
    
    func setLabelColor(chinese:UIColor,pinyin:UIColor){
        self.chineseLabel.textColor = chinese
        self.pinyinLabel.textColor = pinyin
    }
    
    func testify() {
        
        if(self.isAblePut){
            //print("@@@@放得下")
        }else{
            //print("@@@@放不下")
        }
    }
    
    func changeValue(){
        switch self.textStyle! {
        case .chineseandpinyin:
            autoChangeWithoutFrame(style:.chinese)
        case .chinese,.other:
            autoChangeWithoutFrame(style:.pinyin)
        case .pinyin:
            autoChangeWithoutFrame(style:.chineseandpinyin)
        }
    }
    
    @objc func tapped() {
        if(self.isChangeAble){
            self.delegate.tapped()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
