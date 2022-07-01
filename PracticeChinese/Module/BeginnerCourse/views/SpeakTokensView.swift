//
//  SpeakTokensView.swift
//  ChineseDev
//
//  Created by Temp on 2018/6/12.
//  Copyright © 2018年 msra. All rights reserved.
//

import UIKit

class SpeakTokensView: UIView, YBPopupMenuDelegate {
    //初始化，包括token数组，中文，中文字体大小，拼音，拼音字体大小，textStyle显示样式，中拼音结合还是中文，changeAble：自己设置textStyle，还是从本地获取
    //按钮之间的间隙
    var MarginX = 5.0
    //根据算出来的宽度，左右各加多少
    var MarginWidth = 2.0
    //行与行之间的间隙
    var MarginY = 5.0
    //最左边的距离
    var MarginLeft = 0.0
    //最上面的距离
    var MarginTop = 0.0
    //背景图
    var bgView: UIView!
    //最大宽度
    var MaxWidth = 0.0
    //最大宽度
    var CurrentMaxWidth = 0.0
    //最大高度
    var MaxHeight = 0.0
    //true的话不设置颜色
    var ScoreRight = false
    var chineseExHeight:CGFloat = 10.0
    
    var pinyinExHeight:CGFloat = 10.0
    
    //是否允许折行，如果不允许，那么超过最大宽度就要缩小字体
    var foldEnable = true
    //当前item是否可点击
    var selectEnable = true
    //拼音颜色
    var pinyinColor = UIColor.white
    //中文颜色
    var chineseColor = UIColor.white
    //拼音大小
    var PinyinSize = FontAdjust().Speak_ChineseAndPinyin_P()
    //中文大小
    var ChineseSize = FontAdjust().Speak_ChineseAndPinyin_C()
    //tokens
    var tokensArr = [ChatMessageTokenModel]()
    //存放Views
    var viewItemArray = [SpeakTokensItemView]()
    
    var ChangeAble = false
    //是否显示变调，和变调颜色,true表示只显示ipa1
    var ipaFamily = true
    
    var TextStyle = textStyle.chineseandpinyin
    //整体item的位置是居中还是偏左
    var itemAli = itemAlignment.left
    
