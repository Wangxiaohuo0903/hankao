//
//  LearnCardFlowViewController.swift
//  PracticeChinese
//  Page for learn Card Flow
//  Created by 费跃 on 9/5/17.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit
import SnapKit


/** Learn 页面，包括learn and quiz */
class LearnCardFlowViewController : UIViewController,UIScrollViewDelegate,SettingViewDelegate,ChActivityViewCancleDelegate,NetworkRequestFailedLoadDelegate,SelectCorrectDelegate,recordingDelegate {
    
    //MARK: - : 属性
    var baseView: SwipeView!
    /** 记录上一次页面的Index,往回翻，不减 */
    var lastPageIndex:Int!
    /** 记录上一次页面的Index,往回翻，减 */
    var lastPage:Int!
    var lesson: BeginnerLessonsManager!
    var unit: UnitClass!
    var cancelButton:UIButton!
    var moreButton:UIButton!
    /** 存放card类型 */
    var cardtype = [Int]()
    /** 存放所有的cardView */
    var cardViews = [UIView]()
    /** 存放所有的 */
    var pointViews = [UIView]()
    /** titleView */
    var titleView : LearnTitleView!
    let setingView = SettingView(frame: CGRect.zero)
    /** 进度 */
    var progressView: UIView!
    var progressViewLabel = UILabel()
    var pagenumber = 0
    var showPagenumber = 0
    var progressNumber = 0 //负责进度控制
    var groupProgressNumber = 1 // 当前Group的进度
    //当前是第几个group
    var groupNumber = 0
    //存放每个Group中的LearnignItem 和quiz的数量
    var groupNumberArray = [Int] ()
    var currentLearnProgress = 0 //当前学习到的进度，不可减少
    var courseId: String = "L2-1-1-1-s-CN"
    var repeatId: String = "L2-1-1-1-r-CN"
    var lessonInfo: ScenarioSubLessonInfo?
    var hasQuited:Bool = false
    var leftP: CGFloat = 7
    var learningItem: Bool = false //当前是否为学习卡，用于滑动时continue判断
    var currentPageNumber = 0
    var titleString: String = ""
    var sunButton = UIButton()
    let backButton = UIButton()
    //多轮的总阳光
    var loopSunValue: Int = 0
    //这一轮获得的阳光
    var allSunValue = 0
    //阳光值增加
    var sunValue = 0
    //连加
    var evenAdd = -1
    
    var learnItemArray = [ScenarioLessonLearningItem]()
    var exQuizArray = [QuizSample]()
    var exQuizNumber = 0
    var titleViewheight = 40
    var copyQuizArray = [QuizSample]()
    //大于一轮，展示信息
    var showInfo = true
    var learnDetail = false
    
