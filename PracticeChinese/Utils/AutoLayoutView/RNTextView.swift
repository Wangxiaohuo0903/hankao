//
//  RNTextView.swift
//  ChineseDev
//
//  Created by Temp on 2018/7/16.
//  Copyright © 2018年 msra. All rights reserved.
//

import Foundation
import SnapKit

protocol RNTextViewDelegate: class {
    func superViewConstraints()
    func tapped()
}


//SFProText-Medium
//PingFangSC-Medium
class RNTextView: UIView {
    var chineseFontSize:CGFloat = CGFloat(FontAdjust().Option_ChineseAndPinyin_C())
    var pinyinFontSize:CGFloat = CGFloat(FontAdjust().Option_ChineseAndPinyin_P())
    var frameHeight:CGFloat!
    var frameWidth:CGFloat!
    var chineseLabel:UILabel!
    var chineseLabelHeight:CGFloat!
    var pinyinLabel:UILabel!
    var pinyinLabelHeight:CGFloat!
    var isAblePut:Bool!
    var isChangeAble:Bool!
    var textStyle:textStyle!
    var maxFrame:CGRect!
    var delegate:RNTextViewDelegate!
    var pinyinFontname:String!
    var pinyinFontnameMedium:String!
    var chineseFontname:String!
    var pinyinFontRegular = false
    // other模式下，使用chinese输入
    init(frame: CGRect,chinese: String,chineseSize:CGFloat , pinyin: String,pinyinSize:CGFloat,style:textStyle,changeAble:Bool,pinyinFontRegular:Bool) {
        
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.maxFrame = frame
        self.pinyinFontRegular = pinyinFontRegular
        if(changeAble){
            self.textStyle = getTheSystemType()
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
        
        chineseLabel.textColor = UIColor.black
        chineseLabel.text = chinese
        chineseLabel.textAlignment = .center
        chineseLabel.numberOfLines = 0
//        chineseLabel.lineBreakMode = .byTruncatingTail
//                chineseLabel.backgroundColor = UIColor.red
        self.addSubview(chineseLabel)
        
        pinyinLabel.text = pinyin
        pinyinLabel.textAlignment = .center
        pinyinLabel.numberOfLines = 0
        pinyinLabel.textColor = UIColor.learingColor
        self.addSubview(pinyinLabel)
        
        self.isAblePut = checkFrame(style: self.textStyle)
        changeStyle(style: self.textStyle)
        
        let ges = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.addGestureRecognizer(ges)
    }
    
    init(frame: CGRect,chinese: NSAttributedString,chineseSize:CGFloat , pinyin: NSAttributedString,pinyinSize:CGFloat,style:textStyle,changeAble:Bool,pinyinFontRegular:Bool) {
        
        super.init(frame: frame)
        self.maxFrame = frame
        if(changeAble){
            self.textStyle = getTheSystemType()
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
//        chineseLabel.lineBreakMode = .byTruncatingTail
        self.addSubview(chineseLabel)
        
        pinyinLabel.attributedText = pinyin
        pinyinLabel.textAlignment = .center
        pinyinLabel.numberOfLines = 0
//        pinyinLabel.lineBreakMode = .byTruncatingTail
        self.addSubview(pinyinLabel)
        
        
        
        self.isAblePut = checkFrame(style: self.textStyle)
        changeStyle(style: self.textStyle)
        
        let ges = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.addGestureRecognizer(ges)
    }
    
    func systemAutoChangeWithoutFrame(){
        var style = getTheSystemType()
        self.frame = self.maxFrame
        if(self.isChangeAble){
            self.isAblePut = checkFrame(style:style)
            self.textStyle = style
            changeStyle(style:style)
        }
    }
    
    func autoChangeWithoutFrame(style:textStyle) {
        self.frame = self.maxFrame
        if(self.isChangeAble){
            self.isAblePut = checkFrame(style:style)
            self.textStyle = style
            changeStyle(style:style)
        }
    }
    
    func checkFrame(style:textStyle) -> Bool{
        switch style {
        case .chinese,.other:
            chineseLabel.font = UIFont(name: self.chineseFontname, size: FontAdjust().FontSize(Double(chineseFontSize)))
            self.chineseLabelHeight = getLabelheight(labelStr: chineseLabel.text!, font: chineseLabel.font)
            if(chineseLabelHeight >= self.frame.height){
                self.frameHeight = self.frame.height
                return false
            }else{
                self.frameHeight = chineseLabelHeight
                return true
            }
        case .pinyin:
            pinyinLabel.font = UIFont(name: self.pinyinFontname, size: FontAdjust().FontSize(Double(chineseFontSize)))
            self.pinyinLabelHeight = getLabelheight(labelStr: pinyinLabel.text!, font: pinyinLabel.font)
            if(pinyinLabelHeight >= self.frame.height){
                self.frameHeight = self.frame.height
                return false
            }else{
                self.frameHeight = pinyinLabelHeight
                return true
            }
        case .chineseandpinyin:
            pinyinLabel.font = UIFont(name: self.pinyinFontnameMedium, size: FontAdjust().FontSize(Double(pinyinFontSize)))
            chineseLabel.font = UIFont(name: self.chineseFontname, size: FontAdjust().FontSize(Double(chineseFontSize)))
            self.chineseLabelHeight = getLabelheight(labelStr: chineseLabel.text!, font: chineseLabel.font)
            self.pinyinLabelHeight = getLabelheight(labelStr: pinyinLabel.text!, font: pinyinLabel.font)
            if(chineseLabelHeight + pinyinLabelHeight >= self.frame.height){
                self.frameHeight = self.frame.height
                
                self.pinyinLabelHeight = pinyinFontSize
                self.chineseLabelHeight = chineseFontSize
                return false
            }else{
                self.frameHeight = pinyinLabelHeight + chineseLabelHeight
                return true
            }
        }
    }
    
    func changeStyle(style:textStyle) {
        switch style {
        case .chinese,.other:
            pinyinLabel.isHidden = true
            chineseLabel.isHidden = false
            chineseLabel.snp.remakeConstraints { (make) -> Void in
                make.left.right.top.bottom.equalTo(self)
            }
            pinyinLabel.snp.remakeConstraints { (make) -> Void in
                make.left.right.top.bottom.equalTo(self)
            }
        case .pinyin:
            pinyinLabel.isHidden = false
            chineseLabel.isHidden = true
            chineseLabel.snp.remakeConstraints { (make) -> Void in
                make.left.right.top.bottom.equalTo(self)
            }
            pinyinLabel.snp.remakeConstraints { (make) -> Void in
                make.left.right.top.bottom.equalTo(self)
            }
        case .chineseandpinyin:
            pinyinLabel.isHidden = false
            chineseLabel.isHidden = false
            if(self.isAblePut){
                chineseLabel.snp.remakeConstraints { (make) -> Void in
                    make.left.right.equalTo(self)
                    make.top.equalTo(self.snp.centerY).offset((pinyinLabelHeight - chineseLabelHeight)/2)
                    make.height.equalTo(chineseLabelHeight)
                }
                pinyinLabel.snp.remakeConstraints { (make) -> Void in
                    make.left.right.equalTo(self)
                    make.bottom.equalTo(self.snp.centerY).offset((pinyinLabelHeight - chineseLabelHeight)/2)
                    make.height.equalTo(pinyinLabelHeight)
                }
            }else{
                chineseLabel.snp.remakeConstraints { (make) -> Void in
                    make.left.right.bottom.equalTo(self)
                    make.top.equalTo(pinyinLabel.snp.bottom)
                    make.height.equalTo(chineseLabelHeight)
                }
                pinyinLabel.snp.remakeConstraints { (make) -> Void in
                    make.left.right.top.equalTo(self)
                    make.bottom.equalTo(chineseLabel.snp.top)
                    make.height.equalTo(pinyinLabelHeight)
                }
            }
        }
    }
    
    func getLabelWidth(labelStr:String,font:UIFont)->CGFloat{
        let maxSie:CGSize = CGSize(width:.greatestFiniteMagnitude,height:self.frame.height)
        return (labelStr as NSString).boundingRect(with: maxSie, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):font]), context: nil).size.width
    }
    
    func getLabelheight(labelStr:String,font:UIFont)->CGFloat{
        let maxSie:CGSize = CGSize(width:self.frame.width,height:.greatestFiniteMagnitude)
        return (labelStr as NSString).boundingRect(with: maxSie, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):font]), context: nil).size.height + 4
    }
    
    func setLabelTextAli(chinese:NSTextAlignment,pinyin:NSTextAlignment) {
        chineseLabel.textAlignment = chinese
        pinyinLabel.textAlignment = pinyin
    }
    
    func setLabelFont(chinese:String,pinyin:String,textStyle:textStyle){
        self.chineseFontname = chinese
        self.pinyinFontname = pinyin
        if(self.isChangeAble){
            self.textStyle = getTheSystemType()
        }else{
            self.textStyle = textStyle
        }
        self.autoChangeWithoutFrame(style: self.textStyle)
    }
    
    func setLabelText(chinese:String,pinyin:String,textStyle:textStyle){
        if(self.isChangeAble){
            self.textStyle = getTheSystemType()
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
