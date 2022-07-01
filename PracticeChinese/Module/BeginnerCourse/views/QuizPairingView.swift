//
//  QuizPairingView.swift
//  PracticeChinese
//
//  Created by Temp on 2018/6/22.
//  Copyright © 2018年 msra. All rights reserved.
//配对题
import UIKit
import AVFoundation

class QuizPairingView: QuizCardSuper {
    //横向和纵向的间距
    var MarginX = 26.0
    var MarginY = 18.0
    var ViewHwight = 54.0
    var LeftIn = 26.0
    var LeftUn = 18.0
    var inUseItems = [XPDragPariingItemView]()
    var unUseItems = [XPDragPariingItemView]()
    var scrollView = UIScrollView()
    var dragingItem: XPDragPariingItemView?//拖拽块
    var targetItem: XPDragPariingItemView?//目标块
    var placeholderItem: XPDragPariingItemView?
    let headerTitle = UILabel()
    var topHeight = 20
    var isBottom = false
    var allRight = true//是否全部正确
    var hasMatching = false//是否有接触
    var matchingNum = -1 //匹配的位置
    var VioceHeight:CGFloat = 0
    var labelGap:CGFloat = 0
    var quizSample: QuizSample!
    var isCorrect:Int = 0
    var checkAnswers = [Int]()//埋点
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isCorrect = 0

