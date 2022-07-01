//
//  LearnSpeakSummary.swift
//  PracticeChinese
//
//  Created by Temp on 2018/10/8.
//  Copyright © 2018年 msra. All rights reserved.
//

import UIKit

class LearnSpeakSummary: UIViewController,UITableViewDelegate,UITableViewDataSource {
    //未完成
    var unCompletedLesson = [ScenarioLessonLearningItem]()
    //已完成
    var completedLesson = [ScenarioLessonLearningItem]()
    
    var courseId: String = "L2-1-1-1-s-CN"
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //加载学习状态
        loadData()
    }
    //加载数据
    func loadData() {
        CourseManager.shared.listScenarioLesson(id: courseId) { (result) in
//            CWLog(result)
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
       return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LearningSummaryCell.identifier) as! LearningSummaryCell
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            if self.unCompletedLesson.count > 0 {
                return 60
            }
            return 0.01
        }else {
            if self.completedLesson.count > 0 {
                return 60
            }
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()

    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = Bundle.main.loadNibNamed("PractiseHeaderView", owner: self, options: nil)?.first as! PractiseHeaderView
        header.frame = CGRect(x: 0, y: 0, width: ScreenUtils.width, height: 60)
        if section == 0 {
             header.headerTitle.text = "Your progress round"
            return header
        }else {
             header.headerTitle.text = "Items you have done"
        }
        return header
    }
    
    func getLabelheight(labelStr:String,font:UIFont)->CGFloat{
        let labelWidth = ScreenUtils.width - 111
        let maxSie:CGSize = CGSize(width:labelWidth,height:200)
        return (labelStr as String).boundingRect(with: maxSie, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):font]), context: nil).size.height
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
