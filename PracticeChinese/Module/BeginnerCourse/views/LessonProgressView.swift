//
//  ResultCard.swift
//  PracticeChinese
//
//  Created by summer on 2017/9/11.
//  Copyright © 2017年 msra. All rights reserved.
//

import Foundation
import YYText

class LessonProgressView: UIView,UITableViewDataSource,UITableViewDelegate {
    var continueButton = UIButton()
    var tableView: UITableView!
    //未完成
    var unCompletedLesson = [[String : Double]]()
    //已完成
    var completedLesson = [[String : Double]]()
    
    var courseId: String = "L3-1-1-1-s-CN"
    //阳光值
    var allSunValue = 0
    //是否点击了more查看更多
    var moreDidSelected = false
    var learnItemArray = [ScenarioLessonLearningItem]()
    var footerView = UIView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.setSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSubviews(){

        let bottomHeight: CGFloat = 90
        let buttonHeight: CGFloat = 44
        let buttonWidth: CGFloat = (ScreenUtils.width - 60)/2
        let buttonTop = (bottomHeight - buttonHeight)/2

        tableView = UITableView(frame: CGRect(x: -14, y: 0, width: ScreenUtils.width, height: self.frame.height), style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        tableView.showsVerticalScrollIndicator = false
        tableView.register(LearningSummaryCell.nibObject, forCellReuseIdentifier: LearningSummaryCell.identifier)
        tableView.register(LearnMoreCell.nibObject, forCellReuseIdentifier: LearnMoreCell.identifier)
        self.addSubview(tableView)
        tableView.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(self)
            make.top.equalTo(self)
            make.height.equalTo(self.frame.height)
            make.width.equalTo(ScreenUtils.width)
        }
        
        footerView.frame = CGRect(x: 0, y: 0, width: ScreenUtils.width, height: 90)

        continueButton.frame = CGRect(x:(ScreenUtils.width - buttonWidth)/2 , y:buttonTop, width: buttonWidth, height: 44)
        continueButton.setBackgroundImage(UIImage.fromColor(color: UIColor.blueTheme), for: .normal)
        continueButton.setTitle("Continue", for: UIControl.State.normal)
        continueButton.titleLabel?.textAlignment = .center
        continueButton.titleLabel?.font = FontUtil.getFont(size: FontAdjust().FontSize(18), type: .Regular)
        continueButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        continueButton.layer.cornerRadius = 22
        continueButton.layer.masksToBounds = true
        footerView.addSubview(continueButton)

    }

    //加载数据
    func loadData(result: [String: Any]?,completed: Bool = false) {
        if (completed) {
            //说明全部为1,完成了
            continueButton.setTitle("Review", for: UIControl.State.normal)
            self.completedLesson.removeAll()
            for item in self.learnItemArray {
                self.completedLesson.append([item.Text! : 1.0])
            }
        }else {
            //没有全部完成
            self.unCompletedLesson.removeAll()
            self.completedLesson.removeAll()
            for item in self.learnItemArray {
                if result![item.Text!] != nil {
                    if let progress =  (result![item.Text!])! as? Double{
                        if progress < 1.0 {
                            self.unCompletedLesson.append([item.Text! : progress])
                        }else {
                            self.completedLesson.append([item.Text! : progress])
                        }
                    }else {
                        self.unCompletedLesson.append([item.Text! : 0.0])
                    }
                }else {
                    self.unCompletedLesson.append([item.Text! : 0.0])
                }
            }
        }
        tableView.tableFooterView = footerView
        self.tableView.reloadData()
    }
    
