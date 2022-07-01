//
//  NewTextView.swift
//  ChineseDev
//
//  Created by summer on 2017/12/12.
//  Copyright © 2017年 msra. All rights reserved.
//

import Foundation
import SnapKit

protocol NewTextViewDelegate: class {
    func superViewConstraints()
    func tapped()
}

enum newTextStyle {
    case chinese
    case pinyin
    case chineseandpinyin
    case other
}


func newGetTheSystemType() -> newTextStyle{
    switch UserDefaults.standard.integer(forKey: UserDefaultsKeyManager.chineseandpinyin) {
    case 0:
        return .chineseandpinyin
    case 1:
        return .chinese
    case 2:
        return .pinyin
    default:
        return .other
    }
}

func newSetTheSystemType(style:textStyle){
    switch style {
    case .chineseandpinyin:
        UserDefaults.standard.set(Int(0), forKey: UserDefaultsKeyManager.chineseandpinyin)
    case .chinese:
        UserDefaults.standard.set(Int(1), forKey: UserDefaultsKeyManager.chineseandpinyin)
    case .pinyin:
        UserDefaults.standard.set(Int(2), forKey: UserDefaultsKeyManager.chineseandpinyin)
    default:
        UserDefaults.standard.set(Int(3), forKey: UserDefaultsKeyManager.chineseandpinyin)
    }
    UserDefaults.standard.synchronize()
}

//SFProText-Regular
//PingFangSC-Regular
class NewTextView: UIView {
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
    var textStyle:newTextStyle!
    var maxFrame:CGRect!
    var delegate:NewTextViewDelegate!
    var pinyinFontname:String!
    var pinyinFontnameMedium:String!
    var chineseFontname:String!
    var EnglishEnable = false
    // other模式下，使用chinese输入
    init(frame: CGRect,chinese: String,chineseSize:CGFloat , pinyin: String,pinyinSize:CGFloat,style:newTextStyle,changeAble:Bool,_ englishEnable:Bool) {
        
        super.init(frame: frame)
        self.maxFrame = frame
        if(changeAble){
            self.textStyle = newGetTheSystemType()
        }else{
            self.textStyle = style
        }
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
        
        chineseLabel.textColor = UIColor.black
        chineseLabel.text = chinese
        if chinese.isEqual("#") {
            chineseLabel.text = ""
        }
        chineseLabel.textAlignment = .center
        chineseLabel.numberOfLines = 0
        self.addSubview(chineseLabel)
        pinyinLabel.text = pinyin
        if pinyin.isEqual("#") {
            pinyinLabel.text = ""
        }
        pinyinLabel.textAlignment = .center
        pinyinLabel.numberOfLines = 0
        pinyinLabel.textColor = UIColor.learingColor
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
            self.textStyle = newGetTheSystemType()
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
    func refresh(chinese: String,chineseSize:CGFloat , pinyin: String,pinyinSize:CGFloat,_ englishEnable:Bool) {
        chineseLabel.text = chinese
        pinyinLabel.text = pinyin
        EnglishEnable = englishEnable
        self.chineseFontSize = chineseSize
        self.pinyinFontSize = pinyinSize
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
        let style = newGetTheSystemType()
        self.frame = self.maxFrame
//        if(self.isChangeAble){
            self.isAblePut = checkFrame(style:style)
            self.textStyle = style
            changeStyle(style:style)
//        }
    }
    
    func autoChangeWithoutFrame(style:newTextStyle) {
        self.frame = self.maxFrame
//        if(self.isChangeAble){
            self.isAblePut = checkFrame(style:style)
            self.textStyle = style
            changeStyle(style:style)
//        }
    }
    
    func checkFrame(style:newTextStyle) -> Bool{
        if EnglishEnable {
            pinyinLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(Double(pinyinFontSize)), type: .Regular)
            self.pinyinLabelHeight = getLabelheight(labelStr: pinyinLabel.text!, font: pinyinLabel.font)
            if(pinyinLabelHeight >= self.frame.height){
                self.frameHeight = self.frame.height
                return false
            }else{
                self.frameHeight = pinyinLabelHeight + 2
                return true
            }
        }
        switch style {
        case .chinese,.other:
            chineseLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(Double(chineseFontSize)), type: .Regular)
            self.chineseLabelHeight = getLabelheight(labelStr: chineseLabel.text!, font: chineseLabel.font)
            if(chineseLabelHeight >= self.frame.height){
                self.frameHeight = self.frame.height
                return false
            }else{
                self.frameHeight = chineseLabelHeight + 2
                return true
            }
        case .pinyin:
            pinyinLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(Double(pinyinFontSize)), type: .Regular)
            self.pinyinLabelHeight = getLabelheight(labelStr: pinyinLabel.text!, font: pinyinLabel.font)
            if(pinyinLabelHeight >= self.frame.height){
                self.frameHeight = self.frame.height
                return false
            }else{
                self.frameHeight = pinyinLabelHeight + 2
                return true
            }
        case .chineseandpinyin:
            pinyinLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(Double(pinyinFontSize)), type: .Regular)
            chineseLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(Double(chineseFontSize)), type: .Regular)
            self.chineseLabelHeight = getLabelheight(labelStr: chineseLabel.text!, font: chineseLabel.font)
            self.pinyinLabelHeight = getLabelheight(labelStr: pinyinLabel.text!, font: pinyinLabel.font)
            if(chineseLabelHeight + pinyinLabelHeight >= self.frame.height){
                self.frameHeight = self.frame.height
                self.pinyinLabelHeight = pinyinFontSize + 2
                self.chineseLabelHeight = chineseFontSize + 2
                return false
            }else{
                self.frameHeight = pinyinLabelHeight + chineseLabelHeight + 4
                return true
            }
        }

    }
    
    func changeStyle(style:newTextStyle) {
        if EnglishEnable {
            pinyinLabel.isHidden = false
            chineseLabel.isHidden = true
            chineseLabel.snp.remakeConstraints { (make) -> Void in
                make.left.right.top.bottom.equalTo(self)
            }
            pinyinLabel.snp.remakeConstraints { (make) -> Void in
                make.left.right.top.bottom.equalTo(self)
            }
            return
        }
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
                    make.height.equalTo(chineseLabelHeight + 1)
                }
                pinyinLabel.snp.remakeConstraints { (make) -> Void in
                    make.left.right.equalTo(self)
                    make.bottom.equalTo(self.snp.centerY).offset((pinyinLabelHeight - chineseLabelHeight)/2)
                    make.height.equalTo(pinyinLabelHeight + 1)
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
//            if pinyinLabel.text == "" {
//                pinyinLabel.isHidden = true
//                chineseLabel.isHidden = false
//                chineseLabel.snp.remakeConstraints { (make) -> Void in
//                    make.left.right.top.bottom.equalTo(self)
//                }
//                pinyinLabel.snp.remakeConstraints { (make) -> Void in
//                    make.left.right.top.bottom.equalTo(self)
//                }
//            }
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
            self.textStyle = newGetTheSystemType()
        }else{
            self.textStyle = textStyle
        }
        self.autoChangeWithoutFrame(style: self.textStyle)
    }
    
    func setLabelText(chinese:String,pinyin:String,textStyle:newTextStyle){
        if(self.isChangeAble){
            self.textStyle = newGetTheSystemType()
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