        scrollView.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: self.frame.height-ScreenUtils.heightByM(y: CGFloat(75)))
        scrollView.contentSize = CGSize.init(width: bounds.size.width, height: self.frame.height-ScreenUtils.heightByM(y: CGFloat(75)))
        addSubview(scrollView)
        makeContinuButton()
        var buttonGap:CGFloat = 0
        if(AdjustGlobal().CurrentScale == AdjustScale.iPad){
            buttonGap = 60
            continueButton.layer.cornerRadius = 30
        }else{
            buttonGap = 44
            continueButton.layer.cornerRadius = 22
        }

        
        if(AdjustGlobal().CurrentScale == AdjustScale.iPad){
            labelGap = 20
        }else{
            labelGap = 10
        }
        
        
        var  buttonheight:CGFloat = 0
        
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
            buttonheight = 34
        }else{
            buttonheight = UIAdjust().adjustByHeight(15)
        }
        

        
        continueButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.snp.bottom).offset(0)
            make.width.equalTo(self.continueWidth)
            make.height.equalTo(buttonGap)
            make.centerX.equalTo(self)
        }
        
        
        if(AdjustGlobal().CurrentScale == AdjustScale.iPad){
            VioceHeight = 34
        }else{
            VioceHeight = 24
        }
        videoButtonView = UIView(frame:CGRect(x:self.frame.width*0.5-12.5 , y:self.frame.height*0.20-ScreenUtils.heightByM(y: CGFloat(35)), width: 28, height: 28))
        videoButtonView.backgroundColor = UIColor.white
        videoButtonView.layer.cornerRadius = VioceHeight/2
        
        videoButton = CircularProgressView.init(frame: CGRect(x:5 , y:5, width: 18, height: 18), back: UIColor.hex(hex: "E8F0FD"), progressColor: UIColor.hex(hex: "AECFFF"), lineWidth: 2, audioURL: nil, targetObject:self)
        videoButton.playerFinishedBlock = {

        }
        videoButtonView.addSubview(videoButton)
        videoButtonView.isHidden = true
        self.addSubview(videoButtonView)
        
        
        videoButton.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(videoButtonView)
            make.width.height.equalTo(VioceHeight - 10)
        }
        
        
    }
    override func setData(quiz:QuizSample,voice:Dictionary<String,SentenceDetail>){
        quizSample = quiz
        
        buildUI(quiz: quiz, voice: voice)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //quiz:QuizSample,voice:Dictionary<String,SentenceDetail>
    func buildUI(quiz:QuizSample,voice:Dictionary<String,SentenceDetail>) {
        var buttonGap:CGFloat = 0
        if(AdjustGlobal().CurrentScale == AdjustScale.iPad){
            buttonGap = 60
            continueButton.layer.cornerRadius = 30
        }else{
            buttonGap = 44
            continueButton.layer.cornerRadius = 22
        }
        
        let hearStr = "Match the correct items."
        headerTitle.frame = CGRect(x: CGFloat(10), y: 10, width: self.bounds.size.width - 80, height: 45)
        headerTitle.textAlignment = .left
        headerTitle.adjustsFontSizeToFitWidth = true
        headerTitle.numberOfLines = 0
        headerTitle.text = hearStr
        headerTitle.textColor = UIColor.textGray
        headerTitle.font = FontUtil.getFont(size: FontAdjust().HeaderTitleFont(), type: .Regular)
        addSubview(headerTitle)
        
        for (i, illustrationText) in (quiz.Options?.enumerated())! {
            //            TODO: - : 拼音用ipa
            if i < (quiz.Options?.count)! / 2 {
                let item = XPDragPariingItemView(frame: CGRect(x: 0, y: 0, width: self.bounds.width - 52, height: 55))
                item.bezierShapleyer = ViewPath.yb_maskLayer(with: item.bounds, rectCorner: [10,10,0,0], cornerRadius: 8, borderColor: UIColor.clear, backgroundColor: UIColor.itemGrayColor, arrowWidth: 18, arrowHeight: 6, arrowPosition: item.bounds.size.width / 2, arrowDirection: ViewPathArrowDirection.bottom)
                item.layer.addSublayer(item.bezierShapleyer)
                
                item.viewWidth = Double(self.bounds.width - 52)
                item.index = i + 1
                item.originalIndex = i + 1
                item.arrayNum = 0
                item.isUserInteractionEnabled = false
                item.backgroundColor = UIColor.clear
                item.makeData(optionItem: illustrationText,textColor: UIColor.quizTextBlack)
                scrollView.addSubview(item)
                inUseItems.append(item)
            }
            
        }
        
        for (i, illustrationText) in (quiz.Options?.enumerated())! {
            //            TODO: - : 拼音用ipa
            if i >= (quiz.Options?.count)! / 2 {
                let item = XPDragPariingItemView(frame: CGRect(x: 0, y: 0, width: self.bounds.width - 52, height: 55))
                item.bezierShapleyer = ViewPath.yb_maskLayer(with: item.bounds, rectCorner: [0,0,10,10], cornerRadius: 8, borderColor: UIColor.clear, backgroundColor: UIColor.quizButtonBgColor, arrowWidth: 18, arrowHeight: 6, arrowPosition: item.bounds.size.width / 2, arrowDirection: ViewPathArrowDirection.top)
                item.layer.addSublayer(item.bezierShapleyer)
                item.viewWidth = Double(self.bounds.width - 52)
                item.index = i + 1
                item.originalIndex = i + 1
                item.arrayNum = 1
                item.isUserInteractionEnabled = true
                item.makeData(optionItem: illustrationText,textColor: UIColor.blueTheme)
                item.backgroundColor = UIColor.clear
                //\\
//                item.titleLabel.frame = CGRect(x: item.titleLabel.frame.origin.x, y: CGFloat((CGFloat(65) - CGFloat(item.titleLabel.getViewHeight())) / 2.0), width: item.titleLabel.frame.size.width, height: item.titleLabel.frame.size.height)
                scrollView.addSubview(item)
                unUseItems.append(item)
                let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGesture(gesture:)))
                item.addGestureRecognizer(panGesture)
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.itemTapMethod(gesture:)))
                item.addGestureRecognizer(tap)
            }
        }
        self.unUseItems = self.unUseItems.shuffle()

        
        makeItemFrame(itemsArray: inUseItems, index: 0)
        makeItemFrame(itemsArray: unUseItems, index: 1)
        
    }
    @objc func panGesture(gesture:UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            gestureBegan(gesture: gesture)
            break
        case .changed:
            gestureChanged(gesture: gesture)
            break
        case .ended:
            gestureEnd(gesture: gesture)
            break
        default:
            break
        }
        let point: CGPoint = gesture.translation(in: scrollView)
        //        targetItem = getTargetitemWithPoint(dragingView: dragingItem!)
        //该方法返回在横坐标上、纵坐标上拖动了多少像素
        gesture.view?.center = CGPoint(x: (gesture.view?.center.x)! + point.x, y: (gesture.view?.center.y)! + point.y)
        gesture.setTranslation(CGPoint(x: 0, y: 0), in: scrollView)
    }
    
    func gestureBegan(gesture: UIGestureRecognizer) {
        /** 获取被拖拽的卡片 */
        dragingItem = gesture.view as! XPDragPariingItemView
        dragingItem?.bezierShapleyer.fillColor = UIColor.itemDragingColor.cgColor
        dragingItem?.bringSubviewToFront((dragingItem?.titleLabel)!)
        scrollView.bringSubviewToFront(dragingItem!)
        
        if dragingItem == nil {
            return
        }
    }
    
    func gestureChanged(gesture: UIGestureRecognizer) {
        if !(dragingItem != nil)
        {
            return
        }
        
        let point = gesture.location(in: scrollView)
        targetItem = getTargetitemWithPoint(dragingView: dragingItem!)
        
    }
    
    func gestureEnd(gesture: UIGestureRecognizer) {
        
        /** 没有找到合适的拖拽按钮 就不执行下面方法 */
        if (!(dragingItem != nil)) {
            return
        }
        
        dragingItem?.isDraging = false
        dragingItem?.bezierShapleyer.fillColor = UIColor.quizButtonBgColor.cgColor
        targetItem?.bezierShapleyer.fillColor = UIColor.itemGrayColor.cgColor
        for item in inUseItems {
            if item.arrayNum == 0 {
                item.bezierShapleyer.fillColor = UIColor.itemGrayColor.cgColor
            }else {
                item.bezierShapleyer.fillColor = UIColor.quizButtonBgColor.cgColor
            }
        }
        if hasMatching {
            //有触碰
            if unUseItems.contains(dragingItem!) {
                unUseItems.remove(at: unUseItems.index(of: dragingItem!)!)
                if matchingNum < inUseItems.count - 1 {
                    let item = inUseItems[matchingNum + 1]
                    if item.arrayNum == 1 {
                        inUseItems.remove(at: matchingNum + 1)
                        unUseItems.append(item)
                    }
                }
                inUseItems.insert(dragingItem!, at: matchingNum + 1)
            }else {
                let dragNum = inUseItems.index(of: dragingItem!)!
                if matchingNum <= inUseItems.count - 2 {
                    if dragNum != matchingNum + 1 {
                        let item = inUseItems[matchingNum + 1]
                        let matchingItem = inUseItems[matchingNum]
                        if item.arrayNum == 0 {
                            inUseItems.insert(dragingItem!, at: matchingNum + 1)
                            if dragNum > matchingNum {
                                inUseItems.remove(at: dragNum + 1)
                            }else {
                                inUseItems.remove(at: dragNum)
                            }
                        }else {
                           swap(&inUseItems[dragNum], &inUseItems[matchingNum + 1])
                        }
                    }
                }else {
                    inUseItems.insert(dragingItem!, at: matchingNum + 1)
                    inUseItems.remove(at: dragNum)
                }
                
            }
        }else {
            if inUseItems.contains(dragingItem!) {
                inUseItems.remove(at: inUseItems.index(of: dragingItem!)!)
                unUseItems.append(dragingItem!)
            }
        }
        updateUI()
        if unUseItems.count == 0 {
            // 检查对错
            check()
        }
    }
    
    
    
    override func showContinue() {
        var  buttonheight:CGFloat = 0
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
            buttonheight = 34
        }else{
            buttonheight = UIAdjust().adjustByHeight(12)
        }
        var buttonGap:CGFloat = 0
        if(AdjustGlobal().CurrentScale == AdjustScale.iPad){
            buttonGap = 60
            continueButton.layer.cornerRadius = 30
        }else{
            buttonGap = 44
            continueButton.layer.cornerRadius = 22
        }
        UIView.animate(withDuration: 0.3) {
            self.continueButton.alpha = 1
            self.continueButton.frame = CGRect(x:(self.frame.width - 150)/2, y:self.frame.height - buttonGap - buttonheight, width: 150, height:buttonGap)
            self.layoutIfNeeded()
        }
    }
    
    func check() {

        let rightSequence = quizSample?.Answer
        var integerN = rightSequence//商
        var remainder = 0//余数
        var rightArray = [Int]()
        while integerN! > 0 {
            remainder = integerN! % 10
            integerN = integerN! / 10
            rightArray.append(remainder)
        }
        rightArray = rightArray.reversed()
        
        allRight = true
        var answerInt = 0
        for item in inUseItems {
            answerInt = answerInt * 10 + item.originalIndex
        }
        checkAnswers.append(answerInt)
        var userAnswer = 0
        for (i,item) in inUseItems.enumerated() {
            userAnswer = userAnswer + item.originalIndex * 10
            if i % 2 == 1 && item.arrayNum == 1 {
                if i < rightArray.count{
                    if item.originalIndex == rightArray[i] {
                        item.isRight = true
                    } else {
                        item.isRight = false
                        self.allRight = false
                    }
                }else {
                    item.isRight = false
                    self.allRight = false
                }
            }
        }
        if !self.allRight {//有错误
            if firstRight {
                //第一次选择错误
                self.firstClickRight = false
                self.selectDelegate?.showSamepage(tag: quizSample.Tags)
            }
            self.firstRight = false
            self.selectDelegate?.addSunValue(value: -1)
            audioWrongPlayer?.play()
            self.isCorrect = 0
            //有错误
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {() -> Void in
                for item in self.inUseItems {
                    if item.arrayNum == 1 {
                        item.bezierShapleyer.fillColor = UIColor.quizButtonBgColor.cgColor
                        item.titleLabel.setLabelColor(chinese: UIColor.blueTheme, pinyin: UIColor.blueTheme)
                        self.inUseItems.remove(at: self.inUseItems.index(of: item)!)
                        self.unUseItems.append(item)
                    }
                }
                self.unUseItems = self.unUseItems.shuffle()
                self.updateUI()
            })
        }else {
            audioRightPlayer?.play()
            self.isCorrect = 1
            if self.firstRight {
                self.firstClickRight = true
                self.selectDelegate?.addSunValue(value: 2)
                self.firstRight = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.selectDelegate?.gotoNextpage()
            }
        }
        //埋点：点击check
        let info = ["Scope" : "Learn","Lessonid" : self.Lessionid,"Subscope" : "Quiz","IndexPath" : quizSample?.Body?.Text,"Event" : "Check","Value" : checkAnswers] as [String : Any]
        UserManager.shared.logUserClickInfo(info)
        self.updateQuizSelectStatus(lid: self.Lessionid, question: (self.quizSample?.Body?.Text)!, answer: userAnswer, passed:self.firstClickRight ) { (result) in
        }
        updateUI()
    }
    /** 点击手势 */
    @objc func itemTapMethod(gesture: UITapGestureRecognizer) {
        
        let item = gesture.view as? XPDragPariingItemView
        //更新数据源的数据
        if inUseItems.contains(item!) {
            let elementIndex = inUseItems.index(of: item!)
            inUseItems.remove(at: elementIndex!)
            unUseItems.append(item!)
        }
        updateUI()
    }
    
    //连词成句错误后回到初始位置
    func toOriginStatus() {
        for (i,item) in inUseItems.enumerated() {
            for selectitem in unUseItems {
                if selectitem.originalIndex == item.originalIndex {
                    item.frame = (selectitem.frame)
                    item.removeFromSuperview()
                }
            }
        }
        inUseItems.removeAll()
    }
    
    
    /** 获取被拖动方块的方法 */
    func getDragingitemWithPoint(point: CGPoint) -> XPDragPariingItemView? {
        var item: XPDragPariingItemView?
        let checkRect = CGRect(x: point.x, y: point.y, width: 1, height: 1)
        for enumitem in scrollView.subviews {
            if(!enumitem.isKind(of: XPDragPariingItemView.self))
            {
                continue
            }
            if (!inUseItems.contains(enumitem as! XPDragPariingItemView))
            {
                if (!unUseItems.contains(enumitem as! XPDragPariingItemView))
                {
                    continue
                }
            }
            if (enumitem.frame.intersects(checkRect))
            {
                item = enumitem as? XPDragPariingItemView
                break
            }
        }
        return item
    }
    /** 获取目标位置方块的方法 */
    func getTargetitemWithPoint(dragingView: XPDragPariingItemView) -> XPDragPariingItemView? {
        var targetitem: XPDragPariingItemView?
        hasMatching = false
        for enumitem in scrollView.subviews {
            if(!enumitem.isKind(of: XPDragPariingItemView.self))
            {
                continue
            }
            if(enumitem == dragingItem)
            {
                continue
            }
            if (enumitem.isKind(of: XPDragPariingItemView.self))
            {
                var item = enumitem as? XPDragPariingItemView
                item?.isMatching = -1
                if item?.arrayNum == 1 {
                    continue
                }
            }
            
            let isMutul: Bool = dragingView.frame.intersects(enumitem.frame)
            
            if (isMutul)
            {
                hasMatching = true
                targetitem = enumitem as? XPDragPariingItemView
                targetitem?.isMatching = 1
                targetitem?.bezierShapleyer.fillColor = UIColor.itemGrayColor.cgColor
                for itemSu in inUseItems {
                    if itemSu.isMatching == 1 {
                        let targetIndex = inUseItems.index(of: itemSu)
                        matchingNum = targetIndex!
                        itemSu.bezierShapleyer.fillColor = UIColor.hex(hex: "DBE3F5").cgColor
                        itemSu.bringSubviewToFront(itemSu.titleLabel)
                        break
                    }
                }
            }else {
                var item = enumitem as? XPDragPariingItemView
                item?.bezierShapleyer.fillColor = UIColor.itemGrayColor.cgColor
                item?.bringSubviewToFront((item?.titleLabel)!)
            }
        }
        return targetitem
    }
    func itemFrameOfIndex(itemsArray:[XPDragPariingItemView],index:Int) -> CGRect {
        return itemsArray[index].frame
    }
    
    func updateUI() {
        
        UIView.animate(withDuration: 0.35, animations: {() -> Void in
            self.updateItemFrame()
        }, completion: {(_ finished: Bool) -> Void in
        })
    }
    
    func updateItemFrame() {
        makeItemFrame(itemsArray: inUseItems, index: 0)
        makeItemFrame(itemsArray: unUseItems, index: 1)
    }
    /** index = 0 或1，代表上面或者下面 */
    func makeItemFrame(itemsArray: [XPDragPariingItemView], index:Int) {
        let buttonHeight = ViewHwight
        /** 距离左边的位置 */
        var leftX = 0.0
        leftX = Double(0)
        /** 按钮距离上面的距离 */
        var topY1 = Int(ScreenUtils.heightByM(y: CGFloat(85)))
        var topY2 = 1000
        if index == 1 {
            
            topY2 = Int(CGFloat(ScreenUtils.height - ScreenUtils.heightByM(y: CGFloat(200))))
        }
        /** 按钮左右间隙 */
        let marginX = MarginX;
        
        if index == 0 {//上面的位置以上为准
            for (i,item) in itemsArray.enumerated() {
                /** 按钮上下间隙 */
                var gap = MarginY
                if AdjustGlobal().CurrentScale == AdjustScale.iPhone4 || AdjustGlobal().CurrentScale == AdjustScale.iPhone5 {
                    gap = 12.0
                }
                if item.arrayNum == 1 {
                    gap = -12.0
                }
                if i == 0 {
                    topY1 = Int(Double(topY1))
                }else {
                    topY1 = Int(Double(topY1) + Double(buttonHeight) + Double(gap))
                }
                item.frame = CGRect(x: Double(marginX) + Double(leftX), y: Double(topY1), width: Double(item.viewWidth), height: Double(buttonHeight))
            }
        }else {//下面的位置以下为准
            for (i,item) in itemsArray.enumerated().reversed() {
                /** 按钮上下间隙 */
                var gap = MarginY
                if AdjustGlobal().CurrentScale == AdjustScale.iPhone4 || AdjustGlobal().CurrentScale == AdjustScale.iPhone5 {
                    gap = 12.0
                }
                if i == itemsArray.count - 1 {
                    topY2 = Int(Double(topY2))
                }else {
                    topY2 = Int(Double(topY2) - Double(buttonHeight) - Double(gap))
                }
                item.frame = CGRect(x: Double(marginX) + Double(leftX), y: Double(topY2), width: Double(item.viewWidth), height: Double(buttonHeight))
            }
        }
    }
    override func refreshPageValue(){
    }
}
//拖拽的控件
class XPDragPariingItemView: UIView{
    var tokenItems = [Token]()
    //\\
//    var titleLabel:MTextView!
    