    var addLine: Bool = false
    //当前点击的View
    var currentTapView = SpeakTokensItemView()
    //    var delegate:SpeakTokensViewDelegate!
    var whiteColor: Bool = false
    var pop: YBPopupMenu?
    var EnglishEnable: Bool = false
    //是否忽略中拼设置，学以致用对话需要忽略
    var ignoreSetting = false
    
    
    var clickToken: ((String) -> Void)?
    var Scope = "" {
        didSet {
            switch Scope {
            case "Speak":
                self.MarginX = 5
                self.MarginWidth = 16
                self.chineseExHeight = 10.0
                self.pinyinExHeight = 10.0
            case "Quiz_Read":
                self.MarginX = 0
                self.MarginWidth = 5
                self.chineseExHeight = 0.0
                self.pinyinExHeight = 0.0
            case "Scenario":
                self.MarginX = 0
                self.MarginWidth = 1
                self.chineseExHeight = 0.0
                self.pinyinExHeight = 0.0
            case "ConversationChallenge":
                self.MarginX = 0
                self.MarginWidth = 1
                self.chineseExHeight = 0.0
                self.pinyinExHeight = 0.0
            default:
                self.MarginX = 0
                self.MarginWidth = 1
                self.chineseExHeight = 0.0
                self.pinyinExHeight = 0.0
            }
        }
    }

    
    init(frame: CGRect,tokens: [ChatMessageTokenModel], chineseSize:Double, pinyinSize:Double,style:textStyle,changeAble:Bool,showIpa:Bool, _ englishEnable:Bool = false,scope:String,cColor:UIColor,pColor:UIColor,scoreRight:Bool = false, _ ignoreSetting:Bool = false) {
        super.init(frame: frame)
        MaxWidth = Double(frame.width)
        Scope = scope
        self.ignoreSetting = ignoreSetting
        switch Scope {
        case "Speak":
            self.MarginX = 5
            self.MarginWidth = 16
            self.chineseExHeight = 10.0
            self.pinyinExHeight = 10.0
        case "Quiz_Read":
            self.MarginX = 0
            self.MarginWidth = 5
            self.chineseExHeight = 0.0
            self.pinyinExHeight = 0.0
        case "Scenario":
            self.MarginX = 0
            self.MarginWidth = 1
            self.chineseExHeight = 0.0
            self.pinyinExHeight = 0.0
        case "ConversationChallenge":
            self.MarginX = 0
            self.MarginWidth = 1
            self.chineseExHeight = 0.0
            self.pinyinExHeight = 0.0
        default:
            self.MarginX = 0
            self.MarginWidth = 1
            self.chineseExHeight = 0.0
            self.pinyinExHeight = 0.0
        }
        CurrentMaxWidth = Double(frame.width)
        tokensArr = tokens
        PinyinSize = Double(pinyinSize)
        ChineseSize = Double(chineseSize)
        chineseColor = cColor
        pinyinColor = pColor
        ScoreRight = scoreRight
        ChangeAble = changeAble
        ipaFamily = showIpa
        self.EnglishEnable = englishEnable//是否是纯英文的
    }
    
    
    //汉语的大小
    func getTheFontSizeOfChinese() -> Double{
        if EnglishEnable {
            return 0
        }
        if ignoreSetting {
            return ChineseSize
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
        if EnglishEnable || ignoreSetting {
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

    //布局
    func setData() {
        for itemView in viewItemArray {
            itemView.removeFromSuperview()
        }
        viewItemArray.removeAll()
        for tokenModel in tokensArr {
            let item = SpeakTokensItemView(frame: CGRect(x: 0, y: 0, width: 0, height: getTheFontSizeOfPinyin() + getTheFontSizeOfChinese()), tokenModel: tokenModel,chineseSize:getTheFontSizeOfChinese(), pinyinSize:getTheFontSizeOfPinyin(), changeAble:ChangeAble,showIpa:ipaFamily,EnglishEnable,chineseEx:self.chineseExHeight,pinyinEx:self.pinyinExHeight,cColor: chineseColor,pColor: pinyinColor,scoreRight:self.ScoreRight,ignoreSetting)
            item.MarginWidth = self.MarginWidth
            item.Scope = self.Scope
            item.makeUI()
            self.addSubview(item)
            viewItemArray.append(item)
        }
        makeItemFrame(itemsArray: viewItemArray)
    }
    
    //设置frame
    func makeItemFrame(itemsArray: [SpeakTokensItemView]) {
        let buttonHeight = getTheFontSizeOfChinese() + getTheFontSizeOfPinyin() + 14
        /** 距离左边的位置 */
        var leftX = Double(MarginLeft)
        
        /** 按钮距离上面的距离 */
        var topY = MarginTop
        /** 按钮左右间隙 */
        let marginX = MarginX;
        /** 按钮上下间隙 */
        let marginY = MarginY;
        var wrap = false
        
        for (i,item) in itemsArray.enumerated() {
            item.makeUI()
            item.sequence = -1
            item.chineseFontSize = getTheFontSizeOfChinese()
            item.pinyinFontSize = getTheFontSizeOfPinyin()
            item.frame = CGRect(x:Double(leftX), y: Double(topY), width: item.getWidth(), height: Double(item.textLabel.frameHeight))
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
            if width1 > MaxWidth {
                wrap = true
                CurrentMaxWidth = MaxWidth
                if itemsArray.count > 1 {
                    let preItem = itemsArray[i - 1]
                    preItem.sequence = 2
                }
                item.sequence = 1
                topY = Double(topY) + Double(item.textLabel.frameHeight) + Double(marginY)
                leftX = Double(MarginLeft)
                item.frame = CGRect(x: Double(leftX), y: Double(topY), width: Double(item.viewWidth), height: Double(item.textLabel.frameHeight))
            }
            
            if (i == itemsArray.count - 1) {
                item.sequence = 2
            }
            leftX = leftX + Double(item.frame.size.width) + Double(marginX)
            item.textLabel.systemAutoChangeWithoutFrame()
        }
        if !wrap {
            //没有折行
            if itemsArray.count > 0 {
                CurrentMaxWidth = Double((itemsArray.last?.frame.maxX)!)
            }
            
        }
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: CGFloat(CurrentMaxWidth), height: getViewHeight())
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
        return CGFloat(CurrentMaxWidth)
    }
    func modifyTextColor( msg: ChatMessageModel) {
        let pinyin = msg.pinyinText
        let text = msg.text
        let en = msg.en
        let pinyinSet = pinyin.string.split(separator: " ")
        var k = 0
        var attributeSet = [[String : Any]]()
        //swift convert
        for (i, py) in pinyinSet.enumerated() {
            var nsrange = NSRange(location: k, length: py.count)
            let attributes = convertFromNSAttributedStringKeyDictionary(pinyin.attributes(at: k,effectiveRange: &nsrange))
            attributeSet.append(attributes)
            k += 1 + py.count
        }
        //swift convert
        var i = 0
        var pinyinText = NSMutableAttributedString(string: "")
        for (j, model) in self.tokensArr.enumerated() {
            if i == pinyinSet.count {
                break
            }
            k = 0
            var tmpText = NSMutableAttributedString(string: model.pinyinText.string)
            //swift convert
            while k < model.pinyinText.string.count && i < pinyinSet.count {
                let nsrange = NSRange(location: k, length: pinyinSet[i].count)
                if nsrange.location != NSNotFound {
                    tmpText.addAttributes(convertToNSAttributedStringKeyDictionary(attributeSet[i]), range: nsrange)
                    k += pinyinSet[i].count
                    i += 1
                }
            }
            //swift convert
            model.pinyinText = tmpText
        }
        
        //中文
        var chinesetext = text.mutableString
        while true {
            let range = chinesetext.range(of: " ")
            if range.location == NSNotFound {
                break
            }
            chinesetext.deleteCharacters(in: range)
            
        }
        
        for (i,model) in self.tokensArr.enumerated() {
            var preText = NSMutableAttributedString(string: "")
            for (j,model) in self.tokensArr.enumerated() {
                //遍历前面的，
                if j < i {
                    preText = NSMutableAttributedString(string: (preText.mutableString as String) + (model.text.string as String))
                }else {
                    break
                }
                
            }
            let replaceText = text.attributedSubstring(from: NSRange(location: preText.length, length: model.text.length))
            
            model.text = replaceText 
            var range = NSRange(location: 0, length: model.text.length)
            let attributes = convertFromNSAttributedStringKeyDictionary(model.text.attributes(at: 0, effectiveRange: &range))
        }
        
        
    }
}

class SpeakTokensItemView: UIView,SpeakNewTextViewDelegate {
    func superViewConstraints() {
        textLabel.systemAutoChangeWithoutFrame()
    }
    
    func tapped() {
        
    }
    /** 主标题 */
    var textLabel: SpeakNewTextView!
    
    /** view宽度 */
    var viewWidth = 0.0
    var tokenItem = ChatMessageTokenModel()
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
    //算出来的宽度左右各加多少
    var MarginWidth = 0.0
    //true的话不设置颜色
    var ScoreRight = false
    var Scope = ""
    //拼音颜色
    var pinyinColor = UIColor.white
    //中文颜色
    var chineseColor = UIColor.white
    var chineseExHeight:CGFloat = 10.0
    var pinyinExHeight:CGFloat = 10.0
    var ignoreSetting = false
    
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

    convenience init(frame: CGRect,tokenModel:ChatMessageTokenModel, chineseSize:Double, pinyinSize:Double, changeAble:Bool,showIpa:Bool ,_ englishEnable:Bool = false,chineseEx: CGFloat, pinyinEx: CGFloat,cColor:UIColor,pColor:UIColor,scoreRight:Bool = false, _ ignoreSetting: Bool = false) {
        self.init(frame: frame)
        self.pinyinExHeight = pinyinEx
        self.chineseExHeight = chineseEx
        self.ignoreSetting = ignoreSetting
        chineseColor = cColor
        pinyinColor = pColor
        ScoreRight = scoreRight
        tokenItem = tokenModel
        ChangeAble = changeAble
        chineseFontSize = chineseSize
        pinyinFontSize = pinyinSize
        viewFrame = frame
        ipaFamily = showIpa
        EnglishEnable = englishEnable
    }
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func makeUI() {
        let pinyinStr = tokenItem.pinyinText
        let chineseStr = tokenItem.text
        if (textLabel != nil) {
            textLabel.refresh(chinese: chineseStr, chineseSize: FontAdjust().FontSize(chineseFontSize), pinyin: pinyinStr, pinyinSize: FontAdjust().FontSize(pinyinFontSize),EnglishEnable)
            if self.Scope != "Speak" && self.Scope != "Quiz_Read" {
                textLabel.setLabelColor(chinese: chineseColor, pinyin: pinyinColor)
            }
        }else {
            textLabel = SpeakNewTextView(frame: self.bounds, chinese: chineseStr, chineseSize: FontAdjust().FontSize(chineseFontSize), pinyin: pinyinStr, pinyinSize: FontAdjust().FontSize(pinyinFontSize), style: newTextStyle.chineseandpinyin, changeAble: ChangeAble,EnglishEnable,chineseEx:self.chineseExHeight,pinyinEx: self.pinyinExHeight,true)
            if self.Scope != "Speak"  && self.Scope != "Quiz_Read"  {
                textLabel.setLabelColor(chinese: chineseColor, pinyin: pinyinColor)
            }
        }
        if tokenItem.direct == ChatDirect.left {
            //左边
            if tokenItem.pinyinText.string == "" {
                textLabel.backgroundColor = UIColor.clear
            }else {
                textLabel.backgroundColor = UIColor(white: 1, alpha: 0.8)
            }
            if Scope != "Speak"  && self.Scope != "Quiz_Read" {
                textLabel.backgroundColor = UIColor.clear
            }
            
        }else {
            //右边
            if tokenItem.pinyinText.string == "" {
                textLabel.backgroundColor = UIColor.clear
            }else {
                textLabel.backgroundColor = UIColor.hex(hex: "4274D3")
            }
        }
        
        textLabel.setLabelTextAli(chinese: .center, pinyin: .center)
        textLabel.isUserInteractionEnabled = false
        textLabel.delegate = self as SpeakNewTextViewDelegate
        addSubview(textLabel)
        let maxSize:CGSize = CGSize(width:self.bounds.width,height:.greatestFiniteMagnitude)
        
        if ignoreSetting {
            //汉字的长度
            let width1 = Double((chineseStr.string as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(chineseFontSize), type: .Regular)]), context: nil).width) + MarginWidth
            //拼音的长度
            let width2 = Double((pinyinStr.string as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(pinyinFontSize), type: .Regular)]), context: nil).width) + MarginWidth
            
            self.viewWidth = width1 > width2 ? width1 : width2
        }else {
            switch UserDefaults.standard.integer(forKey: UserDefaultsKeyManager.chineseandpinyin) {
            case 0://中拼文
                //汉字的长度
                let width1 = Double((chineseStr.string as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(chineseFontSize), type: .Regular)]), context: nil).width) + MarginWidth
                //拼音的长度
                let width2 = Double((pinyinStr.string as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(pinyinFontSize), type: .Regular)]), context: nil).width) + MarginWidth
                
                self.viewWidth = width1 > width2 ? width1 : width2
            case 1://中文
                //汉字的长度
                let width1 = Double((chineseStr.string as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(chineseFontSize), type: .Regular)]), context: nil).width) + MarginWidth
                
                self.viewWidth = width1
            case 2://　拼音
                //拼音的长度
                let width2 = Double((pinyinStr.string as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(pinyinFontSize), type: .Regular)]), context: nil).width) + MarginWidth
                self.viewWidth = width2
                
            default:
                self.viewWidth = 0
            }
        }
        
        if tokenItem.pinyinText.string == "" {
            //标点符号
            if ignoreSetting {
                if chineseStr.string == "..." {
                    self.viewWidth = 25
                }else {
                    self.viewWidth = 15
                }
            }else {
                switch UserDefaults.standard.integer(forKey: UserDefaultsKeyManager.chineseandpinyin) {
                case 0://中拼文
                    if chineseStr.string == "..." {
                        self.viewWidth = 25
                    }else {
                        self.viewWidth = 15
                    }
                case 1://中文
                    if chineseStr.string == "..." {
                        self.viewWidth = 25
                    }else {
                        self.viewWidth = 15
                    }
                case 2://　拼音
                    self.viewWidth = 0
                default:
                    self.viewWidth = 0
                }
            }
        }
        
    }
    func getWidth() -> Double{
        let pinyinStr = tokenItem.pinyinText.string
        let chineseStr = tokenItem.text.string
        let maxSize:CGSize = CGSize(width:CGFloat(MAXFLOAT),height:.greatestFiniteMagnitude)
        if ignoreSetting {
            //汉字的长度
            let width1 = Double((chineseStr as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(chineseFontSize), type: .Regular)]), context: nil).width) + MarginWidth
            //拼音的长度
            let width2 = Double((pinyinStr as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(pinyinFontSize), type: .Regular)]), context: nil).width) + MarginWidth
            
            self.viewWidth = width1 > width2 ? width1 : width2
        }else {
            switch UserDefaults.standard.integer(forKey: UserDefaultsKeyManager.chineseandpinyin) {
            case 0://中拼文
                //汉字的长度
                let width1 = Double((chineseStr as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(chineseFontSize), type: .Regular)]), context: nil).width) + MarginWidth
                //拼音的长度
                let width2 = Double((pinyinStr as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(pinyinFontSize), type: .Regular)]), context: nil).width) + MarginWidth
                
                self.viewWidth = width1 > width2 ? width1 : width2
            case 1://中文
                //汉字的长度
                let width1 = Double((chineseStr as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(chineseFontSize), type: .Regular)]), context: nil).width) + MarginWidth
                
                self.viewWidth = width1
            case 2://　拼音
                //拼音的长度
                let width2 = Double((pinyinStr as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(pinyinFontSize), type: .Regular)]), context: nil).width) + MarginWidth
                self.viewWidth = width2
                
            default:
                self.viewWidth = 0
            }
        }
        if tokenItem.pinyinText.string == "" {
            if ignoreSetting {
                if chineseStr == "..." {
                    self.viewWidth = 25
                }else {
                    self.viewWidth = 15
                }
            }else {
                //标点符号
                switch UserDefaults.standard.integer(forKey: UserDefaultsKeyManager.chineseandpinyin) {
                case 0://中拼文
                    if chineseStr == "..." {
                        self.viewWidth = 25
                    }else {
                        self.viewWidth = 15
                    }
                case 1://中文
                    if chineseStr == "..." {
                        self.viewWidth = 25
                    }else {
                        self.viewWidth = 15
                    }
                case 2://　拼音
                    self.viewWidth = 0
                default:
                    self.viewWidth = 0
                }
            }
        }
        return self.viewWidth
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
    }
    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKeyDictionary(_ input: [NSAttributedString.Key: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSAttributedStringKeyDictionary(_ input: [String: Any]) -> [NSAttributedString.Key: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
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
