//
//  ResultCard.swift
//  PracticeChinese
//
//  Created by summer on 2017/9/11.
//  Copyright © 2017年 msra. All rights reserved.
//

import Foundation
import YYText
enum ResultStatusStyle {
    case other
    //没有完成
    case notCompleted
    //在这一轮全部完成
    case completed
    //进来前今已经完成了，summary
    case alreadyCompletedAfter
}
protocol ResultCardDelegate {
    //点击Done
    func doneClick(completed:Bool)
}
class ResultCard: UIView,UITableViewDataSource,UITableViewDelegate {
    var isSuccess:Bool!
    var totalPoint:Int!
    var imageView:UIImageView!
    var messageLabel = UILabel()
    var redoButton = UIButton()
    var continueButton = UIButton()
    var doneButton = UIButton()
    var tableView: UITableView!
    var offSet = CGPoint(x: 0, y: 0)
    var delegate: ResultCardDelegate?
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
    //是summary 还是信息展示
    var summary : Bool = true
    var statusStyle:ResultStatusStyle!
    var oldUser = false
    var resultDic = [String : Any]()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isSuccess = true
        totalPoint = 0
        self.backgroundColor = UIColor.white
        self.clipsToBounds = false
        self.layer.masksToBounds = false
        self.setSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSubviews(){
        messageLabel.textColor = UIColor.textGray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(16), type: .Regular)
        
