//
//  TextView.swift
//  ChineseDev
//
//  Created by summer on 2017/12/12.
//  Copyright © 2017年 msra. All rights reserved.
//

import Foundation
import SnapKit

let FontSizeAddition:CGFloat = 0

protocol TextViewDelegate: class {
    func superViewConstraints()
    func tapped()
}

enum textStyle {
    case chinese
    case pinyin
    case chineseandpinyin
    case other
    
}


func getTheSystemType() -> textStyle{
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

func setTheSystemType(style:textStyle){
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

//SFProText-Medium
//PingFangSC-Medium
class TextView: UIView {
    var chineseFontSize:CGFloat = 20 + FontSizeAddition
    var pinyinFontSize:CGFloat = 18 + FontSizeAddition
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
    var delegate:TextViewDelegate!
    var pinyinFontname:String!
    var chineseFontname:String!
    var exHeight:CGFloat = 2
    // other模式下，使用chinese输入
    init(frame: CGRect,chinese: String,chineseSize:CGFloat , pinyin: String,pinyinSize:CGFloat,style:textStyle,changeAble:Bool, showBoth:Bool) {
        
        super.init(frame: frame)
        self.maxFrame = frame
        self.frameWidth = frame.width
        self.frameHeight = frame.height
        self.chineseFontSize = chineseSize + FontSizeAddition
        self.pinyinFontSize = pinyinSize + FontSizeAddition
        self.isChangeAble = changeAble
        if(isChangeAble){
            self.textStyle = getTheSystemType()
        }else {
            self.textStyle = style
        }
        self.pinyinFontname = "PingFangSC-Regular"
        self.chineseFontname = "PingFangSC-Regular"
        chineseLabel = UILabel()
        pinyinLabel = UILabel()
        
        chineseLabel.textColor = UIColor.black
        chineseLabel.text = chinese
        chineseLabel.textAlignment = .center

        self.addSubview(chineseLabel)
        
        pinyinLabel.text = pinyin
        pinyinLabel.textAlignment = .center

        pinyinLabel.textColor = UIColor.learingColor
        self.addSubview(pinyinLabel)

        let ges = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.addGestureRecognizer(ges)
        
        reloadView(chinese: chinese, pinyin: pinyin)
    }
    func reloadView(chinese: String = "",pinyin: String = "") {
        chineseLabel.text = chinese
        pinyinLabel.text = pinyin
        self.isAblePut = checkFrame(style: self.textStyle)
        changeStyle(style: self.textStyle)
    }
    init(frame: CGRect,chinese: NSAttributedString,chineseSize:CGFloat , pinyin: NSAttributedString,pinyinSize:CGFloat,style:textStyle,changeAble:Bool) {
        
        super.init(frame: frame)
        //print(self.frame)
        self.maxFrame = frame
        if(changeAble){
            self.textStyle = getTheSystemType()
        }else{
            self.textStyle = style
        }
        self.frameWidth = frame.width
        self.frameHeight = frame.height
        self.chineseFontSize = chineseSize + FontSizeAddition
        self.pinyinFontSize = pinyinSize + FontSizeAddition
        self.isChangeAble = changeAble
        self.pinyinFontname = "PingFangSC-Medium"
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
        pinyinLabel.font = UIFont(name: self.pinyinFontname, size: FontAdjust().FontSize(Double(pinyinFontSize)))
        chineseLabel.font = UIFont(name: self.chineseFontname, size: FontAdjust().FontSize(Double(chineseFontSize)))
        self.chineseLabelHeight = getLabelheight(labelStr: chineseLabel.text!, font: chineseLabel.font)
        self.pinyinLabelHeight = getLabelheight(labelStr: pinyinLabel.text!, font: pinyinLabel.font)
        if(chineseLabelHeight + pinyinLabelHeight >= self.frame.height){
            self.frameHeight = self.frame.height
            chineseLabel.adjustsFontSizeToFitWidth = true
            pinyinLabel.adjustsFontSizeToFitWidth = true
            self.pinyinLabelHeight = self.frame.height/3
            self.chineseLabelHeight = self.frame.height*2/3
            return false
        }else{
            self.frameHeight = pinyinLabelHeight + chineseLabelHeight + exHeight * 2
            chineseLabel.adjustsFontSizeToFitWidth = false
            pinyinLabel.adjustsFontSizeToFitWidth = false
            return true
        }
    }
    
    func changeStyle(style:textStyle) {
        pinyinLabel.isHidden = false
        chineseLabel.isHidden = false
        if(self.isAblePut){
            chineseLabel.snp.remakeConstraints { (make) -> Void in
                make.left.right.equalTo(self)
                make.top.equalTo(self.snp.centerY).offset((pinyinLabelHeight - chineseLabelHeight)/2)
                make.height.equalTo(chineseLabelHeight + exHeight)
            }
            pinyinLabel.snp.remakeConstraints { (make) -> Void in
                make.left.right.equalTo(self)
                make.bottom.equalTo(self.snp.centerY).offset((pinyinLabelHeight - chineseLabelHeight)/2)
                make.height.equalTo(pinyinLabelHeight + exHeight)
            }
        }else{
            chineseLabel.snp.remakeConstraints { (make) -> Void in
                make.left.right.bottom.equalTo(self)
                make.top.equalTo(pinyinLabel.snp.bottom)
                make.height.equalTo(chineseLabelHeight + exHeight)
            }
            pinyinLabel.snp.remakeConstraints { (make) -> Void in
                make.left.right.top.equalTo(self)
                make.bottom.equalTo(chineseLabel.snp.top)
                make.height.equalTo(pinyinLabelHeight + exHeight)
            }
        }
    }
    
    func getLabelWidth(labelStr:String,font:UIFont)->CGFloat{
        let maxSie:CGSize = CGSize(width:self.frame.width,height:self.frame.height)
        return (labelStr as NSString).boundingRect(with: maxSie, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):font]), context: nil).size.width
    }
    
    func getLabelheight(labelStr:String,font:UIFont)->CGFloat{
        let maxSie:CGSize = CGSize(width:self.frame.width,height:.greatestFiniteMagnitude)
        return (labelStr as String).boundingRect(with: maxSie, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):font]), context: nil).size.height
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
        chineseLabel.backgroundColor = UIColor.red
        pinyinLabel.backgroundColor = UIColor.yellow
        
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
