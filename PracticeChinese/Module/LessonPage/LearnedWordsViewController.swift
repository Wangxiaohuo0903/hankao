//
//  LearnedWordsViewController.swift
//  PracticeChinese
//
//  Created by ThomasXu on 20/06/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class LearnedWordsViewController: UIViewController {
    
    var backView: UIView!
    var words = [learnedItemResult]()
//    var wordMap = [String: Token]()
    var wordDict = [(String, [(String, learnedItemResult)])]() {
        didSet {
            self.wordTable.reloadData()
        }
    }
    var wordTable: UITableView!
    var scenarioLessons: [GetScenarioLessonResult?]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.groupTableViewBackground

        if(AppData.userAssessmentEnabled){
            setUpview()
        }else{
            LCAlertView.show(title: String.PrivacyTitle, message: String.PrivacyConsent, leftTitle: "Don't Allow", rightTitle: "Allow", style: .center, leftAction: {
                LCAlertView.hide()
            }, rightAction: {
                LCAlertView.hide()
                AppData.setUserAssessment(true)
                CourseManager.shared.GetScenarioLearnedItem(completion: { (data, error) in
                    self.setUpview()
                })
            })
        }
        
    }
    
    func setUpview(){
        self.setSubviews()
        self.reloadData()
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)//加上这一句消除tableview头部的空白
        
        backView = setUpEmptyView()
        self.view.addSubview(backView)
        
        if(words.count == 0){
            backView.isHidden = false
        }else{
            backView.isHidden = true
        }
    }
    
    func setUpEmptyView()->UIView{
        let backView = UIView(frame: wordTable.frame)
        let owl = UIImageView(frame: CGRect(x: wordTable.frame.width*3/8, y: wordTable.frame.height*1/3, width: wordTable.frame.width/4, height: wordTable.frame.width/4))
        owl.image = UIImage(named: "owl")
        backView.addSubview(owl)
        let titleFont = FontUtil.getFont(size: 18, type: .Regular)
        let titleLabel = UILabel(frame: CGRect(x: 0, y: owl.frame.maxY + 10, width: wordTable.frame.width, height: titleFont.lineHeight))
        titleLabel.text = "No Words Learned"
        titleLabel.textColor = UIColor.hex(hex: "666666")
        titleLabel.textAlignment = .center
        titleLabel.font = titleFont
        let wordFont = FontUtil.getFont(size: 14, type: .Regular)
        let wordLabel = UILabel(frame: CGRect(x: 0, y: titleLabel.frame.maxY, width: wordTable.frame.width, height: wordFont.lineHeight))
        wordLabel.text = "Words you learned will appear here."
        wordLabel.textColor = UIColor.hex(hex: "BBBDBF")
        wordLabel.textAlignment = .center
        wordLabel.font = wordFont
        backView.addSubview(wordLabel)
        backView.addSubview(titleLabel)
        return backView
    }

    func reloadData() {
        self.words = CourseManager.shared.getLearnedWordMapList()
        var tempWords = [(String, learnedItemResult)]()
        for word in self.words {
            var ipa = ""
            if word.IPA != nil {
                ipa = word.IPA!
            }
            tempWords.append((ipa, word))
        }
        self.wordDict = self.getWordDict(items: tempWords)
    }
    func setSubviews() {
        
        var tableHeight = ScreenUtils.height - 64
        if AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax {
            tableHeight = ScreenUtils.height - 44 - 34
        }
        self.wordTable = UITableView(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: tableHeight), style: .grouped)
        self.wordTable.backgroundColor = UIColor.groupTableViewBackground
        self.wordTable.rowHeight = 60
        self.wordTable.register(LearnedWordCellCell.nibObject, forCellReuseIdentifier: LearnedWordCellCell.identifier)
        self.wordTable.delegate = self
        self.wordTable.dataSource = self
        self.wordTable.sectionHeaderHeight = 10
        self.wordTable.showsVerticalScrollIndicator = false
        self.view.addSubview(self.wordTable)
        NotificationCenter.default.addObserver(self, selector: #selector(updateLessons), name: ChNotifications.FinishOneLesson.notification, object: nil)
        self.updateLessons()
    }
    
    @objc func updateLessons() {
        //  self.scenarioLessons = CourseManager.shared.finishedLessons
    }
    
    override var hidesBottomBarWhenPushed: Bool {
        get { return true }
        set { super.hidesBottomBarWhenPushed = newValue }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "My Words"
        self.navigationController?.navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary(self.ch_getTitleAttribute(textColor: UIColor.white))// temp
        //设置回退按钮为白色
        self.navigationController?.navigationBar.tintColor = UIColor.white
        //隐藏底部 tab 栏
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.fromColor(color: UIColor.blueTheme), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    //根据所有拼音的首字母，将拼音进行分组，具有相同的首字母的拼音被分为一组
    func getWordDict(items: [(String, learnedItemResult)]) -> [(String, [(String, learnedItemResult)])] {
        var dict = Array<Array<(String, learnedItemResult)>>(repeating: Array<(String, learnedItemResult)>(), count: 26)
        for item in items {
            let word = item.0
            
            if word.characters.count <= 0 {
                continue
            }
            let first = word.unicodeScalars.first!
            var index: UInt32 = 0
            if first.value >= UnicodeScalar("a")!.value && first.value <= UnicodeScalar("z")!.value {
                index = first.value - UnicodeScalar("a")!.value
            } else {
                index = first.value - UnicodeScalar("A")!.value
            }
            dict[Int(index)].append(item)
        }
        var arr = [(String, [(String, learnedItemResult)])]()
        for (index, words) in dict.enumerated() {
            if (words.count > 0) {
                let keyValue = Int(UnicodeScalar("A")!.value) + index
                let key = Character(UnicodeScalar(keyValue)!)
                arr.append((String(key), words))
            }
        }
        return arr
    }
}


