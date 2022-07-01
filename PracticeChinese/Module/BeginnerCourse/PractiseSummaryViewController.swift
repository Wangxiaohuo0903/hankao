//
//  PractiseSummaryViewController.swift
//  PracticeChinese
//
//  Created by Temp on 2018/9/3.
//  Copyright © 2018年 msra. All rights reserved.
//

import UIKit

class PractiseSummaryViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var score:Int = 0
    var Id: String = ""
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var done: UIButton!
    var refreshLand = true
    //分数回调
    var finishPratise: ((Int) -> Void)?
    //需要加强的单词
    var hintTurnArray = [HintDetail]()
    //收集所有语音，在summary展示
    var summaryLessonArray = [PractiseMessageModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        updateCoin()
        self.done.layer.cornerRadius = 22
        self.done.layer.masksToBounds = true
        self.navigationItem.hidesBackButton = true
        navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.fromColor(color: UIColor.clear), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()

        tableView.register(PractiseSummaryCell.nibObject, forCellReuseIdentifier: PractiseSummaryCell.identifier)
        tableView.register(WorkOnWordsCell.nibObject, forCellReuseIdentifier: WorkOnWordsCell.identifier)
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: 220))
        let circleView = Bundle.main.loadNibNamed("PractiseSummaryHeader", owner: nil, options: nil)?[0] as! PractiseSummaryHeader
        circleView.frame = CGRect(x: 0, y: 0, width: ScreenUtils.width, height: 220)
        circleView.setData(score: self.score)
        headerView.addSubview(circleView)
        tableView.tableHeaderView = headerView
        
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: 90))
        tableView.tableFooterView = footer
        tableView.separatorStyle = .none
        self.gradientColor(gradientView: bottomView, frame: CGRect(x: 9, y: 0, width: ScreenUtils.width, height: 125), upTodown: true)
        
    }
    func closeTapped() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func doneClick(_ sender: UIButton) {
        if self.refreshLand {
            self.finishPratise?(self.score)
        }
        self.closeTapped()
    }
    func updateCoin() {
        var coin = -SunValueManager.shared().sunValue
        if score >= 60 {
            coin = SunValueManager.shared().sunValue * 2
        }
        ChActivityView.show(.EvaluatingLearn, UIApplication.shared.keyWindow!, UIColor.white, ActivityViewText.EvaluatingCC, UIColor.textGray, UIColor.white)
        UserManager.shared.updateUserCoin(coinDelta: coin, completion: { (success) in
            if success {
                //上传成功
                self.loadHomeData()
            }
            else {
                //上传失败
                ChActivityView.hide()
                UIApplication.topViewController()?.presentUserToast(message: "Please try again!")
            }
        })
    }
    func loadHomeData() {
        if(AppData.userAssessmentEnabled) {
            CourseManager.shared.updateCourseProgress(classType:ClassType.Scenario,id: self.Id) {
                success in
                if !success! {
                    ChActivityView.hide()
                    CWLog("update progress failed \(self.Id)")
                }
                else {
                    RequestManager.shared.refresh = true
                    CourseManager.shared.isLearnPage = false
                    CourseManager.shared.SetCoursesList(update: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        ChActivityView.hide()
                    })
//                    CourseManager.shared.getRecommendLessons { (lessons) in
//                        if lessons.count > 0 {
//                            self.presentUserToast(message: "做完学以致用检测到\(lessons.count)个新的土地")
//                        }else {
//                            self.presentUserToast(message: "做完学以致用没有新的土地")
//                        }
//                        RequestManager.shared.refresh = true
//                        CourseManager.shared.isLearnPage = false
//                        CourseManager.shared.SetCoursesList(update: true)
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
//                            ChActivityView.hide()
//                        })
//                    }
                }
            }
        }else {
             ChActivityView.hide()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.summaryLessonArray.count
        }else {
            return self.hintTurnArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            if self.hintTurnArray.count > 0 {
                let footer = Bundle.main.loadNibNamed("PractiseHeaderView", owner: self, options: nil)?.first as! PractiseHeaderView
                
                footer.headerTitle.text = "Words to work on"
                footer.frame = CGRect(x: 0, y: 0, width: ScreenUtils.width, height: 60)
                return footer
            }
            return UIView()
        }else {
            if self.hintTurnArray.count > 0 {
                let footer = UIView(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: 20))
                let bgView = UIView(frame: CGRect(x: 22, y: 0, width: ScreenUtils.width - 44, height: 15))
                bgView.backgroundColor = UIColor.hex(hex: "F5FAFF")
                
                let maskPath = UIBezierPath(roundedRect: bgView.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 10, height: 10))
                
                let maskLayer = CAShapeLayer()
                
                maskLayer.frame = bgView.bounds
                
                maskLayer.path = maskPath.cgPath
                
                bgView.layer.mask = maskLayer
                footer.addSubview(bgView)
                return footer
            }
            return UIView()
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            let header = Bundle.main.loadNibNamed("PractiseHeaderView", owner: self, options: nil)?.first as! PractiseHeaderView
            
            header.headerTitle.text = "Performance"
            header.frame = CGRect(x: 0, y: 0, width: ScreenUtils.width, height: 60)
            return header
        }else {
            if self.hintTurnArray.count > 0 {
                let header = UIView(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: 20))
                let bgView = UIView(frame: CGRect(x: 22, y: 0, width: ScreenUtils.width - 44, height: 15))
                bgView.backgroundColor = UIColor.hex(hex: "F5FAFF")
                let maskPath = UIBezierPath(roundedRect: bgView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10, height: 10))
                
                let maskLayer = CAShapeLayer()
                
                maskLayer.frame = bgView.bounds
                
                maskLayer.path = maskPath.cgPath
                
                bgView.layer.mask = maskLayer

                header.addSubview(bgView)
                
                return header
            }
            return UIView()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 60
        }else {
            if self.hintTurnArray.count > 0 {
                return 15
            }
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            if self.hintTurnArray.count > 0 {
                return 60
            }
            return 0.01
        }else {
            if self.hintTurnArray.count > 0 {
                return 0.01
            }
            return 0.01
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            let chat = self.summaryLessonArray[indexPath.row]
            let englishheight = getLabelheight(labelStr: chat.english, font: FontUtil.getFont(size: FontAdjust().FontSize(Double(17)), type: .Regular))
            return englishheight + 49 + 70
        }else {
            return 40
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: PractiseSummaryCell.identifier) as! PractiseSummaryCell
            let chat = self.summaryLessonArray[indexPath.row]
            cell.setContent(msg: chat)
            cell.selectionStyle = .none
            cell.line.isHidden = false
            cell.bgView.layer.mask = nil
            cell.exView.isHidden = false
            if indexPath.row == 0 {
                
                let chat = self.summaryLessonArray[indexPath.row]
                let cellHeight = getLabelheight(labelStr: chat.english, font: FontUtil.getFont(size: FontAdjust().FontSize(Double(17)), type: .Bold)) + 49 + 70
                let maskPath = UIBezierPath(roundedRect: CGRect(x: 0.0, y: 0.0, width: ScreenUtils.width - 44, height: cellHeight), byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10, height: 10))

                let maskLayer = CAShapeLayer()
                maskLayer.borderColor = UIColor.hex(hex: "F5FAFF").cgColor
                maskLayer.frame = cell.bgView.bounds
                maskLayer.path = maskPath.cgPath
                cell.bgView.layer.mask = maskLayer
            }
            if indexPath.row == self.summaryLessonArray.count - 1 {
                cell.exView.isHidden = true
                cell.line.isHidden = true
                let chat = self.summaryLessonArray[indexPath.row]
                let cellHeight = getLabelheight(labelStr: chat.english, font: FontUtil.getFont(size: FontAdjust().FontSize(Double(17)), type: .Bold)) + 49 + 70
                let maskPath = UIBezierPath(roundedRect: CGRect(x: 0.0, y: 0.0, width: ScreenUtils.width - 44, height: cellHeight), byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 10, height: 10))
                
                let maskLayer = CAShapeLayer()
                
                maskLayer.frame = cell.bgView.bounds
                
                maskLayer.path = maskPath.cgPath
                
                cell.bgView.layer.mask = maskLayer
            }
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: WorkOnWordsCell.identifier) as! WorkOnWordsCell
        let chat = self.hintTurnArray[indexPath.row]
        var pinyinStr = ""
        let pinyinArray = PinyinFormat(chat.Pinyin)
        if pinyinArray.count != 0 {
            for i in 0...pinyinArray.count-1{
                pinyinStr = pinyinStr + pinyinArray[i]
            }
        }
        let text = chat.Text! + "  " + pinyinStr + "    " + chat.NativeText!
        let attributedString =  NSMutableAttributedString(string: text, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.hex(hex: "4E80D9"), convertFromNSAttributedStringKey(NSAttributedString.Key.font) : FontUtil.getFont(size: 16, type: .Regular)]))

        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.textBlack333, range: NSRange(location: 0, length: chat.Text!.length))

        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.textGray, range: NSRange(location: chat.Text!.length + 2, length: pinyinStr.length))
        cell.chinese.attributedText = attributedString
        cell.selectionStyle = .none
        return cell
    }
    func getLabelheight(labelStr:String,font:UIFont)->CGFloat{
        let labelWidth = ScreenUtils.width - 126
        let maxSie:CGSize = CGSize(width:labelWidth,height:200)
        return (labelStr as String).boundingRect(with: maxSie, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):font]), context: nil).size.height
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