        let bottomHeight: CGFloat = 90
        let buttonHeight: CGFloat = FontAdjust().buttonHeight()
        let buttonWidth: CGFloat = FontAdjust().buttonWidth()
        let buttonTop = (bottomHeight - buttonHeight)/2
        var top: CGFloat = 0
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
            top = -78
        }else {
            top = -54
        }
        
        if(AppData.userAssessmentEnabled && UserManager.shared.isLoggedIn()){
            //授权且登陆
            self.statusStyle = ResultStatusStyle.other
            tableView = UITableView(frame: CGRect(x: -14, y: top, width: ScreenUtils.width, height: self.frame.height - top), style: .grouped)
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
                make.top.equalTo(self).offset(top)
                make.height.equalTo(self.frame.height - top)
                make.width.equalTo(ScreenUtils.width)
            }
            
            footerView.frame = CGRect(x: 0, y: 0, width: ScreenUtils.width, height: 90)
            
            doneButton.frame = CGRect(x:(ScreenUtils.width - buttonWidth)/2 , y:buttonTop, width: buttonWidth, height: buttonHeight)
            doneButton.setBackgroundImage(UIImage.fromColor(color: UIColor.blueTheme), for: .normal)
            doneButton.setTitle("Done", for: UIControl.State.normal)
            doneButton.titleLabel?.textAlignment = .center
            doneButton.titleLabel?.font = FontUtil.getTitleFont()
            doneButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
            doneButton.addTarget(self, action: #selector(resultDoneClick), for: .touchUpInside)
            doneButton.layer.cornerRadius = 22
            doneButton.layer.masksToBounds = true
            footerView.addSubview(doneButton)
            
            redoButton.frame = CGRect(x:ScreenUtils.width / 2 + 10 , y:buttonTop, width: buttonWidth, height: buttonHeight)
            redoButton.setBackgroundImage(UIImage.fromColor(color: UIColor.blueTheme), for: .normal)
            redoButton.setTitle("Next Round", for: UIControl.State.normal)
            redoButton.titleLabel?.textAlignment = .center
            redoButton.titleLabel?.font = FontUtil.getTitleFont()
            redoButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
            redoButton.layer.cornerRadius = 22
            redoButton.layer.masksToBounds = true
            footerView.addSubview(redoButton)
            
            continueButton.frame = CGRect(x:(ScreenUtils.width - buttonWidth)/2 , y:buttonTop, width: buttonWidth, height: buttonHeight)
            continueButton.setBackgroundImage(UIImage.fromColor(color: UIColor.blueTheme), for: .normal)
            continueButton.setTitle("Continue", for: UIControl.State.normal)
            continueButton.titleLabel?.textAlignment = .center
            continueButton.titleLabel?.font = FontUtil.getTitleFont()
            continueButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
            continueButton.layer.cornerRadius = 22
            continueButton.layer.masksToBounds = true
            footerView.addSubview(continueButton)
            
        }else if(UserManager.shared.isLoggedIn() && !AppData.userAssessmentEnabled){
            //登录没授权

            let alertText = "You have done the first round. However, you are unable to receive any diagnosis about your learning performance, for Data Collection and Permission is disabled."
            messageLabel.text = alertText
            self.addSubview(messageLabel)
            imageView = UIImageView(image: UIImage(named: "logopic_blue"))
            imageView.backgroundColor = UIColor.clear
            imageView.frame = CGRect.zero
            imageView.layer.masksToBounds = false
            imageView.clipsToBounds = false
            imageView.isUserInteractionEnabled = true
            
            self.addSubview(imageView)
            doneButton.frame = CGRect(x:(self.frame.width - buttonWidth)/2 , y:self.frame.height-ScreenUtils.heightByM(y: CGFloat(75)), width: buttonWidth, height: buttonHeight)
            doneButton.setBackgroundImage(UIImage.fromColor(color: UIColor.blueTheme), for: .normal)
            doneButton.setTitle("Done", for: UIControl.State.normal)
            doneButton.titleLabel?.textAlignment = .center
            doneButton.titleLabel?.font = FontUtil.getTitleFont()
            doneButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
            doneButton.addTarget(self, action: #selector(resultDoneClick), for: .touchUpInside)
            doneButton.layer.cornerRadius = buttonHeight / 2
            doneButton.layer.masksToBounds = true
            self.addSubview(doneButton)
            
            messageLabel.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(imageView.snp.bottom).offset(30)
                make.width.equalTo(AdjustGlobal().CurrentScaleWidth*0.9)
                make.centerX.equalTo(self)
            }
            imageView.snp.makeConstraints { (make) -> Void in
                make.centerY.equalTo(self).offset(-120)
                make.centerX.equalTo(self)
                make.width.equalTo(AdjustGlobal().CurrentScaleWidth*0.4)
                make.height.equalTo(AdjustGlobal().CurrentScaleWidth*0.4 * 544 / 476)
            }
        }else{
            //没登录
            let alertText = "You are trying out the limited version. Login can unlock more features. "
            messageLabel.text = alertText
            self.addSubview(messageLabel)

            imageView = UIImageView(image: UIImage(named: "logopic_blue"))
            imageView.backgroundColor = UIColor.clear
            imageView.frame = CGRect.zero
            imageView.layer.masksToBounds = false
            imageView.clipsToBounds = false
            imageView.isUserInteractionEnabled = true
            
            self.addSubview(imageView)

            doneButton.frame = CGRect(x:self.frame.width / 2 - 10 - buttonWidth, y:self.frame.height-ScreenUtils.heightByM(y: CGFloat(75)), width: buttonWidth, height: buttonHeight)
            doneButton.setBackgroundImage(UIImage.fromColor(color: UIColor.hex(hex: "E0E0E0")), for: .normal)
            doneButton.setTitle("Later", for: UIControl.State.normal)
            doneButton.titleLabel?.textAlignment = .center
            doneButton.titleLabel?.font = FontUtil.getTitleFont()
            doneButton.setTitleColor(UIColor.hex(hex: "4F4F4F"), for: UIControl.State.normal)
            doneButton.setTitleColor(UIColor.white, for: UIControl.State.highlighted)
            doneButton.setTitleColor(UIColor.white, for: UIControl.State.selected)
            doneButton.addTarget(self, action: #selector(resultDoneClick), for: .touchUpInside)
            doneButton.layer.cornerRadius = buttonHeight / 2
            doneButton.layer.masksToBounds = true
            self.addSubview(doneButton)

            redoButton.frame = CGRect(x:self.frame.width / 2 + 10 , y:self.frame.height-ScreenUtils.heightByM(y: CGFloat(75)), width: buttonWidth, height: buttonHeight)
            redoButton.setBackgroundImage(UIImage.fromColor(color: UIColor.blueTheme), for: .normal)
            redoButton.setTitle("Sign in", for: UIControl.State.normal)
            redoButton.titleLabel?.textAlignment = .center
            redoButton.titleLabel?.font = FontUtil.getTitleFont()
            redoButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
            redoButton.layer.cornerRadius = buttonHeight / 2
            redoButton.layer.masksToBounds = true
            self.addSubview(redoButton)
            
            messageLabel.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(imageView.snp.bottom).offset(30)
                make.width.equalTo(AdjustGlobal().CurrentScaleWidth*0.9)
                make.centerX.equalTo(self)
            }
            
            imageView.snp.makeConstraints { (make) -> Void in
                make.centerY.equalTo(self).offset(-120)
                make.centerX.equalTo(self)
                make.width.equalTo(AdjustGlobal().CurrentScaleWidth*0.4)
                make.height.equalTo(AdjustGlobal().CurrentScaleWidth*0.4 * 544 / 476)
            }
        }
    }
    @objc func resultDoneClick() {
        if self.statusStyle == .completed {
            self.delegate?.doneClick(completed: true)
        }else {
            self.delegate?.doneClick(completed: false)
        }
    }
    //加载数据
    func loadData(_ status: ResultStatusStyle) {
        if(!UserManager.shared.isLoggedIn() || !AppData.userAssessmentEnabled){
            //没登录或没授权
            return
        }
        self.statusStyle = status
        //之前就已经完成,前面展示
        let bottomHeight: CGFloat = 90
        let buttonHeight: CGFloat = FontAdjust().buttonHeight()
        let buttonWidth: CGFloat = FontAdjust().buttonWidth()
        //之前就已经完成
        if self.statusStyle == ResultStatusStyle.alreadyCompletedAfter {
            let alertText = "Great job! You just reviewed what you've learned in this lesson."
            messageLabel.text = alertText
            self.addSubview(messageLabel)
            self.tableView.isHidden = true
            doneButton.isHidden = false
            continueButton.isHidden = true
            redoButton.isHidden = true
            
            doneButton.frame = CGRect(x:(self.frame.width - buttonWidth)/2, y:self.frame.height - ScreenUtils.heightByM(y: CGFloat(75)), width: buttonWidth, height: buttonHeight)
            doneButton.setBackgroundImage(UIImage.fromColor(color: UIColor.blueTheme), for: .normal)
            doneButton.setTitle("Done", for: UIControl.State.normal)
            doneButton.addTarget(self, action: #selector(resultDoneClick), for: .touchUpInside)
            self.addSubview(doneButton)
            
            imageView = UIImageView()
            imageView.image = UIImage.gifImageWithName("give-me-five02")
            imageView.frame = CGRect.zero
            imageView.layer.masksToBounds = false
            imageView.clipsToBounds = false
            imageView.isUserInteractionEnabled = true
            self.addSubview(imageView)

            imageView.snp.makeConstraints { (make) -> Void in
                make.centerY.equalTo(self).offset(-180)
                make.centerX.equalTo(self)
                make.width.equalTo(515/2.3)
                make.height.equalTo(392/2.3)
            }

            messageLabel.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(imageView.snp.bottom).offset(30)
                make.width.equalTo(AdjustGlobal().CurrentScaleWidth*0.9)
                make.centerX.equalTo(self)
            }

        }else{
            //summary，
            CourseManager.shared.listScenarioLesson(id: self.courseId) { (result) in
                if result == nil {
                    return
                }
                if (result?.ScenarioLessonInfo?.Progress)! > 0 {
                    //说明全部为1,完成了
                    for item in self.learnItemArray {
                        self.completedLesson.append([item.Text! : 1.0])
                    }
                    self.statusStyle = ResultStatusStyle.completed
                    self.makeHeaderFooterView()
                    self.tableView.reloadData()
                }else {
                    //没有全部完成
                    if result?.ScenarioLessonInfo?.ItemLearnRateDict != nil {
                        self.resultDic = self.getDictionaryFromJSONString(jsonString: (result?.ScenarioLessonInfo?.ItemLearnRateDict)!) as! [String : Any]
                        self.unCompletedLesson.removeAll()
                        self.completedLesson.removeAll()
                        for item in self.learnItemArray {
                            if self.resultDic[item.Text!] != nil {
                                if let progress =  (self.resultDic[item.Text!])! as? Double{
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
                        if self.unCompletedLesson.count == 0 {
                            //全部完成
                            self.statusStyle = ResultStatusStyle.completed
                        }else {
                            self.statusStyle = ResultStatusStyle.notCompleted
                        }
                        self.makeHeaderFooterView()
                        self.tableView.reloadData()
                    }else {
                        for item in self.learnItemArray {
                            self.unCompletedLesson.append([item.Text! : 0.0])
                        }
                        self.statusStyle = ResultStatusStyle.notCompleted
                        self.makeHeaderFooterView()
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    func makeHeaderFooterView() {
        //全部都完成了,使用give-me
        let headerView = Bundle.main.loadNibNamed("LearnSummaryHeader", owner: nil, options: nil)?[0] as? LearnSummaryHeader
        if self.statusStyle != ResultStatusStyle.alreadyCompletedAfter {
            if self.unCompletedLesson.count == 0 {
                headerView?.frame = CGRect(x: 0, y: 0, width: ScreenUtils.width, height: 200)
                headerView?.imageHeight.constant = 392/2.3
                headerView?.imageWidth.constant = 515/2.3
                headerView?.headImage.image = UIImage.gifImageWithName("give-me-five02")
            }else {
                headerView?.frame = CGRect(x: 0, y: 0, width: ScreenUtils.width, height: 80)
                headerView?.headImage.image = UIImage(named: "NiceWork")
                headerView?.imageHeight.constant = 45
                headerView?.imageWidth.constant = 300
            }
        }else {
            headerView?.frame = CGRect(x: 0, y: 0, width: ScreenUtils.width, height: 0)
            headerView?.headImage.image = UIImage(named: "")
            headerView?.imageHeight.constant = 0
            headerView?.imageWidth.constant = 0
        }
        let bottomHeight: CGFloat = 90
        let buttonHeight: CGFloat = FontAdjust().buttonHeight()
        let buttonWidth: CGFloat = FontAdjust().buttonWidth()
        let buttonTop = (bottomHeight - buttonHeight)/2
        tableView.tableHeaderView = headerView
        //全部完成
        if self.statusStyle == ResultStatusStyle.completed {
            //只有一个Done
            doneButton.isHidden = false
            continueButton.isHidden = true
            redoButton.isHidden = true
        }else if self.statusStyle == ResultStatusStyle.notCompleted {
            //没有全部完成 ，done next round
            doneButton.frame = CGRect(x:ScreenUtils.width / 2 - 10 - buttonWidth, y:buttonTop, width: buttonWidth, height: buttonHeight)
            doneButton.isHidden = false
            continueButton.isHidden = true
            redoButton.isHidden = false
            doneButton.setBackgroundImage(UIImage.fromColor(color: UIColor.hex(hex: "E0E0E0")), for: .normal)
            doneButton.setTitleColor(UIColor.hex(hex: "4F4F4F"), for: UIControl.State.normal)
            doneButton.setTitleColor(UIColor.white, for: UIControl.State.highlighted)
            doneButton.setTitleColor(UIColor.white, for: UIControl.State.selected)
            doneButton.addTarget(self, action: #selector(resultDoneClick), for: .touchUpInside)
        }
        else {
            doneButton.isHidden = false
            continueButton.isHidden = true
            redoButton.isHidden = true
            doneButton.frame = CGRect(x:(ScreenUtils.width - buttonWidth)/2, y: buttonTop, width: buttonWidth, height: buttonHeight)
            doneButton.setBackgroundImage(UIImage.fromColor(color: UIColor.blueTheme), for: .normal)
            doneButton.setTitle("Done", for: UIControl.State.normal)
            doneButton.addTarget(self, action: #selector(resultDoneClick), for: .touchUpInside)
        }
        tableView.tableFooterView = footerView
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
            if self.unCompletedLesson.count > 5 && !moreDidSelected {
                return 6
            }
            return self.unCompletedLesson.count
        }
        return self.completedLesson.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if self.unCompletedLesson.count > 5 && !moreDidSelected {
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
        if indexPath.row == 0 {
            var englishheight: CGFloat = 0
            let chineseheight = self.getLabelheight(labelStr: chinese, font: FontUtil.getFont(size: FontAdjust().FontSize(Double(22)), type: .Regular))
            
            for item in learnItemArray {
                if item.Text == chinese {
                    englishheight = self.getLabelheight(labelStr: item.NativeText!, font: FontUtil.getFont(size: FontAdjust().FontSize(Double(14)), type: .Regular))
                }
            }

            let maskPath = UIBezierPath(roundedRect: CGRect(x: 0.0, y: 0.0, width: ScreenUtils.width - 44, height: chineseheight + englishheight + CGFloat(26)), byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10, height: 10))
            
            let maskLayer = CAShapeLayer()
            maskLayer.borderColor = UIColor.hex(hex: "F5FAFF").cgColor
            maskLayer.frame = cell.bgView.bounds
            maskLayer.path = maskPath.cgPath
            cell.bgView.layer.mask = maskLayer
        }
        if indexPath.section == 1 && indexPath.row == self.completedLesson.count - 1 {
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
        if section == 0 {
            if self.unCompletedLesson.count > 0 {
                let header = Bundle.main.loadNibNamed("PractiseHeaderView", owner: self, options: nil)?.first as! PractiseHeaderView
                header.frame = CGRect(x: 0, y: 0, width: ScreenUtils.width, height: 60)
                if self.statusStyle == ResultStatusStyle.notCompleted {
                    header.headerTitle.text = "Your progress this round"
                }else {
                    header.headerTitle.text = "Items you are working"
                }
                return header
            }
            return UIView()
        }else {
            if self.completedLesson.count > 0 {
                let header = Bundle.main.loadNibNamed("PractiseHeaderView", owner: self, options: nil)?.first as! PractiseHeaderView
                header.frame = CGRect(x: 0, y: 0, width: ScreenUtils.width, height: 60)
                header.headerTitle.text = "Items you have done"
                return header
            }
            return UIView()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if self.unCompletedLesson.count > 5 && !moreDidSelected {
                if indexPath.row == 5 {
                    offSet = self.tableView.contentOffset
                    moreDidSelected = true
                    self.tableView.reloadData()
                    self.tableView.contentOffset = offSet
//                    var indexArray = [IndexPath]()
//                    let count = self.unCompletedLesson.count - 5
//                    for i in 0...count {
//                        let indexP = IndexPath(row: i + 4, section: 0)
//                        indexArray.append(indexP)
//                    }
//                    if (indexArray.count) > 0 {
//                        self.tableView.reloadRows(at: indexArray, with: .none)
//                    }
                }
            }
        }
    }
    
    func getLabelheight(labelStr:String,font:UIFont)->CGFloat{
        let labelWidth = ScreenUtils.width - 121
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
