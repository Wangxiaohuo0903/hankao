//
//  XPDragingViewMutifiy.swift
//  PracticeChinese
//
//  Created by Temp on 2018/5/28.
//  Copyright © 2018年 msra. All rights reserved.
//

import UIKit
import AVFoundation

class XPDragingViewMutifiy: QuizCardSuper {
    //横向和纵向的间距
    var MarginX = 8.0
    var MarginY = 8.0
    var ViewHwight = 44.0
    var LeftIn = 33.0
    var LeftUn = 0.0
    var inUseItems = [XPDragingMutifiyItemView]()
    var unUseItems = [XPDragingMutifiyItemView]()
    var answerArray = [XPDragingMutifiyItemView]()
    var scrollView = UIScrollView()
    var dragingItem: XPDragingMutifiyItemView?
    var targetItem: XPDragingMutifiyItemView?
    var bgView = UIView()
    var checkButton = UIButton()
    var topTitle = UILabel()
    let headerTitle = UILabel()
    var dragType = DragingType.multipleEmpty
    var topHeight = ScreenUtils.height/10
    var isBottom = false//是不是从选项中点击的
    var VioceHeight:CGFloat = 0
    var allRight = true//是否全部正确
    //拼音大小
    var PinyinSize = 12.0
    //中文大小
    var ChineseSize = 18.0
    var quizView:UIView!
    var quizViewHeight:CGFloat = 0
    var quizSample: QuizSample?
    var isCorrect:Int = 0
    var bigFont = false
    
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
            if (self.quizSample?.Body!.AudioUrl != nil)  && (self.quizSample?.Body!.AudioUrl?.hasSuffix("mp3"))! && self.isCorrect == 1{
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
        topHeight = ScreenUtils.height/2.8
        PinyinSize = Double(pinyinSize)
        ChineseSize = Double(chineseSize)
        answer = quiz.Answer
        self.buildUI(quiz: quiz, voice: voice)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func setData(quiz:QuizSample,voice:Dictionary<String,SentenceDetail>){
        quizSample = quiz
        makeData(quiz: quiz, voice: voice, type: dragType, chineseSize: 18, pinyinSize: 12, style: textStyle.chineseandpinyin)
    }
    func buildUI(quiz:QuizSample,voice:Dictionary<String,SentenceDetail>) {
        quizSample = quiz
        //FIXME: - : 　是否有语音
        if(quiz.Body?.AudioUrl != nil && (quiz.Body?.AudioUrl?.hasSuffix("mp3"))!){
            videoButton.audioUrl = quiz.Body?.AudioUrl
        }
        
        scrollView.frame = quizView.bounds
        scrollView.contentSize = CGSize.init(width: quizView.bounds.size.width, height: quizView.bounds.size.height)
        quizView.addSubview(scrollView)

        var hearStr = ""
        LeftIn = 0
        
        /** 带圆角的背景 */
        bgView.frame = CGRect(x: CGFloat(0), y: topTitle.frame.maxY + 10, width: self.bounds.size.width , height: CGFloat(138))
        scrollView.addSubview(bgView)
        
        let headerheight = CGFloat(hearStr.boundingRect(with: CGSize(width:self.frame.width,height:.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(18), type: .Regular)]), context: nil).height)
        
        headerTitle.frame = CGRect(x: CGFloat(26), y: 0, width: self.bounds.size.width - CGFloat(26) * 2, height: headerheight)
        headerTitle.textAlignment = .left
        headerTitle.numberOfLines = 0
        headerTitle.text = hearStr
        headerTitle.textColor = UIColor.white
        headerTitle.font = FontUtil.getFont(size: FontAdjust().HeaderTitleFont(), type: .Regular)
        
