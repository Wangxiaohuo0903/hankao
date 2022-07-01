//
//  FirstPage.swift
//  UIViewTest
//
//  Created by ThomasXu on 23/05/2017.
//  Copyright © 2017 ThomasXu. All rights reserved.
//

import UIKit
import YYText
import SnapKit

class StartPageViewController: UIViewController {
    
    var imgViews = [UIImageView]()
    var scrollView: UIScrollView!
    var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        setSubviews()
        // 接收状态栏高度发生变化的通知
        NotificationCenter.default.addObserver(self, selector: #selector(adjustStatusBar), name: NSNotification.Name("UIApplicationDidChangeStatusBarFrameNotification"), object: nil)
        adjustStatusBar()
    }
    @objc func adjustStatusBar() {
//        print("导航高度 \(ch_getStatusBarHeight())")
        if (ch_getStatusBarHeight() > 20) {
           var statusH = 20.0
            if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
                statusH = 34.0
            }
            scrollView.frame = CGRect(x: 0, y:0, width:  ScreenUtils.width, height:  ScreenUtils.height)
            scrollView.contentSize = CGSize(width: ScreenUtils.width * 4, height: ScreenUtils.height)
            var controlY = ScreenUtils.heightByRate(y: 0.97) - CGFloat(ch_getStatusBarHeight()) + CGFloat(statusH)
            if(AdjustGlobal().getDeviceModel() == "Simulator"){
                if(AdjustGlobal().CurrentScaleHeight == 812){
                    controlY = ScreenUtils.heightByRate(y: 0.96) - CGFloat(ch_getStatusBarHeight()) + CGFloat(statusH)
                }
            }else{
                if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
                    controlY = ScreenUtils.heightByRate(y: 0.96) - CGFloat(ch_getStatusBarHeight()) + CGFloat(statusH)
                }
            }
            pageControl.frame = CGRect(x: pageControl.frame.origin.x, y:controlY, width: pageControl.frame.size.width, height: pageControl.frame.size.height)
            
        }else{
            scrollView.frame = self.view.frame
            scrollView.contentSize = CGSize(width: ScreenUtils.width * 4, height: ScreenUtils.height)
            
            var controlY = ScreenUtils.heightByRate(y: 0.97)
            if(AdjustGlobal().getDeviceModel() == "Simulator"){
                if(AdjustGlobal().CurrentScaleHeight == 812){
                    controlY = ScreenUtils.heightByRate(y: 0.96)
                }
            }else{
                if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
                    controlY = ScreenUtils.heightByRate(y: 0.96)
                }
            }
            pageControl.frame = CGRect(x: pageControl.frame.origin.x, y:controlY, width: pageControl.frame.size.width, height: pageControl.frame.size.height)
            
        }
        view.layoutIfNeeded()
    }
    
    func setSubviews() {
        scrollView = UIScrollView(frame: self.view.frame)
        scrollView.contentSize = CGSize(width: ScreenUtils.width * 4, height: ScreenUtils.height)
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = UIColor.hex(hex: "CEDCEE")
        self.view.addSubview(scrollView)
        
        var promptImgs = [UIImage?]()
        promptImgs.append(ChImageAssets.startPageOne.image)
        promptImgs.append(ChImageAssets.startPageTwo.image)
        promptImgs.append(ChImageAssets.startPageThree.image)

        var promptArray = [["Speech Recognition","Advanced grading system provides instant feedback."],["Professional Course Material","Designed by experienced teachers, aligned with HSK difficulty classification."],["Conversational Interface","powered by cutting edge AI technology."]]
        
        
        var curX: CGFloat = 0
        var margin: CGFloat = 0
        if AdjustGlobal().CurrentScale == AdjustScale.iPhone4 {
            margin = 40
        }
        let curY: CGFloat = ScreenUtils.height * 0.1
        let curWidth: CGFloat = ScreenUtils.width - curX * 2
        let curHeight = curWidth
        //猫头鹰提示部分
        for i in 0...2 {
            let temp = UIImageView(frame: CGRect(x: curX + margin, y: curY, width: curWidth - 2 * margin, height: curHeight -  2 * margin))
            temp.image = promptImgs[i]
            imgViews.append(temp)
            temp.contentMode = .scaleAspectFill
            scrollView.addSubview(temp)
            
            
            let waves = UIImageView(frame: CGRect(x: curX, y:ScreenUtils.height - ScreenUtils.width * 600 / 1125, width: ScreenUtils.width, height: ScreenUtils.width * 600 / 1125))
            waves.contentMode = .scaleAspectFill
            waves.image = ChImageAssets.startPageWaves.image
            scrollView.addSubview(waves)
            
            let prompt1 = UILabel(frame: CGRect(x: curX + 20, y:ScreenUtils.height - ScreenUtils.width * 600 / 1125 / 3 * 2, width: curWidth - 40, height: 30))
            prompt1.text = promptArray[i][0]
            prompt1.textColor = UIColor.white
            prompt1.font = FontUtil.getFont(size: FontAdjust().FontSize(24), type: .Regular)
            prompt1.textAlignment = .center
            prompt1.adjustsFontSizeToFitWidth = true
            scrollView.addSubview(prompt1)
            
            let prompt2 = UILabel(frame: CGRect(x: curX + 20, y:prompt1.frame.minY + 30, width: curWidth - 40, height: 40))
            prompt2.text = promptArray[i][1]
            prompt2.textColor = UIColor.white
            prompt2.font = FontUtil.getFont(size: FontAdjust().FontSize(12), type: .Regular)
            prompt2.textAlignment = .center
            prompt2.numberOfLines = 0
            scrollView.addSubview(prompt2)
            
            curX += ScreenUtils.width
        }
        
        let controller = LoginFullViewController()
        self.addChild(controller)
        controller.view.frame = CGRect(x: curX, y: 0, width: ScreenUtils.width, height: ScreenUtils.height)
        scrollView.addSubview(controller.view)
        controller.didMove(toParent: self)
        
        let controlWidth = ScreenUtils.widthByRate(x: 0.4)
        let controlX = (ScreenUtils.width - controlWidth) / 2
        var controlY = ScreenUtils.heightByRate(y: 0.97)
        let controlHeight = ScreenUtils.heightByRate(y: 0.02)
        if(AdjustGlobal().getDeviceModel() == "Simulator"){
            if(AdjustGlobal().CurrentScaleHeight == 812){
                controlY = ScreenUtils.heightByRate(y: 0.96)
            }
        }else{
            if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
                controlY = ScreenUtils.heightByRate(y: 0.96)
            }
        }
        pageControl = UIPageControl(frame: CGRect(x: controlX, y: controlY, width: controlWidth, height: controlHeight))
        pageControl.numberOfPages = 4
        pageControl.addTarget(self, action: #selector(changePage(sender:)), for: .valueChanged)
        pageControl.currentPage = 0
        self.view.addSubview(pageControl)
        
        
    }
    
    @objc func changePage(sender: AnyObject) {
        self.scrollView.contentOffset = CGPoint(x: ScreenUtils.width * CGFloat(pageControl.currentPage), y: 0)
        if self.pageControl.currentPage == 3 {
            self.pageControl.isHidden = true
        } else {
            self.pageControl.isHidden = false
        }
    }
}

