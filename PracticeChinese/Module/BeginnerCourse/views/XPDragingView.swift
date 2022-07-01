//
//  XPDragingView.swift
//  PracticeChinese
//
//  Created by Temp on 2018/5/28.
//  Copyright © 2018年 msra. All rights reserved.
//

import UIKit
import AVFoundation
//排序题
enum DragingType {
    case sort   //排序
    case sentences //连词成句
    case multipleEmpty //多空题
}

class XPDragingView: QuizCardSuper {
    //横向和纵向的间距
    var MarginX = 8.0
    var MarginY = 8.0
    var ViewHwight = 40.0
    var LeftIn = 33.0
    var LeftUn = 0.0
    var textQuizLabel:MTextView!
    var resultTextQuizLabel:NewTextView!
    var inUseItems = [XPDragingItemView]()
    var unUseItems = [XPDragingItemView]()
    var answerArray = [XPDragingItemView]()
    var scrollView = UIScrollView()
    var dragingItem: XPDragingItemView?
    var placeholderItem: XPDragingItemView?
    var targetItem: XPDragingItemView?
    var bgView = UIView()
    var lineView = UIView()
    var checkButton = UIButton()
    var topTitle = UILabel()
    let headerTitle = UILabel()
    var dragType = DragingType.sort
    var topHeight = ScreenUtils.height/4
    var isBottom = false
    var VioceHeight:CGFloat = 0
    var allRight = true//是否全部正确
    //拼音大小
    var PinyinSize = 12.0
    //中文大小
    var ChineseSize = 18.0
    var quizView:UIView!
    var quizViewHeight:CGFloat = 0
    var quizSample: QuizSample!
    var isCorrect:Int = 0
    var hasMatching = false//是否有接触
    var matchingNum = -1 //匹配的位置
    var checkAnswers = [Int]()
    override func refreshPageValue(){
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isCorrect = 0
        makeContinuButton()
        var buttonGap:CGFloat = 0
        if(AdjustGlobal().CurrentScale == AdjustScale.iPad){
            buttonGap = 60
            continueButton.layer.cornerRadius = 30
        }else{
            buttonGap = 44
            continueButton.layer.cornerRadius = 22
        }

        
        var  buttonheight:CGFloat = 0
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
            buttonheight = 34
        }else{
            buttonheight = UIAdjust().adjustByHeight(12)
        }
        
        var VioceHeight:CGFloat = 0
        
        if(AdjustGlobal().CurrentScale == AdjustScale.iPad){
            VioceHeight = 38
        }else{
            VioceHeight = 28
        }
        
        
        videoButtonView = UIView(frame:CGRect(x:10 , y:0, width: 28, height: 28))
        videoButtonView.backgroundColor = UIColor.blueTheme
        videoButtonView.layer.cornerRadius = VioceHeight/2
        videoButtonView.isHidden = true
        videoButton = CircularProgressView.init(frame: CGRect(x:5 , y:5, width: 18, height: 18), back: UIColor.hex(hex: "E8F0FD"), progressColor: UIColor.hex(hex: "AECFFF"), lineWidth: 2, audioURL: nil, targetObject:self)
        videoButton.playerFinishedBlock = {
//            self.checkButton.isEnabled = true
//            self.scrollView.isUserInteractionEnabled = true
            if (self.quizSample.Body!.AudioUrl != nil && (self.quizSample.Body!.AudioUrl!.hasSuffix("mp3"))) && self.isCorrect == 1 {
                self.isCorrect = 0
                self.selectDelegate?.gotoNextpage()
            }
        }
        videoButtonView.addSubview(videoButton)
        
        self.addSubview(videoButtonView)
        
        var ButtonsHeight:CGFloat = 0
        