        addSubview(headerTitle)

        
        //多空题
        for (num,token) in (quiz.Body?.Tokens)!.enumerated() {
            bigFont = true
            let item = XPDragingMutifiyItemView(frame: CGRect(x: 0, y: 0, width: 0, height: getTheFontSizeOfChinese() + getTheFontSizeOfPinyin() + Double(4)), token: token,chineseSize:getTheFontSizeOfChinese(), pinyinSize:getTheFontSizeOfPinyin(), changeAble:false,showIpa:false,true,4.0)
            item.index = num + 1
            item.orighIndex = num + 1
            if token.Text != "#" {
                item.isClearColor = true
                item.changeTextColor(chineseTextColor: UIColor.quizTextBlack, pinyinTextColor: UIColor.quizTextBlack)
            }else {
                item.isClearColor = false
            }

            scrollView.addSubview(item)
            inUseItems.append(item)
        }
        makeItemFrame(itemsArray: inUseItems, index: 0)
        
        
        if dragType == .multipleEmpty{
            bigFont = false
            //多空题
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
                
                let item = XPDragingMutifiyItemView(frame: CGRect(x: 0, y: 0, width: 0, height: getTheFontSizeOfChinese() + getTheFontSizeOfPinyin() + Double(4)), token: optionToken,chineseSize:getTheFontSizeOfChinese(), pinyinSize:getTheFontSizeOfPinyin(), changeAble:false,showIpa:false,false,20.0)
                item.index = num + 1
                item.orighIndex = num + 1
                /** 添加点击手势 */
                let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.itemTapMethod(gesture:)))
                item.addGestureRecognizer(tap)
                item.isUserInteractionEnabled = true
                scrollView.addSubview(item)
                unUseItems.append(item)
            }
            unUseItems = unUseItems.shuffle()
            makeItemFrame(itemsArray: unUseItems, index: 1)
        }
        
        let token = Token()
        token.Text = ""
        token.NativeText = ""

        
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
    
    
   
    /** 点击手势 */
    @objc func itemTapMethod(gesture: UITapGestureRecognizer) {
        
        var item = gesture.view as? XPDragingMutifiyItemView
        scrollView.bringSubviewToFront(item!)
        //更新数据源的数据
        if inUseItems.contains(item!) {
            isBottom = false
            
            let elementIndex = inUseItems.index(of: item!)
            var token = Token()
            token.Text = "#"
            
            var itemCopy = XPDragingMutifiyItemView(frame: item!.frame, token:token, chineseSize: (item?.getTheFontSizeOfChinese())!, pinyinSize: (item?.getTheFontSizeOfPinyin())!, changeAble: false, showIpa: false,false,4.0)
            itemCopy.frame = item!.frame
            itemCopy.viewWidth = 56
            itemCopy.title = item!.title
            itemCopy.spelltitle = item!.spelltitle
            itemCopy.sequence = item!.sequence
            itemCopy.index = item!.index
            itemCopy.orighIndex = item!.orighIndex
            itemCopy.isToHidden = true
            itemCopy.hasBeenSelected = false
            scrollView.addSubview(itemCopy)
            inUseItems.insert(itemCopy, at: elementIndex!)
            
            for selectitem in unUseItems {
                selectitem.isClearColor = false
                if selectitem.index == item?.index {
                    item?.frame = (selectitem.frame)
                    selectitem.isToHidden = false
                }
            }
            
            
            inUseItems.remove(at: elementIndex! + 1)
            item?.removeFromSuperview()
            
        }
        else {
            //选择选项区答案
            isBottom = true
            //拷贝一个
            var itemCopy = XPDragingMutifiyItemView()
            if item?.hasBeenSelected == false {
                item?.isToHidden = true
                itemCopy = XPDragingMutifiyItemView(frame: item!.frame, token: (item?.tokenItem)!, chineseSize: (item?.getTheFontSizeOfChinese())!, pinyinSize: (item?.getTheFontSizeOfPinyin())!, changeAble: false, showIpa: false,true,20.0)
                itemCopy.frame = item!.frame
                itemCopy.viewWidth = item!.viewWidth
                itemCopy.title = item!.title
                itemCopy.spelltitle = item!.spelltitle
                itemCopy.sequence = item!.sequence
                itemCopy.index = item!.index
                itemCopy.orighIndex = item!.orighIndex
                itemCopy.isToHidden = false
                itemCopy.isNullText = true
                itemCopy.hasBeenSelected = true
                scrollView.addSubview(itemCopy)
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.itemTapMethod(gesture:)))
                itemCopy.addGestureRecognizer(tap)
            }
            
            for (i,item) in self.inUseItems.enumerated() {
                //寻找第一个没有填写的空
                if item.tokenItem.Text == "#" {
                    itemCopy.frame = item.frame
                    inUseItems.remove(at: i)
                    item.removeFromSuperview()
                    inUseItems.insert(itemCopy, at: i)
                    break
                }
            }
        }
        updateUI()
        
        
        
        var  finished = true
        
        for (i,item) in self.inUseItems.enumerated() {
            //寻找第一个没有填写的空
            if item.tokenItem.Text == "#" {
                finished = false
                break
            }
        }
        if finished {
            //完成了
            check()
        }
    }
    
    //连词成句错误后回到初始位置
    func toOriginStatus() {
        for (elementIndex,item) in inUseItems.enumerated() {
            if item.hasBeenSelected == true {
                var token = Token()
                token.Text = "#"
                var itemCopy = XPDragingMutifiyItemView(frame: item.frame, token:token, chineseSize: (item.getTheFontSizeOfChinese()), pinyinSize: (item.getTheFontSizeOfPinyin()), changeAble: false, showIpa: false,false,4.0)
                itemCopy.frame = item.frame
                itemCopy.viewWidth = 56
                itemCopy.title = item.title
                itemCopy.spelltitle = item.spelltitle
                itemCopy.sequence = item.sequence
                itemCopy.index = item.index
                itemCopy.orighIndex = item.orighIndex
                itemCopy.isToHidden = true
                itemCopy.hasBeenSelected = false
                scrollView.addSubview(itemCopy)
                inUseItems.insert(itemCopy, at: elementIndex)
                
                for selectitem in unUseItems {
                    selectitem.isUserInteractionEnabled = true
                    if selectitem.index == item.index {
                        item.frame = (selectitem.frame)
                        selectitem.isToHidden = false
                    }
                }

                inUseItems.remove(at: elementIndex + 1)
                item.removeFromSuperview()
            }
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
        //1.先把我的答案提取出来
        answerArray.removeAll()
        for (i,item) in self.inUseItems.enumerated() {
            if item.hasBeenSelected == true {
                item.isUserInteractionEnabled = false
                answerArray.append(item)
            }
        }
        for (i,item) in self.unUseItems.enumerated() {
            item.isUserInteractionEnabled = false
        }

        var userAnswer = 0
        for (index, answerItem) in self.answerArray.enumerated() {
            userAnswer = userAnswer + answerItem.index * 10
            answerItem.isUserInteractionEnabled = false
            if index < self.answerArray.count {
                if answerItem.index == rightArray[index] {
                    answerItem.isRight = true
                } else {
                    answerItem.isRight = false
                    self.allRight = false
                }
            }else {
                answerItem.isRight = false
                self.allRight = false
            }
        }
        
        //排序如果全部正确，显示正确答案，读语音
        if !self.allRight {//有错误
            if self.firstRight {
                //第一次选择错误
                self.firstClickRight = false
                self.selectDelegate?.showSamepage(tag: self.quizSample?.Tags)
            }
            self.firstRight = false
            self.selectDelegate?.addSunValue(value: -1)
            self.isCorrect = 0
            self.audioWrongPlayer?.play()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {() -> Void in
                self.toOriginStatus()
            })
            
        }else {
            self.audioRightPlayer?.play()
            self.isCorrect = 1
            
            if self.firstRight {
                self.selectDelegate?.addSunValue(value: 2)
                self.firstRight = true
            }
            if (self.quizSample?.Body?.AudioUrl != nil  && (self.quizSample?.Body?.AudioUrl?.hasSuffix("mp3"))! && (UserDefaults.standard.integer(forKey: UserDefaultsKeyManager.readAudio) == 1)) {
                self.videoButton.playNotChangeAudioImage(self.quizSample?.Body?.AudioUrl)
            }else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {() -> Void in
                    self.selectDelegate?.gotoNextpage()
                })
            }
        }
        
        self.updateQuizSelectStatus(lid: self.Lessionid, question: (self.quizSample?.Body?.Text)!, answer: userAnswer, passed:self.firstClickRight ) { (result) in
        }
    }

    func itemFrameOfIndex(itemsArray:[XPDragingMutifiyItemView],index:Int) -> CGRect {
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
    func makeItemFrame(itemsArray: [XPDragingMutifiyItemView], index:Int) {
        
        let buttonHeight = ViewHwight
        /** 距离左边的位置 */
        var leftX = 0.0
        
        if index == 0 {
            leftX = Double(LeftIn)
        }else {
            leftX = Double(LeftUn)
        }
        /** 按钮距离上面的距离 */
        var topY = CGFloat(0.0)
        if index == 0 {
            topY = CGFloat(self.bounds.height / 5.0)
        }else {
            topY = CGFloat(self.bounds.height / 1.5)
        }
        var marginX = MarginX
        /** 按钮左右间隙 */
        if index == 0 {
            marginX = 4
        }
        /** 按钮上下间隙 */
        let marginY = MarginY
        var lastItemFrame = CGRect()
        
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
            if item.isRight {
                item.layer.backgroundColor = UIColor.correctColor.cgColor
            }
        }

        checkButton.frame = CGRect(x: self.bounds.size.width - CGFloat(LeftIn) - CGFloat(50), y:  bgView.frame.maxY, width: CGFloat(50), height: CGFloat(30))

    }

}
extension XPDragingViewMutifiy :RNTextViewDelegate{
    func tapped() {
        
    }
    