    func getDictionaryFromJSONString(jsonString:String) ->NSDictionary{
        
        let jsonData:Data = jsonString.data(using: .utf8)!
        
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
        
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if self.unCompletedLesson.count > 5 && !moreDidSelected{
                return 6
            }else {
                return self.unCompletedLesson.count
            }
        }
        return self.completedLesson.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if self.unCompletedLesson.count > 5 && !moreDidSelected{
                if indexPath.row == 5 {
                    return 40
                }else {
                    var chinese = ""
                    var score = [String: Double]()
                    score = self.unCompletedLesson[indexPath.row]
                    chinese = (score.first?.key)!
                    var englishheight: CGFloat = 0
                    let chineseheight = self.getLabelheight(labelStr: chinese, font: FontUtil.getFont(size: FontAdjust().FontSize(Double(22)), type: .Regular))

                    for item in learnItemArray {
                        if item.Text == chinese {
                            englishheight = self.getLabelheight(labelStr: item.NativeText!, font: FontUtil.getFont(size: FontAdjust().FontSize(Double(14)), type: .Regular))
                        }
                    }
                    return chineseheight + englishheight + CGFloat(26)
                }
            }else {
                var chinese = ""
                var score = [String: Double]()
                score = self.unCompletedLesson[indexPath.row]
                chinese = (score.first?.key)!
                var englishheight: CGFloat = 0
                let chineseheight = self.getLabelheight(labelStr: chinese, font: FontUtil.getFont(size: FontAdjust().FontSize(Double(22)), type: .Regular))
                
                for item in learnItemArray {
                    if item.Text == chinese {
                        englishheight = self.getLabelheight(labelStr: item.NativeText!, font: FontUtil.getFont(size: FontAdjust().FontSize(Double(14)), type: .Regular))
                    }
                }
                return chineseheight + englishheight + CGFloat(26)
            }
        }else {
            var chinese = ""
            var score = [String: Double]()
            score = self.completedLesson[indexPath.row]
            chinese = (score.first?.key)!
            var englishheight: CGFloat = 0
            let chineseheight = self.getLabelheight(labelStr: chinese, font: FontUtil.getFont(size: FontAdjust().FontSize(Double(22)), type: .Regular))
            for item in learnItemArray {
                if item.Text == chinese {
                    englishheight = self.getLabelheight(labelStr: item.NativeText!, font: FontUtil.getFont(size: FontAdjust().FontSize(Double(14)), type: .Regular))
                }
            }
            return chineseheight + englishheight + CGFloat(26)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LearningSummaryCell.identifier) as! LearningSummaryCell
        cell.selectionStyle = .none
        cell.line.isHidden = false
        var chinese = ""
        var score = [String: Double]()
        if indexPath.section == 0 {
            score = self.unCompletedLesson[indexPath.row]
            chinese = (score.first?.key)!
            if self.unCompletedLesson.count > 5 && !moreDidSelected {
                if indexPath.row == 5 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: LearnMoreCell.identifier) as! LearnMoreCell
                    cell.selectionStyle = .none

                    let maskPath = UIBezierPath(roundedRect: CGRect(x: 0.0, y: 0.0, width: ScreenUtils.width - 44, height: 40.0), byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 10, height: 10))
                    
                    let maskLayer = CAShapeLayer()
                    maskLayer.borderColor = UIColor.hex(hex: "F5FAFF").cgColor
                    maskLayer.frame = cell.bgView.bounds
                    maskLayer.path = maskPath.cgPath
                    cell.bgView.layer.mask = maskLayer
                    return cell
                }
                
            }else {
                if indexPath.row == self.unCompletedLesson.count - 1 {
                    var englishheight: CGFloat = 0
                    let chineseheight = self.getLabelheight(labelStr: chinese, font: FontUtil.getFont(size: FontAdjust().FontSize(Double(22)), type: .Regular))
                    
                    for item in learnItemArray {
                        if item.Text == chinese {
                            englishheight = self.getLabelheight(labelStr: item.NativeText!, font: FontUtil.getFont(size: FontAdjust().FontSize(Double(14)), type: .Regular))
                        }
                    }
                    
                    let maskPath = UIBezierPath(roundedRect: CGRect(x: 0.0, y: 0.0, width: ScreenUtils.width - 44, height: chineseheight + englishheight + CGFloat(26)), byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 10, height: 10))
                    
                    let maskLayer = CAShapeLayer()
                    maskLayer.borderColor = UIColor.hex(hex: "F5FAFF").cgColor
                    maskLayer.frame = cell.bgView.bounds
                    maskLayer.path = maskPath.cgPath
                    cell.bgView.layer.mask = maskLayer
                    cell.line.isHidden = true
                }
            }

        }else {
            score = self.completedLesson[indexPath.row]
            cell.statusImageView.isHidden = false
        }

        cell.setData(score: score)
        chinese = (score.first?.key)!
        for item in learnItemArray {
            if item.Text == chinese {
                 cell.english.text = item.NativeText
            }
        }
        var englishheight: CGFloat = 0
        let chineseheight = self.getLabelheight(labelStr: chinese, font: FontUtil.getFont(size: FontAdjust().FontSize(Double(22)), type: .Regular))
        
        for item in learnItemArray {
            if item.Text == chinese {
                englishheight = self.getLabelheight(labelStr: item.NativeText!, font: FontUtil.getFont(size: FontAdjust().FontSize(Double(14)), type: .Regular))
            }
        }
        let maskPath = UIBezierPath(roundedRect: CGRect(x: 0.0, y: 0.0, width: ScreenUtils.width - 44, height: chineseheight + englishheight + CGFloat(26)), byRoundingCorners: [.topLeft, .topRight,.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 0, height: 0))
        
        let maskLayer = CAShapeLayer()
        maskLayer.borderColor = UIColor.hex(hex: "F5FAFF").cgColor
        maskLayer.frame = cell.bgView.bounds
        maskLayer.path = maskPath.cgPath
        cell.bgView.layer.mask = maskLayer
        
        if indexPath.row == 0 {
            let maskPath = UIBezierPath(roundedRect: CGRect(x: 0.0, y: 0.0, width: ScreenUtils.width - 44, height: chineseheight + englishheight + CGFloat(26)), byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10, height: 10))
            
            let maskLayer = CAShapeLayer()
            maskLayer.borderColor = UIColor.hex(hex: "F5FAFF").cgColor
            maskLayer.frame = cell.bgView.bounds
            maskLayer.path = maskPath.cgPath
            cell.bgView.layer.mask = maskLayer
        }
        if indexPath.section == 1 && indexPath.row == self.completedLesson.count - 1 {

            let maskPath = UIBezierPath(roundedRect: CGRect(x: 0.0, y: 0.0, width: ScreenUtils.width - 44, height: chineseheight + englishheight + CGFloat(26)), byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 10, height: 10))
            
            let maskLayer = CAShapeLayer()
            maskLayer.borderColor = UIColor.hex(hex: "F5FAFF").cgColor
            maskLayer.frame = cell.bgView.bounds
            maskLayer.path = maskPath.cgPath
            cell.bgView.layer.mask = maskLayer
            cell.line.isHidden = true
        }
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.unCompletedLesson.count == 0 {
            return 12.0
        }else {
            
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.unCompletedLesson.count == 0 {
            return UIView()
        }else {
            let header = Bundle.main.loadNibNamed("PractiseHeaderView", owner: self, options: nil)?.first as! PractiseHeaderView
            if section == 0 {
                header.headerTitle.text = "Items you are working"
            }else {
                header.headerTitle.text = "Items you have done"
            }
            return header
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if self.unCompletedLesson.count > 5 && !moreDidSelected {
                if indexPath.row == 5 {
                    moreDidSelected = true
                    self.tableView.reloadSections([0], with: .none)
                }
            }
        }
    }
    
    func getLabelheight(labelStr:String,font:UIFont)->CGFloat{
        let labelWidth = ScreenUtils.width - 129
        let maxSie:CGSize = CGSize(width:labelWidth,height:200)
        return (labelStr as String).boundingRect(with: maxSie, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):font]), context: nil).size.height
    }
    
    func getLabelWidth(labelStr:String,font:UIFont)->CGFloat{
        let labelHeight = ScreenUtils.height
        let maxSie:CGSize = CGSize(width:ScreenUtils.width,height:labelHeight)
        return (labelStr as String).boundingRect(with: maxSie, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):font]), context: nil).size.width
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
