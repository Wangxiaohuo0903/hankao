//
//  MTextView.swift
//  ChineseDev
//
//  Created by Temp on 2018/6/12.
//  Copyright © 2018年 msra. All rights reserved.
//

import UIKit


enum itemAlignment {
    case left
    case center
}

class MTextView: UIView, YBPopupMenuDelegate {
    //初始化，包括token数组，中文，中文字体大小，拼音，拼音字体大小，textStyle显示样式，中拼音结合还是中文，changeAble：自己设置textStyle，还是从本地获取
    //按钮之间的间隙
    var MarginX = 2.0
    var MarginWidth = 2.0
    //行与行之间的间隙
    var MarginY = 5.0
    //按钮的高度
    var ViewHwight = 40.0
    //最左边的距离
    var MarginLeft = 0.0
    //最上面的距离
    var MarginTop = 0.0
    //背景图
    var bgView: UIView!
    //最大宽度
    var MaxWidth = 0.0
    //最大高度
    var MaxHeight = 0.0
    //是否允许折行，如果不允许，那么超过最大宽度就要缩小字体
    var foldEnable = true
    //当前item是否可点击
    var selectEnable = true
    //拼音颜色
    var pinyinColor = UIColor.quizTextBlack
    //中文颜色
    var chineseColor = UIColor.quizTextBlack
    //拼音大小
    var PinyinSize = FontAdjust().ChineseAndPinyin_P()
    //中文大小
    var ChineseSize = FontAdjust().ChineseAndPinyin_C()
    //tokens
    var tokensArr = [Token]()
    //存放Views
    var viewItemArray = [MDragingItemView]()
    
    var ChangeAble = false
    //是否显示变调，和变调颜色,true表示只显示ipa1
    var ipaFamily = true

    var TextStyle = textStyle.chineseandpinyin
    //整体item的位置是居中还是偏左
    var itemAli = itemAlignment.left
    
    var addLine: Bool = false
    //当前点击的View
    var currentTapView = MDragingItemView()
//    var delegate:MTextViewDelegate!
    var whiteColor: Bool = false
    var pop: YBPopupMenu?
    var EnglishEnable: Bool = false
    
    var clickToken: ((String) -> Void)?
    
    init(frame: CGRect,tokens: [Token], chineseSize:Double, pinyinSize:Double,style:textStyle,changeAble:Bool,showIpa:Bool, _ englishEnable:Bool = false) {
        super.init(frame: frame)
        MaxWidth = Double(frame.width)
        tokensArr = tokens

        PinyinSize = Double(pinyinSize)
        ChineseSize = Double(chineseSize)
        ChangeAble = changeAble
        ipaFamily = showIpa
        self.EnglishEnable = englishEnable//是否是纯英文的
        
    }
    func changeTextColor(chineseTextColor:UIColor, pinyinTextColor:UIColor) {
        
        for (i,item) in viewItemArray.enumerated() {
            item.changeTextColor(chineseTextColor: chineseTextColor, pinyinTextColor: pinyinTextColor)
        }
    }
    //汉语的大小
    func getTheFontSizeOfChinese() -> Double{
        if EnglishEnable {
            return 0
        }
            switch UserDefaults.standard.integer(forKey: UserDefaultsKeyManager.chineseandpinyin) {
            case 0://中拼文
                return ChineseSize
            case 1://中文
                return ChineseSize
            case 2://　拼音
                return 0
            default:
                return ChineseSize
            }


    }
    //拼音的大小
    func getTheFontSizeOfPinyin() -> Double{
        //如果可以自己设置，那么chineseandpinyin中文28拼音18，chinese只有中文28，拼音28
        if EnglishEnable {
            return PinyinSize
        }
            switch UserDefaults.standard.integer(forKey: UserDefaultsKeyManager.chineseandpinyin) {
            case 0://中拼文
                return PinyinSize
            case 1://中文
                return 0
            case 2://　拼音
                return ChineseSize
            default:
                return PinyinSize
            }
    }
    
