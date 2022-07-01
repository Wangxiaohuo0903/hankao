//
//  LearningCard.swift
//  PracticeChinese
//
//  Created by summer on 2017/9/8.
//  Copyright © 2017年 msra. All rights reserved.
//

import Foundation
import AVFoundation
import SnapKit
protocol recordingDelegate {
    //加阳光值
    func addSunValueNoCombo(value: Int)
}
class LearningCard: UIView,UIScrollViewDelegate,CircularProgressViewDelegate,UIGestureRecognizerDelegate,LCRecordingViewDelegate {
    func recordingStart() {
        tappedHiddenTokens()
        //暂停语音播放
        self.videoButton.pause()
        self.recordingView_read.enableOtherViews()
        self.recordingView_read.backgroundColor = UIColor.white
    }
    
    func recordingAutoCommit() {
        self.recordingSubmit(duration: 10)
    }
    
    func recordingCancel() {
        self.recordingView_read.backgroundColor = UIColor.clear
    }
    
    func recordingSubmit(duration: Double) {
       
        //上传音频
        if let audioData = try? Data(contentsOf: DocumentManager.urlFromFilename(filename: "\(self.recordingView_read.filename).m4a")) {
            let byteData = [Byte](audioData)
            
            let speechInput = chatRateInput(question: (currentCard?.Text)!, keywords: ["##"], expectedAnswer: (currentCard?.Text)!, data: byteData, speechMimeType: "audio/amr", sampleRate: RecordManager.sharedInstance.sampleRate, lessonId: Lessonid, language: AppData.lang)
            ToastAlertView.show("Scoring...")
            CourseManager.shared.rateSpeechScenario(speechInput: speechInput){
                data in
                ToastAlertView.hide()
                self.recordingView_read.filename = "Learning_\(self.Lessonid)_\(UUID().uuidString)"
                if let result = data {
                    if result.Score! >= 50 {
                        self.recordDelegate?.addSunValueNoCombo(value: 1)
                        self.audioRightPlayer?.play()
                    }else {
                       self.audioWrongPlayer?.play()
                    }
                }else {
                    UIApplication.topViewController()?.presentUserToast(message: "Error occured during scoring,please try again.")
                }
            }
        }else {
            UIApplication.topViewController()?.presentUserToast(message: "Error occured during scoring,please try again.")
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: videoButton))! {
            return false
        }
        return true
    }
    func playerDidFinishPlaying() {
        
    }
    
    var recordDelegate:recordingDelegate?
    var chineseandpinyinLabel:MTextView!
    var englishLabel:RNTextView!
    var answerLabel:UILabel!
    var imageView:UIImageView!
    var videoButton:CircularProgressView!
    //录音按钮
    var recordingView_read: LCProgressRecordingView!
    var continueButton:UIButton!
    var cardView: UIScrollView!
    var tipsoffset:CGFloat!
    var signButton:TipsButton!
    var cardHeight:CGFloat!
    var labelHeight:CGFloat!
    var labelView:UIView!
    var videoButtonView:UIView!
    var startMillisec: Int64!
    var voices = Dictionary<String,SentenceDetail>()
    var currentCard: ScenarioLessonLearningItem?
    var myIndex: Int = 0//当前view的位置
    var playerDidFinished: (() -> Void)!
    var Lessonid:String = ""
    var clickTokensArray: (([String : Int]) -> Void)?
    var tokensArrayOfClick = [String : Int]()
    
    var audioRightPlayer:AVAudioPlayer!
    var audioWrongPlayer:AVAudioPlayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        audioRightPlayer = try? AVAudioPlayer(contentsOf: ChBundleAudioUtil.successquizRight.url)
        audioRightPlayer?.prepareToPlay()
        audioWrongPlayer = try? AVAudioPlayer(contentsOf: ChBundleAudioUtil.successquizWrong.url)
        audioWrongPlayer?.prepareToPlay()
        self.backgroundColor = UIColor.grayTheme
        self.tipsoffset = self.frame.height*0.1
        //背景
        self.cardView = UIScrollView(frame: CGRect(x:10, y: 10, width: self.frame.width - 20, height: self.frame.height*0.87))
        self.cardView.isScrollEnabled = false
        self.cardView.delegate = self
        self.addSubview(cardView)
        self.cardView.backgroundColor = UIColor.white
        self.cardView.layer.cornerRadius = 10.0
        self.cardView.showsVerticalScrollIndicator = false
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tappedHiddenTokens))
        gesture.delegate = self
        self.cardView.addGestureRecognizer(gesture)
        
        //contuine按钮
        continueButton = UIButton(frame: CGRect(x:(self.frame.width - FontAdjust().buttonWidth())/2 , y:self.frame.height-74, width: FontAdjust().buttonWidth(), height: FontAdjust().buttonHeight()))
        continueButton.setBackgroundImage(UIImage.fromColor(color: UIColor.blueTheme), for: .normal)
        continueButton.setTitle("Start Quiz", for: UIControl.State.normal)
        continueButton.titleLabel?.textAlignment = .center
        continueButton.titleLabel?.font = FontUtil.getFont(size: FontAdjust().FontSize(18), type: .Regular)
        continueButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        continueButton.layer.cornerRadius = 22
        continueButton.layer.masksToBounds = true
        self.continueButton.alpha = 0
        self.addSubview(continueButton)
        
        var  buttonheight:CGFloat = 0
        
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
            buttonheight = 34
        }else{
            buttonheight = UIAdjust().adjustByHeight(12)
        }
        
        var buttonGap:CGFloat = 0
        if(AdjustGlobal().CurrentScale == AdjustScale.iPad){
            buttonGap = 60
            continueButton.layer.cornerRadius = 30
        }else{
            buttonGap = 44
            continueButton.layer.cornerRadius = 22
        }
        continueButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.snp.bottom).offset(0)
            make.width.equalTo(150)
            make.height.equalTo(buttonGap)
            make.centerX.equalTo(self)
        }
        
        cardView.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self).offset(5)
            make.right.equalTo(self).offset(-5)
            make.top.equalTo(self)
            make.bottom.equalTo(self.snp.bottom).offset(-UIAdjust().adjustByHeight(12) - buttonheight - buttonGap)
            make.centerX.equalTo(self)
        }
        
        
        self.cardHeight = self.frame.height - buttonheight - buttonGap - UIAdjust().adjustByHeight(12)
        self.setSubviews()
        
    }
    //隐藏tokens
    @objc func tappedHiddenTokens() {
        chineseandpinyinLabel.ybPopupMenuDidDismiss()
        NotificationCenter.default.post(name: ChNotifications.DismissPop.notification, object: nil)
        chineseandpinyinLabel.pop = nil
    }
    func setSubviews(){

        imageView = UIImageView(image: UIImage(named: "quizimage"))
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.backgroundColor = UIColor.white
        imageView.layer.masksToBounds = true
        imageView.frame = CGRect(x:0 , y:0, width: self.cardView.frame.width, height: self.cardView.frame.height*0.45)
    
        self.cardView.addSubview(imageView)
        
        
        labelView = UIView()
        self.cardView.addSubview(labelView)
        
        
        answerLabel = UILabel(frame:CGRect(x:self.cardView.frame.width*0.1 , y:self.cardView.frame.height, width: self.cardView.frame.width*0.8, height: self.cardView.frame.height*0.1))
        answerLabel.numberOfLines = 5
        answerLabel.textColor = UIColor.lightText
        answerLabel.textAlignment = .left
        answerLabel.font = UIFont(name: "PingFang SC", size: FontAdjust().FontSize(ScreenUtils.englishFont))
        answerLabel.backgroundColor = UIColor.white
        answerLabel.isUserInteractionEnabled = true
        answerLabel.alpha = 0
        self.cardView.addSubview(answerLabel)
        
        signButton = TipsButton(frame: CGRect(x:0 , y:0, width: self.cardView.frame.width, height: 25))
        signButton.backgroundColor = UIColor.white
        signButton.isUserInteractionEnabled = true
        signButton.addTarget(self,action:#selector(tappedarrow),for:.touchUpInside)
        self.cardView.addSubview(signButton)
        self.cardView.sendSubviewToBack(signButton)
        
        let imageWidth = self.cardView.frame.width
        var imageHeight = self.cardView.frame.width/3*2
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhone4 || AdjustGlobal().CurrentScale == AdjustScale.iPhone5 ){
            imageHeight = self.cardView.frame.width/16*9
        }
        imageView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.cardView).offset(UIAdjust().adjustByHeight(0))
            make.left.equalTo(self).offset(UIAdjust().adjustByHeight(0))
            make.right.equalTo(self).offset(-UIAdjust().adjustByHeight(0))
            make.height.equalTo(imageHeight)
            make.bottom.equalTo(labelView.snp.top).offset(-UIAdjust().adjustByHeight(0))
        }
        
        
        let hidden = UITapGestureRecognizer(target: self, action: #selector(tappedarrow(button:)))
        self.answerLabel.addGestureRecognizer(hidden)
        
    }
    func showContinue() {
        var  buttonheight:CGFloat = 0
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
            buttonheight = 34
        }else{
            buttonheight = UIAdjust().adjustByHeight(12)
        }
        var buttonGap:CGFloat = 0
        if(AdjustGlobal().CurrentScale == AdjustScale.iPad){
            buttonGap = 60
            continueButton.layer.cornerRadius = 30
        }else{
            buttonGap = 44
            continueButton.layer.cornerRadius = 22
        }

        UIView.animate(withDuration: 0.3) {
            self.continueButton.alpha = 1
            self.continueButton.snp.remakeConstraints { (make) -> Void in
                make.bottom.equalTo(self.snp.bottom).offset(-buttonheight)
                make.width.equalTo(150)
                make.height.equalTo(buttonGap)
                make.centerX.equalTo(self)
            }
            self.layoutIfNeeded()
        }
    }
    
    
    func hiddenContinue() {
        var buttonGap:CGFloat = 0
        if(AdjustGlobal().CurrentScale == AdjustScale.iPad){
            buttonGap = 60
            continueButton.layer.cornerRadius = 30
        }else{
            buttonGap = 44
            continueButton.layer.cornerRadius = 22
        }
        
        UIView.animate(withDuration: 0.3) {
            self.continueButton.alpha = 0
            self.continueButton.snp.remakeConstraints { (make) -> Void in
                make.top.equalTo(self.snp.bottom).offset(0)
                make.width.equalTo(150)
                make.height.equalTo(buttonGap)
                make.centerX.equalTo(self)
            }
            self.layoutIfNeeded()
        }
    }
    
    func setData(card:ScenarioLessonLearningItem, voice: Dictionary<String,SentenceDetail>, nextType:Bool){
        voices = voice
        currentCard = card
        
        let imageWidth = self.cardView.frame.width
        var imageHeight = self.cardView.frame.width/3*2
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhone4 || AdjustGlobal().CurrentScale == AdjustScale.iPhone5 ){
            imageHeight = self.cardView.frame.width/16*9
        }
        
        self.labelHeight = self.cardHeight - imageHeight - 40
