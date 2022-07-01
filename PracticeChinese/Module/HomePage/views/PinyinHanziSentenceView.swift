//
//  PinyinHanziSentenceView.swift
//  PracticeChinese
//
//  Created by ThomasXu on 12/07/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit

class PinyinHanziSentenceView: UIView {
    
    var pinyinHeight: CGFloat = 20 //拼音 Label 高度
    var hanziHeight: CGFloat = 20 //汉字 Label 高度
    var leftSpaceWidth: CGFloat = 30//为了保证每一行的第一个汉字是垂直对齐的，同时它们与自己的拼音中心对齐，使每一行的
    //第一个汉字距离左边界固定宽度，那么即使拼音比较宽，左边的部分会在汉字的左边。
    
    var pinyinFont = FontUtil.getFont(size: FontAdjust().FontSize(14), type: .Regular) {
        didSet {
            self.pinyinHeight = pinyinFont.lineHeight + 1
        }
    }
    var hanziFont = FontUtil.getFont(size: FontAdjust().FontSize(20), type: .Regular) {
        didSet {
            self.hanziHeight = hanziFont.lineHeight + 1
        }
    }
    var textColor = UIColor.black
    
    //使用一个变量保存最多多少行。如果有一个单词的拼音长度太长了，一整行都放不下，那么就会进入死循环
    //使用行数来限制循环次数
    static let maxLineNumber = 1000
    var lineNumber: Int = 1
    
    var pinyinSentence: String! {
        didSet{
            self.pinyinArray = pinyinSentence
                .replacingOccurrences(
                    of: "\\s+",
                    with: " ",
                    options: .regularExpression
                )
                .trimmingCharacters(in: .whitespaces)
                .components(separatedBy: " ")
            
        }
    }
    var hanziSentence: String! {
        didSet {
            self.hanziArray = hanziSentence.characters.map() { String($0) }
        }
    }
    var pinyinArray: [String] = [String]()
    var hanziArray: [String] = [String]()
    
    var pinyinLabels: [UILabel] = [UILabel]()
    var hanziLabels: [UILabel] = [UILabel]()
    
    var firstPinyinLineDis: CGFloat = 0//第一行拼音距离上边界的距离
    var minHanziDis: CGFloat = 20 //一行中 两个汉字之间的距离
    var minPinyinDis: CGFloat = 2 //一行中 拼音和拼音，汉字和拼音，拼音和汉字之间的距离
    var pinyinHanziDis:CGFloat = 0//拼音行和汉字行之间的距离
    var rowDis:CGFloat = 4//上一行的汉字和下一行的拼音之间的距离
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getLabel(text: String, font: UIFont) -> UILabel {
        let label = UILabel(frame: CGRect())
        label.text = text
        label.font = font
        label.textColor = self.textColor
        label.textAlignment = .center
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }
    
    //可以首先判断是否是汉字，然后判断是否时汉字字符？？？
    func hasPinyin(text: String) -> Bool {
        let c = text.characters.first!
        if ChineseUtil.isPunctuation(c) {
            return false
        }
        return true
    }
    
    //横坐标以及纵坐标不变，宽度不变，只更新高度
    func getNewFrame() -> CGRect {
        let height = self.getHeight()
        return CGRect(x: self.frame.minX, y: self.frame.minY, width: self.frame.width, height: height)
    }
    
    func getHeight() -> CGFloat {
        let rowHeight = pinyinHeight + pinyinHanziDis + hanziHeight
        return firstPinyinLineDis + CGFloat(self.lineNumber) * rowHeight + rowDis * CGFloat(self.lineNumber - 1)
    }
    
    func getWidth() -> CGFloat {
        var max: CGFloat = 0
        for label in self.pinyinLabels {
            if label.frame.maxX > max {
                max = label.frame.maxX
            }
        }
        for label in self.hanziLabels {
            if label.frame.maxX > max {
                max = label.frame.maxX
            }
        }
        return max
    }
    
    //根据设定的参数重新布局
    func relayoutView() {
        for label in self.pinyinLabels {
            label.removeFromSuperview()
        }
        pinyinLabels.removeAll()
        for pinyin in self.pinyinArray {
            let label = getLabel(text: pinyin, font: self.pinyinFont)
            pinyinLabels.append(label)
        }
        
        for label in self.hanziLabels {
            label.removeFromSuperview()
        }
        hanziLabels.removeAll()
        for hanzi in self.hanziArray {
            let label = getLabel(text: hanzi, font: self.hanziFont)
            hanziLabels.append(label)
        }
        
        layoutPinyinHanzi()
    }
    