    var titleLabel:PairingTextView!
    var viewWidth = 0.0
    /** 在原数组中的位置 */
    var originalIndex = -1
    //0 是上面，1是下面
    var arrayNum = -1
    //被匹配的题
    var isMatching = -1
    /** 拖拽的那一个 */
    var isDraging: Bool = false
    var index = -1
    var bezierPath = UIBezierPath()
    var bezierShapleyer = CAShapeLayer()
    /** 是否正确 */
    var isRight: Bool = false {
        didSet {
            if isRight {
                self.bezierShapleyer.fillColor = UIColor.correctColor.cgColor
            }else {
                self.bezierShapleyer.fillColor = UIColor.wrongColor.cgColor
            }
            titleLabel.setLabelColor(chinese: UIColor.white, pinyin: UIColor.white)
        }
    }
    var textColor = UIColor.white {
        didSet {
            //\\
//            self.titleLabel.pinyinColor = textColor
//            self.titleLabel.chineseColor = textColor
            titleLabel.setLabelColor(chinese: textColor, pinyin: textColor)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func makeData(optionItem:IllustrationText,textColor:UIColor) {
        tokenItems.removeAll()
        tokenItems = optionItem.Tokens!
        //
        if ((optionItem.Tokens?.count)! <= 0 || optionItem.Tokens == nil) {
            //纯英文的
            //\\
//            titleLabel = MTextView(frame: bounds, tokens: tokenItems, chineseSize: FontAdjust().Option_ChineseAndPinyin_C(), pinyinSize: FontAdjust().Option_ChineseAndPinyin_C(), style: .chineseandpinyin, changeAble: true,showIpa:false,true)
            var rect = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - 10)
            if arrayNum == 1 {
                rect = CGRect(x: 0, y: 10, width: bounds.width, height: bounds.height - 10)
            }

            titleLabel = PairingTextView(frame: rect, chinese: "", chineseSize: CGFloat(FontAdjust().Option_ChineseAndPinyin_C()), pinyin: optionItem.Displaytext!, pinyinSize: CGFloat(FontAdjust().Option_ChineseAndPinyin_C()),chinesePinyin:"", style: .pinyin, changeAble: true, pinyinFontRegular: true, isEnglish: true)
            titleLabel.setLabelColor(chinese: textColor, pinyin: textColor)
            
            
        }else {
            //\\
//            titleLabel = MTextView(frame: bounds, tokens: tokenItems, chineseSize: FontAdjust().Option_ChineseAndPinyin_C(), pinyinSize: FontAdjust().Option_ChineseAndPinyin_P(), style: .chineseandpinyin, changeAble: true,showIpa:false,false)
            
            var chineseLongStr = ""
            var pinyinLongStr = ""
            var chinesePinyinLongStr = ""
            
            for tokenItem in optionItem.Tokens! {
                var pinyinStr = ""
                var chinesePinyinStr = ""
                var chineseStr = ""
                if tokenItem.Text != nil {
                    chineseStr = tokenItem.Text!
                }
                //当前显示模式为中拼，ipa为空则 取“”，如果为拼音，则使用nativeText中的内容
                if tokenItem.IPA1 == "" || !(tokenItem.IPA1 != nil) {
                    //表示空格
                    if tokenItem.Text == "#" || tokenItem.Text == "*" || tokenItem.Text == "\\n" {
                        pinyinStr = ""
                        chinesePinyinStr = ""
                        chineseStr = ""
                    }else {
                        switch UserDefaults.standard.integer(forKey: UserDefaultsKeyManager.chineseandpinyin) {
                        case 0://中拼
                            pinyinStr = tokenItem.NativeText!
                        case 1://中文
                            pinyinStr = ""
                        case 2://拼音
                            pinyinStr = tokenItem.NativeText!
                            chinesePinyinStr = tokenItem.NativeText!
                        default:
                            pinyinStr = ""
                            chinesePinyinStr = ""
                        }
                    }

                }else {
                    if(PinyinFormat(tokenItem.IPA1).count == 1){

                        pinyinStr = PinyinFormat(tokenItem.IPA1)[0]
                        chinesePinyinStr = PinyinFormat(tokenItem.IPA1)[0]
                        
                    }else{
                        for i in 0...PinyinFormat(tokenItem.IPA1).count-1{
                            pinyinStr = pinyinStr + PinyinFormat(tokenItem.IPA1)[i]
                            chinesePinyinStr = chinesePinyinStr + PinyinFormat(tokenItem.IPA1)[i]
                        }
                    }
                }
                pinyinLongStr = pinyinLongStr + " " + pinyinStr
                chinesePinyinLongStr = chinesePinyinLongStr + " " + chinesePinyinStr
                chineseLongStr = chineseLongStr + chineseStr
            }
            var rect = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - 10)
            if arrayNum == 1 {
                rect = CGRect(x: 0, y: 10, width: bounds.width, height: bounds.height - 10)
            }
            titleLabel = PairingTextView(frame: rect, chinese: chineseLongStr, chineseSize: CGFloat(FontAdjust().Option_ChineseAndPinyin_C()), pinyin: pinyinLongStr, pinyinSize: CGFloat(FontAdjust().Option_ChineseAndPinyin_P()),chinesePinyin:chinesePinyinLongStr, style: .pinyin, changeAble: true, pinyinFontRegular: true, isEnglish: false)
            
            titleLabel.setLabelColor(chinese: textColor, pinyin: textColor)
        }

        //\\
//        titleLabel.MarginX = 0
//        titleLabel.itemAli = .center
//        titleLabel.selectEnable = false
        self.textColor = textColor
        //\\
//        titleLabel.pinyinColor = textColor
//        titleLabel.chineseColor = textColor
        addSubview(titleLabel)
        bringSubviewToFront(titleLabel)
        //\\
//        titleLabel.setData()
//        titleLabel.changeTextColor(chineseTextColor: textColor, pinyinTextColor: textColor)
//        titleLabel.frame = CGRect(x: 0, y: 10, width: titleLabel.getViewWidth() , height: titleLabel.getViewHeight())
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension QuizPairingView: RNTextViewDelegate {
    func superViewConstraints() {
        //切换模式

        for item in unUseItems {
            
            item.titleLabel.systemAutoChangeWithoutFrame()
            //\\
//            item.titleLabel.changeTextColor(chineseTextColor: UIColor.white, pinyinTextColor:  UIColor.white)
//            item.titleLabel.frame = CGRect(x: item.titleLabel.frame.origin.x, y: CGFloat((CGFloat(65) - CGFloat(item.titleLabel.getViewHeight())) / 2.0), width: item.titleLabel.frame.size.width, height: item.titleLabel.frame.size.height)
            item.titleLabel.setLabelColor(chinese: UIColor.blueTheme, pinyin: UIColor.blueTheme)
        }
        
        for item in inUseItems {
            item.titleLabel.systemAutoChangeWithoutFrame()
            if item.arrayNum == 0 {
                //\\
//                item.titleLabel.changeTextColor(chineseTextColor: UIColor.blueTheme, pinyinTextColor: UIColor.blueTheme)
//                item.titleLabel.frame = CGRect(x: item.titleLabel.frame.origin.x, y: CGFloat((CGFloat(45) - CGFloat(item.titleLabel.getViewHeight())) / 2.0), width: item.titleLabel.frame.size.width, height: item.titleLabel.frame.size.height)
                item.titleLabel.setLabelColor(chinese: UIColor.quizTextBlack, pinyin: UIColor.quizTextBlack)
            }else {
                //\\
//                item.titleLabel.changeTextColor(chineseTextColor: UIColor.white, pinyinTextColor:  UIColor.white)
//                item.titleLabel.frame = CGRect(x: item.titleLabel.frame.origin.x, y: CGFloat((CGFloat(65) - CGFloat(item.titleLabel.getViewHeight())) / 2.0), width: item.titleLabel.frame.size.width, height: item.titleLabel.frame.size.height)
                item.titleLabel.setLabelColor(chinese: UIColor.blueTheme, pinyin: UIColor.blueTheme)
            }
        }
        
    }
    func tapped() {
        
    }
    
}