//        if(card.Description == nil || card.Description == ""){
//            self.labelHeight = self.cardHeight - imageWidth/3*2
//        }
        let url = URL(string: card.Image!)
        if(url != nil){
            imageView.sd_setImage(with: url, placeholderImage: UIImage.fromColor(color: UIColor.lightGray), options: .refreshCached, completed: nil)
        }
    
        let labelWidth = self.frame.width - UIAdjust().adjustByHeight(10)*2
        
        //有个坑，刷新view会BUG，所以单独计算了y来刷新(Snapkit bug)
        let modelText = RNTextView(frame: CGRect(x:0,y:0,width:labelWidth,height:labelHeight), chinese: "你好", chineseSize: FontAdjust().FontSizeForiPhone4(38,-10), pinyin: "mihao", pinyinSize: FontAdjust().FontSizeForiPhone4(26,-6), style: textStyle.chineseandpinyin, changeAble: false, pinyinFontRegular:true)
        
        for token in card.Tokens! {
            if token.IPA1 == "" || !(token.IPA1 != nil) {
                //标点或特殊符号
            }else {
                tokensArrayOfClick.updateValue(0, forKey: token.Text!)
            }
        }
        //中拼音
        var chineseSize:Double = 32
        var piyinSize:Double = 16
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhone5 || AdjustGlobal().CurrentScale == AdjustScale.iPhone4){
            chineseSize = 28
            piyinSize = 13
        }
        chineseandpinyinLabel = MTextView(frame: CGRect(x: 0, y: 0, width: self.cardView.frame.width , height: 60), tokens: card.Tokens!, chineseSize: chineseSize, pinyinSize: piyinSize, style: .chineseandpinyin, changeAble: true,showIpa:true)
        chineseandpinyinLabel.itemAli = .center
        chineseandpinyinLabel.selectEnable = true
        chineseandpinyinLabel.setData()
        chineseandpinyinLabel.clickToken = {text in
            self.tokensArrayOfClick.updateValue(self.tokensArrayOfClick[text]! + 1, forKey: text)
        }
        self.labelView.addSubview(chineseandpinyinLabel)
        //英文
        englishLabel = RNTextView(frame: CGRect(x:10,y:0,width:labelWidth - 20,height:modelText.frameHeight + 2), chinese: "", chineseSize: FontAdjust().FontSize(ScreenUtils.englishFont), pinyin: card.NativeText!, pinyinSize: FontAdjust().FontSize(ScreenUtils.englishFont), style: textStyle.pinyin,changeAble:false, pinyinFontRegular:true)
        englishLabel.setLabelColor(chinese: UIColor.lightText, pinyin: UIColor.lightText)
        englishLabel.delegate = self
        self.labelView.addSubview(englishLabel)
        //录音按钮
        var videoWidth:CGFloat = 0
        var videoButtonViewY = self.cardView.frame.height*0.77
        if(AdjustGlobal().CurrentScale == AdjustScale.iPad){
            videoWidth = 80
        }else if(AdjustGlobal().CurrentScale == AdjustScale.iPhone4 || AdjustGlobal().CurrentScale == AdjustScale.iPhone5){
            videoWidth = 60
        }else{
            videoWidth = 70
        }
        let chineseAndEnglishHeight = chineseandpinyinLabel.getViewHeight() + englishLabel.frameHeight  + 10
        let chineseTop = (labelHeight - chineseAndEnglishHeight - videoWidth - ScreenUtils.heightByM(y: 30)) / 2
        videoButtonView = UIView(frame:CGRect(x:self.cardView.frame.width*0.5 - CGFloat(15) , y:videoButtonViewY, width: videoWidth, height: videoWidth))
        videoButtonView.layer.cornerRadius = videoWidth/2
        videoButton = CircularProgressView(frame: CGRect(x:0 , y:0, width: videoWidth, height: videoWidth), back: UIColor.hex(hex: "E8F0FD"), progressColor: UIColor.hex(hex: "AECFFF"), lineWidth: 2, audioURL: nil, targetObject:self)
        videoButton.Scope = "Learn"
        videoButton.Lessonid = self.Lessonid
        videoButton.Subscope = "Learn"
        videoButton.IndexPath = card.Tags![0]
        videoButton.playerStarted = {
            self.recordingView_read.cancelRecording(sender: nil)
            self.tappedHiddenTokens()
        }
        videoButton.playerFinishedBlock = {
            if nextType {
                self.showContinue()
            }
        }
        videoButton.backgroundColor = UIColor.white
        videoButton.layer.cornerRadius = (videoWidth)/2
        videoButton.layer.masksToBounds = true
        videoButtonView.addSubview(videoButton)
        self.labelView.addSubview(videoButtonView)
        self.labelView.backgroundColor = UIColor.white
        videoButton.audioUrl = voice[card.Text!]?.AudioUrl

        recordingView_read = LCProgressRecordingView(frame: CGRect(x: 0, y: 0 , width: videoWidth + 6, height: videoWidth + 6))
        recordingView_read.delegate = self
        recordingView_read.filename = "Learning_\(self.Lessonid)_\(UUID().uuidString)"
        recordingView_read.dynamicTime = true
        recordingView_read.audioURL = (voice[card.Text!]?.AudioUrl)!
        labelView.addSubview(recordingView_read)
        recordingView_read.backgroundColor = UIColor.white
        if(card.Description == nil || card.Description == ""){
            answerLabel.text = ""
            signButton.isHidden = true
        }else{
            answerLabel.text = card.Description
            signButton.isHidden = false
        }
        
        let textheight = getLabelheight(labelStr: answerLabel.text!, font: answerLabel.font) + 20
        self.tipsoffset = textheight

        labelView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(imageView.snp.bottom).offset(UIAdjust().adjustByHeight(0))
            make.left.equalTo(self).offset(UIAdjust().adjustByHeight(0))
            make.right.equalTo(self).offset(-UIAdjust().adjustByHeight(0))
            make.height.equalTo(labelHeight)
        }
        chineseandpinyinLabel.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.labelView)
            make.top.equalTo(self.labelView).offset(chineseTop)
            make.height.equalTo(chineseandpinyinLabel.getViewHeight())
            make.width.equalTo(chineseandpinyinLabel.getViewWidth())
        }

        englishLabel.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.labelView)
            make.top.equalTo(chineseandpinyinLabel.snp.bottom).offset(10)
            make.height.equalTo(englishLabel.frameHeight)
            make.width.equalTo(englishLabel.frameWidth)
        }
        videoButton.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(videoButtonView)
            make.centerY.equalTo(videoButtonView)
            make.width.height.equalTo(videoWidth)
        }
        videoButtonView.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.labelView).offset(-50)
            make.bottom.equalTo(self.labelView).offset(-ScreenUtils.heightByM(y: 30))
            make.width.height.equalTo(videoWidth)
        }
        recordingView_read.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(labelView).offset(50)
            make.centerY.equalTo(videoButtonView)
            make.width.height.equalTo(videoWidth + 6)
        }

        answerLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self).offset(UIAdjust().adjustByHeight(15))
            make.right.equalTo(self).offset(-UIAdjust().adjustByHeight(15))
            make.height.equalTo(textheight)
            make.bottom.equalTo(self.cardView)
        }
        
        signButton.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(25)
            make.centerX.equalTo(self.cardView)
            make.width.equalTo(self.cardView)
            make.top.equalTo(labelView.snp.bottom).offset(UIAdjust().adjustByHeight(-5))
            make.bottom.equalTo(answerLabel.snp.top).offset(-5)
        }
        
        
    }
    
    func getLabelheight(labelStr:String,font:UIFont)->CGFloat{
        let maxSie:CGSize = CGSize(width:self.frame.width*0.9 - UIAdjust().adjustByHeight(10)*2,height:self.frame.height*0.2)
        return (labelStr as NSString).boundingRect(with: maxSie, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):font]), context: nil).size.height
    }
    
    func refreshPage(){
        self.superViewConstraints()
        self.cardView.setContentOffset(CGPoint(x:0,y:0), animated: false)
        self.signButton.isSelected = false
        self.continueButton.isHidden = true
        self.continueButton.isEnabled = true
    }
    

    //隐藏tips
    func hiddenTips(){
        self.cardView.setContentOffset(CGPoint(x:0,y:0), animated: false)
        self.signButton.changeToArrow()
        self.signButton.isSelected = false
    }
    @objc func tappedarrow(button:UIButton){
        signButton.isSelected = !signButton.isSelected
        tappedHiddenTokens()
        if(signButton.isSelected){
            //打开
            self.answerLabel.alpha = 1
            self.cardView.setContentOffset(CGPoint(x:0,y:self.tipsoffset), animated: true)
            self.signButton.changeToTips()
            //埋点：点击Tips，打开
            let info = ["Scope" : "Learn","Lessonid" : self.Lessonid,"Subscope" : "Learn","IndexPath" : currentCard?.Tags![0],"Event" : "Tips","Value" : "Open"]
            UserManager.shared.logUserClickInfo(info)

        }else{
            UIView.animate(withDuration: 0.5) {
                self.answerLabel.alpha = 0
            }
            self.cardView.setContentOffset(CGPoint(x:0,y:0), animated: true)
            //关闭
                self.signButton.changeToArrow()
            //埋点：点击Tips，关闭
            let info = ["Scope" : "Learn","Lessonid" : self.Lessonid,"Subscope" : "Learn","IndexPath" : currentCard?.Tags![0],"Event" : "Tips","Value" : "Open"]
            UserManager.shared.logUserClickInfo(info)
            
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

    }
    
    
}