    //根据汉字个数放拼音，如果汉字结束，则剩余的拼音丢弃，如果拼音不足，则不放拼音，标点符号上方不放拼音
    //汉字以及拼音水平中点对齐
    //以汉字之间的距离为主，但是如果使汉字之间保持该距离时拼音距离太小或重合，则重新调整汉字之间的距离
    //第一个汉字或拼音顶格
    //如果frame放不下，则后面的内容全部放弃
    private func layoutPinyinHanzi() {
        
        let totalHeight = pinyinHeight + pinyinHanziDis + hanziHeight + rowDis
        
        if (hanziLabels.count <= 0) {
            return
        }
        
        var curX:CGFloat = -1
        /*     if pinyinLabels.count > 0 {
         let temp = pinyinLabels[0].frame.midX
         curX = curX > temp ? curX : temp
         }*/
        
        var curY: CGFloat = self.firstPinyinLineDis
        var pIndex = 0
        var hIndex = 0
        while hIndex < hanziLabels.count {//继续处理汉字
            let hLabel = hanziLabels[hIndex]
            //设置横坐标
            if curX < 0 {
                curX = self.leftSpaceWidth + hLabel.frame.midX//汉字距离左边固定宽度
                if hasPinyin(text: hLabel.text!) && pIndex < pinyinLabels.count {
                    let temp = pinyinLabels[pIndex].frame.midX
                    curX = curX > temp ? curX : temp
                }
            }
            
            if curX + hLabel.frame.width / 2 > frame.width {//汉字需要换行
                curY += totalHeight
                curX = -1
                self.lineNumber += 1
                if self.lineNumber >= PinyinHanziSentenceView.maxLineNumber {
                    print("Error: to many lines")
                    return
                }
                continue
            }
            if hasPinyin(text: hLabel.text!) && pIndex < pinyinLabels.count && pinyinLabels[pIndex].frame.width / 2 + curX > frame.width {//拼音需要换行
                curY += totalHeight
                curX = -1
                self.lineNumber += 1
                if self.lineNumber >= PinyinHanziSentenceView.maxLineNumber {
                    print("Error: to many lines")
                    return
                }
                continue
            }
            hLabel.frame = CGRect(x: curX - hLabel.frame.width / 2, y: curY + pinyinHeight + pinyinHanziDis, width: hLabel.frame.width, height: hanziHeight)
            self.addSubview(hLabel)
            //     hLabel.backgroundColor = UIColor.red
            if hasPinyin(text: hLabel.text!) {//如果汉字有拼音
                if pIndex < pinyinLabels.count {//如果还有拼音剩余
                    let pLabel = pinyinLabels[pIndex]
                    pLabel.frame = CGRect(x: curX - pLabel.frame.width / 2, y: curY, width: pLabel.frame.width, height: pinyinHeight)
                    self.addSubview(pLabel)
                    //       pLabel.backgroundColor = UIColor.blue
                    pIndex += 1
                }
            }
            //如果还有下一个汉字
            if hIndex < hanziLabels.count - 1 {
                curX = hLabel.frame.maxX + minHanziDis + hanziLabels[hIndex + 1].frame.width / 2
                if hasPinyin(text: hLabel.text!) && (pIndex - 1) < pinyinLabels.count {//如果当前汉字需要并且  有  拼音，下一个汉字与拼音要足够远
                    let temp = pinyinLabels[pIndex - 1].frame.maxX + minPinyinDis + hanziLabels[hIndex + 1].frame.width / 2
                    curX = curX > temp ? curX : temp
                }
                if hasPinyin(text: hanziLabels[hIndex + 1].text!) {//下一个汉字需要拼音，则拼音不能
                    if pIndex < pinyinLabels.count {//如果还有下一个拼音
                        let pLabel = pinyinLabels[pIndex]
                        let temp1 = hLabel.frame.maxX + minPinyinDis + pLabel.frame.width / 2//距离当前汉字足够远
                        curX = curX > temp1 ? curX : temp1
                        if hasPinyin(text: hLabel.text!) {//如果当前汉字有拼音
                            let temp2 = pinyinLabels[pIndex - 1].frame.maxX + minPinyinDis + pLabel.frame.width / 2
                            curX = curX > temp2 ? curX : temp2
                        }
                    }
                }
                if pIndex == pinyinLabels.count {//使用这一步之后，以后如果遇到需要拼音的汉字，通过判断pIndex是否在范围内就可以知道它实际有没有汉字
                    pIndex = Int.max
                }
            }//hIndex < hanziLabels.count - 1
            hIndex += 1
        }
    }
    
    static func testView() {
        /*  let view = PinyinHanziSentenceView(frame: CGRect(x: 0, y: 100, width: 200, height: 100))
         view.pinyinSentence = "rrrffffffffffffrri            haffds ha adffffsfadsf fffff a a e"
         view.hanziSentence = "你,,好,赢呵呵呵久是是，，，，，哈哈哈，啊，，，"
         self.view.addSubview(view)
         view.relayoutView()
         view.frame = view.getNewFrame()*/
        
    }
}
