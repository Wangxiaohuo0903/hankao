//
//  SettingView.swift
//  ChineseDev
//
//  Created by summer on 2018/1/3.
//  Copyright © 2018年 msra. All rights reserved.
//

import Foundation
import SnapKit

protocol SettingViewDelegate: class {
    func superViewConstraints()
}

func getIndex() ->UInt{
    switch getTheSystemType() {
    case .chinese:
        return 1
    case .pinyin:
        return 0
    case .chineseandpinyin:
        return 2
    default:
        return 0
    }
}

class SettingView: UIView {
    var settingView:UIView!
    var title:UILabel!
    var cancelButton:UIButton!
    var applyButton:UIButton!
    var styleSegmentedControl:BetterSegmentedControl!
    var delegate:SettingViewDelegate!
    //埋点所用
    var Scope:String = ""
    var Lessonid:String = ""
    var Subscope:String = ""
    var IndexPath:String = ""
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        settingView = UIView(frame: CGRect.zero)
        settingView.backgroundColor = UIColor.white
        settingView.layer.cornerRadius = 10
        self.addSubview(settingView)
        var settingViewWidth = AdjustGlobal().CurrentScaleWidth*0.8
        if(AdjustGlobal().CurrentScale == AdjustScale.iPad){
            settingViewWidth = 320
        }
        
        var styleChoiceHeight = 110
        
        var settingViewHeight = styleChoiceHeight + 130
//        if(AdjustGlobal().CurrentScale == AdjustScale.iPad){
//            settingViewHeight = 320
//        }
        
        title = UILabel(frame: CGRect.zero)
        title.text = "Preference"
        title.font = FontUtil.getFont(size: FontAdjust().FontSize(16), type: .Medium)
        title.textAlignment = .center
        settingView.addSubview(title)
        
        var titleline = UIView(frame: CGRect.zero)
        titleline.backgroundColor = UIColor.hex(hex:"#dcdcdc")
        settingView.addSubview(titleline)
        
        var  buttonline = UIView(frame: CGRect.zero)
        buttonline.backgroundColor = UIColor.hex(hex:"#dcdcdc")
        settingView.addSubview(buttonline)
        
        cancelButton = UIButton(frame: CGRect.zero)
        cancelButton.layer.cornerRadius = 22
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.textAlignment = .center
        cancelButton.titleLabel?.font = FontUtil.getFont(size: FontAdjust().FontSize(16), type: .Regular)
        cancelButton.setBackgroundImage(UIImage.fromColor(color: UIColor.hex(hex: "E0E0E0")), for: .normal)
        cancelButton.setTitleColor(UIColor.hex(hex: "4F4F4F"), for: UIControl.State.normal)
        cancelButton.setTitleColor(UIColor.white, for: UIControl.State.selected)
        cancelButton.setTitleColor(UIColor.white, for: UIControl.State.highlighted)
        cancelButton.layer.borderColor = UIColor.hex(hex: "E0E0E0").cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.masksToBounds = true
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        
        applyButton = UIButton(frame: CGRect.zero)
        applyButton.layer.cornerRadius = 22
        applyButton.setTitle("Apply", for: .normal)
        applyButton.titleLabel?.textAlignment = .center
        applyButton.titleLabel?.font = FontUtil.getFont(size: FontAdjust().FontSize(16), type: .Regular)
        applyButton.setBackgroundImage(UIImage.fromColor(color: UIColor.blueTheme), for:.normal)
        applyButton.setTitleColor(UIColor.white, for: .normal)
        applyButton.layer.borderColor = UIColor.blueTheme.cgColor
        applyButton.layer.borderWidth = 1
        applyButton.layer.masksToBounds = true
        applyButton.addTarget(self, action: #selector(apply), for: .touchUpInside)
        
        settingView.addSubview(applyButton)
        settingView.addSubview(cancelButton)
        
        var styleChoice = UIView(frame: CGRect.zero)
        settingView.addSubview(styleChoice)
        
        styleSegmentedControl = BetterSegmentedControl(frame: CGRect.zero, titles: ["Pinyin","汉字","Both"], index: getIndex(), options:[.backgroundColor(UIColor.white),
                                                                                                                                   .titleColor(UIColor.gray),
                                                                                                                                   .indicatorViewBackgroundColor(UIColor.blueTheme.withAlphaComponent(0.4)),
                                                                                                                                   .selectedTitleColor(UIColor.blueTheme),
                                                                                                                                   .titleFont(FontUtil.getFont(size: FontAdjust().FontSize(14), type: .Regular)),
                                                                                                                                   .selectedTitleFont(FontUtil.getFont(size: FontAdjust().FontSize(14), type: .Regular)),
                                                                                                                                   .indicatorViewBorderWidth(1),
                                                                                                                                   .indicatorViewBorderColor(UIColor.blueTheme),.cornerRadius(5)])
        styleSegmentedControl.layer.borderWidth = 1
        styleSegmentedControl.layer.borderColor = UIColor.hex(hex:"#dcdcdc").cgColor
        styleSegmentedControl.layer.cornerRadius = 5
        styleSegmentedControl.addTarget(self, action: #selector(controlValueChanged), for: .valueChanged)
        styleChoice.addSubview(styleSegmentedControl)
        
        var styleChoiceTitle = UILabel(frame: CGRect.zero)
        styleChoiceTitle.text = "Display"
        styleChoiceTitle.font = FontUtil.getFont(size: FontAdjust().FontSize(14), type: .Regular)
        styleChoiceTitle.textAlignment = .left
        styleChoice.addSubview(styleChoiceTitle)
        
        styleSegmentedControl.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(settingView).offset(-settingViewWidth*0.05)
            make.left.equalTo(settingView.snp.left).offset(settingViewWidth*0.05)
            make.top.equalTo(styleChoice.snp.centerY)
            make.bottom.equalTo(styleChoice.snp.bottom).offset(-15)
        }
        
        styleChoiceTitle.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(settingView)
            make.left.equalTo(settingView.snp.left).offset(settingViewWidth*0.05)
            make.top.equalTo(styleChoice.snp.top)
            make.bottom.equalTo(styleChoice.snp.centerY)
        }
        styleChoice.snp.makeConstraints { (make) -> Void in
            make.left.right.equalTo(settingView)
            make.top.equalTo(titleline.snp.bottom)
            make.bottom.equalTo(buttonline.snp.top)
        }
        