    /** 点击手势 */
    @objc func itemTapMethod(gesture: UITapGestureRecognizer) {
        ybPopupMenuDidDismiss()
        let tapView = gesture.view as! MDragingItemView
        currentTapView = tapView
        currentTapView.backgroundColor = UIColor.colorFromRGB(73, 116, 206, 0.2)
        currentTapView.layer.cornerRadius = 3
        
        print("点击我了")
        clickToken!(currentTapView.tokenItem.Text!)
        var pinyinStr = ""
        if(PinyinFormat(currentTapView.tokenItem.IPA).count == 1){
            pinyinStr = PinyinFormat(currentTapView.tokenItem.IPA)[0]
        }else{
            for i in 0...PinyinFormat(currentTapView.tokenItem.IPA).count-1{
                pinyinStr = pinyinStr + " " + PinyinFormat(currentTapView.tokenItem.IPA)[i]
            }
        }
        let maxSize:CGSize = CGSize(width:CGFloat(156),height:.greatestFiniteMagnitude)
        //汉字的长度
        let width1 = Double((currentTapView.tokenItem.Text! as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(18), type: .Regular)]), context: nil).width) + 4
        //拼音的长度
        let width2 = Double((pinyinStr as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(16), type: .Regular)]), context: nil).width) + 4
        //英文的长度
        let width3 = Double((currentTapView.tokenItem.NativeText! as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(12), type: .Regular)]), context: nil).width) + 6
        print("宽度\(width3)")

        var maxWidth = max(width1, width2)
        maxWidth = max(width3, maxWidth)
        //最大宽度180，最小宽度，74
        if maxWidth > 156 {
         maxWidth = max(156, maxWidth)
        }
        if maxWidth < 50 {
            maxWidth = max(50, maxWidth)
        }
        
        tapView.textLabel.setLabelColor(chinese: UIColor.blueTheme, pinyin: UIColor.blueTheme)
        if !(pop != nil) {
            pop = YBPopupMenu()
        }
        pop?.showRely(on: tapView, superView:self.superview, titles: [pinyinStr,currentTapView.tokenItem.Text,currentTapView.tokenItem.NativeText], icons: nil,difficultyLevel:Int32(currentTapView.tokenItem.DifficultyLevel!), menuWidth: CGFloat(maxWidth + 24), delegate: self)
        
    }
    func ybPopupMenuDidDismiss() {
        currentTapView.backgroundColor = UIColor.white
        currentTapView.layer.cornerRadius = 0
        if currentTapView.showIpa1 {
            if let label = currentTapView.textLabel {
                currentTapView.textLabel.setLabelColor(chinese: UIColor.hex(hex: "333333"), pinyin: UIColor.blueTheme)
            }
        }else {
            if let label = currentTapView.textLabel {
                currentTapView.textLabel.setLabelColor(chinese: UIColor.hex(hex: "333333"), pinyin: UIColor.hex(hex: "333333"))
            }
        }
    }

    //恢复原始的字体颜色
    func toOriginTextColor(){
        currentTapView.textLabel.setLabelColor(chinese: UIColor.hex(hex: "333333"), pinyin: UIColor.hex(hex: "333333"))
    }
    //布局
    func setData() {
        viewItemArray.removeAll()
        for (i,token) in tokensArr.enumerated() {
            let item = MDragingItemView(frame: CGRect(x: 0, y: 0, width: 0, height: getTheFontSizeOfPinyin() + getTheFontSizeOfChinese()), token: token,chineseSize:getTheFontSizeOfChinese(), pinyinSize:getTheFontSizeOfPinyin(), changeAble:ChangeAble,showIpa:ipaFamily,EnglishEnable)
            if (i == 0) {
                currentTapView = item
            }
           /** 添加点击手势 */
            if selectEnable{
                //不是标点或者特殊文字才有横线和可点击
                if token.IPA1 == "" || !(token.IPA1 != nil) {
                    item.addLine = false
                }else {
                    let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.itemTapMethod(gesture:)))
                    item.addGestureRecognizer(tap)
                    item.addLine = true
                }
            }else {
                item.addLine = false
            }
            self.addSubview(item)
            viewItemArray.append(item)
        }
        makeItemFrame(itemsArray: viewItemArray)
    }
    
    //设置frame
    func makeItemFrame(itemsArray: [MDragingItemView]) {
        let buttonHeight = getTheFontSizeOfChinese() + getTheFontSizeOfPinyin() + 8
        /** 距离左边的位置 */
        var leftX = Double(MarginLeft)

        /** 按钮距离上面的距离 */
        var topY = MarginTop
        /** 按钮左右间隙 */
        let marginX = MarginX;
        /** 按钮上下间隙 */
        let marginY = MarginY;
        
        for (i,item) in itemsArray.enumerated() {
            item.makeUI()
            item.sequence = -1
            item.chineseFontSize = getTheFontSizeOfChinese()
            item.pinyinFontSize = getTheFontSizeOfPinyin()
            item.frame = CGRect(x:Double(leftX), y: Double(topY), width: item.getWidth(), height: Double(buttonHeight))
//            print(item.frame)
            let left = Double(MarginLeft)
            if (i == 0) {
                item.sequence = 1
            }
            /** 处理换行 */
            if item.viewWidth == 0 {
                item.sequence = 1
                if i < itemsArray.count - 1 {
                    let lastItem = itemsArray[i + 1]
                    lastItem.sequence = 2
                }
            }
            
            let width1 = Double(item.frame.origin.x) + Double(item.viewWidth) + Double(marginX)
            if width1 > MaxWidth || item.viewWidth == 0{
                if itemsArray.count > 1 {
                    let preItem = itemsArray[i - 1]
                    preItem.sequence = 2
                }
                item.sequence = 1
                topY = Double(topY) + Double(buttonHeight) + Double(marginY)
                leftX = Double(MarginLeft)
                item.frame = CGRect(x: Double(marginX) + Double(leftX), y: Double(topY), width: Double(item.viewWidth), height: Double(buttonHeight))
            }
            
            if (i == itemsArray.count - 1) {
                item.sequence = 2
            }
            leftX = leftX + Double(item.frame.size.width) + Double(marginX)
            item.textLabel.systemAutoChangeWithoutFrame()
            if item.addLine {
                item.changeLineView(color: UIColor.colorFromRGB(153, 153, 153, 1))
            }else {
                item.changeLineView(color: UIColor.colorFromRGB(0, 0, 0, 0))
            }
            
        }
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: getViewWidth(), height: getViewHeight())
        if (itemAli == itemAlignment.center) {
            resetView(itemsArray: itemsArray)
        }
    }
    func resetView(itemsArray: [MDragingItemView]) {
        let buttonHeight = CGFloat(getTheFontSizeOfPinyin() + getTheFontSizeOfChinese() + 8)
        /** 按钮距离上面的距离 */
        var topY = CGFloat(MarginTop)
        /** 按钮左右间隙 */
        let marginX = MarginX;
        if itemsArray.count == 1{
            let itemi = itemsArray[0]
            let mar = (getViewWidth() - (itemi.frame.maxX) - CGFloat(MarginX) + CGFloat(MarginLeft)) / 2
            // 距离左边距
            var leftX: CGFloat = mar
            itemi.frame = CGRect(x: CGFloat(marginX) + CGFloat(leftX), y: topY, width: CGFloat(itemi.viewWidth), height: CGFloat(buttonHeight))
            return
        }
        for var i in 0..<itemsArray.count {
            let itemi = itemsArray[i]
            if itemi.sequence == 1 {
                for j in i..<itemsArray.count {
                    let itemj = itemsArray[j]
                    if itemj.sequence == 2 {
                        let mar = (getViewWidth() - (itemj.frame.maxX) - CGFloat(MarginX) + CGFloat(MarginLeft)) / 2
                        // 距离左边距
                        var leftX: CGFloat = mar
                        for k in i...j {
                            let item: MDragingItemView? = itemsArray[k]
                            item?.frame = CGRect(x: CGFloat(marginX) + CGFloat(leftX), y: topY, width: CGFloat((item?.viewWidth)!), height: CGFloat(buttonHeight))
                            // 处理换行
                            if item?.sequence == 2 {
                                topY = CGFloat(buttonHeight) + CGFloat(MarginY) + topY
                                break
                            }
                            // 重置高度
                            var frame: CGRect? = item?.frame
                            frame?.size.height = CGFloat(buttonHeight)
                            item?.frame = frame!
                            leftX = (item?.frame.size.width)! + CGFloat(marginX) + leftX
                        }
                        if j < itemsArray.count - 2 {
                            i = j
                        }
                        break
                    }
                }
            }else if itemi.sequence == 2 {
                let preItem = itemsArray[i - 1]
                if preItem.sequence == 2 {
                    let mar = (getViewWidth() - (itemi.frame.maxX) - CGFloat(MarginX) + CGFloat(MarginLeft)) / 2
                    // 距离左边距
                    let leftX: CGFloat = mar
                    itemi.frame = CGRect(x: CGFloat(marginX) + CGFloat(leftX), y: topY, width: CGFloat(itemi.viewWidth
                    ), height: CGFloat(buttonHeight))
                }
            }
        }
    }
    func systemAutoChangeWithoutFrame() {
        makeItemFrame(itemsArray: viewItemArray)
    }
    func itemTapMethod() {
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //获取整个View的高度
    func getViewHeight() -> CGFloat {
        //TODO: - :
        let lastItemView = viewItemArray.last
        if lastItemView != nil {
            return lastItemView!.frame.maxY
        }
        return 0
    }
    //获取最大需要的宽度
    func getViewWidth() -> CGFloat {
        return CGFloat(MaxWidth)
    }
}