        if(AdjustGlobal().CurrentScale == AdjustScale.iPad){
            ButtonsHeight = UIAdjust().adjustByHeight(60)
        }else if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
            ButtonsHeight = UIAdjust().adjustByHeight(45)
        }else{
            ButtonsHeight = UIAdjust().adjustByHeight(60)
        }
        quizViewHeight = self.frame.height - ButtonsHeight
        quizView = UIView.init(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: quizViewHeight))
        self.addSubview(quizView)
        
    }
    func makeData(quiz:QuizSample,voice:Dictionary<String,SentenceDetail>, type:DragingType,chineseSize:Double,pinyinSize:Double,style:textStyle) {
        quizSample = quiz
        self.dragType = type
        topHeight = ScreenUtils.height/6
        PinyinSize = Double(pinyinSize)
        ChineseSize = Double(chineseSize)
        answer = quiz.Answer
        self.buildUI(quiz: quiz, voice: voice)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func setData(quiz:QuizSample,voice:Dictionary<String,SentenceDetail>){
        makeData(quiz: quiz, voice: voice, type: dragType, chineseSize: 18, pinyinSize: 12, style: textStyle.chineseandpinyin)
    }
    func buildUI(quiz:QuizSample,voice:Dictionary<String,SentenceDetail>) {
        quizSample = quiz
        //FIXME: - : 　是否有语音
        if(quiz.Body?.AudioUrl != nil) {
            if (quiz.Body?.AudioUrl?.hasSuffix("mp3"))! {
                videoButton.audioUrl = quiz.Body?.AudioUrl
            }
        }
        
        scrollView.frame = quizView.bounds
        scrollView.contentSize = CGSize.init(width: quizView.bounds.size.width, height: quizView.bounds.size.height)
        quizView.addSubview(scrollView)

        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGesture(tap:)))
        scrollView.addGestureRecognizer(panGesture)
        
        var hearStr = ""
        LeftIn = 5
        hearStr = ""
        
        /** 带圆角的背景 */
        bgView.frame = CGRect(x: CGFloat(0), y: topTitle.frame.maxY + 10, width: self.bounds.size.width , height: CGFloat(138))
        scrollView.addSubview(bgView)
        
        lineView.backgroundColor = UIColor.blueTheme
        self.addSubview(lineView)
        
        let headerheight = CGFloat(hearStr.boundingRect(with: CGSize(width:self.frame.width,height:.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(18), type: .Regular)]), context: nil).height)
        
        headerTitle.frame = CGRect(x: CGFloat(26), y: 0, width: self.bounds.size.width - CGFloat(26) * 2, height: headerheight)
        headerTitle.textAlignment = .left
        headerTitle.numberOfLines = 0
        headerTitle.text = hearStr
        headerTitle.textColor = UIColor.quizTextBlack
        headerTitle.font = FontUtil.getFont(size: FontAdjust().HeaderTitleFont(), type: .Regular)
        
        addSubview(headerTitle)
        
        checkButton.frame = CGRect(x: self.bounds.size.width - CGFloat(26) - CGFloat(50), y:  bgView.frame.maxY, width: CGFloat(50), height: CGFloat(30))
        checkButton.titleLabel?.font = FontUtil.getFont(size: FontAdjust().FontSize(16), type: .Regular)
        checkButton.setTitle("Check", for: .normal)
        checkButton.titleLabel?.textAlignment = .right
        checkButton.setTitleColor(UIColor.hex(hex: "DDE7FC"), for: .disabled)
        checkButton.setTitleColor(UIColor.blueTheme, for: .normal)
        checkButton.addTarget(self, action: #selector(self.check), for: .touchUpInside)
        checkButton.isEnabled = true
        scrollView.addSubview(checkButton)


        //排序
        for (num,illustrationText) in quiz.Options!.enumerated() {
            let optionToken = Token()
            var text = ""
            var ipa = ""
            var ipa1 = ""
            var nativetext = ""
            
            for token in illustrationText.Tokens! {
                text.append(token.Text ?? "")
                ipa.append(" \(token.IPA!)")
                ipa1.append(" \(token.IPA!)")
                nativetext.append(token.NativeText ?? "")
            }
            if ipa == " " {
                ipa = ""
            }
            if ipa1 == " " {
                ipa1 = ""
            }
            optionToken.Text = text
            optionToken.IPA = ipa
            optionToken.IPA1 = ipa1
            optionToken.NativeText = nativetext
            
            let item = XPDragingItemView(frame: CGRect(x: 0, y: 0, width: 0, height: getTheFontSizeOfChinese() + getTheFontSizeOfPinyin() + Double(4)), token: optionToken,chineseSize:getTheFontSizeOfChinese(), pinyinSize:getTheFontSizeOfPinyin(), changeAble:false,showIpa:false)
            item.index = num + 1
            item.orighIndex = num
            /** 添加点击手势 */
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.itemTapMethod(gesture:)))
            item.addGestureRecognizer(tap)
            scrollView.addSubview(item)
            inUseItems.append(item)
        }
        inUseItems = inUseItems.shuffle()
        makeItemFrame(itemsArray: inUseItems, index: 0)

        let token = Token()
        token.Text = ""
        token.NativeText = ""
        
        placeholderItem = XPDragingItemView(frame: CGRect(x: 0, y: 0, width: 0, height: getTheFontSizeOfChinese() + getTheFontSizeOfPinyin() + Double(4)), token: token,chineseSize:getTheFontSizeOfChinese(), pinyinSize:getTheFontSizeOfPinyin(), changeAble:false,showIpa:false)
        placeholderItem!.isPlaceholder = true
        scrollView.addSubview(placeholderItem!)
        
    }
    @objc func panGesture(tap:UIPanGestureRecognizer) {
        switch tap.state {
        case .began:
            gestureBegan(gesture: tap)
            break
        case .changed:
            gestureChanged(gesture: tap)
            break
        case .ended:
            gestureEnd(gesture: tap)
            break
        default:
            break
        }
    }
    
    //汉语的大小
    func getTheFontSizeOfChinese() -> Double{
        //如果可以自己设置，那么chineseandpinyin中文28拼音18，chinese只有中文28，拼音22
        switch UserDefaults.standard.integer(forKey: UserDefaultsKeyManager.chineseandpinyin) {
        case 0://中拼文
            return FontAdjust().Option_ChineseAndPinyin_C()
        case 1://中文
            return FontAdjust().Option_ChineseAndPinyin_C()
        case 2://　拼音
            return 0
        default:
            return FontAdjust().Option_ChineseAndPinyin_C()
        }
    }
    //拼音的大小
    func getTheFontSizeOfPinyin() -> Double{
        //如果可以自己设置，那么chineseandpinyin中文28拼音18，chinese只有中文28，拼音28
        switch UserDefaults.standard.integer(forKey: UserDefaultsKeyManager.chineseandpinyin) {
        case 0://中拼文
            return FontAdjust().Option_ChineseAndPinyin_P()
        case 1://中文
            return FontAdjust().Option_ChineseAndPinyin_P()
        case 2://　拼音
            return FontAdjust().Option_ChineseAndPinyin_C()
        default:
            return FontAdjust().Option_ChineseAndPinyin_P()
        }
        
    }
    
    func gestureBegan(gesture: UIGestureRecognizer) {
        
        scrollView.isScrollEnabled = false
        let point = gesture.location(in: scrollView)
        /** 获取被拖拽的卡片 */
        dragingItem = getDragingitemWithPoint(point: point)
        if dragingItem == nil {
            return
        }
        /** 拖拽的是隐藏的 */
        if dragingItem!.isToHidden {
            return
        }
        dragingItem!.isDraging = true
        /** 设置占位按钮的标题 */
        placeholderItem?.tokenItem = (dragingItem?.tokenItem)!
        /** 用空白的方块替代拖拽的方块 */
        var index = -1
        /** 拖拽的是上面的 */
        if (inUseItems.contains(dragingItem!)) {
            isBottom = false
            index = inUseItems.index(of: dragingItem!)!
            inUseItems[index] = placeholderItem!
            placeholderItem?.frame = itemFrameOfIndex(itemsArray: inUseItems, index: index)
        }else {
            isBottom = true
            dragingItem?.isToHidden = true
            let itemCopy = XPDragingItemView(frame: dragingItem!.frame, token: (dragingItem?.tokenItem)!, chineseSize: (dragingItem?.getTheFontSizeOfChinese())!, pinyinSize: (dragingItem?.getTheFontSizeOfPinyin())!, changeAble: false, showIpa: false)
            itemCopy.frame = (dragingItem?.frame)!
            itemCopy.viewWidth = (dragingItem?.viewWidth)!
            itemCopy.title = (dragingItem?.title)!
            itemCopy.spelltitle = (dragingItem?.spelltitle)!
            itemCopy.sequence = (dragingItem?.sequence)!
            itemCopy.index = (dragingItem?.index)!
            itemCopy.orighIndex = (dragingItem?.orighIndex)!
            itemCopy.isDraging = true
            itemCopy.isToHidden = false
            scrollView.addSubview(itemCopy)
            /** 添加点击手势 */
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.itemTapMethod(gesture:)))
            itemCopy.addGestureRecognizer(tap)
            dragingItem = itemCopy
        }
        scrollView.bringSubviewToFront(dragingItem!)
        updateUI()
    }
    
    func gestureChanged(gesture: UIGestureRecognizer) {
        if !(dragingItem != nil)
        {
            return
        }
        if (dragingItem?.isToHidden)! {
            return
        }
        let point = gesture.location(in: scrollView)
        dragingItem?.center = point
        
        if (dragingItem?.frame.maxY)! <  bgView.frame.minY  || ((dragingItem?.frame.minY)! >  bgView.frame.maxY) {
            let placeIndex = inUseItems.index(of: placeholderItem!)
            inUseItems.remove(at: placeIndex!)
            inUseItems.append(placeholderItem!)
            updateUI()
            return
        }
        targetItem = getTargetitemWithPoint(point: point)
        
        if !(targetItem != nil)
        {
            return
        }
        if inUseItems.contains(placeholderItem!) {
            let elementIndex = inUseItems.index(of: placeholderItem!)
            
            inUseItems.remove(at: elementIndex!)
        }
        var targetIndex = inUseItems.index(of: targetItem!)
        placeholderItem?.tokenItem = (dragingItem?.tokenItem)!
        placeholderItem?.frame = CGRect(x: placeholderItem!.frame.origin.x, y: placeholderItem!.frame.origin.y, width: 40, height: placeholderItem!.frame.size.height)
        if (placeholderItem?.frame.origin.y == targetItem?.frame.origin.y) {
            if (Double((dragingItem?.center.x)!) < Double((targetItem?.center.x)!)) {
                targetIndex = targetIndex! + 1
            }
        }else if (Double((placeholderItem?.frame.origin.y)!) < Double((targetItem?.frame.origin.y)!)) {
            targetIndex = targetIndex! + 1
        }
        if inUseItems.contains(targetItem!) {
            inUseItems.insert(placeholderItem!, at: targetIndex!)
        }
        updateUI()
    }
    
    func gestureEnd(gesture: UIGestureRecognizer) {
        scrollView.isScrollEnabled = true
        /** 没有找到合适的拖拽按钮 就不执行下面方法 */
        if (!(dragingItem != nil)) {
            return
        }
        if dragingItem?.isToHidden == true {
            return
        }
        dragingItem?.isDraging = false
        
        if (dragingItem?.frame.minY)! > bgView.frame.maxY {
            if isBottom {
                if inUseItems.contains(placeholderItem!) {
                    let placeIndex = inUseItems.index(of: placeholderItem!)
                    inUseItems[placeIndex!] = dragingItem!
                } else {
                    inUseItems.append(dragingItem!)
                }
                
            }else {
                if inUseItems.contains(dragingItem!) {
                    let placeIndex = inUseItems.index(of: placeholderItem!)
                    inUseItems[placeIndex!] = dragingItem!
                } else {
                    if inUseItems.contains(placeholderItem!) {
                        let placeIndex = inUseItems.index(of: placeholderItem!)
                        inUseItems[placeIndex!] = dragingItem!
                    } else {
                        inUseItems.append(dragingItem!)
                    }
                }
            }
        }else {
            if inUseItems.contains(dragingItem!) {
                let placeIndex = inUseItems.index(of: placeholderItem!)
                inUseItems[placeIndex!] = dragingItem!
            } else {
                if inUseItems.contains(placeholderItem!) {
                    let placeIndex = inUseItems.index(of: placeholderItem!)
                    inUseItems[placeIndex!] = dragingItem!
                } else {
                    inUseItems.append(dragingItem!)
                }
            }
            
        }
        updateUI()
    }
    
    /** 点击手势 */
    @objc func itemTapMethod(gesture: UITapGestureRecognizer) {
  
    }
    
    //连词成句错误后回到初始位置
    func toOriginStatus() {
        for (i,item) in inUseItems.enumerated() {
            for selectitem in unUseItems {
                if selectitem.index == item.index {
                    item.frame = (selectitem.frame)
                    selectitem.isToHidden = false
                    item.removeFromSuperview()
                }
            }
            item.removeFromSuperview()
        }
        inUseItems.removeAll()
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
    
    @objc func check() {
        //判断完之前不能点击
        checkButton.isEnabled = false
        scrollView.isUserInteractionEnabled = false
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
            answerInt = answerInt * 10 + item.index
        }
        checkAnswers.append(answerInt)
        var userAnswer = 0
        for (i,item) in inUseItems.enumerated() {
            userAnswer = userAnswer + item.index * 10
            if i < rightArray.count {
                if item.index == rightArray[i]{
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

        //排序如果全部正确，显示正确答案，读语音
        if dragType == .sort {
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {() -> Void in
                    self.inUseItems = self.inUseItems.shuffle()
                    self.allRight = true
                    for (i,item) in self.inUseItems.enumerated() {
                        item.isDraging = false
                        if i < rightArray.count {
                            if item.index == rightArray[i]{
                            } else {
                                self.allRight = false
                            }
                        }else {

                            self.allRight = false
                        }
                    }
                    if self.allRight {//是正确的顺序，再重新排列一次
                        self.inUseItems = self.inUseItems.shuffle()
                    }
                    self.makeItemFrame(itemsArray: self.inUseItems, index: 0)
                    self.checkButton.isEnabled = true
                    self.scrollView.isUserInteractionEnabled = true
                })
                
            }else {
                audioRightPlayer?.play()
                self.isCorrect = 1
                if self.firstRight {
                    self.firstClickRight = true
                    self.selectDelegate?.addSunValue(value: 2)
                    self.firstRight = true
                }
                //正确
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.MarginX = 0.0
                    self.MarginY = 0.0
                    for item in self.inUseItems {
                        item.MarginW = 8.0
                        item.chineseFontSize = FontAdjust().ChineseAndPinyin_C()
                        item.pinyinFontSize = FontAdjust().ChineseAndPinyin_P()
                        item.isChecked = true
                        item.textLabel.refreshFont(chineseSize: CGFloat(FontAdjust().ChineseAndPinyin_C()), pinyinSize: CGFloat(FontAdjust().ChineseAndPinyin_P()), chineseColor: UIColor.quizTextBlack, pinyinColor: UIColor.quizTextBlack)
                        item.bigFont = true
                        item.isUserInteractionEnabled = false
                    }
                    
                    for item in self.inUseItems {
                        item.makeUI()
                    }
                    
                    self.updateUI()
                    
                    //TODO: - : 读语音
                    if (self.quizSample?.Body?.AudioUrl != nil  && (self.quizSample?.Body?.AudioUrl?.hasSuffix("mp3"))! && (UserDefaults.standard.integer(forKey: UserDefaultsKeyManager.readAudio) == 1)) {
                        self.videoButton.playNotChangeAudioImage(self.quizSample?.Body?.AudioUrl)
                    }else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.selectDelegate?.gotoNextpage()
                            self.scrollView.isUserInteractionEnabled = true
                        }
                    }
                }
            }
            //埋点：点击check
            let info = ["Scope" : "Learn","Lessonid" : self.Lessionid,"Subscope" : "Quiz","IndexPath" : quizSample.Body?.Text,"Event" : "Check","Value" : checkAnswers] as [String : Any]
            UserManager.shared.logUserClickInfo(info)
            
            self.updateQuizSelectStatus(lid: self.Lessionid, question: (self.quizSample?.Body?.Text)!, answer: userAnswer, passed:self.firstClickRight ) { (result) in
            }
        }
        
    }
    /** 获取被拖动方块的方法 */
    func getDragingitemWithPoint(point: CGPoint) -> XPDragingItemView? {
        var item: XPDragingItemView?
        let checkRect = CGRect(x: point.x, y: point.y, width: 1, height: 1)
        for enumitem in scrollView.subviews {
            if(!enumitem.isKind(of: XPDragingItemView.self))
            {
                continue
            }
            if (!inUseItems.contains(enumitem as! XPDragingItemView))
            {
                if (!unUseItems.contains(enumitem as! XPDragingItemView))
                {
                    continue
                }
            }
            if (enumitem.frame.intersects(checkRect))
            {
                item = enumitem as? XPDragingItemView
                break
            }
        }
        return item
    }
    /** 获取目标位置方块的方法 */
    func getTargetitemWithPoint(point: CGPoint) -> XPDragingItemView? {
        var targetitem: XPDragingItemView?

        for enumitem in scrollView.subviews {
            if(!enumitem.isKind(of: XPDragingItemView.self))
            {
                continue
            }
            if(enumitem == dragingItem)
            {
                continue
            }
            if(enumitem == placeholderItem)
            {
                continue
            }
            if (!inUseItems.contains(enumitem as! XPDragingItemView))
            {
                continue
            }
            if (enumitem.frame.contains(point))
            {
                targetitem = enumitem as? XPDragingItemView
            }
        }
        
        
        
        
//        hasMatching = false
//        for enumitem in scrollView.subviews {
//            if(!enumitem.isKind(of: XPDragingItemView.self))
//            {
//                continue
//            }
//            if(enumitem == dragingItem)
//            {
//                continue
//            }
//            if(enumitem == placeholderItem)
//            {
//                continue
//            }
//            if (enumitem.isKind(of: XPDragingItemView.self))
//            {
//                var item = enumitem as? XPDragingItemView
//                item?.isMatching = -1
//            }
//
//            let isMutul: Bool = dragingItem!.frame.intersects(enumitem.frame)
//
//            if (isMutul)
//            {
//                hasMatching = true
//                targetitem = enumitem as? XPDragingItemView
//                targetitem?.isMatching = 1
//                for itemSu in inUseItems {
//                    if itemSu.isMatching == 1 {
//                        let targetIndex = inUseItems.index(of: itemSu)
//                        matchingNum = targetIndex!
//                        break
//                    }
//                }
//            }else {
//                var item = enumitem as? XPDragPariingItemView
//                item?.bezierShapleyer.fillColor = UIColor.white.cgColor
//                item?.bringSubview(toFront: (item?.titleLabel)!)
//            }
//        }
        return targetitem
    }
    func itemFrameOfIndex(itemsArray:[XPDragingItemView],index:Int) -> CGRect {
        return itemsArray[index].frame
    }
    
    func updateUI() {

        UIView.animate(withDuration: 0.25, animations: {() -> Void in
            self.updateItemFrame()
        }, completion: {(_ finished: Bool) -> Void in
            if !self.inUseItems.contains(self.placeholderItem!) {
                self.placeholderItem?.frame = CGRect(x: self.placeholderItem!.frame.origin.x, y: self.placeholderItem!.frame.origin.y, width: 40, height: self.placeholderItem!.frame.size.height)
            }
        })
    }
    
    func updateItemFrame() {
        makeItemFrame(itemsArray: inUseItems, index: 0)
    }
    /** index = 0 或1，代表上面或者下面 */
    func makeItemFrame(itemsArray: [XPDragingItemView], index:Int) {

        let buttonHeight = ViewHwight
        /** 距离左边的位置 */
        var leftX = 0.0
        
        if index == 0 {
            leftX = Double(LeftIn)
        }else {
            leftX = Double(LeftUn)
        }
        /** 按钮距离上面的距离 */
        var topY = CGFloat(10 + 160 * index) + topHeight

        /** 按钮左右间隙 */
        let marginX = MarginX;
        /** 按钮上下间隙 */
        let marginY = MarginY;
        var lastItemFrame = CGRect()
        placeholderItem?.frame = CGRect(x: Double(bounds.width / 2), y: Double(topY), width: Double(40), height: Double(buttonHeight))
        
        for (i,item) in itemsArray.enumerated() {
            item.frame = CGRect(x: Double(leftX), y: Double(topY), width: Double(item.getWidth()), height: Double(buttonHeight))
            var left = 0.0
            if index == 0 {
                left = Double(LeftIn)
            }else {
                left = Double(LeftUn)
            }
            /** sequence = 1 表示某行第一个，sequence = 2 表示某行最后一个 */
            if (i == 0) {
                item.sequence = 1
            }
            if (i == itemsArray.count - 1) {
                item.sequence = 2
            }
            /** 处理换行 */
            let width1 = Double(item.frame.origin.x) + Double(item.viewWidth) + Double(marginX)
            let width2 = Double(self.bounds.size.width) - Double(left)
            
            if width1 > width2 {
                item.sequence = 1
                let preItem = itemsArray[i - 1]
                preItem.sequence = 2
                topY += CGFloat(buttonHeight) + CGFloat(marginY)
                if index == 0 {
                    leftX = Double(LeftIn)
                }else {
                    leftX = Double(LeftUn)
                }
                item.frame = CGRect(x: Double(leftX), y: Double(topY), width: Double(item.viewWidth), height: Double(buttonHeight))
                
            }
            leftX = leftX + Double(item.frame.size.width) + Double(marginX)
            if (i == itemsArray.count - 1) {
                lastItemFrame = item.frame
            }
//            if item.isRight {
//                item.layer.backgroundColor = UIColor.correctColor.cgColor
//            }
        }
        bgView.frame = CGRect(x: Double(LeftIn), y: Double(CGFloat(10 + 160 * index) + topHeight), width: Double(CGFloat(self.frame.size.width)), height: Double(lastItemFrame.maxY  - (CGFloat(10 + 160 * index) + topHeight) + 20))
        lineView.frame = CGRect(x: Double(LeftIn), y: Double(bgView.frame.maxY - 5), width: Double(CGFloat(self.frame.size.width) - CGFloat(2 * LeftIn)), height: 0.5)

        checkButton.frame = CGRect(x: self.bounds.size.width - CGFloat(LeftIn) - CGFloat(50), y:  bgView.frame.maxY, width: CGFloat(50), height: CGFloat(30))

    }

}
extension XPDragingView :RNTextViewDelegate{
    func tapped() {
        
    }
    
