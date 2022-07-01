//
//  LearnedLessonsViewController.swift
//  PracticeChinese
//
//  Created by ThomasXu on 07/07/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class LearnedLessonsViewController: UIViewController {
    
    var lessonTable: UITableView!
    var practiseTable: UITableView!
    var backViewLearn: UIView!
    var backViewPractise: UIView!
    var LearnButton = UIButton()
    var PractiseButton = UIButton()
    var line = UIView()
    var scrollView = UIScrollView()
    var courseStatusDictionary : [String : [String:Any]]?
    var learnItemArray = [ScenarioLessonLearningItem]()
    
    var finishedLessons = [(ScenarioSubLessonInfo, Int)]()//已完成 lesson 列表，元素类型：（course，lesson在course中的下标, 得分）
    var finishedPractiseLessons = [(ScenarioSubLessonInfo, Int)]()//已完成 lesson 列表，元素类型：（course，lesson在course中的下标, 得分）
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)//加上这一句消除tableview头部的空白
        self.view.backgroundColor = UIColor.groupTableViewBackground
        
        self.finishedLessons = CourseManager.shared.getFinishedLessonList()
        
        self.finishedPractiseLessons = CourseManager.shared.getFinishedPractiseLesson()
        if(AppData.userAssessmentEnabled){
            setUpview()
        }else{
            LCAlertView.show(title: String.PrivacyTitle, message: String.PrivacyConsent, leftTitle: "Don't Allow", rightTitle: "Allow", style: .center, leftAction: {
                LCAlertView.hide()
            }, rightAction: {
                LCAlertView.hide()
                AppData.setUserAssessment(true)
            })
        }
        let backButton = UIButton(frame: CGRect(x: 20, y: 0, width: 30, height: 40))
        backButton.setImage(ChImageAssets.left_BackArrow.image, for: .normal)
        backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
        backButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView:backButton)]
    }
    @objc func closeTapped() {
        self.navigationController?.navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary(self.ch_getTitleAttribute(textColor: UIColor.white))// temp
        self.navigationController?.navigationBar.barTintColor = UIColor.blueTheme
        self.navigationController?.popViewController(animated: true)
    }
    func setUpview(){
        self.setSubviews()
        backViewLearn = setUpEmptyView(num: 0.0)
        backViewPractise = setUpEmptyView(num: 1.0)
        scrollView.addSubview(backViewLearn)
        scrollView.addSubview(backViewPractise)
        if(finishedLessons.count == 0){
            backViewLearn.isHidden = false
        }else{
            backViewLearn.isHidden = true
        }
        if(finishedPractiseLessons.count == 0){
            backViewPractise.isHidden = false
        }else{
            backViewPractise.isHidden = true
        }
    }
    
    func setUpEmptyView(num: CGFloat)->UIView{
        let backView = UIView(frame: CGRect(x:num * ScreenUtils.width, y:0, width: ScreenUtils.width, height: ScreenUtils.height - self.ch_getStatusNavigationHeight() - 40))
        backView.backgroundColor = UIColor.groupTableViewBackground
        let owl = UIImageView(frame: CGRect(x: lessonTable.frame.width*3/8, y: lessonTable.frame.height*1/3, width: lessonTable.frame.width/4, height: lessonTable.frame.width/4))
        owl.image = UIImage(named: "owl")
        backView.addSubview(owl)
        let titleFont = FontUtil.getFont(size: 18, type: .Regular)
        let titleLabel = UILabel(frame: CGRect(x: 0, y: owl.frame.maxY + 10, width: lessonTable.frame.width, height: titleFont.lineHeight))
        titleLabel.text = "No Lessons Completed"
        titleLabel.textColor = UIColor.hex(hex: "666666")
        titleLabel.textAlignment = .center
        titleLabel.font = titleFont
        let wordFont = FontUtil.getFont(size: 14, type: .Regular)
        let wordLabel = UILabel(frame: CGRect(x: 0, y: titleLabel.frame.maxY , width: lessonTable.frame.width, height: wordFont.lineHeight))
        wordLabel.text = "Lessons you completed will appear here."
        wordLabel.textColor = UIColor.hex(hex: "BBBDBF")
        wordLabel.textAlignment = .center
        wordLabel.font = wordFont
        backView.addSubview(wordLabel)
        backView.addSubview(titleLabel)
        return backView
    }
    
    
    func setSubviews() {
        let tableHeight = ScreenUtils.height - self.ch_getStatusNavigationHeight() - 40
        //背景
        self.scrollView = UIScrollView(frame: CGRect(x:0, y: 40, width: ScreenUtils.width, height: tableHeight))
        self.scrollView.delegate = self
        self.scrollView.backgroundColor = UIColor.groupTableViewBackground
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.contentSize = CGSize(width: ScreenUtils.width * 2, height: tableHeight)
        self.scrollView.bounces = true
        self.scrollView.isPagingEnabled = true
        self.view.addSubview(scrollView)
        
        
        let segView = UIView()
        segView.backgroundColor = UIColor.white
        segView.frame = CGRect(x: 0, y: 0, width: ScreenUtils.width, height: 40)
        line.frame = CGRect(x: ScreenUtils.width / 2 - (120 - 50)/2 - 50, y: 38, width: 50, height: 2)
        line.backgroundColor = UIColor.blueTheme
        segView.addSubview(line)
        
        LearnButton.frame = CGRect(x: ScreenUtils.width / 2 - 120, y: 0, width: 120, height: 38)
        LearnButton.setTitle("Lesson", for: .normal)
        LearnButton.titleLabel?.font = FontUtil.getFont(size: FontAdjust().FontSize(16), type: .Regular)
        LearnButton.setTitleColor(UIColor.colorFromRGB(117/255.0, 121/255.0, 129/255.0, 0.4), for: .normal)
        LearnButton.setTitleColor(UIColor.textBlack333, for: .selected)
        LearnButton.tag = 0
        LearnButton.isSelected = true
        LearnButton.addTarget(self, action: #selector(changeTableView(_: )), for: .touchUpInside)
        segView.addSubview(LearnButton)
        
        PractiseButton.frame = CGRect(x: ScreenUtils.width / 2, y: 0, width: 120, height: 38)
        PractiseButton.setTitle("Conversation", for: .normal)
        PractiseButton.titleLabel?.font = FontUtil.getFont(size: FontAdjust().FontSize(16), type: .Regular)
        PractiseButton.setTitleColor(UIColor.colorFromRGB(117/255.0, 121/255.0, 129/255.0, 0.4), for: .normal)
        PractiseButton.tag = 1
        PractiseButton.isSelected = false
        PractiseButton.addTarget(self, action: #selector(changeTableView(_: )), for: .touchUpInside)
        PractiseButton.setTitleColor(UIColor.textBlack333, for: .selected)
        
        segView.addSubview(PractiseButton)
        self.view.addSubview(segView)
        
        self.lessonTable = UITableView(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: tableHeight), style: .grouped)
        self.lessonTable.showsVerticalScrollIndicator = false
        self.lessonTable.register(CompletedLessonCell.nibObject, forCellReuseIdentifier:
            CompletedLessonCell.identifier)
        self.lessonTable.delegate = self
        self.lessonTable.dataSource = self
        self.lessonTable.sectionHeaderHeight = 10
        self.lessonTable.separatorStyle = .none
        self.scrollView.addSubview(self.lessonTable)
        
        self.practiseTable = UITableView(frame: CGRect(x: ScreenUtils.width, y: 0, width: ScreenUtils.width, height: tableHeight), style: .grouped)
        self.practiseTable.showsVerticalScrollIndicator = false
        self.practiseTable.register(CompeletedPractiseCell.nibObject, forCellReuseIdentifier: CompeletedPractiseCell.identifier)
        self.practiseTable.delegate = self
        self.practiseTable.dataSource = self
        self.practiseTable.sectionHeaderHeight = 10
        self.practiseTable.separatorStyle = .none
        self.scrollView.addSubview(self.practiseTable)
        
        
    }
    @objc func changeTableView(_ sender: UIButton) {
        if sender.tag == 0 {
            LearnButton.isSelected = true
            PractiseButton.isSelected = false
            line.frame = CGRect(x: ScreenUtils.width / 2 - (120 - 50)/2 - 50, y: 38, width: 50, height: 2)
            self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
        }else {
            PractiseButton.isSelected = true
            LearnButton.isSelected = false
            line.frame = CGRect(x: ScreenUtils.width / 2 + (120 - 60)/2, y: 38, width: 60, height: 2)
            self.scrollView.contentOffset = CGPoint(x: ScreenUtils.width, y: 0)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "My Work"
        self.navigationController?.navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary(self.ch_getTitleAttribute(textColor: UIColor.textBlack333))// temp
        //设置回退按钮为白色
        self.navigationController?.navigationBar.tintColor = UIColor.textBlack333
        //隐藏底部 tab 栏
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.fromColor(color: UIColor.white), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
    }
    override var hidesBottomBarWhenPushed: Bool {
        get { return true }
        set { super.hidesBottomBarWhenPushed = newValue }
    }
}


extension LearnedLessonsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.lessonTable {
            return self.finishedLessons.count
        }else {
            return self.finishedPractiseLessons.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.lessonTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: CompletedLessonCell.identifier) as! CompletedLessonCell
            cell.selectionStyle = .none
            let (course, score) = self.finishedLessons[indexPath.row]
            cell.lessonTitle.text = course.ScenarioLessonInfo!.Name!
            cell.subTitle.text = course.ScenarioLessonInfo?.NativeName
//            cell.scoreLabel.text = "\(CourseManager.shared.getCourseScore((course.ScenarioLessonInfo?.Id)!))"
            cell.scoreLabel.text = ""
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CompeletedPractiseCell.identifier) as! CompeletedPractiseCell
            cell.selectionStyle = .none
            let (course, score) = self.finishedPractiseLessons[indexPath.row]
            cell.lessonTitle.text = course.ScenarioLessonInfo!.NativeName!
            if let level = course.ScenarioLessonInfo!.DifficultyLevel {
                let diffLevel = level > 0 ? level : 1
                cell.HSK.setTitle("HSK\(diffLevel)", for: .normal)
            }else {
                cell.HSK.setTitle("HSK1", for: .normal)
            }
            cell.scoreLabel.text = "\(CourseManager.shared.getCourseScore((course.ScenarioLessonInfo?.Id)!))"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.practiseTable {
            let (course, score) = self.finishedPractiseLessons[indexPath.row]
            let vc = PractiseLandDetailVC.init(nibName: "PractiseLandDetailVC", bundle: Bundle.main)
            vc.courseId = (course.ScenarioLessonInfo?.Id)!
            vc.refreshLand = false
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            let (course, score) = self.finishedLessons[indexPath.row]
//            BeginnerLessonsManager.shared.getCourse(id: (course.SubLessons![1].ScenarioLessonInfo?.Id)!, completion: {
//                (data,error) in
//                self.learnItemArray = BeginnerLessonsManager.shared.learningCard
//                let detailVC = LearnDetailViewController()
//                detailVC.learnItemArray = self.learnItemArray
//                self.navigationController?.pushViewController(detailVC, animated: true)
//
//            })
            for lesson in course.SubLessons! {
                if lesson.ScenarioLessonInfo?.LessonType == .PracticeLesson {
                    let cardVC = LearnCardFlowViewController()
                    cardVC.courseId  = (lesson.ScenarioLessonInfo?.Id)!
                    cardVC.learnDetail = true
                    cardVC.titleString = course.ScenarioLessonInfo!.NativeName!
                    cardVC.finishLearning = { (coinValue,completed) in
                        //首先展示阳光值鼓励图，鼓励图消失后，查询是否有新解锁的土地
                        LCAlertView_Land.show(title: "", message: "\(coinValue)", leftTitle: "", rightTitle: "", style: .image, leftAction: {
                            //OK
                            LCAlertView_Land.hide()
                        }, rightAction: {
                            LCAlertView_Land.hide()
                        }, disapperAction: {
                            LCAlertView_Land.hide()
                        })
                    }
                    let nav = UINavigationWithoutStatusController(rootViewController: cardVC)
                    nav.hidesBottomBarWhenPushed = true
                    nav.modalTransitionStyle = .crossDissolve
                    nav.modalPresentationStyle = .fullScreen
                    self.present(nav, animated: true, completion: {
                        
                    })
                }
            }
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.scrollView.contentOffset.x == 0 {
            line.frame = CGRect(x: ScreenUtils.width / 2 - (120 - 50)/2 - 50, y: 38, width: 50, height: 2)
            LearnButton.isSelected = true
            PractiseButton.isSelected = false
        }
        if self.scrollView.contentOffset.x == ScreenUtils.width {
            line.frame = CGRect(x: ScreenUtils.width / 2 + (120 - 60)/2, y: 38, width: 60, height: 2)
            PractiseButton.isSelected = true
            LearnButton.isSelected = false
        }
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