class MDragingItemView: UIView,NewTextViewDelegate {
    func superViewConstraints() {
        textLabel.systemAutoChangeWithoutFrame()
    }
    
    func tapped() {
        
    }
    /** 主标题 */
    var textLabel: NewTextView!

    /** view宽度 */
    var viewWidth = 0.0
    var tokenItem = Token()
    var isNullText = false//用来标示它最初是不是一个空格
    /** 序号，是某行的第一个或者最后一个吗，为了做行的位置适配，1表示行首，2表示行末 */
    var sequence = -1
    var ChangeAble = false
    var lineView: UIView?
    //是否有变调
    var showIpa1 = false
    //是否显示变调，和变调颜色,true表示只显示ipa1
    var ipaFamily = true
    var hasChoosed = false//多空题，如果选择了答案，那么这个就是true
    
    var EnglishEnable = false
    
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
    var viewFrame = CGRect()

    var addLine = false

    func changeLineView(color:UIColor) {
        if (lineView != nil) {
            lineView?.removeFromSuperview()
            lineView = nil
        }
        lineView = UIView(frame: CGRect(x: 2, y: self.bounds.size.height, width: CGFloat(self.viewWidth) - 4, height: 0.5))
        drawDashLine(lineView, lineLength: 1, lineSpacing: 1, lineColor: color)
        self.addSubview(lineView!)
    }
    convenience init(frame: CGRect,token:Token, chineseSize:Double, pinyinSize:Double, changeAble:Bool,showIpa:Bool ,_ englishEnable:Bool = false) {
        self.init(frame: frame)
        tokenItem = token
        ChangeAble = changeAble
        chineseFontSize = chineseSize
        pinyinFontSize = pinyinSize
        viewFrame = frame
        ipaFamily = showIpa
        EnglishEnable = englishEnable
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
        var pinyinStr = ""
        var chineseStr = ""
        if tokenItem.Text != nil {
            chineseStr = tokenItem.Text!
        }
        //ipa 不等于ipa1, 使用变调后的
        //当前显示模式为中拼，ipa为空则 取“”，如果为拼音，则使用nativeText中的内容
        if tokenItem.IPA1 == "" || !(tokenItem.IPA1 != nil) {
            //表示空格
            if tokenItem.Text == "#" || tokenItem.Text == "*" || tokenItem.Text == "\\n" {
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
            if EnglishEnable {
                pinyinStr = tokenItem.NativeText!
            }
            
        }else {
            if(PinyinFormat(tokenItem.IPA1).count == 1){
                if tokenItem.IPA != tokenItem.IPA1 {
                    showIpa1 = true
                }
                pinyinStr = PinyinFormat(tokenItem.IPA1)[0]
                
            }else{
                if tokenItem.IPA != tokenItem.IPA1 {
                    showIpa1 = true
                }
                for i in 0...PinyinFormat(tokenItem.IPA1).count-1{
                    pinyinStr = pinyinStr + PinyinFormat(tokenItem.IPA1)[i]
                }
            }
        }
        if !ipaFamily {
            showIpa1 = false
        }
        var chineseColor = UIColor.hex(hex: "333333")
        var pinyinColor = UIColor.hex(hex: "333333")
        if showIpa1 {
            pinyinColor = UIColor.blueTheme
        }
        //TODO: - : 为了适配填空题
        if !ipaFamily {
            pinyinColor = UIColor.quizTextBlack
            chineseColor = UIColor.quizTextBlack
        }
        if (textLabel != nil) {
            textLabel.refresh(chinese: chineseStr, chineseSize: FontAdjust().FontSize(chineseFontSize), pinyin: pinyinStr, pinyinSize: FontAdjust().FontSize(pinyinFontSize),EnglishEnable)
        }else {
            textLabel = NewTextView(frame: self.bounds, chinese: chineseStr, chineseSize: FontAdjust().FontSize(chineseFontSize), pinyin: pinyinStr, pinyinSize: FontAdjust().FontSize(pinyinFontSize), style: newTextStyle.chineseandpinyin, changeAble: ChangeAble,EnglishEnable)
        }
        
        textLabel.setLabelColor(chinese: chineseColor, pinyin: pinyinColor)
        textLabel.setLabelTextAli(chinese: .center, pinyin: .center)
        textLabel.isUserInteractionEnabled = false
        textLabel.delegate = self as NewTextViewDelegate
        addSubview(textLabel)
        let maxSize:CGSize = CGSize(width:self.bounds.width,height:.greatestFiniteMagnitude)
        
        switch UserDefaults.standard.integer(forKey: UserDefaultsKeyManager.chineseandpinyin) {
        case 0://中拼文
            //汉字的长度
            let width1 = Double((chineseStr as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(chineseFontSize), type: .Regular)]), context: nil).width) + 4
            //拼音的长度
            let width2 = Double((pinyinStr as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(pinyinFontSize), type: .Regular)]), context: nil).width) + 4
            
            self.viewWidth = width1 > width2 ? width1 : width2
        case 1://中文
            //汉字的长度
            let width1 = Double((chineseStr as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(chineseFontSize), type: .Regular)]), context: nil).width) + 4
            
            self.viewWidth = width1
        case 2://　拼音
            //拼音的长度
            let width2 = Double((pinyinStr as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(pinyinFontSize), type: .Regular)]), context: nil).width) + 4
            self.viewWidth = width2

        default:
            self.viewWidth = 0
        }
        
        if EnglishEnable {
            //英文的长度
            let width1 = Double((tokenItem.NativeText! as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(pinyinFontSize), type: .Regular)]), context: nil).width) + 4
            self.viewWidth = width1
        }
        if isNullText {
            if self.viewWidth < 56 {
                self.viewWidth = 56
            }
        }
        if chineseStr == "#" {
            self.viewWidth = 56
            backgroundColor = UIColor.itemGrayColor
            layer.cornerRadius = 4
        }

        if chineseStr == "*" {
            self.viewWidth = 160
            backgroundColor = UIColor.itemGrayColor
            layer.cornerRadius = 4
        }
        if chineseStr == "\\n" {
            self.viewWidth = 0
        }
    }
    func getWidth() -> Double{
        var pinyinStr = ""
        var chineseStr = ""
        if tokenItem.Text != nil {
            chineseStr = tokenItem.Text!
        }
        //ipa 不等于ipa1, 使用变调后的
        var showIpa1 = false
        if(PinyinFormat(tokenItem.IPA1).count == 1){
            if tokenItem.IPA != tokenItem.IPA1 {
                showIpa1 = true
            }
            pinyinStr = PinyinFormat(tokenItem.IPA1)[0]
        }else{
            if tokenItem.IPA != tokenItem.IPA1 {
                showIpa1 = true
            }
            if tokenItem.IPA1 == "" || !(tokenItem.IPA1 != nil) {
                if tokenItem.Text == "#" || tokenItem.Text == "*" || tokenItem.Text == "\\n"{
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
                for i in 0...PinyinFormat(tokenItem.IPA1).count-1{
                    pinyinStr = pinyinStr + PinyinFormat(tokenItem.IPA1)[i]
                }
            }
        }
        if EnglishEnable {
            pinyinStr = tokenItem.NativeText!
        }
        let maxSize:CGSize = CGSize(width:CGFloat(MAXFLOAT),height:.greatestFiniteMagnitude)
        
        switch UserDefaults.standard.integer(forKey: UserDefaultsKeyManager.chineseandpinyin) {
        case 0://中拼文
            //汉字的长度
            let width1 = Double((chineseStr as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(chineseFontSize), type: .Regular)]), context: nil).width) + 4
            //拼音的长度
            let width2 = Double((pinyinStr as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(pinyinFontSize), type: .Regular)]), context: nil).width) + 4
            
            self.viewWidth = width1 > width2 ? width1 : width2
        case 1://中文
            //汉字的长度
            let width1 = Double((chineseStr as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(chineseFontSize), type: .Regular)]), context: nil).width) + 4
            
            self.viewWidth = width1
        case 2://　拼音
            //拼音的长度
            let width2 = Double((pinyinStr as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(pinyinFontSize), type: .Regular)]), context: nil).width) + 4
            
            self.viewWidth = width2
            
        default:
            self.viewWidth = 0
        }
        if EnglishEnable {
            //英文的长度
            let width2 = Double((pinyinStr as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(pinyinFontSize), type: .Regular)]), context: nil).width) + 4
            
            self.viewWidth = width2
        }
        if isNullText {
            if self.viewWidth < 56 {
                self.viewWidth = 56
            }
        }
        if chineseStr == "#" {
            self.viewWidth = 56
            backgroundColor = UIColor.itemGrayColor
            layer.cornerRadius = 4
        }
        
        if chineseStr == "*" {
            self.viewWidth = 160
            backgroundColor = UIColor.itemGrayColor
            layer.cornerRadius = 4
        }
        if chineseStr == "\\n" {
            self.viewWidth = 0
        }
        return self.viewWidth
    }
    //添加虚线
    func drawDashLine(_ lineView: UIView?, lineLength: Int, lineSpacing: Int, lineColor: UIColor?) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.bounds = lineView?.bounds ?? CGRect.zero
        shapeLayer.position = CGPoint(x: (lineView?.frame.width)! / 2, y: (lineView?.frame.height)!)
        shapeLayer.fillColor = UIColor.clear.cgColor
        //设置虚线颜色为
        shapeLayer.strokeColor = lineColor?.cgColor
        //设置虚线宽度
        shapeLayer.lineWidth = (lineView?.frame.height)!
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        //设置线宽，线间距
        shapeLayer.lineDashPattern = [lineLength, lineSpacing] as [NSNumber]
        //设置路径
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0), transform: .identity)
        path.addLine(to: CGPoint(x: (lineView?.frame.width)!, y: 0), transform: .identity)
        shapeLayer.path = path
        //把绘制好的虚线添加上来
        lineView?.layer.addSublayer(shapeLayer)
    }
    func changeTextColor(chineseTextColor:UIColor, pinyinTextColor:UIColor) {
        textLabel.chineseLabel.textColor = chineseTextColor
        textLabel.pinyinLabel.textColor = pinyinTextColor
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
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
