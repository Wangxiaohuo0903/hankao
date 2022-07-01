//
//  BasePrictiseChatViewController.swift
//  PracticeChinese
//
//  Created by 费跃 on 9/5/17.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class BasePrictiseChatViewController: UIViewController,SettingViewDelegate {
    func superViewConstraints() {
        reloadView()
    }
    
    
    var goodRemarks = [ "Impressive!", "Good job!", "Well done!", "Nice job!", "Great job!"]
    var commonRemarks = [ "Oops, try again!", "You can do better!", "Almost there!", "So close...", "Keep trying!"]
    var perfectRemarks = ["Excellent!", "Fabulous!", "Awesome!", "Fantastic!", "You are the best!"]
    
    //quit control
    var quitIsPresent = false
    var shouldPresentGuide = false

    //data for chat
    var repeatLesson: ReadAfterMeLesson!
    var scenarioLesson: ScenarioLesson!
    
    //index for chat
    var currentIndex = 0
    var bubbleCanAnimate: Bool = false
    var bubbleCanPlayAudio: Bool = false

    // player for controlling audios in session
    var audioPlayer: AVPlayer!
    var nextButton: UIButton!
    var hintButton: UIButton!
    
    var tableView: UITableView!
    var tableHeight:CGFloat = 0
    // action view in the bottom
    var speakView: SpeakActionView!
    // recording View
    var recordView: LCRecordingView!
    var recordViewBg: UIView!
    //Chat Messages
    var msgList = [ChatMessageModel]()
    
    var userAvatar:String = ""
    var teacherAvatar:String = ""
    var cellHeight = [CGFloat]()
    
    //专为log准备
    var logId = ""
    var Scope = ""
    var indexPathStr = ""
    var Subscope = ""
    
    //是否正在打分
    var makingScore = false
    //打分结果
    var scoreResult = false
    var currentScore = 0.0
    var showMask = true

    var shouldShowWithTransform = false {
        didSet {
            if shouldShowWithTransform {
                var footerHeight = self.ch_getNavigationBarHeight() + 10
                
                if (AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax) {
                    footerHeight += self.ch_getTabBarHeight()
                }
                
                self.tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
                let footerView  = UIView(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width , height: footerHeight))
                footerView.backgroundColor = UIColor.white
                tableView.tableFooterView = footerView
                
                let headerView  = UIView(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: 95))
                headerView.backgroundColor = UIColor.white
                tableView.tableHeaderView = headerView
            }
            else {
                var topHeight = self.ch_getNavigationBarHeight()
                if (AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax) {
                    topHeight += ch_getStatusBarHeight()
                }
                self.tableView.transform = CGAffineTransform(scaleX: 1, y: 1)
                let footerView  = UIView(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: 95))
                footerView.backgroundColor = UIColor.white
                tableView.tableFooterView = footerView
                
                let headerView  = UIView(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: 10))
                headerView.backgroundColor = UIColor.white
                tableView.tableHeaderView = headerView
            }
            
        }
    }
    
    var shouldShowHint = false {
        didSet {
            if shouldShowHint {
                self.hintButton.setBackgroundImage(ChImageAssets.PointYellow.image, for: .normal)
                self.hintButton.isUserInteractionEnabled = true
            }
            else {
                self.hintButton.setBackgroundImage(ChImageAssets.PointGray.image, for: .normal)
                self.hintButton.isUserInteractionEnabled = false
            }
        }
    }
    
    var shouldCanRecord = false {
        didSet {
            if shouldCanRecord {
                self.recordView.startButton.setImage(ChImageAssets.MicrophoneBlue.image, for: .normal)
                self.recordView.stop()
                self.recordView.startButton.isEnabled = true
            }
            else {
                self.recordView.startButton.isEnabled = false
                self.recordView.startButton.setImage(ChImageAssets.MicrophoneGray.image, for: .normal)
                self.recordView.stop()
            }
            
        }
    }
    
    var willAppear = false
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override var prefersStatusBarHidden: Bool {
        return willAppear
    }
    
    func reloadView() {
        let tableViewHeight = getTableContentHeight()
        self.tableView.reloadData()
    }
    
    func getTableContentHeight() -> CGFloat {
        var result:CGFloat = 0
        cellHeight.removeAll()
        for msg in self.msgList {
            let cardMaxWidth = AdjustGlobal().CurrentScaleWidth - 60
            switch msg.type {
            case ChatMessageType.audiotext:
                if msg.position == .right {
                    var enFont = FontUtil.getFont(size: 20, type: .Regular)
                    if(AdjustGlobal().CurrentScale == AdjustScale.iPhone4 || AdjustGlobal().CurrentScale == AdjustScale.iPhone5){
                        enFont = FontUtil.getFont(size: 16, type: .Regular)
                    }
                    var mTextHeight = msg.en.string.height(withConstrainedWidth: cardMaxWidth , font: enFont)
                    if(AdjustGlobal().CurrentScale == AdjustScale.iPhone4 || AdjustGlobal().CurrentScale == AdjustScale.iPhone5){
                        mTextHeight += 60
                    }else {
                        mTextHeight += 60
                    }
                    cellHeight.append(mTextHeight)
                }else{
                    let en = msg.en
                    let textArray = msg.textArray
                    var enFont = FontUtil.getFont(size: 14, type: .Regular)
                    if(AdjustGlobal().CurrentScale == AdjustScale.iPhone4 || AdjustGlobal().CurrentScale == AdjustScale.iPhone5){
                        enFont = FontUtil.getFont(size: 13, type: .Regular)
                    }
                    var mTextHeight = msg.en.string.height(withConstrainedWidth: cardMaxWidth , font: enFont)
                    var chineseSize = Double(30)
                    var pinyinSize = Double(16)
                    let chineseandpinyinLabel = SpeakTokensView(frame: CGRect(x: 30, y: 50, width: cardMaxWidth, height: 150), tokens: textArray, chineseSize: chineseSize, pinyinSize: pinyinSize, style: .chineseandpinyin, changeAble: true,showIpa:false,scope: self.Scope,cColor:UIColor.black,pColor:UIColor.black,scoreRight:false,true)
                    chineseandpinyinLabel.setData()
                    
                    let getHeight = chineseandpinyinLabel.getViewHeight()
                    if(AdjustGlobal().CurrentScale == AdjustScale.iPhone4 || AdjustGlobal().CurrentScale == AdjustScale.iPhone5){
                        mTextHeight += getHeight + 60
                    }else {
                        mTextHeight += getHeight + 60
                    }
                    cellHeight.append(mTextHeight)
                }
            default:
                let mTextHeight = msg.text.string.height(withConstrainedWidth: cardMaxWidth, font: FontUtil.getTextFont()) + 10
                result += mTextHeight
            }
        }
        return result
    }
    
    func getLabelWidth(labelStr:String,font:UIFont)->CGFloat{
        
        var indexLabelHeight:CGFloat = 14
        if(AdjustGlobal().CurrentScale == AdjustScale.iPad){
            indexLabelHeight = 18
        }
        let maxSie:CGSize = CGSize(width:self.view.frame.width,height:indexLabelHeight)
        return (labelStr as NSString).boundingRect(with: maxSie, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):font]), context: nil).size.width
    }
    
    func getRemarkByScore(score:Int) -> String {
        var candidates = [String]()
        if score > 90 {
            candidates = perfectRemarks
        }
        else if score < 60 {
            candidates = commonRemarks
        }
        else {
            candidates = goodRemarks
        }
        let i = Int(arc4random_uniform(100)) % candidates.count
        return candidates[i]
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
    
        navigationController?.navigationBar.isTranslucent = true
        
        //制作毛玻璃效果
        var navHeight = self.ch_getNavigationBarHeight()
        if (AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax) {
            navHeight += ch_getStatusBarHeight()
        }
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.fromColor(color: UIColor.init(white: 1, alpha: 0.3)), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        if let url = UserManager.shared.getAvatarUrl() {
            self.userAvatar = url.absoluteString
        }
        var bottomHeight = 110.0
        if (AdjustGlobal().CurrentScale == AdjustScale.iPhone4 || AdjustGlobal().CurrentScale == AdjustScale.iPhone5) {
            bottomHeight = 85.0
        }

        tableHeight = ScreenUtils.height - CGFloat(bottomHeight) - CGFloat(self.ch_getStatusNavigationHeight())

        
        // add dialogue table
        tableView = UITableView(frame: CGRect(x: 0, y: self.ch_getStatusNavigationHeight(), width: ScreenUtils.width, height: tableHeight), style: .grouped)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        tableView.showsVerticalScrollIndicator = false
        tableView.isScrollEnabled = false
        tableView.register(PractiseRightCell.self, forCellReuseIdentifier: PractiseRightCell.identifier)

        tableView.register(TextBubbleCell.self, forCellReuseIdentifier: TextBubbleCell.identifier)
        tableView.register(AudioBubbleCell.self, forCellReuseIdentifier: AudioBubbleCell.identifier)
        tableView.register(PractiseLeftCell.self, forCellReuseIdentifier: PractiseLeftCell.identifier)
        tableView.register(TextTipCell.self, forCellReuseIdentifier: TextTipCell.identifier)
        tableView.register(InputViewCell.self, forCellReuseIdentifier: InputViewCell.identifier)
        tableView.register(PictureBubbleCell.self, forCellReuseIdentifier: PictureBubbleCell.identifier)
        self.view.addSubview(tableView)
        self.view.sendSubviewToBack(tableView)

        let recordViewY = ScreenUtils.height - CGFloat(bottomHeight)

        recordViewBg = UIView(frame: CGRect(x: CGFloat(0.0), y: recordViewY, width: ScreenUtils.width, height: CGFloat(bottomHeight)))
        recordViewBg.isUserInteractionEnabled = false
        self.view.addSubview(recordViewBg)
        
        recordView = LCRecordingView(frame: CGRect(x: 0, y: CGFloat(recordViewY), width: ScreenUtils.width, height: CGFloat(bottomHeight)))

        self.gradientColor(gradientView: recordViewBg, frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: 125), upTodown: true)
        let nextWidth = CGFloat(56)
        nextButton = UIButton(frame: CGRect(x: recordView.frame.maxX - 100 , y: self.recordView.frame.height/2 - nextWidth/2, width: nextWidth, height: nextWidth))
        nextButton.setBackgroundImage(ChImageAssets.NextChat.image, for: .normal)
        nextButton.addTarget(self, action: #selector(clickNext), for: .touchUpInside)
        recordView.addSubview(nextButton)
        recordView.isUserInteractionEnabled = true
        self.view.addSubview(recordView)
        self.reloadView()
    }

    func moreTapped() {
        self.quitIsPresent = true
        LCVoiceButton.stopGlobal()
        let view = SettingView(frame: CGRect.zero)
        UIApplication.shared.keyWindow!.addSubview(view)
        view.delegate = self
        view.snp.makeConstraints { (make) -> Void in
            make.left.right.top.bottom.equalTo(UIApplication.shared.keyWindow!)
        }
        view.Scope = Scope
        view.Lessonid = logId
        view.IndexPath = indexPathStr
        view.Subscope = Subscope
    }
    
    @objc func clickNext() {
        self.nextButton.isEnabled = false
        UIView.animate(withDuration: 0.5) {
            self.nextButton.isEnabled = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //hide status bar
        willAppear = true
        UIView.animate(withDuration: 0.2) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
            
    }
    
    @objc dynamic func closeTapped() {
        self.quitIsPresent = true
        LCVoiceButton.stopGlobal()
        LCAlertView.show(title: "Quit This Session", message: "Are you sure you want to quit? All progress in the session will be lost.", leftTitle: "Quit", rightTitle: "Cancel", style: .center, leftAction: {
            LCAlertView.hide()
            //埋点：点击左上角关闭
            var info = ["Scope" : self.Scope,"Lessonid" : self.logId,"Subscope" : self.Subscope,"IndexPath" : self.indexPathStr,"Event" : "Quit","Value" : "Apply"]
            if self.Subscope == "" {
                info = ["Scope" : self.Scope,"Lessonid" : self.logId,"IndexPath" : self.indexPathStr,"Event" : "Quit","Value" : "Apply"]
            }
            UserManager.shared.logUserClickInfo(info)
            self.navigationController?.dismiss(animated: true, completion: nil)
        }, rightAction: {LCAlertView.hide()
            self.quitIsPresent = false
            self.closeCancelEvent()
            //埋点：点击左上角关闭
            var info = ["Scope" : self.Scope,"Lessonid" : self.logId,"Subscope" : self.Subscope,"IndexPath" : self.indexPathStr,"Event" : "Quit","Value" : "Cancel"]
            if self.Subscope == "" {
                info = ["Scope" : self.Scope,"Lessonid" : self.logId,"IndexPath" : self.indexPathStr,"Event" : "Quit","Value" : "Cancel"]
            }
            UserManager.shared.logUserClickInfo(info)
        })
    }
    
    func closeCancelEvent(){
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.msgList.removeAll()
        self.reloadView()
        self.recordView.removeRecordObserver()
        LCVoiceButton.stopGlobal()
    }
    
    func showHints() {
    }
    
    func showBeginnerGuide() {
        
    }
    
}