extension LearnedWordsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.wordDict.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let wrapper = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        let view = UILabel(frame: CGRect(x: ScreenUtils.widthBySix(x: 38), y: 0, width: wrapper.frame.width, height: wrapper.frame.height))
        wrapper.addSubview(view)
        view.textColor = UIColor.blueTheme
        view.text = self.wordDict[section].0
        view.font = FontUtil.getFont(size: 18, type: .Regular)
        return wrapper
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.wordDict[section].1.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ScreenUtils.heightByM(y: 60)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LearnedWordCellCell.identifier) as! LearnedWordCellCell
        cell.backgroundColor = UIColor.white
        let item = self.wordDict[indexPath.section].1[indexPath.row].1
        cell.pinyn.text = PinyinFormat(self.wordDict[indexPath.section].1[indexPath.row].0).joined(separator: " ")
        cell.name.text = item.Text
        cell.nativeName.text = item.NativeText
        
        let nameW = CGFloat((cell.name.text?.boundingRect(with: CGSize(width:self.view.frame.width,height:.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(17), type: .Regular)]), context: nil).width)!) + 6
        let pinyinW = CGFloat((cell.pinyn.text?.boundingRect(with: CGSize(width:self.view.frame.width,height:.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):FontUtil.getFont(size: FontAdjust().FontSize(17), type: .Regular)]), context: nil).width)!) + 6
        
        cell.name.frame = CGRect(x: 15.0, y: 0, width: nameW, height: ScreenUtils.heightByM(y: 60))
        cell.pinyn.frame = CGRect(x: cell.name.frame.maxX + 10.0, y: 0, width: pinyinW, height: ScreenUtils.heightByM(y: 60))
        cell.nativeName.frame = CGRect(x: cell.pinyn.frame.maxX + 15.0, y: 0, width: self.view.bounds.size.width - nameW - pinyinW - 60.0, height: ScreenUtils.heightByM(y: 60))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.wordTable.deselectRow(at: indexPath, animated: true)
        return
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
