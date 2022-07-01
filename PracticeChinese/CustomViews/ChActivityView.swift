//
//  ChActivityView.swift
//  PracticeChinese
//
//  Created by feiyue on 30/06/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView
import SnapKit
import YYText
protocol ChActivityViewCancleDelegate {
    /**
     加载过程中点击取消
     */
    func cancleLoading()
}

enum ActivityViewType {
    case Origin       //原始的样式
    case HomePage // 首页不中断其他触发行为
    case CancleFullScreen // 全覆盖，并且有取消按钮,并且可以设置颜色
    case ShowNavigationbar // 能够显示Navigationbar
    case EvaluatingLearn  // 数据分析中，没有xquiz每一轮末尾
//    case EvaluatingCC  // 数据分析中，没有x,学以致用对话和CC对话末尾
}

class ChActivityView:UIView {
    var indicatorView:NVActivityIndicatorView!
    var textLabel:YYTextView!//提示文字
    var topTitle:UILabel!
    var boxWidth:CGFloat = 0
    var activiViewType: ActivityViewType = .Origin
    var delegate: ChActivityViewCancleDelegate?
    var backButton: UIButton!
    var loadingImage: UIImageView!
    var indicatorType:Int = 0 {
        didSet {
            setContent()
        }
    }
    var indicatorText:String = "" {
        didSet {
            setContent()
        }
 
    }
    
    var boxView:UIView!
    
    static let shared = ChActivityView()
    private init() {
        super.init(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height))
        backgroundColor = UIColor.loadingBgColor
        boxWidth = ScreenUtils.width - 40
        boxView = UIView(frame: CGRect(x: 20, y: ScreenUtils.heightByRate(y: 0.4) - boxWidth / 2, width: boxWidth, height: ScreenUtils.width - ScreenUtils.widthByRate(x: 0.1) * 2))
        addSubview(boxView)
        setContent()
        