extension StartPageViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        self.pageControl.currentPage = Int(offset.x) / Int(ScreenUtils.width)
        if self.pageControl.currentPage == 3 {
            self.pageControl.isHidden = true
            self.scrollView.isScrollEnabled = false
        } else {
            self.pageControl.isHidden = false
        }
    }
}

class TermOfUseViewController: UIViewController {

    var titleLabel: UILabel!
    var imageView: UIImageView!
    
    var termOfUse: UILabel!
    var privacyPolicy: UILabel!
    
    var experienceLabel: UILabel!
    
    var buttonTermOfUse: LoginRadioButton!
    var buttonExperience: LoginRadioButton!
    
    var explainLabel: UILabel!

    
    var buttonEnter: UIButton!
    
    
    func getAttributeString(text: String) -> NSMutableAttributedString {
        let attributeString = NSMutableAttributedString(string: text)
        attributeString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, text.characters.count))
        return attributeString
    }
    
    var touchTermOfUse: UIButton!
    
    func touchTermOfUse(_ sender: Any) {
        if buttonTermOfUse.isSelected {
            buttonTermOfUse.isSelected = false
            self.buttonEnter.isEnabled = false
        } else {
            buttonTermOfUse.isSelected = true
            self.buttonEnter.isEnabled = true
        }
    }
    
    func touchUserExperience(_ sender: Any) {
        if buttonExperience.isSelected {
            buttonExperience.isSelected = false
        } else {
            buttonExperience.isSelected = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(0xcedcee)
        buttonEnter = UIButton(frame: CGRect.zero)
        termOfUse = UILabel(frame: CGRect.zero)
        explainLabel = UILabel(frame: CGRect.zero)
        privacyPolicy = UILabel(frame: CGRect.zero)
        experienceLabel = UILabel(frame: CGRect.zero)
        buttonTermOfUse = LoginRadioButton(frame: CGRect.zero)
        buttonExperience = LoginRadioButton(frame: CGRect.zero)
        
       
        
        let titleFont = FontUtil.getFont(size: FontAdjust().FontSizeScale(23), type: .Regular)
        titleLabel = UILabel(frame: CGRect(x: 0, y: ScreenUtils.heightByRate(y: 0.05), width: ScreenUtils.width, height: titleFont.lineHeight))
        titleLabel.textColor = UIColor.blueTheme
        titleLabel.font = titleFont
        titleLabel.text = "Welcome"
        self.view.addSubview(titleLabel)
        
        let imageWidth = ScreenUtils.widthByRate(x: 0.725)
        let imageX = (ScreenUtils.width - imageWidth) / 2
        imageView = UIImageView(frame: CGRect(x: imageX, y: ScreenUtils.heightByRate(y: 0.14), width: imageWidth, height: imageWidth))
        imageView.image = ChBundleImageUtil.loginPrivacy.image
        self.view.addSubview(imageView)

        let backImgY = imageView.frame.maxY - ScreenUtils.heightByRate(y: 0.01)
        let backImg = UIImageView(frame: CGRect.zero)
        backImg.image = ChBundleImageUtil.loginWave.image
        self.view.insertSubview(backImg, at: 0)
        
        let labelFont = FontUtil.getFont(size: FontAdjust().FontSize(18), type: .Regular)
        let buttonX = ScreenUtils.widthByRate(x: 0.1)
        let buttonWidth = labelFont.lineHeight * 0.9
        let buttonY = imageView.frame.maxY + backImg.frame.height * 0.29
        buttonTermOfUse = LoginRadioButton(frame: CGRect(x: buttonX, y: buttonY, width: buttonWidth, height: buttonWidth))
        buttonTermOfUse.isSelected = true
        buttonTermOfUse.addTarget(self, action: #selector(tapButtonTermOfUse(sender:)), for: .touchUpInside)
        self.view.addSubview(buttonTermOfUse)
        
        let buttonExperienceY = imageView.frame.maxY + backImg.frame.height * 0.105 + ScreenUtils.heightByRate(y: 0.045) + labelFont.lineHeight - buttonWidth
        buttonExperience = LoginRadioButton(frame: CGRect(x: buttonX, y: buttonExperienceY, width: buttonWidth, height: buttonWidth))
        buttonExperience.isSelected = false
        buttonExperience.addTarget(self, action: #selector(tapButtonExperience(sender:)), for: .touchUpInside)
        self.view.addSubview(buttonExperience)

        
        let labelX: CGFloat = buttonX + buttonWidth + buttonWidth / 2
        let labelY: CGFloat = buttonEnter.frame.maxY
        let labelHeight: CGFloat = labelFont.lineHeight
        
        termOfUse.font = labelFont
        termOfUse.attributedText = getAttributeString(text: "Term of Use")
        termOfUse.textColor = UIColor.white
        termOfUse.sizeToFit()
        termOfUse.frame = CGRect(x: labelX, y: labelY, width: termOfUse.frame.width, height: labelHeight)
//        let termGesture = UITapGestureRecognizer(target: self, action: #selector(tapTermOfUse(_:)))
//        termOfUse.isUserInteractionEnabled = true
//        termOfUse.addGestureRecognizer(termGesture)
        
        
        let attributedStr = NSMutableAttributedString(string:"Choosing Start means that you agree to the Privacy Policy and Terms Of Use.", attributes: convertToOptionalNSAttributedStringKeyDictionary([ convertFromNSAttributedStringKey(NSAttributedString.Key.font) : FontUtil.getFont(size: FontAdjust().FontSize(12), type: .Regular)]))

        attributedStr.yy_setFont(FontUtil.getFont(size: FontAdjust().FontSize(12), type: .Regular), range: NSMakeRange (9, 5))
        attributedStr.yy_setFont(FontUtil.getFont(size: FontAdjust().FontSize(12), type: .Medium), range: NSMakeRange (43, 14))
        attributedStr.yy_setUnderlineStyle(NSUnderlineStyle.single, range: NSMakeRange (43, 14))
        attributedStr.yy_setFont(FontUtil.getFont(size: FontAdjust().FontSize(12), type: .Medium), range: NSMakeRange (62, 12))
        attributedStr.yy_setUnderlineStyle(NSUnderlineStyle.single, range: NSMakeRange (62, 12))

        attributedStr.yy_setTextHighlight(NSMakeRange (41, 14), color: UIColor.white, backgroundColor: UIColor.clear) {
            view, text, range, rect in
            self.openBrowser(urlStr: "https://go.microsoft.com/fwlink/?LinkId=521839")
        }
        
        attributedStr.yy_setTextHighlight(NSMakeRange (60, 12), color: UIColor.white, backgroundColor: UIColor.clear) {
            view, text, range, rect in
            self.openBrowser(urlStr: "http://go.microsoft.com/fwlink/?linkid=206977")
        }
        attributedStr.yy_color = UIColor.white
        attributedStr.yy_alignment = .center
        
        var suggestionLabel = YYLabel()
        suggestionLabel.numberOfLines = 3
        suggestionLabel.sizeToFit()
        
        suggestionLabel.frame = CGRect(x: ScreenUtils.widthByRate(x: 0.15), y: ScreenUtils.height - ScreenUtils.heightByM(y: 70), width: ScreenUtils.widthByRate(x: 0.7), height: 70)
        suggestionLabel.attributedText = attributedStr
        
        
        privacyPolicy.font = labelFont
        privacyPolicy.attributedText = getAttributeString(text: "Privacy Policy")
        privacyPolicy.textColor = UIColor.white
        privacyPolicy.sizeToFit()
        privacyPolicy.frame = CGRect(x: suggestionLabel.frame.maxX + 6, y: labelY, width: privacyPolicy.frame.width, height: labelHeight)
//        let privacyGesture = UITapGestureRecognizer(target: self, action: #selector(tapPrivacyPolicy(_:)))
//        privacyPolicy.isUserInteractionEnabled = true
//        privacyPolicy.addGestureRecognizer(privacyGesture)
        
        let experienceY = buttonExperience.frame.midY - labelFont.lineHeight / 2
        experienceLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(16), type: .Regular)
        experienceLabel.textColor = UIColor.white
        experienceLabel.text = "Enable Intelligent Learning Assessment"
        experienceLabel.frame = CGRect(x: labelX, y: experienceY, width: 0, height: labelHeight)
        experienceLabel.sizeToFit()
        
        let explainY = experienceLabel.frame.maxY + ScreenUtils.heightByRate(y: 0.01)
        explainLabel.frame = CGRect(x: labelX, y: explainY, width: imageWidth, height: 10)
        explainLabel.textAlignment = .left
        explainLabel.numberOfLines = 0
        explainLabel.text = String.PrivacyConsent
        explainLabel.font = FontUtil.getFont(size: 40, type: .Regular)
        explainLabel.textColor = UIColor(0xcedcee)
//        explainLabel.sizeToFit()

        
        let enterWidth = ScreenUtils.widthByRate(x: 0.75)
        let enterY = explainLabel.frame.maxY + ScreenUtils.heightByRate(y: 0.03)
        let enterX = (ScreenUtils.width - enterWidth) / 2
        buttonEnter.frame = CGRect(x: enterX, y: min(enterY, ScreenUtils.heightByRate(y: 0.93)), width: enterWidth, height: ScreenUtils.heightByRate(y: 0.066))
        buttonEnter.setTitle("Start", for: .normal)
        buttonEnter.setTitleColor(UIColor.blueTheme, for: .normal)
        buttonEnter.titleLabel?.font = FontUtil.getFont(size: FontAdjust().FontSize(20), type: .Regular)
        buttonEnter.layer.cornerRadius = buttonEnter.frame.height * 0.5
        buttonEnter.layer.masksToBounds = true
        buttonEnter.backgroundColor = UIColor.white
        buttonEnter.addTarget(self, action: #selector(clickEnter), for: .touchUpInside)
        
        suggestionLabel.frame = CGRect(x: ScreenUtils.widthByRate(x: 0.15), y:buttonEnter.frame.maxY + (ScreenUtils.height - (buttonEnter.frame.maxY + 70))/2, width: ScreenUtils.widthByRate(x: 0.7), height: 70)
        
        termOfUse.isHidden = true
        privacyPolicy.isHidden = true
        buttonEnter.isHidden = false
        buttonTermOfUse.isHidden = true
        
        view.addSubview(suggestionLabel)
        self.view.addSubview(buttonEnter)
        view.bringSubviewToFront(buttonEnter)
        self.view.addSubview(experienceLabel)
        self.view.addSubview(termOfUse)
        self.view.addSubview(explainLabel)
        
        buttonExperience.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(experienceLabel)
            make.right.equalTo(experienceLabel.snp.left).offset(UIAdjust().adjustByWidth(-10))
            if(AdjustGlobal().isiPad){
                make.height.width.equalTo((buttonExperience.titleLabel?.font.lineHeight)!*0.9)
            }else{
                make.height.width.equalTo((buttonExperience.titleLabel?.font.lineHeight)!*0.75)
            }
        }
        
        experienceLabel.sizeToFit()
        experienceLabel.snp.makeConstraints { (make) -> Void in
            if(AdjustGlobal().isiPad){
                make.bottom.equalTo(explainLabel.snp.top).offset(UIAdjust().adjustByHeight(-6))
            }else{
                make.bottom.equalTo(explainLabel.snp.top).offset(UIAdjust().adjustByHeight(-8))
            }
            make.left.equalTo(explainLabel)
            make.right.equalTo(self.view)
        }
        
        
        explainLabel.adjustsFontSizeToFitWidth=true
        explainLabel.lineBreakMode = .byTruncatingMiddle
        explainLabel.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.view).offset(UIAdjust().adjustByHeightScale(0.015))
            if(AdjustGlobal().isiPad){
                make.height.equalTo(UIAdjust().adjustByHeightScale(0.1))
                make.bottom.equalTo(buttonEnter.snp.top).offset(UIAdjust().adjustByHeight(-26))
            }else{
                make.height.equalTo(UIAdjust().adjustByHeightScale(0.1))
                make.bottom.equalTo(buttonEnter.snp.top).offset(UIAdjust().adjustByHeight(-28))
            }
            make.width.equalTo(UIAdjust().adjustByWidthScale(0.75))
        }
        
        buttonEnter.snp.makeConstraints { (make) -> Void in
            if(AdjustGlobal().isiPad){
                make.bottom.equalTo(suggestionLabel.snp.top).offset(UIAdjust().adjustByHeight(-6))
            }else{
                make.bottom.equalTo(suggestionLabel.snp.top).offset(UIAdjust().adjustByHeight(-8))
            }
            make.centerX.equalTo(self.view)
            make.height.equalTo(UIAdjust().adjustByHeightScale(0.066))
            make.width.equalTo(UIAdjust().adjustByWidthScale(0.75))
        }
        
        suggestionLabel.sizeThatFits(CGSize(width: UIAdjust().adjustByWidthScale(0.7), height: UIAdjust().adjustByHeight(40)))
        suggestionLabel.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(self.view.snp.bottom).offset(UIAdjust().adjustByHeightScale(-0.04))
            make.centerX.equalTo(self.view)
            make.height.equalTo(UIAdjust().adjustByHeightScale(0.06))
            make.width.equalTo(UIAdjust().adjustByWidthScale(0.7))
        }
        

        backImg.snp.makeConstraints { (make) -> Void in
            make.left.right.equalTo(self.view)
            make.top.equalTo(buttonExperience.snp.top).offset((-1)*Double(self.view.frame.width*0.2))
            make.height.equalTo(self.view.frame.width*2.16)
        }
        
        let statusHeight = UIApplication.shared.statusBarFrame.height
        
        titleLabel.sizeToFit()
        titleLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.view).offset(statusHeight + UIAdjust().adjustByHeight(20))
            make.centerX.equalTo(self.view)
        }
        
        
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(titleLabel.snp.bottom).offset(UIAdjust().adjustByHeight(20))
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(backImg.snp.top)
        }
        
