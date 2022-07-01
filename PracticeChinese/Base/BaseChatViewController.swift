//
//  BaseChatViewController.swift
//  PracticeChinese
//
//  Created by 费跃 on 9/5/17.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class BaseChatViewController: UIViewController,SettingViewDelegate {
    func superViewConstraints() {
        reloadViewAndCellheight()
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
    var cellIndent = [CGFloat]()
    var visualEffectView : UIVisualEffectView!
    var backButton:UIButton!
    //专为log准备
    var logId = ""
    var Scope = ""
    var indexPathStr = ""
    var Subscope = ""
//    var CurrentChatpage = ""//speak，Scenario，Conversation Challenge
    
    var shouldShowWithTransform = false {
        didSet {
            if shouldShowWithTransform {
                //
                var footerHeight = self.ch_getNavigationBarHeight() + 10
                
                if (AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax) {
                    footerHeight += self.ch_getTabBarHeight()
                }
                
                self.tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
                let footerView  = UIView(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width - 20, height: footerHeight))
                footerView.backgroundColor = UIColor.white
                tableView.tableFooterView = footerView
                
                let headerView  = UIView(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width - 20, height: 95))
                headerView.backgroundColor = UIColor.white
                tableView.tableHeaderView = headerView
            }
            else {
                var topHeight = self.ch_getNavigationBarHeight()
                if (AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax) {
                    topHeight += ch_getStatusBarHeight()
                }
                self.tableView.transform = CGAffineTransform(scaleX: 1, y: 1)
                let footerView  = UIView(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width - 20, height: 95))
                footerView.backgroundColor = UIColor.white
                tableView.tableFooterView = footerView
                
                let headerView  = UIView(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width - 20, height: 10))
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
//                UIView.animate(withDuration: 1) {
                    if !self.nextButton.isHidden {
                        //右下角有next按钮的时候，中间这个大的就是repeat
                        self.recordView.startButton.setImage(ChImageAssets.MicrophoneRepeat.image, for: .normal)
                        self.recordView.stop()
                    }else {
                        self.recordView.startButton.setImage(ChImageAssets.MicrophoneBlue.image, for: .normal)

                        self.recordView.stop()
                    }
