//
//  AchievementVC.swift
//  PracticeChinese
//
//  Created by Temp on 2018/10/10.
//  Copyright © 2018年 msra. All rights reserved.
//

import UIKit

class AchievementVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    let nullLabel = UILabel()
    var tableView: UITableView!
    
    var farmAchievements = [Int]()
    var fieldAchievements = [Int]()
    var orchardAchievements = [Int]()
    var gardenAchievements = [Int]()
    
    var farmCourseList = [ScenarioSubLessonInfo?]()
    var orchardCourseList = [ScenarioSubLessonInfo?]()
    var gardenCourseList = [ScenarioSubLessonInfo?]()
    var fieldCourseList = [ScenarioSubLessonInfo?]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        self.navigationItem.title = "Achievements"
        self.navigationController?.navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary(self.ch_getTitleAttribute(textColor: UIColor.textBlack333))
        //设置回退按钮为白色
        self.navigationController?.navigationBar.tintColor = UIColor.textBlack333
        //隐藏底部 tab 栏
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.fromColor(color: UIColor.hex(hex: "F8F8F8")), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height - self.ch_getStatusNavigationHeight()), style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        tableView.showsVerticalScrollIndicator = false
        tableView.register(UserAchievementCell.nibObject, forCellReuseIdentifier: UserAchievementCell.identifier)
        view.addSubview(tableView)
        
        nullLabel.frame = CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height - self.ch_getStatusNavigationHeight())
        nullLabel.text = "What you have planted will appear here."
        nullLabel.font = FontUtil.getFont(size: 16, type: .Regular)
        nullLabel.textColor = UIColor.hex(hex: "C6C6C6")
        nullLabel.textAlignment = .center
        
        calculationOfAchievement(section: 0, array: farmCourseList)
        calculationOfAchievement(section: 1, array: orchardCourseList)
        calculationOfAchievement(section: 2, array: gardenCourseList)
        calculationOfAchievement(section: 3, array: fieldCourseList)
        
        reloadTableView()
        view.addSubview(nullLabel)
        
        let backButton = UIButton(frame: CGRect(x: 20, y: 0, width: 30, height: 40))
        backButton.setImage(ChImageAssets.left_BackArrow.image, for: .normal)
        backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
        backButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView:backButton)]
    }
    @objc func closeTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    func calculationOfAchievement(section:Int ,array:[ScenarioSubLessonInfo?]) {
        var carrot = 0
        var tomato = 0
        var beans = 0
        var onion = 0
        var broccoli = 0
        
        for course in array {
            if (course?.ScenarioLessonInfo!.LessonIcons?.count)! > 0 {
                let typeArray = course?.ScenarioLessonInfo!.LessonIcons![0].split(separator: "_")
                if typeArray![1] == "1" {
                    //胡萝卜carrot
                    carrot += 1
                }else if typeArray![1] == "2" {
                    //番茄tomato
                    tomato += 1
                }else if typeArray![1] == "3" {
                    //豌豆beans
                    beans += 1
                }else if typeArray![1] == "4" {
                    //洋葱onion
                    onion += 1
                }else if typeArray![1] == "5" {
                    //西蓝花broccoli
                    broccoli += 1
                }
            }
        }
        
        if section == 0 {
            farmAchievements = [carrot,tomato,beans,onion,broccoli]
        }else if section == 1 {
            orchardAchievements = [carrot,tomato,beans,onion,broccoli]
        }
        else if section == 2 {
            gardenAchievements = [carrot,tomato,beans,onion,broccoli]
        }
        else if section == 3 {
            fieldAchievements = [carrot,tomato,beans,onion,broccoli]
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            return 1
        default:
            return 0
        }
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 230
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titles = ["Vegetables","Fruits","Flowers","Grains"]
        let header = Bundle.main.loadNibNamed("AchievementHeader", owner: self, options: nil)?.first as! AchievementHeader
        header.headerTitle.text = titles[section]
        header.frame = CGRect(x: 0, y: 0, width: ScreenUtils.width, height: 40)
        return header
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserAchievementCell.identifier) as! UserAchievementCell
        cell.selectionStyle = .none
        switch indexPath.section {
        case 0:
            cell.setData(lessons: farmCourseList, countArray: farmAchievements)
            
        case 1:
            cell.setData(lessons: orchardCourseList, countArray: orchardAchievements)
            
        case 2:
            cell.setData(lessons: gardenCourseList, countArray: gardenAchievements)
        case 3:
            cell.setData(lessons: fieldCourseList, countArray: fieldAchievements)
        default:
            CWLog("")
        }
        return cell
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
