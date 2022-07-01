//
//  LessonsCardView.swift
//  PracticeChinese
//
//  Created by ThomasXu on 06/07/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import SnapKit
import Foundation

protocol LessonScrollViewDelegate {
    func scrollPage(index:Int)
}

class LessonScrollView: UIScrollView {
    
    var cardIndex: UILabel!
    var lessonCardDelegate: LessonCardViewDelegate!
    var lessonScrollDelegate: LessonScrollViewDelegate!
    fileprivate var lessonList = [ScenarioSubLessonInfo]()
    
    //   var listScenarioLessonResult: ListScenarioLessonsResult! {//当前Course的所有ScenarioLesson
    let itemWidthRate: CGFloat = 0.7
    static var cardBackgroundColor: UIColor!
    var itemSize: CGSize!
    var itemSpacing = ScreenUtils.widthByRate(x: 0.05)
    let smallItemHeightRate: CGFloat = 0.88
    let smallItemWidthRate: CGFloat = 1
    
    var currentIndex = 0
    var colorTheme = UIColor.lightBlueTheme
    var initialOffset: CGFloat!
    
    var previousOffset:CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        backgroundColor = .clear
        
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        isScrollEnabled = true
        isUserInteractionEnabled = true
        delegate = self
        decelerationRate = UIScrollView.DecelerationRate.fast
        
        itemSize = CGSize(width: ScreenUtils.widthByRate(x: itemWidthRate), height: frame.height)
        initialOffset = ScreenUtils.widthByRate(x: (1 - itemWidthRate) / 2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLessons(lessonList: [ScenarioSubLessonInfo]) {
        self.lessonList = lessonList
        self.setupView()
    }
    
    private func setupView() {
        
        for view in self.subviews {
            view.removeFromSuperview()
        }
        let width = initialOffset * 2 + CGFloat(lessonList.count) * itemSize.width + CGFloat(lessonList.count - 1) * itemSpacing
        contentSize = CGSize(width: width, height: frame.height)
        contentOffset = CGPoint(x: 0, y: 0)
        
        var curX: CGFloat = initialOffset
        for (idx, lesson) in lessonList.enumerated() {
            var cardView:LessonCardView
            if 0 == idx {
                cardView = LessonCardView(frame: CGRect(x: curX, y: 0, width: itemSize.width, height: itemSize.height))
            } else {
                let width = itemSize.width * smallItemWidthRate
                let height = itemSize.height * smallItemHeightRate
                let x = (curX + curX + itemSize.width) / 2 - width / 2
                let y = itemSize.height / 2 - height / 2
                cardView = LessonCardView(frame: CGRect(x: x, y: y, width: width, height: height))
            }
            cardView.delegate = self.lessonCardDelegate
            cardView.lessonArrayIndex = 0
            cardView.lessonIndex.text = "\(idx + 1)"
            cardView.lessonArrayIndex = idx
            cardView.colorTheme = colorTheme
            //判断是否完成 scenario 部分
            let userScenario = lesson.ScenarioLessonInfo as! UserScenarioLessonAbstract
            if let info = lesson.ScenarioLessonInfo {
                cardView.lessonTitle.text = info.Name
                cardView.lessonLocalTitle.text = info.NativeName
                cardView.score = info.Score! > 0 ? info.Score! : 0
                cardView.lessonState = info.Progress!

            }
            addSubview(cardView)
            curX += itemSize.width + itemSpacing
        }
        
        cardIndex = UILabel(frame: CGRect.zero)
        cardIndex.textAlignment = .center
        cardIndex.font = FontUtil.getFont(size: FontAdjust().FontSize(14), type: .Regular)
        cardIndex.text = "1 / \(lessonList.count)"
        cardIndex.textColor = UIColor.hex(hex: "3f3f3f")
    }
    
    private func setupView1() {
        let lessonList = [1, 2, 3, 4]
        for view in self.subviews {
            view.removeFromSuperview()
        }
        let width = initialOffset * 2 + CGFloat(lessonList.count) * itemSize.width + CGFloat(lessonList.count - 1) * itemSpacing
        contentSize = CGSize(width: width, height: frame.height)
        contentOffset = CGPoint(x: 0, y: 0)
        
        var curX: CGFloat = initialOffset
        for (idx, lesson) in lessonList.enumerated() {
            var cardView:LessonCardView
            if 0 == idx {
                cardView = LessonCardView(frame: CGRect(x: curX, y: 0, width: itemSize.width, height: itemSize.height))
            } else {
                let width = itemSize.width * smallItemWidthRate
                let height = itemSize.height * smallItemHeightRate
                let x = (curX + curX + itemSize.width) / 2 - width / 2
                let y = itemSize.height / 2 - height / 2
                cardView = LessonCardView(frame: CGRect(x: x, y: y, width: width, height: height))
            }
            cardView.delegate = self.lessonCardDelegate
            cardView.lessonArrayIndex = 0
            cardView.lessonIndex.text = "\(idx + 1)"
            cardView.lessonArrayIndex = idx
            addSubview(cardView)
            curX += itemSize.width + itemSpacing
        }
        
        cardIndex = UILabel(frame: CGRect.zero)
        cardIndex.textAlignment = .center
        cardIndex.text = "1 / 10"
        cardIndex.textColor = UIColor.hex(hex: "3f3f3f")
    }
    
    func mockScrollToIndex(index: Int) {
        self.currentIndex = index
        let offsetX = CGFloat(index) * (itemSize.width + itemSpacing)
        self.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
      /*  UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 12, options: .allowAnimatedContent, animations: {
            self.setContentOffset(CGPoint(x:offsetX,y:0), animated: true)
        }, completion: nil)*/
        
    }
    
}

extension LessonScrollView: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        let width = itemSize.width + itemSpacing
        let nearestIndex = Int(CGFloat(targetContentOffset.pointee.x) / width + 0.5)
        let clampedIndex = max( min( nearestIndex, lessonList.count - 1 ), 0 )
        self.currentIndex = clampedIndex
        let xOffset = CGFloat(clampedIndex) * width
        //       xOffset = xOffset == 0.0 ? 1.0 : xOffset//////
        targetContentOffset.pointee.x = xOffset
        self.cardIndex.text = "\(self.currentIndex + 1) / \(self.lessonList.count)"
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.x
        let minWidth = itemSize.width * smallItemWidthRate
        let minHeight = itemSize.height * smallItemHeightRate
        let viewWidth = frame.width
        let maxDis = itemSize.width + itemSpacing
        let itemOut = (viewWidth - (itemSize.width + 2 * itemSpacing)) / 2
        //    let maxDis =
        for view in self.subviews {
            let viewCenter = view.frame.midX
            let dis = abs(viewCenter - offset - viewWidth / 2)
            if (view.frame.minX >= offset && (view.frame.minX - offset) < (viewWidth - itemOut)) ||
                (view.frame.minX < offset && view.frame.maxX > (offset + itemOut)) {
                let rate: CGFloat = dis / maxDis
                let width = minWidth + (itemSize.width - minWidth) * (1 - rate)
                let height = minHeight + (itemSize.height - minHeight) * (1 - rate)
                view.frame = getNewFrame(frame: view.frame, width: width, height: height)
            } else {
                //view.frame = view.frame
            }
        }
    }
    
    func getNewFrame(frame: CGRect, width: CGFloat, height: CGFloat) -> CGRect {
        return CGRect(x: frame.midX - width / 2, y: frame.midY - height / 2, width: width, height: height)
    }
}