//                }
                self.recordView.startButton.isEnabled = true
            }
            else {
                self.recordView.startButton.isEnabled = false
                self.recordView.startButton.setImage(ChImageAssets.MicrophoneGray.image, for: .normal)
                self.recordView.startButton.setImage(ChImageAssets.MicrophoneGray.image, for: .disabled)
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
        
        let tableContentHeight = getTableContentHeight()
//        //是否需要反转列表
        var tableViewContentHeight = ScreenUtils.height - self.ch_getNavigationBarHeight() - 95 - 10
        
        if self.ch_getStatusBarHeight() != 20 {
            tableViewContentHeight -=  self.ch_getStatusBarHeight()
        }
        
        shouldShowWithTransform = tableContentHeight > tableViewContentHeight
        self.tableView.reloadData()
        if self.shouldShowWithTransform {
            self.tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .bottom, animated: false)
        }
    }
    func reloadViewAndCellheight() {
        let tableContentHeight = getTableContentHeightAndRefreshView()
        //        //是否需要反转列表
        var tableViewContentHeight = ScreenUtils.height - self.ch_getNavigationBarHeight() - 95 - 10
        
        if self.ch_getStatusBarHeight() != 20 {
            tableViewContentHeight -=  self.ch_getStatusBarHeight()
        }
        
        shouldShowWithTransform = tableContentHeight > tableViewContentHeight
        self.tableView.reloadData()
        if self.shouldShowWithTransform {
            self.tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .bottom, animated: false)
        }
    }
    func getTableContentHeight() -> CGFloat {
        var result:CGFloat = 0
        cellHeight.removeAll()
        cellIndent.removeAll()
        var lastMsg:ChatMessageModel!

        for (i, msg) in self.msgList.enumerated() {
            if (i > 0) {
                if (msg.position != lastMsg.position) || (lastMsg.type == .tip && msg.type != .tip) || (msg.type == .tip && lastMsg.type != .tip) {
                    self.cellIndent.append(20)
                }
                else {
                    self.cellIndent.append(10)
                }
            }
            lastMsg = msg

            switch msg.type {
            case ChatMessageType.picture:
                cellHeight.append(CGFloat(msg.CellHeight))
                result += CGFloat(msg.CellHeight)
                
            case ChatMessageType.text:
                cellHeight.append(CGFloat(msg.CellHeight))
                result += CGFloat(msg.CellHeight)
            case ChatMessageType.audio:
                    cellHeight.append(CGFloat(msg.CellHeight))
                    result += CGFloat(msg.CellHeight)
            case ChatMessageType.audiotext:

                cellHeight.append(CGFloat(msg.CellHeight))
                result += CGFloat(msg.CellHeight)
            default:
                cellHeight.append(CGFloat(msg.CellHeight))
                result += CGFloat(msg.CellHeight)
            }
        }
        self.cellIndent.append(0)
        result += self.cellIndent.reduce(0, +)

        return result
    }
    
    //重新计算高度
    func getTableContentHeightAndRefreshView() -> CGFloat {
        var result:CGFloat = 0
        cellHeight.removeAll()
        cellIndent.removeAll()
        var lastMsg:ChatMessageModel!
        
        for (i, msg) in self.msgList.enumerated() {
            if (i > 0) {
                if (msg.position != lastMsg.position) || (lastMsg.type == .tip && msg.type != .tip) || (msg.type == .tip && lastMsg.type != .tip) {
                    self.cellIndent.append(20)
                }
                else {
                    self.cellIndent.append(10)
                }
            }
            lastMsg = msg
            
            switch msg.type {
            case ChatMessageType.picture:
                cellHeight.append(CGFloat(msg.CellHeight))
                result += CGFloat(msg.CellHeight)
                
            case ChatMessageType.text:
                cellHeight.append(CGFloat(msg.CellHeight))
                result += CGFloat(msg.CellHeight)
            case ChatMessageType.audio:
                cellHeight.append(CGFloat(msg.CellHeight))
                result += CGFloat(msg.CellHeight)
            case ChatMessageType.audiotext:
                var mTextHeight = CGFloat(0.0)

                if msg.position == .right {
                    let en = msg.en
                    let textArray = msg.textArray
                    mTextHeight = 0
                    let buttonsViewHeight:CGFloat = 43
                    mTextHeight += buttonsViewHeight

                    let cardMaxWidth = AdjustGlobal().CurrentScaleWidth - 70 - 26 - 20

                    let enHeight = en.string.height(withConstrainedWidth: cardMaxWidth, font: FontUtil.getDescFont()) + 2
                    var indexLabelWidth:CGFloat = 0

                    if msg.index != "" {
                        let indexFont = FontUtil.getFont(size: FontAdjust().FontSize(11), type: .Regular)
                        indexLabelWidth = getLabelWidth(labelStr: msg.index, font: indexFont)+6
                    }else{
                        let indexFont = FontUtil.getFont(size: FontAdjust().FontSize(11), type: .Regular)
                        let string  = "Reference Answer"
                        indexLabelWidth = getLabelWidth(labelStr: string, font: indexFont)+8
                    }

                    let chineseandpinyinLabel = SpeakTokensView(frame: CGRect(x: 13, y: 0, width: cardMaxWidth, height: 150), tokens: textArray, chineseSize: FontAdjust().Speak_ChineseAndPinyin_C(), pinyinSize: FontAdjust().Speak_ChineseAndPinyin_P(), style: .chineseandpinyin, changeAble: true,showIpa:false,scope: self.Scope,cColor:UIColor.black,pColor:UIColor.lightText,scoreRight:false)
                    chineseandpinyinLabel.setData()
                    let getHeight = chineseandpinyinLabel.getViewHeight()
                    mTextHeight += getHeight + enHeight + 15

                }else{
                    let indexPath = NSIndexPath(row: 0, section: i)
                    let en = msg.en
                    let textArray = msg.textArray
                    mTextHeight = 0
                    var buttonsViewHeight:CGFloat = 36

                    mTextHeight += buttonsViewHeight

                    var cardMaxWidth = AdjustGlobal().CurrentScaleWidth - 70 - 26 - 20

                    let enHeight = en.string.height(withConstrainedWidth: cardMaxWidth, font: FontUtil.getDescFont()) + 2
                    let englishwidth = en.string.wdith(withConstrainedWidth: cardMaxWidth, font: FontUtil.getDescFont()) + 4

                    var indexLabelWidth:CGFloat = 0
                    if msg.index != "" {
                        let indexFont = FontUtil.getFont(size: FontAdjust().FontSize(11), type: .Regular)
                        indexLabelWidth = getLabelWidth(labelStr: msg.index, font: indexFont)+6
                    }else{
                        let indexFont = FontUtil.getFont(size: FontAdjust().FontSize(11), type: .Regular)
                        let string  = "Reference Answer"
                        indexLabelWidth = getLabelWidth(labelStr: string, font: indexFont)+8
                    }

                    //20左右padding+15喇叭weight+20喇叭index间距
                    let cardMinWidth = AdjustGlobal().CurrentScaleWidth*0.3
                    let chineseandpinyinLabel = SpeakTokensView(frame: CGRect(x: 13, y: 0, width: cardMaxWidth, height: 150), tokens: textArray, chineseSize: FontAdjust().Speak_ChineseAndPinyin_C(), pinyinSize: FontAdjust().Speak_ChineseAndPinyin_P(), style: .chineseandpinyin, changeAble: true,showIpa:false,scope: self.Scope,cColor:UIColor.black,pColor:UIColor.lightText,scoreRight:false)
                    chineseandpinyinLabel.setData()

                    let getHeight = chineseandpinyinLabel.getViewHeight()

                    let enWidth = min(cardMaxWidth,max(cardMinWidth,max(englishwidth, chineseandpinyinLabel.getViewWidth())))

                    mTextHeight += getHeight + enHeight + 15
                }
                cellHeight.append(mTextHeight)
                msg.CellHeight = Int(mTextHeight)
                result += mTextHeight
//                cellHeight.append(CGFloat(msg.CellHeight))
//                result += CGFloat(msg.CellHeight)
            default:
                cellHeight.append(CGFloat(msg.CellHeight))
                result += CGFloat(msg.CellHeight)
            }
        }
        self.cellIndent.append(0)
        result += self.cellIndent.reduce(0, +)
        
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
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.fromColor(color: UIColor.init(white: 1, alpha: 0.3)), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        var top = FontAdjust().quitButtonTop()
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
            top = self.ch_getStatusBarHeight()
        }
        backButton = UIButton(frame: CGRect(x: FontAdjust().quitButtonTop(), y: top, width: 40, height: 40))
        backButton.setImage(ChImageAssets.CloseIcon.image, for: .normal)
        backButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        self.navigationController?.view.addSubview(backButton)
        
        let moreButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        moreButton.setImage(ChImageAssets.MoreIconLearn.image, for: .normal)
        moreButton.imageView?.tintColor = UIColor.black
        moreButton.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)