        boxView.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(self)
            make.width.equalTo(boxWidth)
            make.height.equalTo(160)
        }
    }

    
    func setContent() {
        indicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        indicatorView.type = .ballSpinFadeLoader
        indicatorView.padding = 8
        indicatorView.sd_setIndicatorStyle(.gray)
        boxView.addSubview(indicatorView)
        indicatorView.startAnimating()
        indicatorView.snp.makeConstraints { (make) in
            make.centerX.equalTo(boxView)
            make.top.equalTo(boxView)
            make.width.height.equalTo(100)
        }
        
        topTitle = UILabel(frame: CGRect(x: 0, y: indicatorView.frame.maxY, width: boxWidth, height: 0))
        topTitle.font = FontUtil.getFont(size: FontAdjust().FontSize(14), type: .Regular)
        topTitle.textAlignment = .center
        topTitle.textColor = .gray
        topTitle.text = ""
        boxView.addSubview(topTitle)
        
        textLabel = YYTextView(frame: CGRect(x: 0, y: topTitle.frame.maxY, width: boxWidth, height: 30))
        textLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(16), type: .Regular)
        textLabel.textAlignment = .center
        textLabel.textColor = .gray
        textLabel.isEditable = false
        textLabel.isScrollEnabled = false
        boxView.addSubview(textLabel)
        
        loadingImage = UIImageView(frame: CGRect(x: (boxWidth - 100)/2, y: 0, width: 100, height: 90))
        loadingImage.image = UIImage(named: "magnifying glass")
        loadingImage.isHidden = true
        boxView.addSubview(loadingImage)
        loadingImage.snp.makeConstraints { (make) in
            make.centerX.equalTo(boxView)
            make.top.equalTo(boxView)
            make.width.equalTo(100)
            make.height.equalTo(90)
        }
        
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
            backButton = UIButton(frame: CGRect(x: FontAdjust().quitButtonTop(), y: 0+34, width: 40, height: 40))
        }else{
            backButton = UIButton(frame: CGRect(x: FontAdjust().quitButtonTop(), y: FontAdjust().quitButtonTop(), width: 40, height: 40))
        }
        backButton.setImage(ChImageAssets.CloseIcon.image, for: .normal)
        backButton.addTarget(self, action: #selector(cancleLoading), for: .touchUpInside)
        backButton.isHidden = true
        addSubview(backButton)
    }
    //取消加载
    @objc func cancleLoading() {
        ChActivityView.hide()
        self.delegate?.cancleLoading()
    }
    //可以设置显示类型,默认半透明黑色背景，全屏幕，是否中断用户操作
    class func show(_ type: ActivityViewType = .Origin, _ superview: UIView? = UIApplication.shared.keyWindow!, _ bgColor: UIColor = UIColor.loadingBgColor, _ showtext: String = "",_ textColor: UIColor = UIColor.loadingTextColor , _ loadingColor: UIColor = UIColor.gray) {
        let loadingTextArray = ["DO YOU KNOW|There are over 1.2 billion people speaking mandarin around the globe.","Have you practiced your Chinese speaking today?","Language is the key to the heart of people.","Learning a language is also learning a culture."]
        let textRandom = Int(arc4random_uniform(UInt32(loadingTextArray.count)))
        let loadText = loadingTextArray[textRandom]
        let actView = ChActivityView.shared
        ChActivityView.shared.activiViewType = type
        if bgColor == UIColor.learingColor {
            actView.backButton.imageView?.tintColor = UIColor.white
        }else {
            actView.backButton.imageView?.tintColor = UIColor.gray
        }
        actView.topTitle.frame = CGRect(x: (ScreenUtils.widthByRate(x: 0.8) - 320)/2, y: actView.indicatorView.frame.maxY, width: 320, height: 0)

        switch type {
        case .Origin:
            //原始的
            actView.frame = CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height)
            actView.backgroundColor = bgColor
            actView.loadingImage.isHidden = true
            actView.textLabel.text = ""
            actView.textLabel.textColor = UIColor.clear
            actView.indicatorView.color = loadingColor
            actView.backButton.isHidden = true
            UIApplication.shared.keyWindow!.addSubview(ChActivityView.shared)
            break
        case .EvaluatingLearn:
            //数据分析中
            actView.frame = CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height)
            actView.backgroundColor = bgColor
            actView.topTitle.text = ""
            actView.textLabel.text = showtext
            actView.textLabel.textColor = textColor
            actView.indicatorView.color = loadingColor
            actView.backButton.isHidden = true
            actView.loadingImage.isHidden = false
            actView.textLabel.frame = CGRect(x: actView.textLabel.frame.origin.x, y: actView.loadingImage.frame.maxY + 5, width: actView.textLabel.frame.width, height: actView.textLabel.frame.height)
            UIApplication.shared.keyWindow!.addSubview(ChActivityView.shared)
            break
        case .HomePage:
            //HomePage类型是透明背景，不中断用户操作，局部显示，有提示文字
            actView.frame = CGRect(x: 0, y: ScreenUtils.heightBySix(y: 0), width: ScreenUtils.width, height: ScreenUtils.height)
            actView.backgroundColor = bgColor
            actView.textLabel.text = ""
            actView.textLabel.textColor = textColor
            actView.indicatorView.color = loadingColor
            actView.backButton.isHidden = true
            actView.loadingImage.isHidden = true
            superview?.addSubview(ChActivityView.shared)
            break
        case .CancleFullScreen:
            //全屏幕显示，有取消按钮，背景色随底部
            ChActivityView.HiddenJZStatusBar(alpha: 0)
            actView.frame = CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height)
            actView.backgroundColor = bgColor
            actView.textLabel.text = loadText
            actView.loadingImage.isHidden = true
            if loadText != "" {
                let array = loadText.components(separatedBy: "|")
                var text = NSMutableAttributedString(string: array[0])
                if array[0] == "DO YOU KNOW" {
                    text = NSMutableAttributedString(string: array[1])
                }
                text.yy_setFont(FontUtil.getFont(size: FontAdjust().FontSize(16), type:.Regular), range: text.yy_rangeOfAll())
                //字体
                text.yy_setAlignment(.center, range: text.yy_rangeOfAll())
                if loadText.hasPrefix("DO YOU KNOW"){
                    actView.topTitle.text = array[0]
                    actView.topTitle.frame = CGRect(x: actView.topTitle.frame.origin.x, y: actView.indicatorView.frame.maxY, width: actView.topTitle.frame.width, height: 30)
                }
                text.yy_setColor(textColor, range: text.yy_rangeOfAll())
                text.yy_setMaximumLineHeight(18, range: text.yy_rangeOfAll())
                actView.textLabel.attributedText = text
            }
            actView.textLabel.sizeToFit()
            actView.topTitle.textColor = textColor
            actView.textLabel.frame = CGRect(x: actView.textLabel.frame.origin.x, y: actView.topTitle.frame.maxY, width: actView.textLabel.frame.width, height: actView.textLabel.frame.height)
            actView.textLabel.textColor = textColor
            actView.indicatorView.color = loadingColor
            actView.backButton.isHidden = false
            UIApplication.shared.keyWindow!.addSubview(ChActivityView.shared)
            break
        case .ShowNavigationbar:
            actView.frame = CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height)
            actView.backgroundColor = bgColor
            actView.textLabel.text = ""
            actView.textLabel.textColor = UIColor.clear
            actView.indicatorView.color = loadingColor
            actView.backButton.isHidden = true
            superview?.addSubview(ChActivityView.shared)
            break
        default:
            UIApplication.shared.keyWindow!.addSubview(ChActivityView.shared)
            break
        }
        actView.indicatorView.startAnimating()
    }
    
    //attention
    class func hide(_ type: ActivityViewType = .Origin) {
        ChActivityView.HiddenJZStatusBar(alpha: 1)
        switch type {
        case .HomePage:
            ChActivityView.shared.removeFromSuperview()
        case .ShowNavigationbar:
            ChActivityView.shared.removeFromSuperview()
        default:
            if(UIApplication.shared.keyWindow!.subviews.contains(ChActivityView.shared)){
                ChActivityView.shared.removeFromSuperview()
            }
        }
    }
    
    //attention
    class func hide(_ type: ActivityViewType = .Origin,statusAlpha:CGFloat) {
        ChActivityView.HiddenJZStatusBar(alpha: statusAlpha)
        switch type {
        case .HomePage:
            ChActivityView.shared.removeFromSuperview()
        case .ShowNavigationbar:
            ChActivityView.shared.removeFromSuperview()
       
        default:
            if(UIApplication.shared.keyWindow!.subviews.contains(ChActivityView.shared)){
                ChActivityView.shared.removeFromSuperview()
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    ///获取状态栏
    class func HiddenJZStatusBar(alpha:CGFloat){
//        var object = UIApplication.shared,statusBar:UIView?
//        if object.responds(to: NSSelectorFromString("statusBar")) {
//            statusBar = object.value(forKey: "statusBar") as?UIView
//        }
//        UIView.animate(withDuration: 0.3) {
//            statusBar?.alpha = alpha
//        }
    }
}


class ActivityViewText {
    static let HomePageLoading = "DO YOU KNOW\nThere are over 1.2 billion people speaking mandarin around the globe."
    static let EvaluatingLearn = "Evaluating your learning progress…"
    static let EvaluatingCC = "Evaluating your performance…"
}