    func superViewConstraints() {
        for item in unUseItems {
            item.makeUI()
            item.changeTextColor(chineseTextColor: UIColor.quizTextBlack, pinyinTextColor: UIColor.quizTextBlack)
        }
        
        for item in inUseItems {
            item.makeUI()
            item.changeTextColor(chineseTextColor: UIColor.quizTextBlack, pinyinTextColor: UIColor.quizTextBlack)
        }
        updateUI()
        
    }
    
}

class XPDragingMutifiyItemView: UIView,NewTextViewDelegate {
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
    var bigFont: Bool = false
    var minWidth = 56.0//符号宽度
    var isNullText = false//用来标示它最初是不是一个空格
    var chineseFontSize = 28.0 {
        didSet {
            if (textLabel != nil) {
                textLabel.chineseFontSize = CGFloat(chineseFontSize)
            }
        }
    }
    var pinyinFontSize = 16.0 {
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
                textLabel.setLabelColor(chinese: UIColor.blueTheme, pinyin: UIColor.blueTheme)
                layer.cornerRadius = 0.0
                layer.masksToBounds = false
                layer.borderColor = UIColor.blueTheme.cgColor
            }
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
            
        DispatchQueue.main.async {
            self.textLabel.setLabelColor(chinese: UIColor.white, pinyin: UIColor.white)
            if self.isRight {
                self.layer.backgroundColor = UIColor.correctColor.cgColor
            }else {
                self.layer.backgroundColor = UIColor.wrongColor.cgColor
            }
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
                layer.backgroundColor = UIColor.quizButtonBgColor.cgColor
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
                if isToHidden {
                    textLabel.setLabelColor(chinese: UIColor.clear, pinyin: UIColor.clear)
                    layer.backgroundColor = UIColor.itemGrayColor.cgColor
                }else {
                    textLabel.setLabelColor(chinese: UIColor.blueTheme, pinyin: UIColor.blueTheme)
                    layer.backgroundColor = UIColor.quizButtonBgColor.cgColor
                }
            }
        }
    }
    convenience init(frame: CGRect,token:Token, chineseSize:Double, pinyinSize:Double, changeAble:Bool,showIpa:Bool,_ bigfont: Bool = false, _ marginW: Double) {
        self.init(frame: frame)
        tokenItem = token
        chineseFontSize = chineseSize
        pinyinFontSize = pinyinSize
        self.MarginW = marginW
        self.bigFont = bigfont
        if tokenItem.Text == "#" {
            isNullText = true
        }
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
//        backgroundColor = UIColor.yellow
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
                
                for i in 0...PinyinFormat(tokenItem.IPA1).count-1{
                    pinyinStr = pinyinStr + PinyinFormat(tokenItem.IPA)[i]
                }
            }
        }
        
        let pinyinColor = UIColor.quizTextBlack
        let chineseColor = UIColor.quizTextBlack
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
        if isNullText {
            if self.viewWidth < 56 {
                self.viewWidth = 56
            }
        }
        if tokenItem.Text! == "#" {
            self.viewWidth = 56
            self.isToHidden = true
        }
        
        if tokenItem.Text! == "*" {
            self.viewWidth = 160
            self.isToHidden = true
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
        if isNullText {
            if self.viewWidth < 56 {
                self.viewWidth = 56
            }
        }
        if tokenItem.Text! == "#" {
            self.viewWidth = 56
            backgroundColor = UIColor.itemGrayColor
            layer.cornerRadius = 4
        }
        
        if tokenItem.Text! == "*" {
            self.viewWidth = 160
            backgroundColor = UIColor.itemGrayColor
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
        textLabel.frame = CGRect(x: 0, y: 3, width: self.bounds.size.width, height: self.bounds.size.height - 6)
        if isPlaceholder {
            textLabel.setLabelColor(chinese: UIColor.clear, pinyin: UIColor.clear)
            layer.backgroundColor = UIColor.quizButtonBgColor.cgColor
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
                        textLabel.setLabelColor(chinese: UIColor.quizTextBlack, pinyin: UIColor.quizTextBlack)
                        layer.backgroundColor = UIColor.clear.cgColor
                    }else if isNullHolder {
                        textLabel.setLabelColor(chinese: UIColor.clear, pinyin: UIColor.clear)
                        layer.backgroundColor = UIColor.quizButtonBgColor.cgColor
                    }
                    else {
                        layer.backgroundColor = UIColor.quizButtonBgColor.cgColor
                    }
                    
                }
            }
            if isRight {
                layer.backgroundColor = UIColor.correctColor.cgColor
                textLabel.setLabelColor(chinese: UIColor.quizButtonBgColor, pinyin: UIColor.white)
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