protocol LessonCardViewDelegate {
    func pressReadAfterMe(lessonIndex: Int)
    func pressScenario(lessonIndex: Int)
}

class LessonCardView: UIView {
    
    var lessonIndex: UILabel!
    var lessonTitle: UILabel!
    var lessonLocalTitle: UILabel!//本地语言描述的标题
    
    var learnStatus: UIImageView!
    var learnStatusLine1: UILabel!
    var learnStatusLine2: UILabel!
    
    //var readButton: ButtonWithTriangle!
    var scenarioButton: UIButton!
    var lessonArrayIndex: Int!//在课程列表中的下标，从0开始
    var score = 0
    var colorTheme = UIColor.lightBlueTheme {
        didSet {
            lessonIndex.backgroundColor = colorTheme
            scenarioButton.setBackgroundImage(UIImage.fromColor(color: colorTheme), for: .normal)

        }
    }
    var lessonState: Int = 0 {
        didSet {
            self.updateLessonState()
        }
    }
    
    func pressReadAfterMe(_ sender: Any) {
        delegate?.pressReadAfterMe(lessonIndex: self.lessonArrayIndex)
    }
    
    @objc func pressScenario(_ sender: Any) {
        delegate?.pressScenario(lessonIndex: self.lessonArrayIndex)
    }
    var delegate:LessonCardViewDelegate?
    