//        moreButton.applyNavBarConstraints(size: (width: 20, height: 20))
        
        self.navigationItem.setRightBarButton(UIBarButtonItem(customView:moreButton), animated: true)
        
        
        
        if let url = UserManager.shared.getAvatarUrl() {
            self.userAvatar = url.absoluteString
        }
        var tableHeight = ScreenUtils.height - self.ch_getNavigationBarHeight()
        if self.ch_getStatusBarHeight() != 20 {
            tableHeight = ScreenUtils.height + self.ch_getNavigationBarHeight() + self.ch_getStatusBarHeight()
        }else {
            tableHeight = ScreenUtils.height + self.ch_getNavigationBarHeight()
        }
        // add dialogue table
        tableView = UITableView(frame: CGRect(x: 9, y: 0, width: ScreenUtils.width - 20, height: tableHeight), style: .grouped)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        tableView.showsVerticalScrollIndicator = false
        tableView.transform = CGAffineTransform(scaleX: 1, y: 1)

        tableView.register(ScoredAudioTextBubbleCell.self, forCellReuseIdentifier: ScoredAudioTextBubbleCell.identifier)
        tableView.register(TextBubbleCell.self, forCellReuseIdentifier: TextBubbleCell.identifier)
        tableView.register(AudioBubbleCell.self, forCellReuseIdentifier: AudioBubbleCell.identifier)
        tableView.register(AudioTextBubbleCell.self, forCellReuseIdentifier: AudioTextBubbleCell.identifier)
        tableView.register(TextTipCell.self, forCellReuseIdentifier: TextTipCell.identifier)
        tableView.register(InputViewCell.self, forCellReuseIdentifier: InputViewCell.identifier)
        tableView.register(PictureBubbleCell.self, forCellReuseIdentifier: PictureBubbleCell.identifier)
        self.view.addSubview(tableView)
        self.view.sendSubviewToBack(tableView)
        var bottomHeight = 110.0
        if (AdjustGlobal().CurrentScale == AdjustScale.iPhone4 || AdjustGlobal().CurrentScale == AdjustScale.iPhone5) {
            bottomHeight = 85.0
        }
        var recordViewY = ScreenUtils.height - CGFloat(bottomHeight)

        recordViewBg = UIView(frame: CGRect(x: CGFloat(0.0), y: recordViewY, width: ScreenUtils.width, height: CGFloat(bottomHeight)))
        recordViewBg.isUserInteractionEnabled = false
        self.view.addSubview(recordViewBg)
        
        recordView = LCRecordingView(frame: CGRect(x: 0, y: CGFloat(recordViewY), width: ScreenUtils.width, height: CGFloat(bottomHeight)))

        self.gradientColor(gradientView: recordViewBg, frame: CGRect(x: 9, y: 0, width: ScreenUtils.width - 18, height: 125), upTodown: true)
        let nextWidth = CGFloat(56)
        nextButton = UIButton(frame: CGRect(x: recordView.frame.maxX - 100 , y: self.recordView.frame.height/2 - nextWidth/2, width: nextWidth, height: nextWidth))
        nextButton.setBackgroundImage(ChImageAssets.NextChat.image, for: .normal)
        nextButton.addTarget(self, action: #selector(clickNext), for: .touchUpInside)
        recordView.addSubview(nextButton)
        recordView.isUserInteractionEnabled = true
        self.view.addSubview(recordView)
        
        let button = self.recordView.startButton!
        let point = button.superview!.convert(button.frame.origin, to: nil)
        
        let hintheight = CGFloat(56)
        let hintwidth = hintheight
        
        var showX = CGFloat(44)
        if(AdjustGlobal().isiPad){
            showX = CGFloat(84)
        }
        let showY = self.recordView.frame.height/2 - hintheight/2
        
        
        hintButton = UIButton(frame: CGRect(x: showX, y: showY, width: hintwidth, height: hintheight))

        hintButton.setBackgroundImage(ChImageAssets.PointGray.image, for: .normal)
        hintButton.addTarget(self, action: #selector(showHints), for: .touchUpInside)
      
        self.shouldShowHint = false
        
        self.recordView.addSubview(hintButton)
        
        self.reloadView()
        
    }


    @objc func moreTapped() {
        self.quitIsPresent = true
        LCVoiceButton.stopGlobal()
        LCVoiceButton.singlePlayer.delegate?.playFinish()
        self.shouldCanRecord = true
        
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
    
    @objc func closeTapped() {
        self.quitIsPresent = true
        LCVoiceButton.stopGlobal()
        LCVoiceButton.singlePlayer.delegate?.playFinish()
        self.shouldCanRecord = true
        
        LCAlertView.show(title: "Quit This Session", message: "Are you sure you want to quit? All progress in the session will be lost.", leftTitle: "Quit", rightTitle: "Cancel", style: .center, leftAction: {
            LCAlertView.hide()
            //埋点：点击左上角关闭
            var info = ["Scope" : self.Scope,"Lessonid" : self.logId,"Subscope" : self.Subscope,"IndexPath" : self.indexPathStr,"Event" : "Quit","Value" : "Apply"]
            if self.Subscope == "" {
                info = ["Scope" : self.Scope,"Lessonid" : self.logId,"IndexPath" : self.indexPathStr,"Event" : "Quit","Value" : "Apply"]
            }
            UserManager.shared.logUserClickInfo(info)
            self.backButton.removeFromSuperview()
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
        LCVoiceButton.singlePlayer.delegate?.playFinish()
    }
    
    @objc func showHints() {
    }
    
    func showBeginnerGuide() {
        
    }
    
}

extension BaseChatViewController: UITableViewDataSource, UITableViewDelegate, LCVoiceButtonDelegate {
    
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
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = self.shouldShowWithTransform ? (self.msgList.count - indexPath.section - 1) : indexPath.section
        let msg = self.msgList[index]
        var shouldHideAvatar = false
        if index > 0 && (self.msgList[index-1].position == msg.position) {
            shouldHideAvatar = true
        }
        switch msg.type {
        case ChatMessageType.picture:
            let cell = tableView.dequeueReusableCell(withIdentifier: PictureBubbleCell.identifier, for: indexPath) as! PictureBubbleCell
            cell.setContent(msg: msg)
            cell.transform = tableView.transform
            return cell
            
        case ChatMessageType.text:
            let cell = tableView.dequeueReusableCell(withIdentifier: TextBubbleCell.identifier, for: indexPath) as! TextBubbleCell
            var showAvatarImage = true
            if index != 0 {
                let lastMsg = self.msgList[index - 1]
                
                if (lastMsg.type == ChatMessageType.text) {
                    showAvatarImage = false
                }else {
                    showAvatarImage = true
                }
            }
            cell.Scope = self.Scope
            cell.Lessonid = self.logId
            cell.indexPathStr = indexPathStr
            cell.setContent(msg: msg,showAvatarImage:showAvatarImage)
            cell.transform = tableView.transform
            return cell
        case ChatMessageType.audio:
            if msg.audioUrl == "" {
                var showAvatarImage = true
                if index != 0 {
                    let lastMsg = self.msgList[index - 1]
                    
                    if (lastMsg.type == ChatMessageType.text && lastMsg.position == .left && msg.position == .left) {
                        showAvatarImage = false
                    }else {
                        showAvatarImage = true
                    }
                }
                let cell = tableView.dequeueReusableCell(withIdentifier: InputViewCell.identifier, for: indexPath) as! InputViewCell
                cell.Scope = self.Scope
                cell.Lessonid = self.logId
                cell.indexPathStr = indexPathStr
                cell.setContent(msg: msg,showAvatarImage:showAvatarImage)
                cell.transform = tableView.transform
                return cell
                
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: AudioBubbleCell.identifier, for: indexPath) as! AudioBubbleCell
            cell.Scope = self.Scope
            cell.Lessonid = self.logId
            cell.indexPathStr = indexPathStr
            cell.setContent(msg: msg)
            cell.audioButton.delegate = self
            cell.avatarImg.isHidden = shouldHideAvatar
            cell.transform = tableView.transform
            return cell
        case ChatMessageType.audiotext:
            if msg.position == .left {
                //对话左侧，带文字
                let cell = tableView.dequeueReusableCell(withIdentifier: AudioTextBubbleCell.identifier, for: indexPath) as! AudioTextBubbleCell
                cell.Scope = self.Scope
                cell.Lessonid = self.logId
                cell.indexPathStr = indexPathStr
                cell.setContent(msg: msg)
                cell.audioButton.delegate = self
                cell.avatarImg.isHidden = shouldHideAvatar
                if ((self.msgList[self.msgList.count - 1].type == .audiotext) && self.msgList.count == index + 1) && self.bubbleCanPlayAudio {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        cell.audioButton.delegate = self
                        cell.audioButton.play()
                        self.bubbleCanPlayAudio = false
                    }
                }
                cell.transform = tableView.transform
                cell.backgroundColor = UIColor.white
                return cell

            }
            else {
                //对话右侧
                let cell = tableView.dequeueReusableCell(withIdentifier: ScoredAudioTextBubbleCell.identifier, for: indexPath) as! ScoredAudioTextBubbleCell
                cell.transform = tableView.transform
                cell.Scope = self.Scope
                cell.Lessonid = self.logId
                cell.indexPathStr = indexPathStr

                if (self.msgList.count == index + 1) {
                    cell.setContent(msg: msg, animate: self.bubbleCanAnimate)
                    cell.avatarImg.isHidden = shouldHideAvatar

//                    if self.bubbleCanPlayAudio {
//                        cell.audioButton.play()
//                    }
                }
                else {
                    cell.setContent(msg: msg)
                }
                cell.audioButton.delegate = self
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
        let index = self.shouldShowWithTransform ? (self.msgList.count - section - 1) : section
        if shouldShowWithTransform {
            return self.cellIndent[index]
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if shouldShowWithTransform {
            return 0.01
        }
        return self.cellIndent[section]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        let index = self.shouldShowWithTransform ? (self.msgList.count - indexPath.section - 1) : indexPath.section
        return cellHeight[index]
        
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
