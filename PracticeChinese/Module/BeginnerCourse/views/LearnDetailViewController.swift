//
//  LearnDetailViewController.swift
//  PracticeChinese
//
//  Created by Temp on 2018/12/17.
//  Copyright © 2018 msra. All rights reserved.
//

import UIKit

class LearnDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var learnItemArray = [ScenarioLessonLearningItem]()
    var tableView: UITableView!
    var footerView = UIView()
    var continueButton = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setSubviews()
    }
    func setSubviews(){
        
        let bottomHeight: CGFloat = 90
        let buttonHeight: CGFloat = 44
        let buttonWidth: CGFloat = 150
        let buttonTop = (bottomHeight - buttonHeight)/2
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height), style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        tableView.showsVerticalScrollIndicator = false
        tableView.register(LearningSummaryCell.nibObject, forCellReuseIdentifier: LearningSummaryCell.identifier)
        tableView.register(LearnMoreCell.nibObject, forCellReuseIdentifier: LearnMoreCell.identifier)
        self.view.addSubview(tableView)

        footerView.frame = CGRect(x: 0, y: 0, width: ScreenUtils.width, height: 90)
        
        continueButton.frame = CGRect(x:(ScreenUtils.width - buttonWidth)/2 , y:buttonTop, width: buttonWidth, height: 44)
        continueButton.setBackgroundImage(UIImage.fromColor(color: UIColor.blueTheme), for: .normal)
        continueButton.setTitle("Review", for: UIControl.State.normal)
        continueButton.titleLabel?.textAlignment = .center
        continueButton.titleLabel?.font = FontUtil.getFont(size: FontAdjust().FontSize(18), type: .Regular)
        continueButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        continueButton.addTarget(self,action:#selector(continueTask),for:.touchUpInside)
        continueButton.layer.cornerRadius = 22
        footerView.addSubview(continueButton)
        self.tableView.tableFooterView = footerView
        
    }
    //大于一轮，进入学习流
    @objc func continueTask(button:UIButton)  {
        let cardVC = LearnCardFlowViewController()
        
        cardVC.courseId  = BeginnerLessonsManager.shared.id
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.learnItemArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let course = self.learnItemArray[indexPath.row]
        
        let chineseheight = self.getLabelheight(labelStr: course.Text!, font: FontUtil.getFont(size: FontAdjust().FontSize(Double(22)), type: .Regular))
        let englishheight = self.getLabelheight(labelStr: course.NativeText!, font: FontUtil.getFont(size: FontAdjust().FontSize(Double(14)), type: .Regular))
        return chineseheight + englishheight + CGFloat(26)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LearningSummaryCell.identifier) as! LearningSummaryCell
        cell.selectionStyle = .none
        let course = self.learnItemArray[indexPath.row]
        cell.statusImageView.isHidden = false
        cell.chinese.text = course.Text
        cell.english.text = course.NativeText
        let chineseheight = self.getLabelheight(labelStr: course.Text!, font: FontUtil.getFont(size: FontAdjust().FontSize(Double(22)), type: .Regular))
        let englishheight = self.getLabelheight(labelStr: course.NativeText!, font: FontUtil.getFont(size: FontAdjust().FontSize(Double(14)), type: .Regular))
        if indexPath.row == 0 {
            let maskPath = UIBezierPath(roundedRect: CGRect(x: 0.0, y: 0.0, width: ScreenUtils.width - 44, height: chineseheight + englishheight + CGFloat(26)), byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10, height: 10))
            
            let maskLayer = CAShapeLayer()
            maskLayer.borderColor = UIColor.hex(hex: "F5FAFF").cgColor
            maskLayer.frame = cell.bgView.bounds
            maskLayer.path = maskPath.cgPath
            cell.bgView.layer.mask = maskLayer
        }
        if indexPath.section == 1 && indexPath.row == self.learnItemArray.count - 1 {
            let maskPath = UIBezierPath(roundedRect: CGRect(x: 0.0, y: 0.0, width: ScreenUtils.width - 44, height: chineseheight + englishheight + CGFloat(26)), byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 10, height: 10))
            
            let maskLayer = CAShapeLayer()
            maskLayer.borderColor = UIColor.hex(hex: "F5FAFF").cgColor
            maskLayer.frame = cell.bgView.bounds
            maskLayer.path = maskPath.cgPath
            cell.bgView.layer.mask = maskLayer
        }
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    func getLabelheight(labelStr:String,font:UIFont)->CGFloat{
        let labelWidth = ScreenUtils.width - 121
        let maxSie:CGSize = CGSize(width:labelWidth,height:200)
        return (labelStr as String).boundingRect(with: maxSie, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):font]), context: nil).size.height
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
