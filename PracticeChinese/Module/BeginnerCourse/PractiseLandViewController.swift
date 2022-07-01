//
//  PractiseLandViewController.swift
//  PracticeChinese
//
//  Created by Temp on 2018/9/12.
//  Copyright © 2018年 msra. All rights reserved.
//

import UIKit
//土地页面
class PractiseLandViewController: UIViewController ,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate {
    
    var collectionView : UICollectionView!
    var courseNum:IndexPath?
    var courseStatusDictionary : [String : [String:Any]]?
    var achievement:Int = 0
    var recieveNotiOne:Int = 0
    var menuButton = UIButton()
    var headerView: FDSlideBar!
    let clearance = CGFloat(24.0)
    var _isScrollDown = true//滚动方向
    var _selectIndex = 0//记录位置
    var lastOffsetY: CGFloat = 0
    var sunButton = UIButton()
    var bgView: UIView?
    var oldImage = UIImage(named: "seed_success")
    var circleView: AnimationView?
    //新解锁的课程
    var unlockLesson = [ScenarioSubLesson]()
    var unlockIndexPath = [IndexPath]()
    var refreshLand = true
    var updateCoin: ((Int) -> Void)?
    var collectCellNum: CGFloat = 4.0
    var sunValueCost = SunValueManager.shared()
    //第一次进来
    var firstIn = true
    
    var gardenCourseList = [ScenarioSubLessonInfo?]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    var farmCourseList = [ScenarioSubLessonInfo?]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    var orchardCourseList = [ScenarioSubLessonInfo?]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    var fieldCourseList = [ScenarioSubLessonInfo?]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        analytics()
        if AdjustGlobal().CurrentScale == AdjustScale.iPad {
            collectCellNum = 6.0
        }
        self.view.backgroundColor = UIColor.white
        self.automaticallyAdjustsScrollViewInsets = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.fromColor(color: UIColor.hex(hex: "F8F8F8")), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "Conversation"
        self.navigationController?.navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary(self.ch_getTitleAttribute(textColor: UIColor.textBlack333))// temp
        //设置回退按钮为白色
        self.navigationController?.navigationBar.tintColor = UIColor.textBlack333
        //隐藏底部 tab 栏
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.fromColor(color: UIColor.hex(hex: "F8F8F8")), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.createUI()
        
        loadData()
        setupSlideBar()
        
        let backButton = UIButton(frame: CGRect(x: 20, y: 0, width: 30, height: 40))
        backButton.setImage(ChImageAssets.left_BackArrow.image, for: .normal)
        backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
        backButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        self.navigationItem.setLeftBarButton(UIBarButtonItem(customView:backButton), animated: true)