extension BasePrictiseChatViewController: UITableViewDataSource, UITableViewDelegate, LCVoiceButtonDelegate {
    
    @objc dynamic func buttonPlayStop() {
        self.shouldCanRecord = true
        self.showBeginnerGuide()

    }
    func buttonPlayStart(){
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.msgList.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = self.shouldShowWithTransform ? (self.msgList.count - indexPath.section - 1) : indexPath.section
        let msg = self.msgList[index]
        //当前的最后一个cell
        let lastmsg = self.msgList.last
        var maskPosition = 0
        if lastmsg?.position == .left {
            maskPosition = 0
        }else {
            maskPosition = 1
        }
        
        switch msg.type {
        case ChatMessageType.audiotext:
            if msg.position == .left {
                //对话左侧，带文字
                let cell = tableView.dequeueReusableCell(withIdentifier: PractiseLeftCell.identifier, for: indexPath) as! PractiseLeftCell
                cell.Scope = self.Scope
                cell.Lessonid = self.logId
                cell.indexPathStr = indexPathStr
                cell.setContent(msg: msg)

                if (self.msgList[0].type == .audiotext) && self.bubbleCanPlayAudio {
                    cell.audioButton.play()
                    self.bubbleCanPlayAudio = false
                }
                if showMask && maskPosition == 0 {
                    cell.disabled = true
                }else {
                    cell.disabled = false
                }
                cell.audioButton.delegate = self
                cell.transform = tableView.transform
                cell.backgroundColor = UIColor.white
                return cell

            }
            else {
                //对话右侧
                let cell = tableView.dequeueReusableCell(withIdentifier: PractiseRightCell.identifier, for: indexPath) as! PractiseRightCell
                cell.backgroundColor = UIColor.white
                cell.transform = tableView.transform
                cell.Scope = self.Scope
                cell.Lessonid = self.logId
                cell.indexPathStr = indexPathStr
                cell.setContent(msg: msg)
                cell.startMakingScore(start: makingScore)
                cell.showScoreResult(show: scoreResult, score: CGFloat(currentScore))
                if showMask && maskPosition == 1 {
                    cell.disabled = true
                }else {
                    cell.disabled = false
                }
                return cell
            }
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: TextTipCell.identifier, for: indexPath) as! TextTipCell
            cell.setContent(msg: msg, image: nil)
            cell.transform = tableView.transform
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        var allCellHeight = CGFloat()
        var bigger = false
        for (index,height) in cellHeight.enumerated() {
            allCellHeight += height
            if height > tableHeight/2 {
                bigger = true
            }
        }
        if bigger {
            if section == 0 {
                return  (tableHeight - CGFloat(allCellHeight)) / 3
            }else {
                return  (tableHeight - CGFloat(allCellHeight)) / 6
            }
        }
        if allCellHeight > tableHeight {
            return 0.1
        }
        var headerHeight = CGFloat(0.0)
        if section == 0 {
            headerHeight = (tableHeight - CGFloat(allCellHeight)) / 3
        }else {
            headerHeight = tableHeight/2 - cellHeight.last! - (tableHeight - CGFloat(allCellHeight)) / 3
        }
        if headerHeight < 0.0 {
            return 0.0
        }
        return headerHeight

    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

        var allCellHeight = CGFloat()
        var bigger = false
        for height in cellHeight {
            allCellHeight += height
            if height > tableHeight/2 {
                bigger = true
            }
        }
        if bigger {
            if section == 0 {
                return  (tableHeight - CGFloat(allCellHeight)) / 6
            }else {
                return  (tableHeight - CGFloat(allCellHeight)) / 3
            }
        }
        if allCellHeight > tableHeight {
            return 0.1
        }
        var footerHeight = CGFloat(0.0)
        if section == 1 {
            footerHeight = (tableHeight - CGFloat(allCellHeight)) / 3
        }else {
            footerHeight = tableHeight/2 - cellHeight.first! - (tableHeight - CGFloat(allCellHeight)) / 3
        }
        if footerHeight < 0.0 {
            return 0.0
        }
        return footerHeight
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight[indexPath.section]
        
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
