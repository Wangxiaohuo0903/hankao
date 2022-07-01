//
//  PractiseLandDetailVC.swift
//  PracticeChinese
//
//  Created by Temp on 2018/9/3.
//  Copyright © 2018年 msra. All rights reserved.
//

import UIKit

class PractiseLandDetailVC: UIViewController,UITableViewDelegate,UITableViewDataSource ,NetworkRequestFailedLoadDelegate {
    func cancleLoading() {
        
    }
    
    func reloadData() {
        loadData()
    }
    
    func backClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var tableView: UITableView!
    var score:Int = 0
    var courseId: String = ""
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var done: UIButton!
    //需要加强的单词
    var hintTurnArray = [HintDetail]()
    //收集所有语音，在summary展示
    var scenarioLessonArray = [ChatTurn]()
    var scenarioLessonTurnArray = [ChatTurn]()
    var summaryLessonArray = [PractiseMessageModel]()
    var scenarioLesson: ScenarioLesson!
    var sentenceDict: VideoSentenceDictionary!
    var circleView: LandDetailHeader!
    var refreshLand = true
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LCVoiceButton.singlePlayer.delegate?.playFinish()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.done.isHidden = true
        self.done.layer.cornerRadius = 22
        self.done.layer.masksToBounds = true
        self.done.setBackgroundImage(UIImage.fromColor(color: UIColor.blueTheme), for: .normal)
        
        self.navigationItem.title = "Content"
        self.navigationController?.navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary(self.ch_getTitleAttribute(textColor: UIColor.textBlack333))// temp
        //设置回退按钮为白色
        self.navigationController?.navigationBar.tintColor = UIColor.textBlack333
        //隐藏底部 tab 栏
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.fromColor(color: UIColor.hex(hex: "F8F8F8")), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()

