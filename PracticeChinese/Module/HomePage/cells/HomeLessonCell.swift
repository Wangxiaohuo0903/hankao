//
//  HomeLessonCell.swift
//  Collection
//
//  Created by Temp on 2019/3/28.
//  Copyright © 2019 Person. All rights reserved.
//

import UIKit
protocol CourseClickDelegate {
    func courseClick(course:ScenarioSubLessonInfo?)
    func chanllengeCourseClick(course:ScenarioSubLessonInfo?)
}
// Lesson Cell
class HomeLessonCell: UITableViewCell {
    //每一cell内的LearnProgressViewvar
    var progressViewArray = [LearnProgressView]()
    var courseArray = [ScenarioSubLessonInfo?]()
    var lockStatus = true
    let topMargin = 180
    
    let circleHeight:Int = 150
    let conversationHeight:Int = 80
    let pathImageView = UIImageView()
    var delegate : CourseClickDelegate?
    var index = IndexPath()

    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?,coursesArray:[ScenarioSubLessonInfo],indexPath:IndexPath) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(pathImageView)
        self.courseArray = coursesArray
        self.index = indexPath
        self.makeCellUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeCellUI() {

        self.pathImageView.frame = CGRect(x: 0, y: 0, width: Int(ScreenUtils.width), height: self.courseArray.count/2 * topMargin + 40)
        self.pathImageView.isHidden = true
        for progressView in self.progressViewArray {
            progressView.removeFromSuperview()
        }
        let progressViewWidth = Int((ScreenUtils.width - 60) / 2)
        let progressViewHeight = 180
        for (i,course) in self.courseArray.enumerated() {
            var progressViewframe = CGRect(x: Int((ScreenUtils.width) / 2) - progressViewWidth/2, y: i/2 * topMargin, width: progressViewWidth, height: progressViewHeight )
            if (course?.SubLessons![0].ScenarioLessonInfo!.Tags!.contains("ChallengeLesson"))! {
                if self.courseArray.count % 2 == 0{
                    //lesson是奇数个
                    progressViewframe = CGRect(x: Int(ScreenUtils.width / 2) - progressViewWidth / 2, y: (self.courseArray.count)/2 * topMargin - 20, width: progressViewWidth, height: 80)
                }else {
                    progressViewframe = CGRect(x: Int(ScreenUtils.width / 2) - progressViewWidth / 2, y: (self.courseArray.count - 1)/2 * topMargin, width: progressViewWidth, height: 80)
                }
            }else {
                self.pathImageView.isHidden = false
                if Bool(course?.ScenarioLessonInfo?.isFinished ?? true) {
                    //注意改回来
                    if self.index.row == 0 {
                        self.pathImageView.image = UIImage(named: "blue_4_top")
                    }else {
                        self.pathImageView.image = UIImage(named: "gray_\(self.courseArray.count - 1)")
                    }
                }else {
                    if self.index.row == 0 {
                        self.pathImageView.image = UIImage(named: "blue_4_top")
                    }else {
                        self.pathImageView.image = UIImage(named: "blue_\(self.courseArray.count - 1)")
                    }
                }
                progressViewframe = CGRect(x: Int(ScreenUtils.width / 2) - progressViewWidth, y: i/2 * topMargin, width: progressViewWidth, height: progressViewHeight )
                if i % 2 == 1 {
                    progressViewframe = CGRect(x: Int(ScreenUtils.width / 2) , y: i/2 * topMargin + 40, width: progressViewWidth, height: progressViewHeight)
                }
            }
            let progressView = LearnProgressView(frame: progressViewframe, course: course)
            progressView.index = i
            progressView.refreshStatus(lockStatus: Bool(course?.ScenarioLessonInfo?.isFinished ?? true))
            progressView.courseClick = { (courseData,index) in
                //点击课程
                if (courseData.SubLessons![0].ScenarioLessonInfo!.Tags!.contains("ChallengeLesson")) {
                    if courseData.ScenarioLessonInfo?.isFinished == true {
                        self.delegate?.chanllengeCourseClick(course: courseData)
                    }
                }else {
                    //注意改回来
                    if courseData.ScenarioLessonInfo?.isFinished == false {
                        self.delegate?.courseClick(course: courseData)
                    }
                }
            }
            self.contentView.addSubview(progressView)
            self.progressViewArray.append(progressView)
        }

    }
    
    func refresh() {
        for progressView in self.progressViewArray {
            progressView.refreshStatus(lockStatus: self.lockStatus)
        }
    }
    func updateCourseList(courses:[ScenarioSubLessonInfo?]) {
        if self.courseArray.count != courses.count {
            self.courseArray = courses
            for progressView in self.progressViewArray {
                progressView.removeFromSuperview()
            }
            makeCellUI()
        }else {
            self.courseArray = courses
            refresh()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.makeCellUI()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}

//Chanllenge Cell
class HomeChanllengeCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
}

