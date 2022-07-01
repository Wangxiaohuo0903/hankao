//
//  CompletedLandVC.swift
//  PracticeChinese
//
//  Created by Temp on 2018/10/10.
//  Copyright © 2018年 msra. All rights reserved.
//

import UIKit

class CompletedLandVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var headerView: FDSlideBar!
    var titleBgView: UIView!
    var tableView: UITableView!
    var achievementsBtn = UIButton()
    let achievementsText = UILabel()
    var vector = UIImageView()
    let titleLabel = UILabel()
    var bgView = UIView()
    var _isScrollDown = true//滚动方向
    var _selectIndex = 0//记录位置
    var lastOffsetY: CGFloat = 0
    let nullLabel = UILabel()
    var itemsTitle = [String?]()
    var itemsCount = [Int]()
    var farmCourseList = [ScenarioSubLessonInfo?]() {
        didSet {
            reloadTableView() 
        }
    }
    
    var orchardCourseList = [ScenarioSubLessonInfo?]() {
        didSet {
            reloadTableView()
        }
    }
    
    var gardenCourseList = [ScenarioSubLessonInfo?]() {
        didSet {
            reloadTableView()
        }
    }
    
    var fieldCourseList = [ScenarioSubLessonInfo?]() {
        didSet {
            reloadTableView()
        }
    }
    
    func reloadTableView() {
        self.tableView.reloadData()
        if self.farmCourseList.count == 0 && self.orchardCourseList.count == 0 && self.gardenCourseList.count == 0 && self.fieldCourseList.count == 0 {
            nullLabel.isHidden = false
            tableView.isHidden = true
        }else {
            nullLabel.isHidden = true
            tableView.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.hex(hex: "f2f2f2")
        self.automaticallyAdjustsScrollViewInsets = true
        titleBgView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width / 4 * 3, height: self.ch_getStatusNavigationHeight()))
        titleBgView.backgroundColor = UIColor.white
        view.addSubview(titleBgView)
        
        titleLabel.frame = CGRect(x: 23, y: self.ch_getStatusBarHeight(), width: ScreenUtils.width / 4 * 3, height: self.ch_getNavigationBarHeight())
        titleLabel.text = "My Work"
        titleLabel.textAlignment = .left
        titleLabel.textColor = UIColor.textBlack333
        titleLabel.font = FontUtil.getFont(size: 16, type: .Bold)
        titleBgView.addSubview(titleLabel)
        
        tableView = UITableView(frame: CGRect(x: 0, y: self.ch_getStatusNavigationHeight() + 40, width: ScreenUtils.width / 4 * 3, height: ScreenUtils.height - 40 - 50 - self.ch_getStatusNavigationHeight()), style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.hex(hex: "f2f2f2")
        tableView.showsVerticalScrollIndicator = false
        tableView.register(CompletedLandCell.nibObject, forCellReuseIdentifier: CompletedLandCell.identifier)
        view.addSubview(tableView)

        achievementsBtn.backgroundColor = UIColor.white
        achievementsBtn.frame = CGRect(x: 0, y: ScreenUtils.height - 50, width: ScreenUtils.width / 4 * 3, height: 50)
        achievementsBtn.addTarget(self, action: #selector(toAchievements), for: .touchUpInside)
        view.addSubview(achievementsBtn)
        
        achievementsText.frame = CGRect(x: 23, y: ScreenUtils.height - 50, width: ScreenUtils.width / 4 * 3 - 50, height: 50)
        achievementsText.text = "Achievements"
        achievementsText.textAlignment = .left
        achievementsText.textColor = UIColor.textBlack333
        achievementsText.font = FontUtil.getFont(size: 16, type: .Bold)
        view.addSubview(achievementsText)
        
//        vector = UIImageView(image: UIImage(named: "Vector"))
//        vector.frame = CGRect(x: ScreenUtils.width / 4 * 3 - 30, y: ScreenUtils.height - 32.5, width: 10, height: 15)
//        view.addSubview(vector)
        
        bgView.backgroundColor = UIColor.hex(hex: "F8F8F8")
        bgView.frame = CGRect(x: 0, y: self.ch_getStatusNavigationHeight(), width: ScreenUtils.width, height: 40)
        view.addSubview(bgView)
        
        nullLabel.frame = CGRect(x: 0, y: 0, width: ScreenUtils.width / 4 * 3, height: ScreenUtils.height - self.ch_getStatusNavigationHeight())
        nullLabel.text = "Conversations you have done will appear here."
        nullLabel.font = FontUtil.getFont(size: 16, type: .Regular)
        nullLabel.textColor = UIColor.hex(hex: "C6C6C6")
        nullLabel.textAlignment = .center
        nullLabel.numberOfLines = 0
        view.addSubview(nullLabel)

        setupSlideBar()
    }
    
    func setupSlideBar() {
        itemsTitle.removeAll()
        itemsCount.removeAll()
        
        if farmCourseList.count > 0 {
            itemsTitle.append("Level 1")
            itemsCount.append(farmCourseList.count)
        }
        if orchardCourseList.count > 0 {
            itemsTitle.append("Level 2")
            itemsCount.append(orchardCourseList.count)
        }
        if gardenCourseList.count > 0 {
            itemsTitle.append("Level 3")
            itemsCount.append(gardenCourseList.count)
        }
        if fieldCourseList.count > 0 {
            itemsTitle.append("Level 4")
            itemsCount.append(fieldCourseList.count)
        }
        let sliderBar = FDSlideBar()
        sliderBar.frame = CGRect(x: 0, y: 0, width:Int(ScreenUtils.width / 4 * 3), height: 40)
        sliderBar.backgroundColor = UIColor.hex(hex: "F8F8F8")
        // Init the titles of all the item
        sliderBar.itemsTitle = itemsTitle
        // Set some style to the slideBar
        sliderBar.itemColor = UIColor.hex(hex: "C6C6C6")
        sliderBar.itemSelectedColor = UIColor.hex(hex: "83BB56")
        sliderBar.sliderColor = UIColor.hex(hex: "F8F8F8")
        sliderBar.slideBarItemSelectedCallback({ (idx,title) in
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: Int(idx)), at: .none, animated: true)
        })
        self.headerView = sliderBar
        bgView.addSubview(self.headerView)
        let leftView = UIView()
        gradientColor(gradientView: leftView,directionFromLeft:0)
        leftView.frame = CGRect(x: 0, y: 0, width: 20, height: 40)
        bgView.addSubview(leftView)
        
        let rightView = UIView()
        gradientColor(gradientView: rightView,directionFromLeft:1)
        rightView.frame = CGRect(x: Int(ScreenUtils.width / 4 * 3) - 20, y: 0, width: 20, height: 40)
        bgView.addSubview(rightView)
        
        if itemsTitle.count < 2 {
            bgView.isHidden = true
            tableView.frame = CGRect(x: 0, y: self.ch_getStatusNavigationHeight(), width: ScreenUtils.width / 4 * 3, height: ScreenUtils.height - self.ch_getStatusNavigationHeight() - 50)
        }else {
            bgView.isHidden = false
            tableView.frame = CGRect(x: 0, y: self.ch_getStatusNavigationHeight() + 40, width: ScreenUtils.width / 4 * 3, height: ScreenUtils.height - self.ch_getStatusNavigationHeight() - 40 - 50)
        }
        self.tableView.reloadData()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsCount[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CompletedLandCell.identifier) as! CompletedLandCell
        cell.selectionStyle = .none
        let title = itemsTitle[indexPath.section]
        var course: ScenarioSubLessonInfo?
        if title == "Level 1" {
            course = self.farmCourseList[indexPath.row]
        }else if title == "Level 2" {
            course = self.orchardCourseList[indexPath.row]
        }else if title == "Level 3" {
            course = self.gardenCourseList[indexPath.row]
        }else if title == "Level 4" {
            course = self.fieldCourseList[indexPath.row]
        }
        if let courseData = course {
            var urlString = "farm_1"
            if (courseData.ScenarioLessonInfo?.LessonIcons?.count)! > 0 {
                urlString = (courseData.ScenarioLessonInfo?.LessonIcons?[0]) ?? "farm_1"
            }
            if urlString.hasPrefix("http") {
                cell.leftImage.sd_setImage(with: URL(string: urlString), placeholderImage: UIImage(named: "farm_1"), options: .retryFailed) { (image, error, type, url) in
                    
                }
            }else {
                cell.leftImage.image = UIImage(named: urlString)
            }
            cell.lessonTitle.text = courseData.ScenarioLessonInfo?.NativeName
        }
        return cell

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ScreenUtils.heightByM(y: 60)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return itemsCount.count
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width / 4 * 3, height: 0.3))
        headerView.backgroundColor = UIColor.white
        let headerLine = UIView(frame: CGRect(x: 20, y: 0, width: ScreenUtils.width / 4 * 3 - 35, height: 0.3))
        headerLine.backgroundColor = UIColor.hex(hex: "E8E8E8")
        headerView.addSubview(headerLine)
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.5
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width / 4 * 3, height: 0.5))
        footerView.backgroundColor = UIColor.white
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.5
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if !_isScrollDown && (tableView.isDragging || tableView.isDecelerating) {
            selectRowAtIndexPath(index: section)
        }
    }
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        if _isScrollDown && (tableView.isDragging || tableView.isDecelerating) {
            selectRowAtIndexPath(index: section + 1)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = PractiseLandDetailVC.init(nibName: "PractiseLandDetailVC", bundle: Bundle.main)
        vc.refreshLand = false
        let title = itemsTitle[indexPath.section]
        var course: ScenarioSubLessonInfo?
        if title == "Level 1" {
            course = self.farmCourseList[indexPath.row]
        }else if title == "Level 2" {
            course = self.orchardCourseList[indexPath.row]
        }else if title == "Level 3" {
            course = self.gardenCourseList[indexPath.row]
        }else if title == "Level 4" {
            course = self.fieldCourseList[indexPath.row]
        }
        vc.courseId = (course?.ScenarioLessonInfo?.Id!)!
        let mc = self.slideMenuController()?.mainViewController as! UINavigationController
        mc.pushViewController(vc, animated: false)
        self.slideMenuController()?.closeRightWithVelocity(1000)
    }
    func selectRowAtIndexPath(index: NSInteger) {
        _selectIndex = index
        if _isScrollDown {
            //往上拖
            headerView.selectItem(at: (_selectIndex - 1))
        }else {
            //往下拉
            if _selectIndex != 0 {
                headerView.selectItem(at: (_selectIndex - 1))
            }
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.tableView == scrollView) {
            _isScrollDown = lastOffsetY < scrollView.contentOffset.y
            lastOffsetY = scrollView.contentOffset.y
        }
    }
    
    @objc func toAchievements() {
        let vc = AchievementVC()
        vc.farmCourseList = self.farmCourseList
        vc.orchardCourseList = self.orchardCourseList
        vc.gardenCourseList = self.gardenCourseList
        vc.fieldCourseList = self.fieldCourseList
        let mc = self.slideMenuController()?.mainViewController as! UINavigationController
        mc.pushViewController(vc, animated: false)
        self.slideMenuController()?.closeRightWithVelocity(1000)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//            let vc = AchievementVC()
//            vc.farmCourseList = self.farmCourseList
//            vc.orchardCourseList = self.orchardCourseList
//            vc.gardenCourseList = self.gardenCourseList
//            vc.fieldCourseList = self.fieldCourseList
//            let mc = self.slideMenuController()?.mainViewController as! UINavigationController
//            mc.pushViewController(vc, animated: true)
//        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