    func superViewConstraints() {
        //切换模式
        if (textQuizLabel != nil) {
            textQuizLabel.systemAutoChangeWithoutFrame()
        }
        for item in unUseItems {
            item.makeUI()
            item.changeTextColor(chineseTextColor: UIColor.blueTheme, pinyinTextColor: UIColor.blueTheme)
        }
        
        for item in inUseItems {
            item.makeUI()
            item.changeTextColor(chineseTextColor: UIColor.blueTheme, pinyinTextColor: UIColor.blueTheme)
        }
        
        updateUI()
        
    }
    
}

class XPDragingModel: NSObject {
    /** 显示的标题 */
    var title = ""
    var spelltitle = ""
    /** 在未选择Array中的位置 */
    var index = -1
    //0 是上面，1是下面
    var arrayNum = -1
}

class XPDragingItemView: UIView,NewTextViewDelegate {
    func superViewConstraints() {
        
    }
    
    func tapped() {
        
    }
    var MarginW = 20.0//计算出的文字再加MarginW
    var tokenItem = Token()
    /** 序号，是某行的第一个或者最后一个吗，为了做行的位置适配 */
    var sequence = -1
    //0 是上面，1是下面
    var arrayNum = -1
    //被匹配的题
    var isMatching = -1
    var index = -1
    var orighIndex = -1
    var dragButton = UIButton()
    /** 显示的标题 */
    var title: String = "" {
        didSet {
            if isToHidden {
                textLabel.setLabelColor(chinese: UIColor.clear, pinyin: UIColor.clear)
                layer.backgroundColor = UIColor.itemGrayColor.cgColor
            }
            else {
                textLabel.setLabelColor(chinese: UIColor.blueTheme, pinyin: UIColor.blueTheme)
                layer.backgroundColor = UIColor.quizButtonBgColor.cgColor
            }
        }
    }
    /** 主标题 */
    var textLabel: NewTextView!
    var spelltitle: String = ""
    /** 是否占位 */
    var isPlaceholder = false
    /** view宽度 */
    var viewWidth = 0.0
    /** 在原数组中的位置 */
    var originalIndex = -1
    var hasBeenSelected = false//多空题，如果被选择了就是true
    var bigFont = false//使用大号字体
    var chineseFontSize = 18.0 {
        didSet {
            if (textLabel != nil) {
                textLabel.chineseFontSize = CGFloat(chineseFontSize)
            }
        }
    }
    var pinyinFontSize = 12.0 {
        didSet {
            if (textLabel != nil) {
                textLabel.pinyinFontSize = CGFloat(pinyinFontSize)
            }
        }
    }
    /** 是否背景透明 */
    var isClearColor: Bool = false {
        didSet {
            if isClearColor {
                textLabel.setLabelColor(chinese: UIColor.white, pinyin: UIColor.white)
                layer.cornerRadius = 0.0
                layer.masksToBounds = false
                layer.borderColor = UIColor.blueTheme.cgColor
            }
        }
    }
    /** 黑字白色背景 */
    var isChecked: Bool = false {
        didSet {
            textLabel.setLabelColor(chinese: UIColor.quizTextBlack, pinyin: UIColor.quizTextBlack)
            layer.borderColor = UIColor.white.cgColor
            layer.backgroundColor = UIColor.white.cgColor
        }
    }
    /** 是否占位，选词排序的提示框 */
    var isNullHolder: Bool = false {
        didSet {
            if isNullHolder {
                textLabel.setLabelColor(chinese: UIColor.clear, pinyin: UIColor.clear)
            }
        }
    }
    /** 是否正确 */
    var isRight: Bool = false {
        didSet {
            textLabel.setLabelColor(chinese: UIColor.white, pinyin: UIColor.white)
            if isRight {
                layer.backgroundColor = UIColor.correctColor.cgColor
            }else {
                layer.backgroundColor = UIColor.wrongColor.cgColor
            }
        }
    }
    /** 是否隐藏 */
    var isToHidden = false {
        didSet {
            if isToHidden {
                self.isUserInteractionEnabled = false
                textLabel.setLabelColor(chinese: UIColor.clear, pinyin: UIColor.clear)
                layer.backgroundColor = UIColor.itemGrayColor.cgColor
            }
            else {
                self.isUserInteractionEnabled = true
                textLabel.setLabelColor(chinese: UIColor.blueTheme, pinyin: UIColor.blueTheme)
                layer.backgroundColor = UIColor.white.cgColor
            }
        }
    }
    /** 拖拽的那一个 */
    var isDraging: Bool = false {
        didSet {
            textLabel.setLabelColor(chinese: UIColor.blueTheme, pinyin: UIColor.blueTheme)
            if isDraging {
                textLabel.setLabelColor(chinese: UIColor.blueTheme, pinyin: UIColor.blueTheme)
                layer.backgroundColor = UIColor.hex(hex: "C8DAFF").cgColor
            }else {
                if (isToHidden) {
                    textLabel.setLabelColor(chinese: UIColor.clear, pinyin: UIColor.clear)
                    layer.backgroundColor = UIColor.itemGrayColor.cgColor
                }else {
                    if isClearColor {
                        textLabel.setLabelColor(chinese: UIColor.white, pinyin: UIColor.white)
                        layer.backgroundColor = UIColor.clear.cgColor
                    }else if isNullHolder {
                        textLabel.setLabelColor(chinese: UIColor.clear, pinyin: UIColor.clear)
                        layer.backgroundColor = UIColor.itemGrayColor.cgColor
                    }else if isChecked {
                        textLabel.setLabelColor(chinese: UIColor.quizTextBlack, pinyin: UIColor.quizTextBlack)
                        layer.backgroundColor = UIColor.white.cgColor
                    }
                    else {
                        textLabel.setLabelColor(chinese: UIColor.quizContinueColor, pinyin: UIColor.quizContinueColor)
                        layer.backgroundColor = UIColor.quizButtonBgColor.cgColor
                    }
                    
                }
 
            }
        }
    }
    convenience init(frame: CGRect,token:Token, chineseSize:Double, pinyinSize:Double, changeAble:Bool,showIpa:Bool) {
        self.init(frame: frame)
        tokenItem = token
        chineseFontSize = chineseSize
        pinyinFontSize = pinyinSize
        makeUI()
    }
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func makeUI() {
        layer.cornerRadius = 4.0
        layer.masksToBounds = true
        var pinyinStr = ""
        var chineseStr = tokenItem.Text!
        //ipa 不等于ipa1, 使用变调后的
        //当前显示模式为中拼，ipa为空则 取“”，如果为拼音，则使用nativeText中的内容
        if tokenItem.IPA == "" || !(tokenItem.IPA != nil) {
            //表示空格
            if tokenItem.Text == "#" || tokenItem.Text == "*"{
                pinyinStr = ""
                chineseStr = ""
            }else {
                switch UserDefaults.standard.integer(forKey: UserDefaultsKeyManager.chineseandpinyin) {
                case 0://中拼
                    pinyinStr = ""
                case 1://中文
                    pinyinStr = ""
                case 2://拼音
                    pinyinStr = tokenItem.NativeText!
                default:
                    pinyinStr = ""
                }
            }
        }else {
            if(PinyinFormat(tokenItem.IPA1).count == 1){
                
                pinyinStr = PinyinFormat(tokenItem.IPA)[0]
                
            }else{
                
                for i in 0...PinyinFormat(tokenItem.IPA).count-1{
                    pinyinStr = pinyinStr + PinyinFormat(tokenItem.IPA)[i]
                }
            }
        }
        
        let pinyinColor = UIColor.white
        let chineseColor = UIColor.white
        let maxSize:CGSize = CGSize(width:self.bounds.width,height:.greatestFiniteMagnitude)
        let exWidth = MarginW
        switch UserDefaults.standard.integer(forKey: UserDefaultsKeyManager.chineseandpinyin) {
        case 0://中拼文
            //汉字的长度
            let width1 = Double((tokenItem.Text! as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(getTheFontSizeOfChinese()), type: .Regular)]), context: nil).width) + exWidth
            //拼音的长度
            let width2 = Double((pinyinStr as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(getTheFontSizeOfPinyin()), type: .Regular)]), context: nil).width) + exWidth
            
            self.viewWidth = width1 > width2 ? width1 : width2
            
        case 1://中文
            //汉字的长度
            let width1 = Double((tokenItem.Text! as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(getTheFontSizeOfChinese()), type: .Regular)]), context: nil).width) + exWidth
            
            self.viewWidth = width1
        case 2://　拼音
            //拼音的长度
            let width2 = Double((pinyinStr as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(getTheFontSizeOfPinyin()), type: .Regular)]), context: nil).width) + exWidth
            self.viewWidth = width2
            
        default:
            self.viewWidth = 0
        }
        if (textLabel != nil) {
            textLabel.refresh(chinese: chineseStr, chineseSize: FontAdjust().FontSize(getTheFontSizeOfChinese()), pinyin: pinyinStr, pinyinSize: FontAdjust().FontSize(getTheFontSizeOfPinyin()),false)
        }else {
            textLabel = NewTextView(frame: self.bounds, chinese: chineseStr, chineseSize: FontAdjust().FontSize(getTheFontSizeOfChinese()), pinyin: pinyinStr, pinyinSize: FontAdjust().FontSize(getTheFontSizeOfPinyin()), style: newTextStyle.chineseandpinyin, changeAble: true,false)
        }
        
        textLabel.setLabelColor(chinese: chineseColor, pinyin: pinyinColor)
        textLabel.setLabelTextAli(chinese: .center, pinyin: .center)
        textLabel.isUserInteractionEnabled = false
        textLabel.delegate = self as NewTextViewDelegate
        addSubview(textLabel)
        
        if tokenItem.IPA == "" || !(tokenItem.IPA != nil) {
            self.viewWidth = 35
        }
        if tokenItem.Text! == "#" {
            self.viewWidth = 56
            backgroundColor = UIColor.quizButtonBgColor
            layer.backgroundColor = UIColor.colorFromRGB(255, 255, 255, 0.16).cgColor
            layer.cornerRadius = 4
        }
        
        if tokenItem.Text! == "*" {
            self.viewWidth = 160
            backgroundColor = UIColor.quizButtonBgColor
            layer.cornerRadius = 4
        }
        if isRight {
            layer.backgroundColor = UIColor.correctColor.cgColor
        }
    }
    //汉语的大小
    func getTheFontSizeOfChinese() -> Double{
        //如果可以自己设置，那么chineseandpinyin中文28拼音18，chinese只有中文28，拼音22
        switch UserDefaults.standard.integer(forKey: UserDefaultsKeyManager.chineseandpinyin) {
        case 0://中拼文
            if self.bigFont
            {
                return FontAdjust().ChineseAndPinyin_C()
            }
            return FontAdjust().Option_ChineseAndPinyin_C()
        case 1://中文
            if self.bigFont
            {
                return FontAdjust().ChineseAndPinyin_C()
            }
            return FontAdjust().Option_ChineseAndPinyin_C()
        case 2://　拼音
            return 0
        default:
            if self.bigFont
            {
                return FontAdjust().ChineseAndPinyin_C()
            }
            return FontAdjust().Option_ChineseAndPinyin_C()
        }
        
    }
    //拼音的大小
    func getTheFontSizeOfPinyin() -> Double{
        //如果可以自己设置，那么chineseandpinyin中文28拼音18，chinese只有中文28，拼音28
        
        switch UserDefaults.standard.integer(forKey: UserDefaultsKeyManager.chineseandpinyin) {
        case 0://中拼文
            if self.bigFont
            {
                return FontAdjust().ChineseAndPinyin_P()
            }
            return FontAdjust().Option_ChineseAndPinyin_P()
        case 1://中文
            return 0
        case 2://　拼音
            if self.bigFont
            {
                return FontAdjust().ChineseAndPinyin_C()
            }
            return FontAdjust().Option_ChineseAndPinyin_C()
        default:
            if self.bigFont
            {
                return FontAdjust().ChineseAndPinyin_P()
            }
            return FontAdjust().Option_ChineseAndPinyin_P()
        }
        
    }
    func getWidth() -> Double{
        
        var pinyinStr = ""
        //ipa 不等于ipa1, 使用变调后的
        var showIpa1 = false
        if(PinyinFormat(tokenItem.IPA1).count == 1){
            if tokenItem.IPA != tokenItem.IPA {
                showIpa1 = true
            }
            pinyinStr = PinyinFormat(tokenItem.IPA)[0]
        }else{
            if tokenItem.IPA != tokenItem.IPA {
                showIpa1 = true
            }
            if tokenItem.IPA == "" || !(tokenItem.IPA != nil) {
                if tokenItem.Text == "#" || tokenItem.Text == "*"{
                    pinyinStr = ""
                }else {
                    switch UserDefaults.standard.integer(forKey: UserDefaultsKeyManager.chineseandpinyin) {
                    case 0://中拼
                        pinyinStr = ""
                    case 1://中文
                        pinyinStr = ""
                    case 2://拼音
                        pinyinStr = tokenItem.NativeText!
                    default:
                        pinyinStr = ""
                    }
                }
            }else {
                for i in 0...PinyinFormat(tokenItem.IPA).count-1{
                    pinyinStr = pinyinStr + PinyinFormat(tokenItem.IPA)[i]
                }
            }
        }
        let maxSize:CGSize = CGSize(width:CGFloat(MAXFLOAT),height:.greatestFiniteMagnitude)
        let exWidth = MarginW
        switch UserDefaults.standard.integer(forKey: UserDefaultsKeyManager.chineseandpinyin) {
        case 0://中拼文
            //汉字的长度
            let width1 = Double((tokenItem.Text! as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(getTheFontSizeOfChinese()), type: .Regular)]), context: nil).width) + exWidth
            //拼音的长度
            let width2 = Double((pinyinStr as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(getTheFontSizeOfPinyin()), type: .Regular)]), context: nil).width) + exWidth
            
            self.viewWidth = width1 > width2 ? width1 : width2
        case 1://中文
            //汉字的长度
            let width1 = Double((tokenItem.Text! as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(getTheFontSizeOfChinese()), type: .Regular)]), context: nil).width) + exWidth
            
            self.viewWidth = width1
        case 2://　拼音
            //拼音的长度
            let width2 = Double((pinyinStr as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(getTheFontSizeOfPinyin()), type: .Regular)]), context: nil).width) + exWidth
            
            self.viewWidth = width2
            
        default:
            self.viewWidth = 0
        }
        if tokenItem.IPA == "" || !(tokenItem.IPA != nil) {
            self.viewWidth = 35
        }
        if tokenItem.Text! == "#" {
            self.viewWidth = 56
            backgroundColor = UIColor.colorFromRGB(255, 255, 255, 0.16)
            layer.cornerRadius = 4
        }
        
        if tokenItem.Text! == "*" {
            self.viewWidth = 160
            backgroundColor = UIColor.colorFromRGB(255, 255, 255, 0.16)
            layer.cornerRadius = 4
        }
        return self.viewWidth
    }
    func changeTextColor(chineseTextColor:UIColor, pinyinTextColor:UIColor) {
        textLabel.chineseLabel.textColor = chineseTextColor
        textLabel.pinyinLabel.textColor = pinyinTextColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel.frame = CGRect(x: 0, y: 2, width: self.bounds.size.width, height: self.bounds.size.height - 4)
        if isPlaceholder {
            textLabel.setLabelColor(chinese: UIColor.clear, pinyin: UIColor.clear)
            layer.backgroundColor = UIColor.clear.cgColor
        }else {
            textLabel.setLabelColor(chinese: UIColor.blueTheme, pinyin: UIColor.blueTheme)
            if (isDraging) {
                layer.backgroundColor = UIColor.hex(hex: "C8DAFF").cgColor
            }else {
                if (isToHidden) {
                    textLabel.setLabelColor(chinese: UIColor.clear, pinyin: UIColor.clear)
                    layer.backgroundColor = UIColor.itemGrayColor.cgColor
                }else {
                    if isClearColor {
                        textLabel.setLabelColor(chinese: UIColor.white, pinyin: UIColor.white)
                        layer.backgroundColor = UIColor.clear.cgColor
                    }else if isNullHolder {
                        textLabel.setLabelColor(chinese: UIColor.clear, pinyin: UIColor.clear)
                        layer.backgroundColor = UIColor.itemGrayColor.cgColor
                    }else if isChecked {
                        textLabel.setLabelColor(chinese: UIColor.quizTextBlack, pinyin: UIColor.quizTextBlack)
                        layer.backgroundColor = UIColor.white.cgColor
                    }
                    else {
                        textLabel.setLabelColor(chinese: UIColor.quizContinueColor, pinyin: UIColor.quizContinueColor)
                        layer.backgroundColor = UIColor.quizButtonBgColor.cgColor
                    }
                    
                }
            }
        }
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