    let lessonBgView = UIView()
    //老用户
    var oldUser: Bool = false
    //回答错误
    var answerFalse: Bool = false
    // 是否已经完成
    var alreadyCompleted = false
    //做完题之后的回调，看看有没有新的解锁
    var finishLearning: ((Int,Bool) -> Void)?
    //MARK: - : 视图控制器方法
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
        if (AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax) {
            willAppear = false
        }else {
            willAppear = true
        }
        UIView.animate(withDuration: 0.2) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.navigationController != nil {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage.fromColor(color: UIColor.clear), for: .default)
        }
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.leftBarButtonItems = nil
        self.view.backgroundColor = UIColor.grayTheme
        /** 设置返回按钮 */
        self.cancelButton = UIButton(frame: CGRect(x: FontAdjust().quitButtonTop(), y: self.ch_getStatusBarHeight() > 20 ? self.ch_getStatusBarHeight() - 10 : FontAdjust().quitButtonTop(), width: 40, height: 40))
        self.cancelButton.setImage(ChImageAssets.CloseIcon.image, for: .normal)
        self.cancelButton.addTarget(self, action: #selector(self.quitLearn), for: .touchUpInside)
        self.navigationController?.view.addSubview(cancelButton)
        
        learningItem = true
        self.hasQuited = false
        self.lastPageIndex = 0
        self.lastPage = 0
        progressNumber = 1
        
        //  "self.view.backgroundColor = UIColor.grayTheme" will lead to ChActivityView not to show over iOS 13, so we delay the invocation of ChActivityView.show to the next runloop
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.loadData();
        }
        makeUI()
    }
    /** click back btn */
    func closeTapped() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    /** make up UI */
    func makeUI() {
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
            self.baseView = SwipeView(frame: CGRect(x:0, y:78, width:ScreenUtils.width, height:ScreenUtils.height-78))
        }else{
            self.baseView = SwipeView(frame: CGRect(x:0, y:54, width:ScreenUtils.width, height:ScreenUtils.height - 54))
        }
        self.baseView.isScrollEnabled = true
        self.baseView.delegate = self
        self.baseView.dataSource = self
        self.baseView.isPagingEnabled = true
        self.baseView.itemsPerPage = 1
        self.baseView.alignment = .center
        self.baseView.layer.masksToBounds = false
        self.baseView.clipsToBounds = false
        
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
            titleViewheight = Int(30 + self.ch_getStatusBarHeight())
        }

        progressView = UIView(frame: CGRect(x:0, y: 0, width: Int(view.frame.width), height:titleViewheight))
        titleView = LearnTitleView(frame: CGRect(x: 40, y: titleViewheight - 36, width: Int(ScreenUtils.width - 110), height: 40))
        titleView.setData(title: titleString)
        progressView.addSubview(titleView)
        self.navigationController?.view.addSubview(progressView)
        
        var y: Int = Int(FontAdjust().quitButtonTop())
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
            y = 34
        }
        moreButton = UIButton(frame: CGRect(x: Int(ScreenUtils.width - 36), y: Int(y), width: 36, height: 36))
        moreButton.setImage(ChImageAssets.MoreIconLearn.image, for: .normal)
        moreButton.imageView?.tintColor = UIColor.lightText
        moreButton.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)
        self.navigationController?.view.addSubview(moreButton)
        
        self.baseView.alpha = 0
        self.progressView.alpha = 0
        self.titleView.alpha = 0
        self.sunButton.alpha = 0
        self.moreButton.alpha = 0
        self.cancelButton.alpha = 0
    }
    //MARK: - 展示信息
    func showLessonInfo(result: [String: Any]?,completed: Bool = false) {
        var height = ScreenUtils.height
        var top:CGFloat = 0
        var navHeight: Int = 64
        var topY = 20
        if (AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax) {
            navHeight = Int(self.ch_getStatusNavigationHeight())
            topY = Int(self.ch_getStatusBarHeight())
        }

        if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
            top = 0
            height = ScreenUtils.height
        }
        lessonBgView.frame = CGRect(x: 0, y: 0, width: ScreenUtils.width, height: height)
        lessonBgView.backgroundColor = UIColor.white
        lessonBgView.isUserInteractionEnabled = true
        let page = LessonProgressView(frame: CGRect(x: 0,  y: navHeight, width: Int(ScreenUtils.width) , height: Int(height) - navHeight))
        page.learnItemArray = self.learnItemArray
        page.continueButton.addTarget(self,action:#selector(showBaseView),for:.touchUpInside)
        page.loadData(result: result, completed: completed)
        page.continueButton.isHidden = false
        self.view.addSubview(lessonBgView)
        lessonBgView.addSubview(page)
        
        let naviView = UIView(frame: CGRect(x: 0, y:0, width: Int(ScreenUtils.width), height: navHeight))
        lessonBgView.addSubview(naviView)
        naviView.backgroundColor = UIColor.grayTheme
        
        let titleLabel = UILabel(frame: CGRect(x: 50, y: topY, width: Int(ScreenUtils.width - 100), height: 40))
        titleLabel.font = FontUtil.getFont(size: 20, type: .Medium)
        titleLabel.textColor = UIColor.textBlack333
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        if completed == false {
            titleLabel.text = "Progress"
        }else {
            titleLabel.text = self.titleString
        }
        naviView.addSubview(titleLabel)
        backButton.frame = CGRect(x: 5, y: topY, width: 30, height: 40)
        backButton.setImage(ChImageAssets.left_BackArrow.image, for: .normal)
        backButton.addTarget(self, action: #selector(self.backClick), for: .touchUpInside)
        self.navigationController?.view.addSubview(backButton)

    }
    
    @objc func showBaseView() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.fromColor(color: UIColor.clear), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.leftBarButtonItems = nil
        self.showInfo = false
        self.baseView.alpha = 1
        self.progressView.alpha = 1
        self.titleView.alpha = 1
        self.sunButton.alpha = 1
        self.moreButton.alpha = 1
        self.cancelButton.alpha = 1
        self.backButton.removeFromSuperview()
        if(cardViews[baseView.currentItemIndex].isKind(of: LearningCard.self)){
            let curpage = self.cardViews[baseView.currentItemIndex] as! LearningCard
            if !hasQuited {
                curpage.videoButton.play()
            }
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.lessonBgView.alpha = 0
        }) { (finish) in
            self.lessonBgView.isHidden = true
        }
    }
    //显示阳光值按钮
    func setSunButtonUI() {
        if(AppData.userAssessmentEnabled && UserManager.shared.isLoggedIn()){
            var topHeight = 70
            if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
                topHeight = 90
            }
            sunButton.frame = CGRect(x: Int(ScreenUtils.width - 66), y: topHeight, width: 66, height: 32)
            sunButton.setImage(UIImage(named: "sunNew"), for: .normal)
            sunButton.setTitle(" \(allSunValue)", for: .normal)
            sunButton.backgroundColor = UIColor.blueTheme
            sunButton.titleLabel?.font = FontUtil.getFont(size: 16, type: .Bold)
            sunButton.setTitleColor(UIColor.hex(hex: "FFAC1A"), for: .normal)
            let maskPath = UIBezierPath(roundedRect: CGRect(x: 0.0, y: 0.0, width: 66, height: 32), byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: 16, height: 16))
            
            let maskLayer = CAShapeLayer()
            maskLayer.borderColor = UIColor.blueTheme.cgColor
            maskLayer.frame = sunButton.bounds
            maskLayer.path = maskPath.cgPath
            sunButton.layer.mask = maskLayer
            self.view.addSubview(sunButton)
            self.view.bringSubviewToFront(sunButton)
        }
    }
    //MARK: - 加载数据
    func loadData() {
        ChActivityView.shared.delegate = self
        ChActivityView.show(.CancleFullScreen, UIApplication.shared.keyWindow!, UIColor.loadingBgColor, ActivityViewText.HomePageLoading,UIColor.loadingTextColor,UIColor.gray)
        BeginnerLessonsManager.shared.getCourse(id: courseId, completion: {
            (data,error) in
            if !self.hasQuited{
                if(data)!{
                    self.setContent()
                    self.analytics()
                }
                else {
                    if let requestError = error {
                        self.showErrorInfo(requestError: requestError)
                    }
                    ChActivityView.hide()
                }
            }else {
                ChActivityView.hide()
            }
        })
    }
    
    //展示错误数据
    func showErrorInfo(requestError:Error) {
        var networkErrorText = NetworkRequestFailedText.DataError
        if requestError.localizedDescription.hasPrefix("The request timed out.")
        {
            networkErrorText = NetworkRequestFailedText.NetworkTimeout
            
        }else if requestError.localizedDescription.hasPrefix("The Internet connection appears to be offline.") {
            networkErrorText = NetworkRequestFailedText.NetworkError
        }
        let alertView = AlertNetworkRequestFailedView.init(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height - self.ch_getStatusBarHeight()))
        alertView.delegate = self
        alertView.show(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height - self.ch_getStatusBarHeight()),superView:self.navigationController!.view,alertText:networkErrorText,textColor:UIColor.loadingTextColor,bgColor: UIColor.loadingBgColor,showHidenButton: true)
    }
    /**
     判断是否开启权限
     */
    func analytics() {
        if UserManager.shared.isLoggedIn(){
            if(!AppData.userAssessmentEnabled){
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    LCAlertView.show(title: String.PrivacyTitle, message: String.PrivacyConsent, leftTitle: "Don't Allow", rightTitle: "Allow", style: .center, leftAction: {
                        LCAlertView.hide()
                    }, rightAction: {
                        LCAlertView.hide()
                        AppData.setUserAssessment(true)
                        self.setSunButtonUI()
                    })
                }
            }
        }
    }
    //MARK: - : 页面设置
    func setContent() {
        DispatchQueue.global(qos: .default).async {
            self.initCardtype()
            self.courseId = BeginnerLessonsManager.shared.id
            self.showPagenumber = 0
            for i in 0..<self.cardtype.count {
                if self.cardtype[i] == -1 {
                    self.showPagenumber += 1
                }else {
                    break
                }
            }
            DispatchQueue.main.async {
                //设置数据
                for i in 0..<self.showPagenumber + 1 {
                    var playAudio = false
                    if i == 0{
                        playAudio = true
                    }
                    self.setupPages(i:i,playAudio: playAudio)
                }
                self.progressNumber = self.showPagenumber
                 //设置进度条
 
                self.setProgressUI()
                self.view.addSubview(self.baseView)
                self.setSunButtonUI()
                if !self.showInfo{
                    ChActivityView.hide()
                    self.showBaseView()
                    return
                }
                CourseManager.shared.listScenarioLesson(id: self.courseId) { (result) in
                    if result != nil {
                        if (result?.ScenarioLessonInfo?.Progress)! > 0 {
                            //老用户,或者新用户完成课程
                            self.alreadyCompleted = true
                            self.showLessonInfo(result: nil,completed: true)
                             ChActivityView.hide()
                            return
                        }
                        if (result?.ScenarioLessonInfo?.TriedCount)! > 0 && (result?.ScenarioLessonInfo?.Progress)! <= 0{
                            self.showInfo = true
                            let resultDic = self.getDictionaryFromJSONString(jsonString: (result?.ScenarioLessonInfo?.ItemLearnRateDict)!) as! [String : Any]
                            self.showLessonInfo(result: resultDic,completed: false)
                             ChActivityView.hide()
                            return
                        }
                         ChActivityView.hide()
                        self.showBaseView()
                    }
                }
            }
        }
    
    }

    func getDictionaryFromJSONString(jsonString:String) ->NSDictionary{
        
        let jsonData:Data = jsonString.data(using: .utf8)!
        
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
        
        
    }
    func superViewConstraints() {
        if(self.cardViews[baseView.currentItemIndex].isKind(of: LearningCard.self)){
            (self.cardViews[baseView.currentItemIndex] as! LearningCard).hiddenTips()
        }
        for page in cardViews{
            if(page.isKind(of: QuizCardAudioWord.self)){//文本翻译
                (page as! QuizCardAudioWord).superViewConstraints()
            }
            if(page.isKind(of: ReadAftermeView.self)){//跟读
                (page as! ReadAftermeView).superViewConstraints()
            }
            else if(page.isKind(of: LearningCard.self)){//学习卡
                (page as! LearningCard).superViewConstraints()
            }
            else if(page.isKind(of: QuizCardTextAudio.self)){//补全句子
                (page as! QuizCardTextAudio).superViewConstraints()       
            }
            else if(page.isKind(of: XPDragingView.self)){//排序题
                (page as! XPDragingView).superViewConstraints()
            }
            else if(page.isKind(of: XPDragingViewSentence.self)){//选词排序
                (page as! XPDragingViewSentence).superViewConstraints()
            }
            else if(page.isKind(of: XPDragingViewMutifiy.self)){//多空题
                (page as! XPDragingViewMutifiy).superViewConstraints()
            }
            else if(page.isKind(of: QuizPairingView.self)){//多空题,排序题，选词排序
                (page as! QuizPairingView).superViewConstraints()
            }
            else if(page.isKind(of: QuizCardDialogue.self)){//补全对话题
                (page as! QuizCardDialogue).superViewConstraints()
            }
            if(page.isKind(of: QuizCardSuper.self)){
                (page as! QuizCardSuper).refreshPageValue()
            }
        }
    }
    
    func initCardtype(){
        copyQuizArray.removeAll()
        self.learnItemArray = BeginnerLessonsManager.shared.learningCard
        self.learnItemArray = self.learnItemArray.sorted { (s1, s2) -> Bool in
            let dimension1 = s1.Tags?[0]
            let dimension2 = s2.Tags?[0]
            
            let group1 = Int(dimension1?[5] ?? "0")!
            let group2 = Int(dimension2?[5] ?? "0")!
            let item1 = Int(dimension1?[11] ?? "0")!
            let item2 = Int(dimension2?[11] ?? "0")!
            
            return (group1 == group2) && (item1 < item2)
        }
        for quiz in BeginnerLessonsManager.shared.quizCard {
            //注意改回去
            if copyQuizArray.count > 0 {
                //看看要插入的quiz，是否已经有同样维度的题在里面了
                let group_item = quiz.Tags![0]
                let dimension = Int(quiz.Tags![1].substring(from: 9))
                
                var has = false
                for dimensionQuiz in copyQuizArray {
                    let group_item_in = dimensionQuiz.Tags![0]
                    let dimension_in = Int(dimensionQuiz.Tags![1].substring(from: 9))

                    if dimension_in == dimension && group_item_in == group_item {
                        //已经有同一纬度的了，不再添加
                        has = true
                        exQuizArray.append(quiz)
                        break
                    }
                }
                if !has {
                    copyQuizArray.append(quiz)
                }

            }else
            {
                copyQuizArray.append(quiz)
            }
        }
        self.pagenumber = BeginnerLessonsManager.shared.learningCard.count + copyQuizArray.count
        
        var i = 0,j = 0,k = 0,group = 1, quizcardnumber = 0,learncardnumber = 0,groupLearnCount = 0,everyGroupCount = 0
        while(k<self.pagenumber - 1){
            everyGroupCount = 0
            // 每一group内的learn数量
            groupLearnCount = 0
            j = 0
            var quizTempArray = [Any]()
            while(j<copyQuizArray.count){
                if(copyQuizArray[j].Tags?.first!.hasPrefix("Group"+String(group)))!{
                    quizTempArray.append(copyQuizArray[j])
                    quizcardnumber = quizcardnumber + 1
                    everyGroupCount += 1
                }
                j = j + 1
            }
            //判断quiz数量是不是等于0
            if quizTempArray.count == 0 {
                i = 0
                var learnTempArray = [Any]()
                while(i<BeginnerLessonsManager.shared.learningCard.count){
                    if(BeginnerLessonsManager.shared.learningCard[i].Tags?.first!.hasPrefix("Group"+String(group)))!{
                        groupLearnCount = groupLearnCount + 1
                    }
                    i = i + 1
                }
                self.pagenumber -= groupLearnCount
            }else {
                i = 0
                var learnTempArray = [Any]()
                while(i<BeginnerLessonsManager.shared.learningCard.count){
                    if(BeginnerLessonsManager.shared.learningCard[i].Tags?.first!.hasPrefix("Group"+String(group)))!{
                        cardtype.append(-1)
                        learnTempArray.append(BeginnerLessonsManager.shared.learningCard[i])
                        learncardnumber = learncardnumber + 1
                        everyGroupCount += 1
                    }
                    i = i + 1
                }
                let sortedLearningItem = self.sortLearningItemArray(learningTempArray: learnTempArray as! [ScenarioLessonLearningItem],quizTempArray:quizTempArray as! [QuizSample])
                self.pagenumber -= (learnTempArray.count - sortedLearningItem.count)
                learncardnumber -= (learnTempArray.count - sortedLearningItem.count)
                everyGroupCount -= (learnTempArray.count - sortedLearningItem.count)
                for i in 0..<(learnTempArray.count - sortedLearningItem.count) {
                    cardtype.removeLast()
                }
                BeginnerLessonsManager.shared.allCard = BeginnerLessonsManager.shared.allCard + sortedLearningItem
                
                groupNumberArray.append(everyGroupCount)
                BeginnerLessonsManager.shared.allCard = BeginnerLessonsManager.shared.allCard + self.sortArray(quizTempArray: quizTempArray as! [QuizSample])
                k = learncardnumber + quizcardnumber
            }
            group = group + 1
        }
        self.pagenumber = BeginnerLessonsManager.shared.allCard.count + 1
        cardtype.append(-2)
    }
    
    //如果某个item没有quiz。则不展示这个item
    func sortLearningItemArray(learningTempArray:[ScenarioLessonLearningItem],quizTempArray: [QuizSample]) -> [Any] {
        var learnItemArray = learningTempArray
        var sortedLearnArray = [ScenarioLessonLearningItem]()
        for quizSample in quizTempArray {
            let dimension = quizSample.Tags![0]
            for (i,item) in learnItemArray.enumerated() {
                if item.Tags![0] == dimension {
                    sortedLearnArray.append(item)
                    learnItemArray.remove(at: i)
                }
            }
        }
        return sortedLearnArray
    }
    

    func sortArray(quizTempArray:[QuizSample]) -> [Any] {

        var sortedArray = [Any]()
        for quizSample in quizTempArray {
            let dimension = quizSample.Tags![1]
            let dimensionNum = dimension.substring(from: 9)
            if Int(dimensionNum)! >= 1 && Int(dimensionNum)! <= 4 {
                sortedArray.append(quizSample)
                cardtype.append((quizSample.QuizType?.rawValue)!)
            }
        }

        for quizSample in quizTempArray {
            let dimension = quizSample.Tags![1]
            let dimensionNum = dimension.substring(from: 9)
            if Int(dimensionNum)! >= 5 && Int(dimensionNum)! <= 7 {
                sortedArray.append(quizSample)
                cardtype.append((quizSample.QuizType?.rawValue)!)
            }
        }
        for quizSample in quizTempArray {
            let dimension = quizSample.Tags![1]
            let dimensionNum = dimension.substring(from: 9)
            if Int(dimensionNum)! >= 8 && Int(dimensionNum)! <= 9 {
                sortedArray.append(quizSample)
                cardtype.append((quizSample.QuizType?.rawValue)!)
            }
        }
        for quizSample in quizTempArray {
            let dimension = quizSample.Tags![1]
            let dimensionNum = dimension.substring(from: 9)
            if Int(dimensionNum)! >= 10 {
                sortedArray.append(quizSample)
                cardtype.append((quizSample.QuizType?.rawValue)!)
            }
        }
        return sortedArray
    }
    
    
    func reloadSwipeViewSize(_ swipeView: SwipeView!,frame:CGRect){
        let currentPage = swipeView.currentItemIndex
        for i in 0...(pagenumber-1) {
            cardViews[i].frame = frame
        }
        swipeView.reloadData()
        swipeView.scroll(toPage: currentPage, duration: 0.5)
    }

    func setupPages(i: Int,playAudio:Bool,_ addView: Bool = false) {
        if i >= cardtype.count {
            return
        }
        if i == 0 {
            cardViews.removeAll()
        }
        let y = CGFloat(0)
        var height = CGFloat(0)
        
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
            height = ScreenUtils.height - 78
        }else {
            height = ScreenUtils.height - 54
        }
        
        switch cardtype[i] {
        case 0:
            //这个是不应该有的状态，暂时用图片匹配题
            let page = QuizCardSuper(frame: CGRect(x: leftP/2,  y: y, width: ScreenUtils.width - 4 * leftP, height: height))
            page.makeContinuButton()
            cardViews.append(page)
            page.continueButton.addTarget(self,action:#selector(quizContinue),for:.touchUpInside)
            page.selectDelegate = self
            page.setOrder(order: i)
            page.myIndex = i
            page.backgroundColor = UIColor.red
            page.alpha = 1
            page.showContinue()
            break
        case -3:
            let page = transitionPage(frame: CGRect(x: leftP/2,  y: y, width: ScreenUtils.width - 4 * leftP, height: height))
            cardViews.append(page)
            break
        case -2://结果
            let page = ResultCard(frame: CGRect(x: leftP/2,  y:0, width: ScreenUtils.width - 4 * leftP, height: height))
            cardViews.append(page)
            page.delegate = self
            page.courseId = self.courseId
            page.learnItemArray = self.learnItemArray
            page.redoButton.addTarget(self,action:#selector(TappedRedoButton),for:.touchUpInside)
//            page.doneButton.addTarget(self,action:#selector(doneTask),for:.touchUpInside)
            page.continueButton.addTarget(self,action:#selector(continueTask),for:.touchUpInside)
            break
        case -1://学习卡
            
            var nextType = false
            if cardtype[i+1] != -1 {
                nextType = true
            }
            let page = LearningCard(frame: CGRect(x: leftP/2,  y: y, width: ScreenUtils.width - 4 * leftP, height: height))
            cardViews.append(page)
            page.Lessonid = self.courseId
            page.recordDelegate = self
            page.setData(card: BeginnerLessonsManager.shared.allCard[i] as! ScenarioLessonLearningItem, voice: BeginnerLessonsManager.shared.voice, nextType: nextType)
            page.continueButton.addTarget(self,action:#selector(TappedContinueButton),for:.touchUpInside)
            page.myIndex = i
            if playAudio && !self.showInfo && !self.hasQuited {
                page.videoButton.play()
            }
            break
        case 9://图片匹配题
            let page = QuizCardImageAudio(frame: CGRect(x: leftP/2,  y: y, width: ScreenUtils.width - 4 * leftP, height: height))
            cardViews.append(page)
            page.Lessionid = self.courseId
            page.setData(quiz: BeginnerLessonsManager.shared.allCard[i] as! QuizSample, voice:BeginnerLessonsManager.shared.voice)
            page.continueButton.addTarget(self,action:#selector(quizContinue),for:.touchUpInside)
            page.selectDelegate = self
            page.setOrder(order: i)
            page.myIndex = i
            page.alpha = 0
//            page.showContinue()
            break
        case 11://听力匹配题
            let page = QuizCardAudio(frame: CGRect(x: leftP/2,  y: y, width: ScreenUtils.width - 4 * leftP, height: height))
            cardViews.append(page)
            page.Lessionid = self.courseId
            page.setData(quiz: BeginnerLessonsManager.shared.allCard[i] as! QuizSample, voice: BeginnerLessonsManager.shared.voice)
            page.continueButton.addTarget(self,action:#selector(quizContinue),for:.touchUpInside)
            page.selectDelegate = self
            page.setOrder(order: i)
            page.myIndex = i
            page.alpha = 0
//            page.showContinue()
            break
        case 15://跟读题
            let page = ReadAftermeView(frame: CGRect(x: leftP/2,  y: y, width: ScreenUtils.width - 4 * leftP, height: height))
            cardViews.append(page)
            page.Lessionid = self.courseId
            page.setData(quiz: BeginnerLessonsManager.shared.allCard[i] as! QuizSample, voice: BeginnerLessonsManager.shared.voice)
            page.continueButton.addTarget(self,action:#selector(quizContinue),for:.touchUpInside)
            page.selectDelegate = self
            page.setOrder(order: i)
            page.myIndex = i
            page.alpha = 0
//            page.showContinue()
            break
        case 21://补全对话(长的)
            let page = QuizCardDialogue(frame: CGRect(x: leftP/2,  y: y, width: ScreenUtils.width - 4 * leftP, height: height))
            cardViews.append(page)
            page.Lessionid = self.courseId
            page.setData(quiz: BeginnerLessonsManager.shared.allCard[i] as! QuizSample, voice: BeginnerLessonsManager.shared.voice)
            page.continueButton.addTarget(self,action:#selector(quizContinue),for:.touchUpInside)
            page.selectDelegate = self
            page.setOrder(order: i)
            page.myIndex = i
            page.alpha = 0
//            page.showContinue()
            break
        case 22://文本翻译
            let page = QuizCardAudioWord(frame: CGRect(x: leftP/2,  y: y, width: ScreenUtils.width - 4 * leftP, height: height))
            cardViews.append(page)
            page.Lessionid = self.courseId
            page.setData(quiz: BeginnerLessonsManager.shared.allCard[i] as! QuizSample, voice: BeginnerLessonsManager.shared.voice)
            page.continueButton.addTarget(self,action:#selector(quizContinue),for:.touchUpInside)
            page.selectDelegate = self
            page.setOrder(order: i)
            page.myIndex = i
            page.alpha = 0
//            page.showContinue()
            break
        case 23://补全句子(短的)
            let page = QuizCardTextAudio(frame: CGRect(x: leftP/2,  y: y, width: ScreenUtils.width - 4 * leftP, height: height))
            cardViews.append(page)
            page.Lessionid = self.courseId
            page.setData(quiz: BeginnerLessonsManager.shared.allCard[i] as! QuizSample, voice: BeginnerLessonsManager.shared.voice)
            page.continueButton.addTarget(self,action:#selector(quizContinue),for:.touchUpInside)
            page.selectDelegate = self
            page.setOrder(order: i)
            page.myIndex = i
            page.alpha = 0
//            page.showContinue()
            break
        case 24://理解题
            let page = QuizCardTFComprehension(frame: CGRect(x: leftP/2,  y: y, width: ScreenUtils.width - 4 * leftP, height: height))
            cardViews.append(page)
            page.Lessionid = self.courseId
            page.setData(quiz: BeginnerLessonsManager.shared.allCard[i] as! QuizSample, voice: BeginnerLessonsManager.shared.voice)
            page.continueButton.addTarget(self,action:#selector(quizContinue),for:.touchUpInside)
            page.selectDelegate = self
            page.setOrder(order: i)
            page.myIndex = i
            page.alpha = 0
//            page.showContinue()
            break
        case 25://选词成句题
            let page = XPDragingViewSentence(frame: CGRect(x: leftP/2,  y: y, width: ScreenUtils.width - 4 * leftP, height: height))
            cardViews.append(page)
            page.Lessionid = self.courseId
            page.dragType = .sentences
            page.setData(quiz: BeginnerLessonsManager.shared.allCard[i] as! QuizSample, voice: BeginnerLessonsManager.shared.voice)
            page.continueButton.addTarget(self,action:#selector(quizContinue),for:.touchUpInside)
            page.selectDelegate = self
            page.setOrder(order: i)
            page.myIndex = i
            page.alpha = 0
//            page.showContinue()
            break
        case 26://排序题
            let page = XPDragingView(frame: CGRect(x: leftP/2,  y: y, width: ScreenUtils.width - 4 * leftP, height: height))
            cardViews.append(page)
            page.dragType = .sort
            page.Lessionid = self.courseId
            page.setData(quiz: BeginnerLessonsManager.shared.allCard[i] as! QuizSample, voice: BeginnerLessonsManager.shared.voice)
            page.continueButton.addTarget(self,action:#selector(quizContinue),for:.touchUpInside)
            page.selectDelegate = self
            page.setOrder(order: i)
            page.myIndex = i
            page.alpha = 0
//            page.showContinue()
            break
        case 27://多空
            let page = XPDragingViewMutifiy(frame: CGRect(x: leftP/2,  y: y, width: ScreenUtils.width - 4 * leftP, height: height))
            cardViews.append(page)
            page.Lessionid = self.courseId
            page.dragType = .multipleEmpty
            page.setData(quiz: BeginnerLessonsManager.shared.allCard[i] as! QuizSample, voice: BeginnerLessonsManager.shared.voice)
            page.continueButton.addTarget(self,action:#selector(quizContinue),for:.touchUpInside)
            page.selectDelegate = self
            page.setOrder(order: i)
            page.myIndex = i
            page.alpha = 0
//            page.showContinue()
            break
        case 28://配对题
            let page = QuizPairingView(frame: CGRect(x: leftP/2,  y: y, width: ScreenUtils.width - 4 * leftP, height: height))
            cardViews.append(page)
            page.Lessionid = self.courseId
            page.setData(quiz: BeginnerLessonsManager.shared.allCard[i] as! QuizSample, voice: BeginnerLessonsManager.shared.voice)
            page.continueButton.addTarget(self,action:#selector(quizContinue),for:.touchUpInside)
            page.selectDelegate = self
            page.setOrder(order: i)
            page.myIndex = i
            page.alpha = 0
//            page.showContinue()
            break
        case 29://对错题
            let page = QuizCardTFImageAudio(frame: CGRect(x: leftP/2, y: y, width: ScreenUtils.width - 4 * leftP, height: height))
            cardViews.append(page)
            page.Lessionid = self.courseId
            page.setData(quiz: BeginnerLessonsManager.shared.allCard[i] as! QuizSample, voice: BeginnerLessonsManager.shared.voice)
            page.continueButton.addTarget(self,action:#selector(quizContinue),for:.touchUpInside)
            page.selectDelegate = self
            page.setOrder(order: i)
            page.myIndex = i
            page.alpha = 0
//            page.showContinue()
            break
            
        
        //无用
        case 17:
            let page = QuizCardImageAudio(frame: CGRect(x: leftP,  y: y, width: ScreenUtils.width - 4 * leftP, height: height))
            cardViews.append(page)
            page.Lessionid = self.courseId
            page.setData(quiz: BeginnerLessonsManager.shared.allCard[i] as! QuizSample, voice:BeginnerLessonsManager.shared.voice)
            page.setOrder(order: i)
            page.continueButton.addTarget(self,action:#selector(quizContinue),for:.touchUpInside)
            page.selectDelegate = self
            page.myIndex = i
            page.showContinue()
            break
        case 16:
            let page = QuizCardTextAudio(frame: CGRect(x: leftP/2,  y: y, width: ScreenUtils.width - 4 * leftP, height: height))
            cardViews.append(page)
            page.Lessionid = self.courseId
            page.setData(quiz: BeginnerLessonsManager.shared.allCard[i] as! QuizSample, voice: BeginnerLessonsManager.shared.voice)
            page.continueButton.addTarget(self,action:#selector(quizContinue),for:.touchUpInside)
            page.selectDelegate = self
            page.setOrder(order: i)
            page.myIndex = i
            page.showContinue()
            break
        case 18:
            let page = QuizCardAudioWord(frame: CGRect(x: leftP,  y: y, width: ScreenUtils.width - 4 * leftP, height: height))
            cardViews.append(page)
            page.Lessionid = self.courseId
            page.setData(quiz: BeginnerLessonsManager.shared.allCard[i] as! QuizSample, voice: BeginnerLessonsManager.shared.voice)
            page.setOrder(order: i)
            page.continueButton.addTarget(self,action:#selector(quizContinue),for:.touchUpInside)
            page.selectDelegate = self
            page.myIndex = i
            page.showContinue()
        case 19:
            let page = QuizCardTFImageAudioText(frame: CGRect(x: leftP/2,  y: y, width: ScreenUtils.width - 4 * leftP, height:height))
            cardViews.append(page)
            page.Lessionid = self.courseId
            page.setData(quiz: BeginnerLessonsManager.shared.allCard[i] as! QuizSample, voice: BeginnerLessonsManager.shared.voice)
            page.continueButton.addTarget(self,action:#selector(quizContinue),for:.touchUpInside)
            page.selectDelegate = self
            page.setOrder(order: i)
            page.myIndex = i
            page.showContinue()
            break
        case 20:
            let page = QuizCardTFImageAudio(frame: CGRect(x: leftP/2, y: y, width: ScreenUtils.width - 4 * leftP, height: height))
            cardViews.append(page)
            page.Lessionid = self.courseId
            page.setData(quiz: BeginnerLessonsManager.shared.allCard[i] as! QuizSample, voice: BeginnerLessonsManager.shared.voice)
            page.continueButton.addTarget(self,action:#selector(quizContinue),for:.touchUpInside)
            page.selectDelegate = self
            page.setOrder(order: i)
            page.myIndex = i
            page.showContinue()
            break
        default:
            break
        }
    }
    
    func getLabelWidth(labelStr:String,font:UIFont)->CGFloat{
        let maxSie:CGSize = CGSize(width:view.frame.width,height:13)
        return (labelStr as NSString).boundingRect(with: maxSie, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):font]), context: nil).size.width
    }
    func setProgressUI() {
        
        currentPageNumber = 0
        progressView.backgroundColor = UIColor.grayTheme
        progressViewLabel.textColor = UIColor.blueTheme
        progressViewLabel.textAlignment = .right
        progressViewLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(14), type: .Medium)
        let labelwidth = getLabelWidth(labelStr: "10/10", font: progressViewLabel.font) + 5
        
        progressViewLabel.frame = CGRect(x:view.frame.width - 75, y: CGFloat(titleViewheight - 36), width: labelwidth, height:36)
        progressView.addSubview(progressViewLabel)
        setupProgress()
        
    }
    //MARK:设置进度
    func setupProgress(){
        if groupNumberArray.count == 0 {
            return
        }
        pointViews.removeAll()
        progressViewLabel.text = String(groupNumber + 1)+"/"+String(groupNumberArray.count)
        var top: CGFloat = 0
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
            top = 33
        }
        //修改进度条长度
        let eachWdith = (view.frame.width)/CGFloat((groupNumberArray[groupNumber]))
        for i in 0...groupNumberArray[groupNumber]{
            
            let point =  UIView(frame: CGRect(x:CGFloat(i), y: top, width:eachWdith*CGFloat(i + 1)-CGFloat(i), height: 7))
            point.backgroundColor = UIColor.grayTheme
            progressView.addSubview(point)
            pointViews.append(point)
        }
        for page in pointViews{
            page.removeFromSuperview()
        }
        for page in pointViews.reversed(){
            progressView.addSubview(page)
        }
        pointViews[0].backgroundColor = UIColor.blueTheme
        view.addSubview(progressView)
    }
    
    //MARK: - : 语言选择
    @objc func moreTapped() {
        LCVoiceButton.stopGlobal()
        LCVoiceButton.singlePlayer.delegate?.playFinish()
        UIApplication.shared.keyWindow!.addSubview(setingView)
        setingView.delegate = self
        setingView.snp.makeConstraints { (make) -> Void in
            make.left.right.top.bottom.equalTo(UIApplication.shared.keyWindow!)
        }
        NotificationCenter.default.post(name: ChNotifications.DismissPop.notification, object: nil)
        
        if(self.cardViews[baseView.currentItemIndex].isKind(of: LearningCard.self)){
            let page = cardViews[self.baseView.currentItemIndex] as! LearningCard
            page.chineseandpinyinLabel.pop = nil
        }
        
        
        if(self.cardViews[self.baseView.currentItemIndex].isKind(of: LearningCard.self)){
            //埋点：点击左上角关闭
            let data = BeginnerLessonsManager.shared.allCard[self.currentPageNumber] as! ScenarioLessonLearningItem
            setingView.Scope = "Learn"
            setingView.Lessonid = self.courseId
            setingView.Subscope = "Learn"
            setingView.IndexPath = data.Tags![0]
        }else if(self.self.cardViews[self.baseView.currentItemIndex].isKind(of: QuizCardSuper.self)){

            //埋点：点击左上角关闭
            let data = BeginnerLessonsManager.shared.allCard[self.currentPageNumber] as! QuizSample
            setingView.Scope = "Learn"
            setingView.Lessonid = self.courseId
            setingView.Subscope = "Quiz"
            setingView.IndexPath = (data.Body?.Text)!
        }
        
        
        
    }
    
    //MARK: - : Redo
    @objc func TappedRedoButton(button:UIButton)  {
        if(UserManager.shared.isLoggedIn() && AppData.userAssessmentEnabled){
            //登陆了
            let cardVC = LearnCardFlowViewController()
            cardVC.courseId = courseId
            cardVC.repeatId = repeatId
            cardVC.titleString = titleString
            cardVC.showInfo = false
            cardVC.loopSunValue = self.loopSunValue
            cardVC.finishLearning = { (coinValue,completed) in
//                self.loopSunValue += coinValue
                self.loopSunValue = coinValue
                self.finishLearning?(self.loopSunValue,completed)
            }
            self.navigationController?.pushViewController(cardVC, animated: true)
            self.navigationItem.hidesBackButton = true
        }else {
            //没登录
            let vc = LoginFullViewController()
            vc.dissmis = true
            if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
                vc.offset = 78
            }else{
                vc.offset = 54
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //大于一轮，进入学习流
    @objc func continueTask(button:UIButton)  {
        
    }

    //每一part最后一个Quiz，点击Contuine进入学习卡
    @objc func quizContinue() {
        changeThemeColor(learn: true)
        exQuizNumber = 0
        groupProgressNumber = 1
        groupNumber += 1
        evenAdd = -1
        setupProgress()
        self.learningItem = true
        cardViews.removeAll()
        showPagenumber = 0
        progressNumber = progressNumber - 1
        self.lastPageIndex = 0
        self.lastPage = 0
        for i in 0..<cardtype.count {
            if cardtype[i + progressNumber] == -1 {
                showPagenumber += 1
            }else {
                break
            }
        }
        
        if cardtype.count > 1 {
            for i in 0..<showPagenumber + 1 {
                var playAudio = false
                if i == 0{
                    playAudio = true
                }
                self.setupPages(i:i + progressNumber,playAudio: playAudio)
            }
        }
        currentPageNumber = progressNumber
        progressViewLabel.text = String(groupNumber + 1)+"/"+String(groupNumberArray.count)
        progressNumber = progressNumber + showPagenumber
        baseView.previousItemIndex = 0
        baseView.currentItemIndex = 0
        self.baseView.itemsPerPage = 1
        baseView.isScrollEnabled = true
        self.baseView.reloadData()
//        if self.showPagenumber == 1 {
//            if (self.cardViews[0].isKind(of: LearningCard.self)){
//                let currentView = self.cardViews[0] as! LearningCard
//                currentView.showContinue()
//            }
//        }
        if self.currentPageNumber < BeginnerLessonsManager.shared.allCard.count {
            if let data = BeginnerLessonsManager.shared.allCard[self.currentPageNumber] as? QuizSample {
                let info = ["Scope" : "Learn","Lessonid" : self.courseId,"Subscope" : "Quiz","IndexPath" : data.Body?.Text,"Event" : "Continue"]
                UserManager.shared.logUserClickInfo(info)
            }
        }
    }
    //添加阳光值
    func addSunValueNoCombo(value: Int) {
        if(AppData.userAssessmentEnabled && UserManager.shared.isLoggedIn()){
            sunValue = value
            allSunValue += sunValue
            self.sunButton.setTitle(" \(allSunValue)", for: .normal)
            SunAnimationView.showSunValue(sunValue, combo: -1)
        }
    }
    //添加阳光值
    func addSunValue(value: Int) {
        if(AppData.userAssessmentEnabled && UserManager.shared.isLoggedIn()){
            if value == -1 {
                //答错，连加结束
                evenAdd = -1
                return
            }
            evenAdd += 1
            sunValue = value + evenAdd
            allSunValue += sunValue
            self.sunButton.setTitle(" \(allSunValue)", for: .normal)
            SunAnimationView.showSunValue(sunValue, combo: evenAdd)
        }
    }
    //选择了错误的答案，查找是否有备用
    func showSamepage(tag: [String]?) {
        DispatchQueue.global(qos: .default).async {
            //处理耗时操作的代码块...
            let group_item_in = tag![0]
            let dimension_in = Int(tag![1].substring(from: 9))
            var dimensionArray = [1,2,3,4]
            switch dimension_in {
            case 1:
                dimensionArray = [1,2,3,4]
                break
            case 2:
                dimensionArray = [1,2,3,4]
                break
            case 3:
                dimensionArray = [1,2,3,4]
                break
            case 4:
                dimensionArray = [1,2,3,4]
                break
                
            case 5:
                dimensionArray = [5,6,7]
                break
            case 6:
                dimensionArray = [5,6,7]
                break
            case 7:
                dimensionArray = [5,6,7]
                break
                
            case 8:
                dimensionArray = [8,9]
                break
            case 9:
                dimensionArray = [8,9]
                break
            case 10:
                dimensionArray = [10]
                break
            default:
                dimensionArray = [0]
            }
            
            for (i,quiz) in self.exQuizArray.enumerated() {
                let group_item = quiz.Tags![0]
                let dimension = Int(quiz.Tags![1].substring(from: 9))
                if dimensionArray.contains(dimension!) && group_item_in == group_item {
                    //有的话插入
                    self.answerFalse = true
                    self.exQuizNumber += 1
                    BeginnerLessonsManager.shared.allCard.insert(quiz, at: self.progressNumber)
                    self.cardtype.insert((quiz.QuizType?.rawValue)!, at: self.progressNumber)
                    self.cardViews.removeLast()
                    self.exQuizArray.remove(at: i)
                    //操作完成，调用主线程来刷新界面
                    DispatchQueue.main.async {
                        self.setupPages(i: self.progressNumber,playAudio: false,true)
                        self.baseView.reloadData()
                    }
                    break
                }
            }
        }
        
    }

    //选择了正确的选项，读完语音之后跳转
    func gotoNextpage() {
        self.showPagenumber += 1
        self.progressNumber += 1
        self.setupPages(i: self.progressNumber,playAudio: false)
        //下一个是学习卡，当前是问题卡，那么删除前面的
//        let delay = DispatchTime.now() + 0.0
//        DispatchQueue.main.asyncAfter(deadline: delay) {
        if(!self.cardViews[self.baseView.currentItemIndex].isKind(of: LearningCard.self)){
            if self.baseView.currentItemIndex + 1 >= self.cardViews.count {
                return
            }
            if (self.cardViews[self.baseView.currentItemIndex + 1].isKind(of: LearningCard.self)){
                let currentView = self.cardViews[self.baseView.currentItemIndex] as! QuizCardSuper
                currentView.showContinue()
            }
            else {
                self.baseView.reloadData()
               UIView.animate(withDuration: 0.4) {
                    self.cardViews[self.baseView.currentItemIndex + 1].alpha = 1
                }
                self.baseView.scrollToItem(at: self.baseView.currentItemIndex+1, duration: 0.5)
                
                if(self.cardViews[self.baseView.currentItemIndex].isKind(of: ResultCard.self)){
                    self.cardViews[self.baseView.currentItemIndex - 1].alpha = 0
                }
            }
        }else {
            self.baseView.reloadData()
            if self.baseView.currentItemIndex + 1 >= self.cardViews.count {
                return
            }
           UIView.animate(withDuration: 0.4) {
                self.cardViews[self.baseView.currentItemIndex + 1].alpha = 1
            }
            
            self.baseView.scrollToItem(at: self.baseView.currentItemIndex+1, duration: 0.3)
            if(self.cardViews[self.baseView.currentItemIndex].isKind(of: ResultCard.self)){
                self.cardViews[self.baseView.currentItemIndex].alpha = 0
            }
        }
//        }
    }
    
    //MARK: - :学习卡上的Continue
    @objc func TappedContinueButton(button:UIButton) {
        changeThemeColor(learn: false)
        learningItem = false
        button.isEnabled = false
        showPagenumber += 1
        progressNumber += 1
        self.setupPages(i: progressNumber,playAudio: false)
        baseView.reloadData()
       UIView.animate(withDuration: 0.4) {
            self.cardViews[self.baseView.currentItemIndex + 1].alpha = 1
        }
        
        baseView.scrollToItem(at: baseView.currentItemIndex+1, duration: 0.5)
        if((button.superview?.isKind(of: LearningCard.self))!){
            let page = button.superview as! LearningCard
            page.recordingView_read.cancelRecording(sender: nil)
            if page.videoButton.playerStatus == VedioStatus.playing {
                page.videoButton.stop()
            }
            //埋点：点击Continue
            let info = ["Scope" : "Learn","Lessonid" : page.Lessonid,"Subscope" : "Learn","IndexPath" : page.currentCard?.Tags![0],"Event" : "Continue"]
            UserManager.shared.logUserClickInfo(info)
            
        }else if((button.superview?.isKind(of: QuizCardSuper.self))!){
            let page = button.superview as! QuizCardSuper
            if page.videoButton.playerStatus == VedioStatus.playing {
                page.videoButton.stop()
            }
        }
        
    }
    //MARK: - : 导航控制器方法
    var willAppear = false
    
    override func setNeedsStatusBarAppearanceUpdate() {
        super.setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override var prefersStatusBarHidden: Bool {
        return willAppear
    }
    
    //MARK: - : 退出learn
    @objc func quitLearn() {
        self.cancelButton.isEnabled = false
        if (cardViews.count == 0) {
            hasQuited = true
            self.navigationController?.dismiss(animated: true, completion: nil)
            return
        }
        if(cardViews[self.baseView.currentItemIndex].isKind(of: LearningCard.self)){
            let page = cardViews[self.baseView.currentItemIndex] as! LearningCard
            page.recordingView_read.cancelRecording(sender: nil)
            if page.videoButton.playerStatus == VedioStatus.playing {
                page.videoButton.pause()
            }
            
        }else if(cardViews[self.baseView.currentItemIndex].isKind(of: QuizCardSuper.self)){
            let page = cardViews[self.baseView.currentItemIndex] as! QuizCardSuper
            if page.videoButton.playerStatus == VedioStatus.playing {
                page.videoButton.pause()
            }
            
        }
        if showInfo {
            hasQuited = true
            self.navigationController?.dismiss(animated: true, completion: nil)
            return
        }
        LCAlertView.show(title: "Quit This Session", message: "Are you sure you want to quit? All progress in the session will be lost.", leftTitle: "Quit", rightTitle: "Cancel", style: .center, leftAction: {
            LCAlertView.hide()
            self.hasQuited = false
            if self.baseView.currentItemIndex < self.cardViews.count {
                if(self.cardViews[self.baseView.currentItemIndex].isKind(of: LearningCard.self)){
                    let page = self.cardViews[self.baseView.currentItemIndex] as! LearningCard
                    page.recordingView_read.cancelRecording(sender: nil)
                    if page.videoButton.playerStatus == VedioStatus.playing {
                        page.videoButton.stop()
                    }
                }else if(self.cardViews[self.baseView.currentItemIndex].isKind(of: QuizCardSuper.self)){
                    let page = self.cardViews[self.baseView.currentItemIndex] as! QuizCardSuper
                    if page.videoButton.playerStatus == VedioStatus.playing {
                        page.videoButton.stop()
                    }
                }
                if (self.cardViews[self.baseView.currentItemIndex].isKind(of: ReadAftermeView.self)){
                    let curpage = self.cardViews[self.baseView.currentItemIndex] as? ReadAftermeView
                    if (curpage != nil) {
                        curpage?.playButton.pause()
                        curpage?.recordingView_read.cancelRecording(sender: nil)
                    }
                }
            }
            if self.currentPageNumber < BeginnerLessonsManager.shared.allCard.count {
                if let data = BeginnerLessonsManager.shared.allCard[self.currentPageNumber] as? QuizSample {
                    let info = ["Scope" : "Learn","Lessonid" : self.courseId,"Subscope" : "Quiz","IndexPath" : data.Body?.Text,"Event" : "Quit","Value" : "Apply"]
                    UserManager.shared.logUserClickInfo(info)
                }else if let data = BeginnerLessonsManager.shared.allCard[self.currentPageNumber] as? ScenarioLessonLearningItem {
                    
                    let info = ["Scope" : "Learn","Lessonid" : self.courseId,"Subscope" : "Learn","IndexPath" : data.Tags![0],"Event" : "Quit","Value" : "Apply"]
                    UserManager.shared.logUserClickInfo(info)
                }
            }
            self.hasQuited = true
            self.navigationController?.dismiss(animated: true, completion: nil)
        }, rightAction: {
            LCAlertView.hide()
            self.hasQuited = false
            if self.currentPageNumber < BeginnerLessonsManager.shared.allCard.count {
                if let data = BeginnerLessonsManager.shared.allCard[self.currentPageNumber] as? QuizSample {
                    let info = ["Scope" : "Learn","Lessonid" : self.courseId,"Subscope" : "Quiz","IndexPath" : data.Body?.Text,"Event" : "Quit","Value" : "Cancel"]
                    UserManager.shared.logUserClickInfo(info)
                }else if let data = BeginnerLessonsManager.shared.allCard[self.currentPageNumber] as? ScenarioLessonLearningItem {
                    
                    let info = ["Scope" : "Learn","Lessonid" : self.courseId,"Subscope" : "Learn","IndexPath" : data.Tags![0],"Event" : "Quit","Value" : "Cancel"]
                    UserManager.shared.logUserClickInfo(info)
                }
            }
        })
        self.cancelButton.isEnabled = true
    }
    
    //MARK: - : 点击advanced or continue
    func doneTask() {
//        //检查有没有解锁的课程
//        finishLearning?(self.loopSunValue)
//        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - : 加载失败和加载中的代理方法
    func reloadData() {
        loadData()
    }
    
    @objc func backClick() {
        quitLearn()
    }
    
    func cancleLoading(){
        quitLearn()
    }
    //MARK:修改背景颜色
    func changeThemeColor(learn:Bool) {
        let bgColor = learn ? UIColor.grayTheme : UIColor.white
        self.view.backgroundColor = bgColor
        progressView.backgroundColor = bgColor
        
        if(groupProgressNumber<groupNumberArray[groupNumber]){
            for i in groupProgressNumber+1...groupNumberArray[groupNumber]{
                let view = pointViews[i]
                view.backgroundColor = bgColor
            }
            
        }else{
            for i in 0...groupNumberArray[groupNumber]{
                let view = pointViews[i]
                view.backgroundColor = UIColor.blueTheme
            }
        }
    }
    
}
//MARK: - : 扩展LearnCardFlowViewController
extension LearnCardFlowViewController: SwipeViewDataSource, SwipeViewDelegate,ResultCardDelegate{
    func doneClick(completed:Bool) {
        //检查有没有解锁的课程
        finishLearning?(self.loopSunValue,completed)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    func numberOfItems(in swipeView: SwipeView!) -> Int {
        return showPagenumber
    }
    
    func swipeView(_ swipeView: SwipeView!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {
        if index >= cardViews.count {
            var height = CGFloat(0)
            let y = CGFloat(0)
            if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
                height = ScreenUtils.height - 78
            }else {
                height = ScreenUtils.height - 54
            }
            if index >= cardViews.count {
                return  UIView(frame: CGRect(x: leftP/2,  y: y, width: ScreenUtils.width - 4 * leftP, height: height))
            }
        }
        return cardViews[index]
    }
    
    func swipeViewCurrentItemIndexDidChange(_ swipeView: SwipeView!) {
        //埋点：滑动学习卡，区分滑动至上一张还是下一张
        if (self.cardViews[swipeView.currentItemIndex].isKind(of: LearningCard.self)){
            var value = "Next"
            if swipeView.previousItemIndex < swipeView.currentPage {
                //往后
                value = "Next"
            }else {
                //往前
                value = "Last"
            }
            let currentPage = cardViews[swipeView.previousItemIndex] as! LearningCard
            let info = ["Scope" : "Learn","Lessonid" : self.courseId,"Subscope" : "Learn","IndexPath" : currentPage.currentCard?.Tags![0],"Event" : "Slide","Value" : value]
            UserManager.shared.logUserClickInfo(info)
            
            let values = currentPage.tokensArrayOfClick.values
            var clicked = false
            for i in values {
                if i > 0 {
                    //说明点击过
                    clicked = true
                    break
                }
            }
            
            if clicked {
                let infoClick = ["Scope" : "Learn","Lessonid" : self.courseId,"Subscope" : "Learn","IndexPath" : currentPage.currentCard?.Tags![0],"Event" : "Tokens","Value" : currentPage.tokensArrayOfClick] as [String : Any]
                UserManager.shared.logUserClickInfo(infoClick)
                for (key, value) in currentPage.tokensArrayOfClick
                {
                    if value > 0 {
                        currentPage.tokensArrayOfClick.updateValue(0, forKey: key)
                    }
                }
            }
        }
        
        //前一个是学习卡，当前是问题卡，隐藏学习卡
        if lastPageIndex != 0 && swipeView.currentItemIndex != 0 {
            if(self.cardViews[swipeView.previousItemIndex].isKind(of: LearningCard.self)){
                if (!self.cardViews[swipeView.currentItemIndex].isKind(of: LearningCard.self)){
                    UIView.animate(withDuration: 0.1) {
                        self.cardViews[swipeView.previousItemIndex].alpha = 0
                    }
                }
            }
            //前一个是问题卡，不让前一个显示
            if(!self.cardViews[swipeView.previousItemIndex].isKind(of: LearningCard.self)){
                UIView.animate(withDuration: 0.1) {
                    self.cardViews[swipeView.previousItemIndex].alpha = 0
                }
            }
            //当前事问题卡
            
            if(!self.cardViews[swipeView.currentPage].isKind(of: LearningCard.self)){
                if swipeView.currentItemIndex + 1 < self.cardViews.count - 1 {
                    if (self.cardViews[swipeView.currentItemIndex + 1].isKind(of: LearningCard.self)){
                        UIView.animate(withDuration: 0.1) {
                            self.cardViews[swipeView.currentItemIndex + 1].alpha = 0
                        }
                    }
                }
            }
            //当前问题卡，下一个问题卡
            if (!self.cardViews[swipeView.currentItemIndex].isKind(of: LearningCard.self)){
                if swipeView.currentItemIndex + 1 < self.cardViews.count - 1 {
                    if (!self.cardViews[swipeView.currentItemIndex + 1].isKind(of: LearningCard.self)){
                        UIView.animate(withDuration: 0.1) {
                            self.cardViews[swipeView.currentItemIndex + 1].alpha = 0
                        }
                    }
                }
            }
        }
        if(cardViews[swipeView.previousItemIndex].isKind(of: LearningCard.self)){
            let lastpage = cardViews[swipeView.previousItemIndex] as! LearningCard
            lastpage.hiddenTips()
            lastpage.tappedHiddenTokens()
            if (!self.cardViews[swipeView.currentItemIndex].isKind(of: LearningCard.self)){
                UIView.animate(withDuration: 0.1) {
                    self.cardViews[swipeView.previousItemIndex].alpha = 0
                }
            }
        }
        
        self.lastPage = swipeView.currentItemIndex
        //进度条管理
        let num = progressNumber - showPagenumber + baseView.currentItemIndex
        groupProgressNumber = swipeView.currentItemIndex - exQuizNumber
        if(groupProgressNumber<groupNumberArray[groupNumber]){
            for i in 0...groupProgressNumber{
                let view = pointViews[i]
                view.backgroundColor = UIColor.blueTheme
            }
            for i in groupProgressNumber+1...groupNumberArray[groupNumber]{
                let view = pointViews[i]
                view.backgroundColor = UIColor.grayTheme
            }
        }else{
            for i in 0...groupNumberArray[groupNumber]{
                let view = pointViews[i]
                view.backgroundColor = UIColor.blueTheme
            }
        }
        
        if(cardtype[swipeView.currentItemIndex] != -2){
            currentPageNumber = num
            progressViewLabel.text = String(groupNumber + 1)+"/"+String(groupNumberArray.count)
        }
        self.lastPageIndex = swipeView.currentItemIndex

        if(cardViews[swipeView.previousItemIndex].isKind(of: LearningCard.self)){
            let lastpage = cardViews[swipeView.previousItemIndex] as! LearningCard
            lastpage.recordingView_read.cancelRecording(sender: nil)
            if lastpage.videoButton.playerStatus == VedioStatus.playing {
                lastpage.videoButton.stop()
            }
        }else if(cardViews[swipeView.previousItemIndex].isKind(of: QuizCardSuper.self)){
            let lastpage = cardViews[swipeView.previousItemIndex] as! QuizCardSuper
            if lastpage.videoButton.playerStatus == VedioStatus.playing {
                lastpage.videoButton.stop()
            }
        }

        if(!cardViews[swipeView.currentItemIndex].isKind(of: LearningCard.self)){
            baseView.isScrollEnabled = false
            changeThemeColor(learn: false)

        }else {
            baseView.isScrollEnabled = true
            changeThemeColor(learn: true)
        }

        if(cardViews[swipeView.currentItemIndex].isKind(of: LearningCard.self)){
            let curpage = self.cardViews[swipeView.currentItemIndex] as! LearningCard
            if !hasQuited {
                curpage.videoButton.play()
            }
            
        }
        else if (cardViews[swipeView.currentItemIndex].isKind(of: ReadAftermeView.self)){
            let curpage = self.cardViews[swipeView.currentItemIndex] as! ReadAftermeView
            curpage.playButton.play()
        }
        else if (cardViews[swipeView.currentItemIndex].isKind(of: QuizCardAudio.self)){
            let curpage = self.cardViews[swipeView.currentItemIndex] as! QuizCardAudio
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                curpage.videoButton.play()
            }
        }
//        else if (cardViews[swipeView.currentItemIndex].isKind(of: QuizCardSuper.self)){
//            let curpage = self.cardViews[swipeView.currentItemIndex] as! QuizCardSuper
//            curpage.videoButton.play()
//        }
        
        if(cardtype[num] == -2){
            if self.setingView != nil {
                self.setingView.removeFromSuperview()
            }
//            willAppear = true
//            self.setNeedsStatusBarAppearanceUpdate()
            self.sunButton.isHidden = true
            self.loopSunValue += self.allSunValue
            if AppData.userAssessmentEnabled && UserManager.shared.isLoggedIn(){
                //update progress
                ChActivityView.shared.delegate = self
                ChActivityView.show(.EvaluatingLearn, UIApplication.shared.keyWindow!, UIColor.white, ActivityViewText.EvaluatingLearn, UIColor.textGray, UIColor.white)
                CourseManager.shared.updateCourseProgress(classType:ClassType.Scenario ,id: self.courseId) {
                    success in
                        UserManager.shared.updateUserCoin(coinDelta: self.allSunValue, completion: { (success) in
                            (self.cardViews.last as! ResultCard).allSunValue = self.allSunValue
                            if self.alreadyCompleted {
                                (self.cardViews.last as! ResultCard).loadData(ResultStatusStyle.alreadyCompletedAfter)
                            }else {
                                (self.cardViews.last as! ResultCard).loadData(ResultStatusStyle.other)
                            }
                        })
                        //存储学过的单词
                        RequestManager.shared.refresh = false
                        CourseManager.shared.SetCoursesList(update: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            ChActivityView.hide()
                        }
                }
            }
            progressView.isHidden = true
            cancelButton.isHidden = true
            moreButton.isHidden = true
        }
    }
    func swipeViewWillBeginDragging(_ swipeView: SwipeView!) {
        if learningItem {
            if showPagenumber != 1 && swipeView.currentItemIndex == showPagenumber - 1{
                let curpage = swipeView.currentItemView as! LearningCard
                curpage.showContinue()
            }else if showPagenumber == 1{
                let curpage = swipeView.currentItemView as! LearningCard
                curpage.showContinue()
            }
        }

    }
    
    func swipeViewDidEndScrollingAnimation(_ swipeView: SwipeView!) {
        if learningItem {
            if swipeView.currentItemIndex == showPagenumber - 1 {
                let curpage = swipeView.currentItemView
                if (curpage?.isKind(of: LearningCard.self))! {
                    if let currentPage = (curpage as? LearningCard) {
                        currentPage.showContinue()
                    }
                }
            }
        }
    }

    func swipeViewDidEndDecelerating(_ swipeView: SwipeView!) {
        if learningItem {
            if swipeView.currentItemIndex == showPagenumber - 1 {
                let curpage = swipeView.currentItemView
                if (curpage?.isKind(of: LearningCard.self))! {
                    if let currentPage = (curpage as? LearningCard) {
                        currentPage.showContinue()
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