//
//        print(UIScreen.main.bounds)
//        print(self.view.frame)
        
    }
    
//    func tapTermOfUse(_ sender: UITapGestureRecognizer) {
//        openBrowser(urlStr: "http://go.microsoft.com/fwlink/?linkid=206977")
//    }
//
//    func tapPrivacyPolicy(_ sender: UITapGestureRecognizer) {
//        openBrowser(urlStr: "https://go.microsoft.com/fwlink/?LinkId=521839")
//    }
    
    
    private func openBrowser(urlStr: String) {
        let url = URL(string: urlStr)!
        if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)

                // Fallback on earlier versions
            }
        } else {
            self.presentUserToast(message: "cannot open url")
        }

    }
    
    @objc func tapButtonTermOfUse(sender: AnyObject) {
        buttonTermOfUse.isSelected = !buttonTermOfUse.isSelected
    }
    
    @objc func tapButtonExperience(sender: AnyObject) {
        buttonExperience.isSelected = !buttonExperience.isSelected
    }

    
    @objc func clickEnter(_ sender: Any) {
        if false == self.buttonTermOfUse.isSelected {
            self.presentUserToast(message: "Term of Use and Privacy Policy need to be agreed.")
            return
        }
//        if(buttonExperience.isSelected){
//            AppData.setUserExperience(true)
//        }else{
//            AppData.setUserExperience(false)
//        }
//        UserManager.shared.setAppOpened()
//        NotificationCenter.default.post(name: AppDelegate.appStartNotification, object: nil)
//        if(!UserManager.shared.isLoggedIn()){
//            AlertLoginView.showfrist()
//        }
        UserManager.shared.logInAsVisitor() {
            UserManager.shared.setAppOpened()
            if(self.buttonExperience.isSelected){
                AppData.setUserExperience(true)
            }else{
                AppData.setUserExperience(false)
            }
            NotificationCenter.default.post(name: AppDelegate.appStartNotification, object: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class LoginRadioButton: UIButton {
    
    override open var isSelected: Bool {
        didSet {
            ChImageAssets.VoiceIcon1.image?.withRenderingMode(.alwaysTemplate)
            if isSelected {
                self.setImage(ChImageAssets.SelectedGoal.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            } else {
                self.setImage(ChImageAssets.UnselectedGoal.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.imageView?.tintColor = UIColor.white
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
