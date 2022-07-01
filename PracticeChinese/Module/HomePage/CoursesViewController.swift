//
//  CourseViewController.swift
//  PracticeChinese
//
//  Created by ThomasXu on 19/06/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit
/*
class CoursesViewController: UIViewController {
    
    var courseTable: UITableView!
    var courses = [ListScenarioLessonsResult?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.groupTableViewBackground
        
        let tableWidth = ScreenUtils.widthByRate(x: 0.9)
        let tableX = (ScreenUtils.width - tableWidth) / 2
        let tableY: CGFloat = ScreenUtils.heightByRate(y: 0.05)
        let tableHeight = ScreenUtils.height - tableY
        
        courseTable = UITableView(frame: CGRect(x: tableX, y: tableY, width: tableWidth, height: tableHeight))
        courseTable.backgroundColor = UIColor.clear
        courseTable.dataSource = self
        courseTable.delegate = self
        courseTable.register(AllCourseTableCell.self, forCellReuseIdentifier: AllCourseTableCell.identifier)
        courseTable.rowHeight = 120//ScreenUtils.heightByRate(y: 0.2)
        courseTable.separatorStyle = .none
        courseTable.showsVerticalScrollIndicator = false
        self.view.addSubview(courseTable)
        
        
        //设置渐变色
        let layer = CAGradientLayer()
        layer.frame = self.view.bounds
        layer.colors = [UIColor.white.withAlphaComponent(1).cgColor, UIColor.white.withAlphaComponent(0).cgColor]
        layer.startPoint = CGPoint(x: 0, y: 0.0)
        layer.endPoint = CGPoint(x: 0, y: 1)
        self.view.layer.mask = layer//如果不把window的background color 设置为白色，梯度渐变会是黑色的

        NotificationCenter.default.addObserver(self, selector: #selector(showNetworkFailedRequestView), name: ChNotifications.NetworkFailedRequest.notification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshCurrentPage), name: ChNotifications.ReloadPageInfos.notification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshCurrentPage), name: ChNotifications.UpdateAllCourses.notification, object: nil)//当所有课程有更新时需要重新加载数据
        NotificationCenter.default.addObserver(self, selector: #selector(refreshCurrentPage), name: ChNotifications.UpdateCoursesAddedIntoPlan.notification, object: nil)//当有课程添加到plan中时，也需要更新数据
        self.refreshCurrentPage()
    }
    
    func showNetworkFailedRequestView() {
        AlertNetworkRequestFailedView.show(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height))
    }
    
    func refreshCurrentPage() {
        RequestManager.shared.reLoad = false
        self.courses = CourseManager.shared.allCourses
        self.courseTable.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = "All Courses"
        self.navigationController?.navigationBar.titleTextAttributes = self.ch_getTitleAttribute()
        //显示下边界
        self.tabBarController?.tabBar.isHidden = false
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.fromColor(color: UIColor.blueTheme), for: .default)
        //设置 新的界面的 回退 按钮不带有内容
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: ChNotifications.NetworkFailedRequest.notification, object: nil)
        NotificationCenter.default.removeObserver(self, name: ChNotifications.ReloadPageInfos.notification, object: nil)
    }
    
}

extension CoursesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let course = LessonsViewController()
        course.course = self.courses[indexPath.row]! //as! UserScenarioLessonAbstract
        course.lessons = CourseManager.shared.getCourseSubLessons(courseId: course.course.ScenarioLessonInfo!.Id!)
        course.isLessonAdded = CourseManager.shared.isCourseAddedIntoPlan(id: self.courses[indexPath.row]!.ScenarioLessonInfo!.Id!)
        self.ch_pushViewController(course, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AllCourseTableCell.identifier) as! AllCourseTableCell
        if let course = self.courses[indexPath.row] {
            cell.courseName.text = course.ScenarioLessonInfo?.Name
            cell.backgroundColor = UIColor.clear
            cell.courseNativeName.text = course.ScenarioLessonInfo?.NativeName
            cell.courseImageUrl = course.ScenarioLessonInfo?.ImageUrl
            if CourseManager.shared.isCourseAddedIntoPlan(id: course.ScenarioLessonInfo!.Id!) {
                cell.courseAddedToPlanMark.isHidden = false
            } else {
                cell.courseAddedToPlanMark.isHidden = true
            }
            var finished: Float = 0
            for lesson in course.SubLessons! {
                let scenario = lesson.ScenarioLessonInfo as! UserScenarioLessonAbstract
                if scenario.Progress! >= 0 {
                    finished += 1
                }
            }
        }
        cell.selectionStyle = .none
        return cell
    }
}

class AllCourseTableCell: UITableViewCell {
    var courseImage: UIImageView!
    var courseName: UILabel!
    var courseNativeName: UILabel!
    var courseImageUrl:String?
    var courseAddedToPlanMark: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func addSubviews() {
        courseImage = UIImageView(frame: CGRect.zero)
        //   courseImage.image = ChImageAssets.MeIcon2.image
        self.contentView.addSubview(courseImage)
        
        let nameFont = FontUtil.getFont(size: 14, type: .Bold)
        courseName = UILabel(frame: CGRect.zero)
        courseName.text = "住宿"
        courseName.textAlignment = .left
        courseName.font = nameFont
        self.contentView.addSubview(courseName)
        
        courseNativeName = UILabel(frame: CGRect.zero)
        courseNativeName.text = "Accommodation"
        courseNativeName.textAlignment = .left
        courseNativeName.font = nameFont
        self.contentView.addSubview(courseNativeName)
        
        courseAddedToPlanMark = UIImageView(frame: CGRect.zero)
        courseAddedToPlanMark.image = ChImageAssets.courseAdded.image
        self.contentView.addSubview(courseAddedToPlanMark)
        courseAddedToPlanMark.isHidden = false
        
    }
    
    func setSubviewFrame() {
        let contentWidth = self.contentView.frame.width
        let contentHeight = self.contentView.frame.height
        let imgX: CGFloat = 10
        let imgHeight = contentHeight * 0.9
        let imgY = (contentHeight - imgHeight) / 2
        courseImage.frame = CGRect(x: imgX, y: imgY, width: imgHeight, height: imgHeight)
        courseImage.layer.cornerRadius = imgHeight / 2
        courseImage.layer.masksToBounds = true
        courseImage.sd_setSVGImage(urlString: courseImageUrl)
        
        let centerSpace: CGFloat = 4
        let labelX = courseImage.frame.maxX + 20
        let labelHeight = courseName.font.lineHeight
        let nameY = contentHeight / 2 - centerSpace - labelHeight
        let labelWidth = contentWidth - labelX - 10
        courseName.frame = CGRect(x: labelX, y: nameY, width: labelWidth, height: labelHeight)
        
        let courseEnglishY = contentHeight / 2 + centerSpace
        courseNativeName.frame = CGRect(x: labelX, y: courseEnglishY, width: labelWidth, height: labelHeight)
        
        let markHeight = contentHeight * 0.5
        let markWidth = markHeight / 0.6
        let markX = contentWidth - markWidth
        courseAddedToPlanMark.frame = CGRect(x: markX, y: 0, width: markWidth, height: markHeight)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = UIEdgeInsetsInsetRect(contentView.frame, UIEdgeInsetsMake(0, 0, 20, 0))
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds  = true
        contentView.backgroundColor = UIColor.white
        self.setSubviewFrame()
    }
}*/
