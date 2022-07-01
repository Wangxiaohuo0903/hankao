//
//  ShareView.swift
//  ChineseDev
//
//  Created by summer on 2017/12/4.
//  Copyright © 2017年 msra. All rights reserved.
//

import Foundation
//import SwiftShareBubbles
import Social
import UIKit
import SnapKit
//import ScreenshotSharer

class ShareView: UIViewController {
//    var bubbles: SwiftShareBubbles?
//    var button:UIButton!
    
    
//    let sssharer = ScreenshotSharer()
    
    var label:TextView!
    var signtop:UIView!
    var signbotton:UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 320))
        view.backgroundColor = UIColor.blue
        self.view.addSubview(view)
        
        let Button = UIButton(frame: CGRect.zero)
        Button.backgroundColor = UIColor.green
        Button.addTarget(self,action:#selector(tappedButton),for:.touchUpInside)
        self.view.addSubview(Button)
        
        
        
        
        view.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(self.view)
            make.width.equalTo(300)
            make.height.equalTo(320)
        }
        label = TextView(frame: CGRect(x: 0, y: 0, width: 300, height: 320), chinese:"",chineseSize:20, pinyin: "hdsakhfjakhffdhsjkafhkjashfkhsafdjhkafahkdsfasdfhjkdshafkahfadsfadsafd",pinyinSize:18, style: textStyle.pinyin,changeAble:true,showBoth:false)
        label.testify()
        label.delegate = self
        self.view.addSubview(label)
        
        label.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(self.view)
            make.width.equalTo(label.frameWidth)
            make.height.equalTo(label.frameHeight)
        }
        
        signtop = UIView()
        signtop.backgroundColor = UIColor.gray
        self.view.addSubview(signtop)
        signbotton = UIView()
        signbotton.backgroundColor = UIColor.gray
        self.view.addSubview(signbotton)
        
        signtop.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(10)
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(label.snp.top)
        }
        
        signbotton.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(10)
            make.left.right.equalTo(self.view)
            make.top.equalTo(label.snp.bottom)
        }
        
        Button.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.view)
            make.width.equalTo(300)
            make.height.equalTo(60)
            make.bottom.equalTo(self.view.snp.bottom).offset(20)
        }
    }
    
    @objc func tappedButton() {
        var stylechange:textStyle = textStyle.other
        
        if(label.textStyle == textStyle.chineseandpinyin){
            stylechange = textStyle.chinese
            label.setLabelText(chinese: "修改啊啊发", pinyin: "sfasf", textStyle: stylechange)
        }else if(label.textStyle == textStyle.chinese){
            stylechange = textStyle.pinyin
            label.setLabelText(chinese: "大法师法师", pinyin: "sadh", textStyle: stylechange)
        }else{
            stylechange = textStyle.chineseandpinyin
            label.setLabelText(chinese: "大事发生发", pinyin: "sfasf", textStyle: stylechange)
        }
    
        label.snp.remakeConstraints { (make) -> Void in
            make.center.equalTo(self.view)
            make.width.equalTo(label.frameWidth)
            make.height.equalTo(label.frameHeight)
        }
        
        signtop.snp.remakeConstraints { (make) -> Void in
            make.height.equalTo(10)
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(label.snp.top)
        }
        
        signbotton.snp.remakeConstraints { (make) -> Void in
            make.height.equalTo(10)
            make.left.right.equalTo(self.view)
            make.top.equalTo(label.snp.bottom)
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
//        sssharer.isEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
//        sssharer.isEnabled = false
    }
    
    // SwiftShareBubblesDelegate
//    func bubblesTapped(bubbles: SwiftShareBubbles, bubbleId: Int) {
//        if let bubble = Bubble(rawValue: bubbleId) {
//            print("\(bubble)")
//            switch bubble {
//            case .facebook:
//                break
//            case .twitter:
//                break
//            case .line:
//                break
//            default:
//                break
//            }
//        } else {
//            // custom case
//        }
//    }
//
//    func bubblesDidHide(bubbles: SwiftShareBubbles) {
//    }
//
//    func buttonTapped() {
//        bubbles?.show()
//    }
}

extension ShareView:TextViewDelegate{
    func tapped() {
        
    }
    
    func superViewConstraints() {
        label.snp.remakeConstraints { (make) -> Void in
            make.center.equalTo(self.view)
            make.width.equalTo(label.frameWidth)
            make.height.equalTo(label.frameHeight)
        }
        
        signtop.snp.remakeConstraints { (make) -> Void in
            make.height.equalTo(10)
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(label.snp.top)
        }
        
        signbotton.snp.remakeConstraints { (make) -> Void in
            make.height.equalTo(10)
            make.left.right.equalTo(self.view)
            make.top.equalTo(label.snp.bottom)
        }
    }
}