        tableView.register(LandDetailTableViewCell.nibObject, forCellReuseIdentifier: LandDetailTableViewCell.identifier)
        tableView.register(WorkOnWordsCell.nibObject, forCellReuseIdentifier: WorkOnWordsCell.identifier)
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: 120))
        circleView = Bundle.main.loadNibNamed("LandDetailHeader", owner: nil, options: nil)?[0] as! LandDetailHeader
        circleView.frame = CGRect(x: 0, y: 0, width: ScreenUtils.width, height: 120)
        headerView.addSubview(circleView)
        tableView.tableHeaderView = headerView
        
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: 90))
        tableView.tableFooterView = footer
        
        tableView.separatorStyle = .none
        tableView.isHidden = true
        self.gradientColor(gradientView: bottomView, frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: 90), upTodown: true)
        loadData()
        
        let backButton = UIButton(frame: CGRect(x: 20, y: 0, width: 30, height: 40))
        backButton.setImage(ChImageAssets.left_BackArrow.image, for: .normal)
        backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
        backButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView:backButton)]
    }
    
    func loadData() {
        CourseManager.shared.getScenarioLessonInfo(id: courseId) {
            (lesson,error) in
            if lesson == nil {
                if let requestError = error {
                    var networkErrorText = NetworkRequestFailedText.DataError
                    if requestError.localizedDescription.hasPrefix("The request timed out.")
                    {
                        networkErrorText = NetworkRequestFailedText.NetworkTimeout
                        
                    }else if requestError.localizedDescription.hasPrefix("The Internet connection appears to be offline.") {
                        networkErrorText = NetworkRequestFailedText.NetworkError
                    }
                    let alertView = AlertNetworkRequestFailedView.init(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height))
                    alertView.delegate = self
                    alertView.show(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.height),superView:self.view,alertText:networkErrorText,textColor:UIColor.loadingTextColor,bgColor: UIColor.loadingBgColor,showHidenButton: true)
                }
                return
            }
            self.done.isHidden = false
            self.tableView.isHidden = false
            self.scenarioLesson = lesson!.ScenarioLesson
            self.sentenceDict = lesson!.VideoSentenceDictionary
            self.sortChatTurns()
            self.circleView.setData(scenario: self.scenarioLesson)
            self.tableView.reloadData()
        }
    }
    
    func sortChatTurns() {

        for chatTurn in (self.scenarioLesson.ChatTurn)! {
            if chatTurn.TurnType == 0 {
                self.scenarioLessonArray.append(chatTurn)
                if chatTurn.AnswerOptions?.count != 0 {
                }
            }
        }
        
        for chatTurn in (self.scenarioLesson.ChatTurn)! {
            if chatTurn.TurnType == 1 {
                self.scenarioLessonTurnArray.append(chatTurn)
                if chatTurn.AnswerOptions?.count != 0 {
                }
            }
        }
        var maxIndex = max( self.scenarioLessonArray.count, self.scenarioLessonTurnArray.count)
        var i = 0
        while i < maxIndex {
            
            if i < self.scenarioLessonArray.count {
                let chatTurn = self.scenarioLessonArray[i]
                if (chatTurn.AnswerOptions?.count)! > 0 {
                    for detail in chatTurn.AnswerOptions![0].HintDetails! {
                        var contains = false
                        for hint in self.hintTurnArray {
                            if detail.Text ==  hint.Text {
                                contains = true
                                break
                            }
                        }
                        if contains == false {
                            self.hintTurnArray.append(detail)
                        }
                    }
                }
                if chatTurn.Tokens?.count != 0 {
                    
                    var pinyin:String = ""
                    var chinese:String = ""
                    if (chatTurn.Tokens?.count)! > 0 {
                        //FIXME: - : 怎么判断是纯英文的？tokens 为空
                        for token in chatTurn.Tokens! {
                            chinese = chinese.appending(token.Text!)
                            var ipa = ""
                            var pinyinStr = ""//是一个数组，需要拼接
                            if(token.IPA != nil && token.IPA != ""){//不是标点或者特殊的符号
                                ipa = token.IPA!
                                if(PinyinFormat(ipa).count == 1){
                                    pinyinStr = PinyinFormat(ipa)[0]
                                }else{
                                    for i in 0...PinyinFormat(ipa).count-1{
                                        pinyinStr = pinyinStr + PinyinFormat(ipa)[i]
                                    }
                                }
                            }else {
                                if pinyin.hasSuffix(" ") {
                                    pinyin = pinyin.substring(to: pinyin.length - 1)
                                }
                                pinyinStr = pinyinStr + token.NativeText!
                            }
                            pinyin = pinyin.appending("\(pinyinStr)\(" ")")
                        }
                        //注意改回去
                        var audioURL = ""
                        if let audioUrl = self.sentenceDict.TextDictionary?[chatTurn.Question!]?.AudioUrl {
                            audioURL = audioUrl
                        }else {
                            audioURL = "https://mtutordev.blob.core.chinacloudapi.cn/system-audio/lesson/zh-CN/zh-CN/0342b5aff1e19bfaaa604e265278e317.mp3"
                        }
                        let modelAnswer = PractiseMessageModel(question:chatTurn.Question!,english: chatTurn.NativeQuestion!, chinese: chinese, pinyin: pinyin, audiourl: audioURL, userAudio: NSURL(string: "")!, score: 0, tokens:chatTurn.Tokens!)
                        summaryLessonArray.append(modelAnswer)
                    }
                }
            }
            
            if i < self.scenarioLessonTurnArray.count {
                let chatTurnRight = self.scenarioLessonTurnArray[i]
                if (chatTurnRight.AnswerOptions?.count)! > 0 {
                    for detail in chatTurnRight.AnswerOptions![0].HintDetails! {
                        var contains = false
                        for hint in self.hintTurnArray {
                            if detail.Text ==  hint.Text {
                                contains = true
                                break
                            }
                        }
                        if contains == false {
                            self.hintTurnArray.append(detail)
                        }
                    }
                }
                if chatTurnRight.Tokens?.count != 0 {
                    var pinyin:String = ""
                    var chinese:String = ""
                    if (chatTurnRight.Tokens?.count)! > 0 {
                        //FIXME: - : 怎么判断是纯英文的？tokens 为空
                        for token in chatTurnRight.Tokens! {
                            chinese = chinese.appending(token.Text!)
                            var ipa = ""
                            var pinyinStr = ""//是一个数组，需要拼接
                            if(token.IPA != nil && token.IPA != ""){//不是标点或者特殊的符号
                                ipa = token.IPA!
                                if(PinyinFormat(ipa).count == 1){
                                    pinyinStr = PinyinFormat(ipa)[0]
                                }else{
                                    for i in 0...PinyinFormat(ipa).count-1{
                                        pinyinStr = pinyinStr + PinyinFormat(ipa)[i]
                                    }
                                }
                            }else {
                                if pinyin.hasSuffix(" ") {
                                    pinyin = pinyin.substring(to: pinyin.length - 1)
                                }
                                pinyinStr = pinyinStr + token.NativeText!
                            }
                            pinyin = pinyin.appending("\(pinyinStr)\(" ")")
                        }
                        //注意改回去
                        var audioURL = ""
                        if let audioUrl = self.sentenceDict.TextDictionary?[chatTurnRight.Question!]?.AudioUrl {
                            audioURL = audioUrl
                        }else {
                            audioURL = "https://mtutordev.blob.core.chinacloudapi.cn/system-audio/lesson/zh-CN/zh-CN/0342b5aff1e19bfaaa604e265278e317.mp3"
                        }
                        let modelAnswer = PractiseMessageModel(question:chatTurnRight.Question!,english: chatTurnRight.NativeQuestion!, chinese: chinese, pinyin: pinyin, audiourl: audioURL, userAudio: NSURL(string: "")!, score: 0, tokens:chatTurnRight.Tokens!)
                        summaryLessonArray.append(modelAnswer)
                    }
                }
            }
            i += 1
        }
        tableView.reloadData()
    }
    
    
    @objc func closeTapped() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func doneClick(_ sender: Any) {
        self.HiddenJZStatusBar(alpha: 0)
        let vc = PractiseIntroViewController()
        //做过的再做不刷新土地状态和阳光值
        vc.refreshLand = false
        vc.TurnType = 0
        vc.courseId = courseId
        vc.score = CourseManager.shared.getCourseScore(courseId)
        let nav = UINavigationController(rootViewController: vc)
        nav.hidesBottomBarWhenPushed = true
        nav.modalTransitionStyle = .crossDissolve
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: false) {
            var viewControllers = self.navigationController?.viewControllers
            viewControllers?.removeLast()
            self.navigationController?.viewControllers = viewControllers!
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
                
                footer.headerTitle.text = "Key Words"
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
            
            header.headerTitle.text = "Sentences"
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
            let englishheight = getLabelheight(labelStr: chat.english, font: FontUtil.getFont(size: FontAdjust().FontSize(Double(14)), type: .Regular))
            return englishheight + 49 + 35
        }else {
            return 40
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: LandDetailTableViewCell.identifier) as! LandDetailTableViewCell
            let chat = self.summaryLessonArray[indexPath.row]
            cell.chinese.adjustsFontSizeToFitWidth = true
            cell.chinese.numberOfLines = 1
            cell.setContent(msg: chat)
            cell.selectionStyle = .none
            cell.line.isHidden = false
            cell.bgView.layer.mask = nil
            cell.exView.isHidden = false
            cell.chinese.adjustsFontSizeToFitWidth = true
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
                maskLayer.borderColor = UIColor.hex(hex: "F5FAFF").cgColor
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
        let labelWidth = ScreenUtils.width - 94
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