        menuButton.frame = CGRect(x: 0, y: 0, width:44, height: 44)
        menuButton.setImage(UIImage(named: "drawer"), for: .normal)
        menuButton.addTarget(self, action: #selector(completedPractise), for: .touchUpInside)
        menuButton.imageView?.contentMode = .scaleAspectFit
        menuButton.imageEdgeInsets=UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: -10)
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        self.navigationItem.setRightBarButtonItems([negativeSpacer,UIBarButtonItem(customView:menuButton)], animated: true)
    }
    func loadData() {
        
        if CourseManager.shared.beginnerLessonInfo != nil && CourseManager.shared.beginnerLessonInfo.SubLessons?.count != 0 {
            self.fieldCourseList.removeAll()
            self.fieldCourseList = CourseManager.shared.mediumLessonInfo!.SubLessons!
        }
        
        if CourseManager.shared.practicalLessonInfo != nil && CourseManager.shared.practicalLessonInfo.SubLessons?.count != 0 {
            self.farmCourseList.removeAll()
            self.orchardCourseList.removeAll()
            self.gardenCourseList.removeAll()
            self.fieldCourseList.removeAll()
            for course in CourseManager.shared.practicalLessonInfo!.SubLessons![0].SubLessons! {
                self.farmCourseList.append(course)
            }
            
            for course in CourseManager.shared.practicalLessonInfo!.SubLessons![1].SubLessons! {
                self.orchardCourseList.append(course)
            }
            
            for course in CourseManager.shared.practicalLessonInfo!.SubLessons![2].SubLessons! {
                self.gardenCourseList.append(course)
            }
            
            for course in CourseManager.shared.practicalLessonInfo!.SubLessons![3].SubLessons! {
                self.fieldCourseList.append(course)
            }
        }
        
        //排序
        self.farmCourseList = self.farmCourseList.sorted { (s1, s2) -> Bool in
            let id1 = s1?.ScenarioLessonInfo?.Id?.components(separatedBy: "-")
            let id2 = s2?.ScenarioLessonInfo?.Id?.components(separatedBy: "-")
            return Int(id1![3])! < Int(id2![3])!
        }
        self.gardenCourseList = self.gardenCourseList.sorted { (s1, s2) -> Bool in
            let id1 = s1?.ScenarioLessonInfo?.Id?.components(separatedBy: "-")
            let id2 = s2?.ScenarioLessonInfo?.Id?.components(separatedBy: "-")
            return Int(id1![3])! < Int(id2![3])!
        }
        self.orchardCourseList = self.orchardCourseList.sorted { (s1, s2) -> Bool in
            let id1 = s1?.ScenarioLessonInfo?.Id?.components(separatedBy: "-")
            let id2 = s2?.ScenarioLessonInfo?.Id?.components(separatedBy: "-")
            return Int(id1![3])! < Int(id2![3])!
        }
        self.fieldCourseList = self.fieldCourseList.sorted { (s1, s2) -> Bool in
            let id1 = s1?.ScenarioLessonInfo?.Id?.components(separatedBy: "-")
            let id2 = s2?.ScenarioLessonInfo?.Id?.components(separatedBy: "-")
            return Int(id1![3])! < Int(id2![3])!
        }
        self.collectionView.reloadData()
        for lesson in self.unlockLesson {
            let idString = lesson.ScenarioLessonInfo?.Id
            let row = String(idString!).components(separatedBy: "-")[3]
            let section = String(idString!).components(separatedBy: "-")[2]
            let indexPath = IndexPath(row: Int(row)! - 1, section: Int(section)!)
            unlockIndexPath.append(indexPath)
        }
        if (self.unlockIndexPath.count) > 0 {
                self.collectionView.scrollToItem(at: self.unlockIndexPath.first ?? IndexPath(row: 0, section: 0), at: .top, animated: true)
        }

    }
    
    
    func analytics() {
        if UserManager.shared.isLoggedIn(){
            if(!AppData.userAssessmentEnabled){
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    LCAlertView.show(title: String.PrivacyTitle, message: String.PrivacyConsent, leftTitle: "Don't Allow", rightTitle: "Allow", style: .center, leftAction: {
                        LCAlertView.hide()
                    }, rightAction: {
                        LCAlertView.hide()
                        AppData.setUserAssessment(true)
                        self.collectionView.reloadData()
                        self.setupSlideBar()
                    })
                }
            }
        }
    }
    func setupSlideBar() {
        if bgView != nil {
            bgView?.removeFromSuperview()
            bgView = nil
        }
        bgView = UIView()
        bgView?.backgroundColor = UIColor.hex(hex: "F8F8F8")
        bgView?.frame = CGRect(x: 0, y: 0, width: ScreenUtils.width, height: 40)
        view.addSubview(bgView!)
  
        let sliderBar = FDSlideBar()
        let width = self.getLabelWidth(score: "\(self.achievement)")
        var sliderWidth = Int(ScreenUtils.width) - Int(width) - 65
        
        if !AppData.userAssessmentEnabled {
            sliderWidth = Int(ScreenUtils.width)
        }
        sliderBar.frame = CGRect(x: 0, y: 0, width: sliderWidth, height: 40)
        sliderBar.backgroundColor = UIColor.hex(hex: "F8F8F8")
        // Init the titles of all the item
        sliderBar.itemsTitle = ["Level 1", "Level 2", "Level 3", "Level 4",]
        // Set some style to the slideBar
        sliderBar.itemColor = UIColor.hex(hex: "C6C6C6")
        sliderBar.itemSelectedColor = UIColor.hex(hex: "83BB56")
        sliderBar.sliderColor = UIColor.hex(hex: "F8F8F8")
        sliderBar.slideBarItemSelectedCallback({ (idx,title) in
            self.collectionView.scrollToItem(at: IndexPath(row: 0, section: Int(idx * 2)), at: UICollectionView.ScrollPosition.top, animated: true)
        })
        self.headerView = sliderBar
        bgView?.addSubview(self.headerView)
        
        let leftView = UIView()
        gradientColor(gradientView: leftView,directionFromLeft:0)
        leftView.frame = CGRect(x: 0, y: 0, width: 20, height: 40)
        bgView?.addSubview(leftView)
        
        let rightView = UIView()
        gradientColor(gradientView: rightView,directionFromLeft:1)
        rightView.frame = CGRect(x: sliderWidth + 10, y: 0, width: 20, height: 40)
        bgView?.addSubview(rightView)

        if AppData.userAssessmentEnabled {
            let sunBgView = UIView()
            sunBgView.frame = CGRect(x: sliderWidth + 30, y: 0, width: Int(width + 30), height: 40)
            sunBgView.backgroundColor = UIColor.hex(hex: "F8F8F8")
            bgView?.addSubview(sunBgView)
            self.sunButton.setTitle(" \(self.achievement)", for: .normal)
            sunButton.frame = CGRect(x: 20, y: 0, width:width, height: 40)
            sunButton.setImage(UIImage(named: "sunNew"), for: .normal)
            sunButton.setTitleColor(UIColor.hex(hex: "FFAC1A"), for: .normal)
            sunButton.titleLabel?.font = FontUtil.getFont(size: 16, type: .Medium)
            sunButton.imageView?.contentMode = .scaleAspectFit
            sunButton.setTitle(" \(achievement)", for: .normal)
            sunButton.backgroundColor = UIColor.hex(hex: "F8F8F8")
            sunBgView.addSubview(sunButton)
        }
    }
    
    //渐变色
    func gradientColor(gradientView : UIView , directionFromLeft:Int) {
        var from = 0.5
        var to = 1.0
        if directionFromLeft == 0 {
            from = 1.0
            to = 0.5
        }
        let colorOne = UIColor(red: 248.0 / 255.0, green: 248.0 / 255.0, blue: 248.0 / 255.0, alpha: CGFloat(from))
        let colorTwo = UIColor(red: 248.0 / 255.0, green: 248.0 / 255.0, blue: 248.0 / 255.0, alpha: CGFloat(to))
        let colors = [colorOne.cgColor, colorTwo.cgColor]
        let gradient = CAGradientLayer()
        //设置开始和结束位置(设置渐变的方向)
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        gradient.colors = colors
        gradient.frame = CGRect(x: 0, y: 0, width: 20, height: 40)
        gradientView.layer.insertSublayer(gradient, at: 0)
    }
    //MARK: 右侧已完成课程
    @objc func completedPractise() {

        let vc = self.slideMenuController()?.rightViewController as! CompletedLandVC
        
        vc.farmCourseList.removeAll()
        vc.orchardCourseList.removeAll()
        vc.gardenCourseList.removeAll()
        vc.fieldCourseList.removeAll()

        for course in self.farmCourseList {
            if (course?.ScenarioLessonInfo?.Score)! >= 60 && (course?.ScenarioLessonInfo?.Progress)! >= 1  {
                vc.farmCourseList.append(course)
            }
        }

        for course in self.orchardCourseList {
            if (course?.ScenarioLessonInfo?.Score)! >= 60 && (course?.ScenarioLessonInfo?.Progress)! >= 1  {
                vc.orchardCourseList.append(course)
            }
        }
        
        for course in self.gardenCourseList {
            if (course?.ScenarioLessonInfo?.Score)! >= 60 && (course?.ScenarioLessonInfo?.Progress)! >= 1 {
                vc.gardenCourseList.append(course)
            }
        }
        
        for course in self.fieldCourseList {
            if (course?.ScenarioLessonInfo?.Score)! >= 60 && (course?.ScenarioLessonInfo?.Progress)! >= 1 {
                vc.fieldCourseList.append(course)
            }
        }
//        farmSort()
//        orchardSort()
//        gardenSort()
//        fieldSort()
        vc.setupSlideBar()
        self.slideMenuController()?.openRight()
    }
    //farm排序
    func farmSort() {
        let vc = self.slideMenuController()?.rightViewController as! CompletedLandVC
        for i in (0..<vc.farmCourseList.count) {
            for j in (i..<vc.farmCourseList.count - 1) {
                let coursej1 = vc.farmCourseList[j]
                let coursej2 = vc.farmCourseList[j+1]
                let type1Array = coursej1?.ScenarioLessonInfo!.LessonIcons![0].split(separator: "_")
                let type2Array = coursej2?.ScenarioLessonInfo!.LessonIcons![0].split(separator: "_")
                if (type1Array?.count)! >= 2 && (type2Array?.count)! >= 2 {
                    if type1Array![1] > type2Array![1] {
                        let tmp = vc.farmCourseList[j+1]
                        vc.farmCourseList[j+1] = vc.farmCourseList[j]
                        vc.farmCourseList[j] = tmp
                    }
                }
            }
        }
        vc.reloadTableView()
    }
    
    //orchard
    func orchardSort() {
        let vc = self.slideMenuController()?.rightViewController as! CompletedLandVC
        
        for i in (0..<vc.orchardCourseList.count) {
            let course1 = vc.orchardCourseList[i]
            for j in (i..<vc.orchardCourseList.count - 1) {
                let course2 = vc.orchardCourseList[j]
                let type1Array = course1?.ScenarioLessonInfo!.LessonIcons![0].split(separator: "_")
                let type2Array = course2?.ScenarioLessonInfo!.LessonIcons![0].split(separator: "_")
                if (type1Array?.count)! >= 2 && (type2Array?.count)! >= 2 {
                    if type1Array![1] > type2Array![1] {
                        let tmp = vc.orchardCourseList[j]
                        vc.orchardCourseList[j] = vc.orchardCourseList[j + 1]
                        vc.orchardCourseList[j + 1] = tmp
                    }
                }
            }
        }
        vc.reloadTableView()
    }
    //garden
    func gardenSort() {
        let vc = self.slideMenuController()?.rightViewController as! CompletedLandVC
        
        for i in (0..<vc.gardenCourseList.count) {
            let course1 = vc.gardenCourseList[i]
            for j in (i..<vc.gardenCourseList.count - 1) {
                let course2 = vc.gardenCourseList[j]
                let type1Array = course1?.ScenarioLessonInfo!.LessonIcons![0].split(separator: "_")
                let type2Array = course2?.ScenarioLessonInfo!.LessonIcons![0].split(separator: "_")
                if (type1Array?.count)! >= 2 && (type2Array?.count)! >= 2 {
                    if type1Array![1] > type2Array![1] {
                        let tmp = vc.gardenCourseList[j]
                        vc.gardenCourseList[j] = vc.gardenCourseList[j + 1]
                        vc.gardenCourseList[j + 1] = tmp
                    }
                }
            }
        }
        vc.reloadTableView()
    }
    //field
    func fieldSort() {
        let vc = self.slideMenuController()?.rightViewController as! CompletedLandVC
        for i in (0..<vc.fieldCourseList.count) {
            let course1 = vc.fieldCourseList[i]
            for j in (i..<vc.fieldCourseList.count - 1) {
                let course2 = vc.fieldCourseList[j]
                let type1Array = course1?.ScenarioLessonInfo!.LessonIcons![0].split(separator: "_")
                let type2Array = course2?.ScenarioLessonInfo!.LessonIcons![0].split(separator: "_")
                if (type1Array?.count)! >= 2 && (type2Array?.count)! >= 2 {
                    if type1Array![1] > type2Array![1] {
                        let tmp = vc.fieldCourseList[j]
                        vc.fieldCourseList[j] = vc.fieldCourseList[j + 1]
                        vc.fieldCourseList[j + 1] = tmp
                    }
                }
            }
        }
        vc.reloadTableView() 
    }
    //退出土地
    @objc func closeTapped() {
        self.dismiss(animated: false) {
            
        }
    }
    //通知学以致用完成情况
    func finishPratise(_ score: Int) {
        var course: ScenarioSubLessonInfo?
        if let num = courseNum?.section {
            if courseNum?.section == 1 {
                course = self.farmCourseList[(courseNum?.row)!]
            }
            else if courseNum?.section == 3 {
                course = self.orchardCourseList[(courseNum?.row)!]
            }
            else if courseNum?.section == 5 {
                course = self.gardenCourseList[(courseNum?.row)!]
            }
            else if courseNum?.section == 7 {
                course = self.fieldCourseList[(courseNum?.row)!]
            }
        }else {
            course = self.farmCourseList.first as! ScenarioSubLessonInfo
        }
        loadData()
        var heightScore = course?.ScenarioLessonInfo?.Score
        course?.ScenarioLessonInfo?.Score = score
        var fruit = "farm_1"
        if (course?.ScenarioLessonInfo?.Tags?.count)! > 0 {
            fruit = "farm_1"
        }
        if (course?.ScenarioLessonInfo?.LessonIcons?.count)! > 0 {
            fruit = (course?.ScenarioLessonInfo?.LessonIcons?[0])!
        }
        
        //之前成功了,不需要弹出提示,也不用加成就值
        if !self.refreshLand {
        }else {
            //先弹窗，弹窗消失的回调中，更新土地状态
            if score >= 60 {
                UserDefaults.standard.synchronize()
                if (circleView != nil) {
                    circleView?.removeFromSuperview()
                    circleView = nil
                }
                circleView = Bundle.main.loadNibNamed("AnimationView", owner: nil, options: nil)?[0] as! AnimationView
                circleView?.frame = CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height)
                circleView?.startAnimation(score: score, oldImage: self.oldImage!, newImage: fruit, success: true,lostSunValue: self.sunValueCost.sunValue) {
                    self.recieveNotiOne = 0
                    DispatchQueue.main.async(execute: {
                        self.sunButton.setTitle(" \(self.achievement)", for: .normal)
                    })
                    self.collectionView.reloadData()
                    self.circleView?.hide()
                    if (self.courseNum != nil) {
                        var cell = self.collectionView.cellForItem(at: self.courseNum!) as? CollectionViewCell
                        if (cell != nil) {
                          cell!.Landbutton.swing(nil)
                        }else {
                            self.collectionView.layoutIfNeeded()
                            cell = self.collectionView.cellForItem(at: self.courseNum!) as? CollectionViewCell
                            if (cell != nil) {
                                cell!.Landbutton.swing(nil)
                            }
                        }
                    }
                }
                UIApplication.shared.keyWindow?.addSubview(circleView!)
                
            }else {
                //失败了，减少阳光值
                if circleView != nil {
                    circleView?.removeFromSuperview()
                    circleView = nil
                }
                circleView = Bundle.main.loadNibNamed("AnimationView", owner: nil, options: nil)?[0] as! AnimationView
                circleView?.frame = CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height)
                circleView?.startAnimation(score: score, oldImage: self.oldImage!, newImage: "drooping_success",success:false,lostSunValue:self.sunValueCost.sunValue){
                    DispatchQueue.main.async(execute: {
                        self.recieveNotiOne = 0
                        self.sunButton.setTitle(" \(self.achievement)", for: .normal)
                    })
                    self.collectionView.reloadData()

                    self.circleView?.hide()
                }
                UIApplication.shared.keyWindow?.addSubview(circleView!)

            }
        }
        
    }
    
    
    func createUI(){
        
        let layout = UICollectionViewFlowLayout()
        
        layout.itemSize = CGSize(width :(self.view.frame.size.width - clearance)/collectCellNum , height:(self.view.frame.size.width - clearance)/collectCellNum * 1.1)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.headerReferenceSize = CGSize(width: ScreenUtils.width, height: 1)
        let tableHeight = ScreenUtils.height - self.ch_getStatusNavigationHeight() - 40
        collectionView = UICollectionView(frame:CGRect(x:clearance/2 ,y:40,width:self.view.frame.size.width - clearance,height:tableHeight),collectionViewLayout:layout)
        self.view .addSubview(collectionView)
        collectionView.backgroundColor = UIColor.white
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        collectionView.register(CollectionHeaderViewCell.self, forCellWithReuseIdentifier: "CollectionHeaderViewCell")
        collectionView.register(HeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderReusableView")
        
        collectionView.delegate=self;
        collectionView.dataSource=self;
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
    }
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section % 2 == 0 || indexPath.section == 0 {//栅栏分割
            if indexPath.section == 0 {
                return CGSize(width: (self.view.frame.size.width - clearance), height: 10)
            }
            return CGSize(width: (self.view.frame.size.width - clearance), height: 40)
        }
        return CGSize(width: (self.view.frame.size.width - clearance)/collectCellNum, height: (self.view.frame.size.width - clearance)/collectCellNum * 1.1)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section % 2 == 0  || section == 0 {//栅栏分割
            return 1
        }
        if section == 1 {
           return self.farmCourseList.count
        }else if section == 3 {
            return self.orchardCourseList.count
        }else if section == 5 {
            return self.gardenCourseList.count
        }else if section == 7 {
            return self.fieldCourseList.count
        }
        return 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if !_isScrollDown && (collectionView.isDragging || collectionView.isDecelerating) {
            selectRowAtIndexPath(index: indexPath.section)
        }
    }
    func selectRowAtIndexPath(index: NSInteger) {
        _selectIndex = index
        if _isScrollDown {
            //往上拖
            
            let itemNum = (_selectIndex - 1)/2
            headerView.selectItem(at: itemNum)
        }else {
            //往下拉
            if _selectIndex == 2 {//0
                headerView.selectItem(at: 0)
            }
            else if _selectIndex == 3 {//1
                headerView.selectItem(at: 1)
            }else if _selectIndex == 4 {//1
                headerView.selectItem(at: 1)
            }
            else if _selectIndex == 5 {//2
                headerView.selectItem(at: 2)
            }
            else if _selectIndex == 6 {//2
                headerView.selectItem(at: 2)
            }
            else if _selectIndex == 7 {//3
                headerView.selectItem(at: 3)
            }
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.collectionView == scrollView) {
            _isScrollDown = lastOffsetY < scrollView.contentOffset.y
            lastOffsetY = scrollView.contentOffset.y
        }
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        
        if _isScrollDown && (collectionView.isDragging || collectionView.isDecelerating) {
            selectRowAtIndexPath(index: indexPath.section + 1)
        }
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderReusableView", for: indexPath) as! HeaderReusableView
            return header
        }
        let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderReusableView", for: indexPath) as! HeaderReusableView
        return reusableView
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section % 2 == 0 {//栅栏分割
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionHeaderViewCell", for: indexPath) as!CollectionHeaderViewCell
            if indexPath.section == 0 {
                cell.fenceImage.frame = CGRect(x: 0, y: 0, width: cell.bounds.width, height:  10)
                cell.fenceImage.image = UIImage(named: "")
            }else {
                
                cell.fenceImage.frame = CGRect(x: 4, y: 0, width: cell.bounds.width - 8, height:  40)
                cell.fenceImage.image = UIImage(named: "fence")

            }
            return cell
        }
        
        var status : Int = -1
        //胡萝卜carrot,番茄tomato,豌豆beans,洋葱onion,西蓝花broccoli
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as!CollectionViewCell
        if !UserManager.shared.isLoggedIn() || !AppData.userAssessmentEnabled {
            //没登录 \ 没开启权限
            cell.setData(course: nil, status: -1)
            return cell
        }

        var course : ScenarioSubLessonInfo?
        
        switch indexPath.section {
        case 1:
            course = self.farmCourseList[indexPath.row]
            break
        case 3:
            course = self.orchardCourseList[indexPath.row]
            break
        case 5:
            course = self.gardenCourseList[indexPath.row]
            break
        case 7:
            course = self.fieldCourseList[indexPath.row]
            break
        default:
            break
        }

        if course?.ScenarioLessonInfo?.Name != "" && course?.ScenarioLessonInfo?.Name != nil {
            //有数据
            var landImage: UIImage!
            //1.未解锁
            if course?.ScenarioLessonInfo?.Progress == -1 {
                cell.setData(course: nil, status: -1)
                return cell
            }
            //2.已解锁
            else if (course?.ScenarioLessonInfo?.Progress)! < 1 {
                //未做过
                cell.setData(course: nil, status: 0)
            }else {
                //已解锁，做过，没及格
                if (course?.ScenarioLessonInfo?.Score)! < 60 {
                    cell.setData(course: nil, status: 1)
                }else {
                    //3.及格了
                    cell.setData(course: course, status: 2)
                }
            }
            if firstIn {
                for indexP in self.unlockIndexPath {
                    if indexP.row == indexPath.row && indexP.section == indexPath.section {
                        firstIn = false
                        cell.Landbutton.isHidden = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            cell.Landbutton.isHidden = false
                            cell.Landbutton.swing(nil)
                        }
                        break
                    }
                }
            }
        
            
        }else{
            //没数据
            cell.setData(course: nil, status: -1)
        }

        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.sunValueCost.sunValue = indexPath.section / 2 * 10 + 30
        if indexPath.section != 1 && indexPath.section != 3 && indexPath.section != 5 && indexPath.section != 7 {
           return
        }
        //没登录
        if !UserManager.shared.isLoggedIn() {
            UIApplication.topViewController()?.presentUserToast(message: "You must log in first.")
            return
        }
        
        //没开启权限
        if !AppData.userAssessmentEnabled {
            UIApplication.topViewController()?.presentUserToast(message: "Not yet available.\n Learn new lessons to unlock this conversation. ")
            return
        }
        
        var course : ScenarioSubLessonInfo?
        switch indexPath.section {
        case 1:
            course = self.farmCourseList[indexPath.row]
            break
        case 3:
            course = self.orchardCourseList[indexPath.row]
            break
        case 5:
            course = self.gardenCourseList[indexPath.row]
            break
        case 7:
            course = self.fieldCourseList[indexPath.row]
            break
        default:
            return
        }
        if course?.ScenarioLessonInfo?.Name != "" && course?.ScenarioLessonInfo?.Name != nil {
            courseNum = indexPath
            let vc = PractiseIntroViewController()
            vc.TurnType = 0
            vc.courseId = course!.ScenarioLessonInfo!.Id!
            //有数据
            //1.未解锁
            if course?.ScenarioLessonInfo?.Progress == -1 {
                UIApplication.topViewController()?.presentUserToast(message: "Not yet available.\n Learn new lessons to unlock this conversation. ")
                return
            }
                //2.已解锁
            else if (course?.ScenarioLessonInfo?.Progress)! < 1 {
                //做过，但没完成或者没做过，种子
                self.oldImage = UIImage(named: "seed_success")
                vc.score =  -1
                self.refreshLand = true
                //阳光值低于30
                self.coinLower()
            }else {
                //已解锁，做过，没及格，发芽
                if (course?.ScenarioLessonInfo?.Score)! < 60 {
                    self.oldImage = UIImage(named: "sprout")
                    vc.score =  (course!.ScenarioLessonInfo?.Score)!
                    self.refreshLand = true
                    //阳光值低于30
                    self.coinLower()
                }else {
                    //3.及格了
                    vc.score =  (course!.ScenarioLessonInfo?.Score)!
                    self.refreshLand = false
                }
            }

            vc.refreshLand = self.refreshLand
            vc.finishPratise = { score in
                //做完学以致用
                if self.refreshLand {
                    if score >= 60 {
                        self.achievement += SunValueManager.shared().sunValue * 2
                    }else {
                        self.achievement -= SunValueManager.shared().sunValue
                    }
                    self.sunButton.setTitle(" \(self.achievement)", for: .normal)
                    self.sunButton.frame = CGRect(x: 20, y: 0, width:self.getLabelWidth(score: "\(self.achievement)"), height: 40)
                    self.finishPratise(score)
                }
            }
            let nav = UINavigationController(rootViewController: vc)
            nav.hidesBottomBarWhenPushed = true
            nav.modalTransitionStyle = .crossDissolve
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
            return
        }else{
            //没数据
            UIApplication.topViewController()?.presentUserToast(message: "Not yet available.\n Learn new lessons to unlock this conversation. ")
            return
        }
    }
    
    func coinLower() {
        //阳光值低于30
        if self.achievement < self.sunValueCost.sunValue {
            LCAlertView_Land.show(title: "Not Enough Points", message: "Total \(SunValueManager.shared().sunValue) points required for the challenge. Learning or reviewing lessons will help you earn points.", leftTitle: "OK", rightTitle: "OK", style: .oneButton, leftAction: {
                //OK
                LCAlertView_Land.hide()
            }, rightAction: {
                LCAlertView_Land.hide()
            }, disapperAction: {
                LCAlertView_Land.hide()
            })
            return
        }
    }
    
    func getLabelWidth(score: String = "") -> Int {
        let maxSize:CGSize = CGSize(width:self.view.bounds.width,height:.greatestFiniteMagnitude)
        let width = Double(("\(score)" as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(16), type: .Medium)]), context: nil).width) + 30
        return Int(width)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
