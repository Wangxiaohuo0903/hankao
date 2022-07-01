//
//  OptionButton.swift
//  PracticeChinese
//
//  Created by summer on 2017/9/8.
//  Copyright © 2017年 msra. All rights reserved.
//

import SnapKit
import Foundation

class OptionButton: UIButton {
    
    var buttonView:UILabel!
    var buttonOrder:Int!
    var chineseandpinyinLabel:RNTextView!
    var englishLabel:RNTextView!
    let bgClocr = UIColor.hex(hex: "E8F0FD")
    init(frame: CGRect,chinese:String,pinyin:String,english:String) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(makeNomalColor(sender:)), for: .touchCancel)
        
        self.setBackgroundImage(createImage(with: bgClocr), for: .normal)
        self.setBackgroundImage(createImage(with: UIColor.itemDragingColor), for: .highlighted)

        let pinyinS = pinyin
        buttonOrder = -1
        self.layer.cornerRadius = 7
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.cgColor
        buttonView = UILabel(frame: CGRect(x:0, y:0, width: self.frame.width-4, height: self.frame.height))
        buttonView.backgroundColor = UIColor.clear
        buttonView.isUserInteractionEnabled = false
        self.addSubview(buttonView)
        
        chineseandpinyinLabel = RNTextView(frame: CGRect(x:0, y:0, width: self.frame.width-4, height: self.frame.height-4), chinese:chinese , chineseSize: CGFloat(FontAdjust().Option_ChineseAndPinyin_C()), pinyin: pinyinS, pinyinSize: CGFloat(FontAdjust().Option_ChineseAndPinyin_P()), style: textStyle.chineseandpinyin, changeAble: true, pinyinFontRegular:false)
        chineseandpinyinLabel.setLabelColor(chinese: UIColor.blueTheme, pinyin: UIColor.blueTheme)
        buttonView.addSubview(chineseandpinyinLabel)
        chineseandpinyinLabel.delegate = self
        buttonView.bringSubviewToFront(chineseandpinyinLabel)
        
        englishLabel = RNTextView(frame: CGRect(x:0, y:0, width: self.frame.width-4, height: self.frame.height-4), chinese: "", chineseSize: CGFloat(FontAdjust().Option_ChineseAndPinyin_C()), pinyin:english , pinyinSize: CGFloat(FontAdjust().Option_ChineseAndPinyin_C()), style: textStyle.pinyin, changeAble: false, pinyinFontRegular:true)
        englishLabel.setLabelColor(chinese: UIColor.blueTheme, pinyin: UIColor.blueTheme)
        buttonView.addSubview(englishLabel)
        buttonView.bringSubviewToFront(englishLabel)
        englishLabel.delegate = self
        
        self.snp.makeConstraints { (make) -> Void in
            make.left.right.bottom.top.equalTo(self)
        }
        
        buttonView.snp.makeConstraints { (make) -> Void in
            make.left.top.equalTo(self).offset(0)
            make.right.bottom.equalTo(self).offset(0)
        }
        
        chineseandpinyinLabel.snp.makeConstraints { (make) -> Void in
            make.left.right.bottom.top.equalTo(buttonView)
        }
        
        englishLabel.snp.makeConstraints { (make) -> Void in
            make.left.right.bottom.top.equalTo(buttonView)
        }
        
        
        if(english == ""){
            englishLabel.isHidden = true
            chineseandpinyinLabel.isHidden = false
        }else{
            englishLabel.isHidden = false
            chineseandpinyinLabel.isHidden = true
        }
    }

    @objc func makeNomalColor(sender:UIButton) {
        sender.setBackgroundImage(self.createImage(with: bgClocr), for: .normal)
    }
    func refreshButtonValue() {
        if(chineseandpinyinLabel.isHidden == false){
            chineseandpinyinLabel.systemAutoChangeWithoutFrame()
        }
    }
    
    func refreshButton(){
        if(chineseandpinyinLabel.isHidden == false){
            chineseandpinyinLabel.systemAutoChangeWithoutFrame()
        }
        self.setBackgroundImage(self.createImage(with: bgClocr), for: .normal)
        self.isUserInteractionEnabled = true
    }
    func makeButtonDisabled() {
        self.isUserInteractionEnabled = false
    }
    func makeButtonEnabled() {
        self.isUserInteractionEnabled = true
    }
    func refreshToNomalColor(){
        self.setBackgroundImage(self.createImage(with: bgClocr), for: .normal)
        chineseandpinyinLabel.setLabelColor(chinese: UIColor.blueTheme, pinyin: UIColor.blueTheme)
        englishLabel.setLabelColor(chinese: UIColor.blueTheme, pinyin: UIColor.blueTheme)
    }
    func setCorrect(){
        self.setBackgroundImage(self.createImage(with: UIColor.correctColor), for: .normal)
        chineseandpinyinLabel.setLabelColor(chinese: UIColor.white, pinyin: UIColor.white)
        englishLabel.setLabelColor(chinese: UIColor.white, pinyin: UIColor.white)
    }
    
    func setWrong(){
        self.setBackgroundImage(self.createImage(with: UIColor.wrongColor), for: .normal)
        chineseandpinyinLabel.setLabelColor(chinese: UIColor.white, pinyin: UIColor.white)
        englishLabel.setLabelColor(chinese: UIColor.white, pinyin: UIColor.white)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func createImage(with color: UIColor?) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor((color?.cgColor)!)
        context?.fill(rect)
        let theImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return theImage
    }
    
}

extension OptionButton:RNTextViewDelegate{
    func tapped() {
        
    }
    
    func superViewConstraints() {
    }
}