extension LearningCard:LCVoiceButtonDelegate,RNTextViewDelegate,NewTextViewDelegate{
    func tapped() {
        var videoWidth:CGFloat = 0
        if(AdjustGlobal().CurrentScale == AdjustScale.iPad){
            videoWidth = 65
        }else if(AdjustGlobal().CurrentScale == AdjustScale.iPhone4 || AdjustGlobal().CurrentScale == AdjustScale.iPhone5){
            videoWidth = 60
        }else{
            videoWidth = 70
        }
        let textheight = getLabelheight(labelStr: answerLabel.text!, font: answerLabel.font) + 20
        self.tipsoffset = textheight
        
        videoButtonView.layer.cornerRadius = videoWidth/2
        
        chineseandpinyinLabel.snp.remakeConstraints { (make) -> Void in
            make.centerX.equalTo(self.labelView)
            make.centerY.equalTo(self.labelView).offset(-ScreenUtils.heightByM(y: 30))
            make.height.equalTo(chineseandpinyinLabel.getViewHeight())
            make.width.equalTo(chineseandpinyinLabel.getViewWidth())
        }

        videoButtonView.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.labelView)
            make.centerY.equalTo(imageView.snp.bottom)
            make.width.height.equalTo(videoWidth)
        }
        let labelGap = (chineseandpinyinLabel.getViewHeight() + englishLabel.frameHeight)/2 + 10
        
        englishLabel.snp.remakeConstraints { (make) -> Void in
            make.centerX.equalTo(self.labelView)
            make.centerY.equalTo(chineseandpinyinLabel).offset(labelGap)
            make.height.equalTo(englishLabel.frameHeight)
            make.width.equalTo(englishLabel.frameWidth)
        }
    }
    
    func superViewConstraints() {
        chineseandpinyinLabel.systemAutoChangeWithoutFrame()

        let textheight = getLabelheight(labelStr: answerLabel.text!, font: answerLabel.font) + 20
        self.tipsoffset = textheight
        
        chineseandpinyinLabel.snp.remakeConstraints { (make) -> Void in
            make.centerX.equalTo(labelView)
            make.centerY.equalTo(labelView).offset(-70)
            make.height.equalTo(chineseandpinyinLabel.getViewHeight())
            make.width.equalTo(chineseandpinyinLabel.getViewWidth())
        }
        let labelGap = (chineseandpinyinLabel.getViewHeight() + englishLabel.frameHeight)/2 + 10
        
        englishLabel.snp.remakeConstraints { (make) -> Void in
            make.centerX.equalTo(self.labelView)
            make.centerY.equalTo(chineseandpinyinLabel).offset(labelGap)
            make.height.equalTo(englishLabel.frameHeight)
            make.width.equalTo(englishLabel.frameWidth)
        }
        
    }

    
    func buttonPlayStop() {

    }

    func buttonPlayStart() {
        
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