        cancelButton.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(settingViewWidth*0.4)
            make.height.equalTo(44)
            make.left.equalTo(settingView.snp.left).offset(settingViewWidth*0.075)
            make.bottom.equalTo(settingView.snp.bottom).offset(-20)
        }
        
        applyButton.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(settingViewWidth*0.4)
            make.height.equalTo(44)
            make.right.equalTo(settingView.snp.right).offset(-settingViewWidth*0.075)
            make.bottom.equalTo(settingView.snp.bottom).offset(-20)
        }
        
        buttonline.snp.makeConstraints { (make) -> Void in
            make.left.right.equalTo(settingView)
            make.height.equalTo(1)
            make.bottom.equalTo(applyButton.snp.top).offset(-20)
        }
        
        titleline.snp.makeConstraints { (make) -> Void in
            make.left.right.equalTo(settingView)
            make.height.equalTo(1)
            make.top.equalTo(settingView.snp.top).offset(50)
        }
        
        title.snp.makeConstraints { (make) -> Void in
            make.left.right.equalTo(settingView)
            make.top.equalTo(settingView.snp.top)
            make.bottom.equalTo(titleline.snp.top)
        }
        
        settingView.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(self)
            make.width.equalTo(settingViewWidth)
            make.height.equalTo(settingViewHeight)
        }
        
//        let gesture = UITapGestureRecognizer(target: self, action: #selector(tappedBack))
//        self.addGestureRecognizer(gesture)
    }
    
    @objc func controlValueChanged(){
        //print(styleSegmentedControl.index)
    }
    
    @objc func cancel() {
        //埋点：点击右上角设置
        var info = ["Scope" : self.Scope,"Lessonid" : self.Lessonid,"Subscope" : self.Subscope,"IndexPath" : self.IndexPath,"Event" : "Setting","Value" : "Cancel"]
        if Subscope == "" {
            info = ["Scope" : self.Scope,"Lessonid" : self.Lessonid,"IndexPath" : self.IndexPath,"Event" : "Setting","Value" : "Cancel"]
        }
        UserManager.shared.logUserClickInfo(info)
        self.removeFromSuperview()
    }
    
    @objc func apply() {
        var originSetting = 0
        var newSetting = 0
        switch UserDefaults.standard.integer(forKey: UserDefaultsKeyManager.chineseandpinyin) {
        case 0://中拼文
            originSetting = 1
        case 1://中文
            originSetting = 2
        case 2://拼音
            originSetting = 3
        default:
            originSetting = 0
        }
        
        switch styleSegmentedControl.index {
        case 2:
            //点击中拼文
            UserDefaults.standard.set(Int(0), forKey: UserDefaultsKeyManager.chineseandpinyin)
            newSetting = 1
        case 1:
            //点击中文
            UserDefaults.standard.set(Int(1), forKey: UserDefaultsKeyManager.chineseandpinyin)
            newSetting = 2
        case 0:
            //点击拼音
            UserDefaults.standard.set(Int(2), forKey: UserDefaultsKeyManager.chineseandpinyin)
            newSetting = 3
        default:
            UserDefaults.standard.set(Int(0), forKey: UserDefaultsKeyManager.chineseandpinyin)
            newSetting = 1
        }
        UserDefaults.standard.synchronize()
        //埋点：点击右上角设置
        var info = ["Scope" : self.Scope,"Lessonid" : self.Lessonid,"Subscope" : self.Subscope,"IndexPath" : self.IndexPath,"Event" : "Setting","Value" : [originSetting,newSetting]] as [String : Any]
        if Subscope == "" {
            info = ["Scope" : self.Scope,"Lessonid" : self.Lessonid,"IndexPath" : self.IndexPath,"Event" : "Setting","Value" : [originSetting,newSetting]] as [String : Any]
        }
        UserManager.shared.logUserClickInfo(info)
        self.delegate.superViewConstraints()
        self.removeFromSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