    var cardInfo = LessonCard() {
        didSet {
            //     setupContent()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.setSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateLessonState() {
        if (self.lessonState < 0) {
            self.learnStatus.image = ChImageAssets.trophyGray.image
            self.learnStatusLine1.text = "0"
            self.learnStatusLine1.textColor = UIColor.hex(hex: "3f3f3f")
            return
        }
        else {
            self.learnStatus.image = ChImageAssets.trophyGolden.image
            self.learnStatusLine1.text = "\(self.score)"
            self.learnStatusLine1.textColor = UIColor.hex(hex: "3f3f3f")//LessonCardViewController.mainColor
        }
    }
    
    func setSubviews() {
        
        lessonIndex = UILabel(frame: CGRect.zero)
        lessonIndex.text = "10"
        lessonIndex.textAlignment = .center
        lessonIndex.backgroundColor = UIColor.lightBlueTheme
        self.addSubview(lessonIndex)
        
        lessonTitle = UILabel(frame: CGRect.zero)
        lessonTitle.text = "住宿"
        self.addSubview(lessonTitle)
        
        lessonLocalTitle = UILabel(frame: CGRect.zero)
        lessonLocalTitle.text = "Accommodation"
        self.addSubview(lessonLocalTitle)
        
        learnStatus = UIImageView(frame: CGRect.zero)
        learnStatus.image = ChImageAssets.MeIcon2.image
        self.addSubview(learnStatus)
        learnStatusLine1 = UILabel(frame: CGRect.zero)
        learnStatusLine1.textAlignment = .center
        learnStatusLine1.textColor = UIColor.hex(hex: "f6c127")
        self.addSubview(learnStatusLine1)
        //learnStatusLine2 = UILabel(frame: CGRect.zero)
        //learnStatusLine2.textAlignment = .center
        //learnStatusLine2.textColor = learnStatusLine1.textColor
        //self.addSubview(learnStatusLine2)
        
        let buttonFont = FontUtil.getFont(size: FontAdjust().FontSize(17), type: .Regular)
        
        scenarioButton = UIButton(frame: CGRect.zero)
        scenarioButton.setBackgroundImage(UIImage.fromColor(color: UIColor.blueTheme), for: .normal)
        scenarioButton.setTitleColor(UIColor.hex(hex: "3f3f3f"), for: .normal)
        scenarioButton.setTitle("Start", for: .normal)
        scenarioButton.titleLabel?.font = buttonFont
        scenarioButton.addTarget(self, action: #selector(pressScenario(_:)), for: .touchUpInside)
        self.addSubview(scenarioButton)
        self.updateLessonState()
        
    }
    
    func updateSubviewsFrame() {
        let indexY = frame.height * 0.1
        let indexHeight = frame.height * 0.1
        let indexX = (frame.width - indexHeight) / 2
        lessonIndex.frame = CGRect(x: indexX, y: indexY, width: indexHeight, height: indexHeight)
        lessonIndex.layer.cornerRadius = indexHeight / 2
        lessonIndex.layer.masksToBounds = true
        
        let titleY = lessonIndex.frame.maxY + frame.height * 0.06
        let titleFont = FontUtil.getFont(size: FontAdjust().FontSize(16), type: .Regular)
        lessonTitle.frame = CGRect(x: 0, y: titleY, width: frame.width, height: titleFont.lineHeight)
        lessonTitle.font = titleFont
        lessonTitle.textColor = UIColor.hex(hex: "3f3f3f")
        lessonTitle.textAlignment = .center
        
        let localY = lessonTitle.frame.maxY + frame.height * 0.01
        let localFont = FontUtil.getFont(size: FontAdjust().FontSize(14), type: .Regular)
        lessonLocalTitle.frame = CGRect(x: 0, y: localY, width: frame.width, height: localFont.lineHeight)
        lessonLocalTitle.font = localFont
        lessonLocalTitle.textColor = UIColor.hex(hex: "3f3f3f")
        lessonLocalTitle.textAlignment = .center
        
        let statusY = lessonLocalTitle.frame.maxY + frame.height * 0.11
        let statusHeight = frame.width * 0.3
        let statusWidth = statusHeight
        let statusX = (frame.width - statusWidth) / 2
        learnStatus.frame = CGRect(x: statusX, y: statusY, width: statusWidth, height: statusHeight)
        let lineFont = FontUtil.getFont(size: FontAdjust().FontSize(18), type: .Regular)
        let line1Y = learnStatus.frame.maxY - statusHeight * 0.75//使用比例来保证文字在图片中的位置
        learnStatusLine1.frame = CGRect(x: 0, y: line1Y, width: frame.width, height: lineFont.lineHeight)
        learnStatusLine1.font = lineFont
        //let line2Y = learnStatusLine1.frame.maxY
        //learnStatusLine2.frame = CGRect(x: 0, y: line2Y, width: frame.width, height: lineFont.lineHeight)
        //learnStatusLine2.font = lineFont
        
        var buttonY = learnStatus.frame.maxY + frame.height * 0.11
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhone4){
            buttonY = learnStatus.frame.maxY + frame.height * 0.06
        }
        let buttonWidth = frame.width * 0.4
        let buttonHeight = frame.height * 0.1
        let buttonX = (frame.width - buttonWidth ) / 2
        
        scenarioButton.frame = CGRect(x: buttonX , y: buttonY, width: buttonWidth, height: buttonHeight)
        scenarioButton.layer.cornerRadius = buttonHeight / 2
        scenarioButton.layer.masksToBounds = true
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateSubviewsFrame()
    }
}
