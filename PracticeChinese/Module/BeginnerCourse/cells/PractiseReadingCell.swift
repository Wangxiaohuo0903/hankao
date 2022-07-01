//
//  PractiseReadingCell.swift
//  PracticeChinese
//
//  Created by Temp on 2018/11/26.
//  Copyright © 2018 msra. All rights reserved.
//

import UIKit
import AVFoundation

class PractiseReadingCell: UITableViewCell,TextViewDelegate,LCVoiceButtonDelegate,LCRecordingViewDelegate {
    

    @IBOutlet weak var pinyin: UILabel!
    @IBOutlet weak var chinese: UILabel!
    var msg:PractiseMessageModel!
    @IBOutlet weak var english: UILabel!
    var recordingView_read: RecordignWithProgressView!
    var videoButton:CircularProgressView!
    
    @IBOutlet weak var statusLabel: UILabel!
    var userAudioButton: LCVoiceButton!
    var userAudioPlayBtn: UIButton!
    var userAudioBgView: UIView!
    var repeatId = ""
    //打分完成
    var rateFinished: ((Int,NSMutableAttributedString) -> Void)?
    var score: Int = -1
    var audioRightPlayer:AVAudioPlayer!
    var audioWrongPlayer:AVAudioPlayer!
    var pinyinText = ""
    var pinyinGroup = [String]()
    var iconImage = UIButton()
    
    @IBOutlet weak var recordingView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.chinese.adjustsFontSizeToFitWidth = true
        self.pinyin.adjustsFontSizeToFitWidth = true
        audioRightPlayer = try? AVAudioPlayer(contentsOf: ChBundleAudioUtil.successquizRight.url)
        audioRightPlayer?.prepareToPlay()
        audioWrongPlayer = try? AVAudioPlayer(contentsOf: ChBundleAudioUtil.successquizWrong.url)
        audioWrongPlayer?.prepareToPlay()
        self.creatUserAudioButton()
    }
    
    func creatUserAudioButton() {
        let audioW :CGFloat = 42
        let bottomHeight:CGFloat = 132 - 50
        userAudioBgView = UIView()
        userAudioBgView.frame = CGRect(x: ScreenUtils.width / 2 + 60, y: (bottomHeight - audioW)/2, width: audioW, height: audioW)
        userAudioButton = LCVoiceButton(frame: CGRect(x: 0 , y: 0, width: audioW, height: audioW), style: .speaker)
        userAudioBgView.layer.cornerRadius = (audioW)/2
        userAudioBgView.layer.masksToBounds = true
        let placeholder = ChImageAssets.Placeholder_Avatar.image
        if UserManager.shared.getAvatarUrl() == nil {
            self.userAudioButton.changeImages(voice1: placeholder!,voice2: placeholder!,voice3: placeholder!, defaultImage:placeholder!)
        }else {
            iconImage.sd_setImage(with: UserManager.shared.getAvatarUrl()!, for: .normal) { (image, error, type, url) in
                if (image != nil) {
                    self.userAudioButton.changeImages(voice1: image!,voice2: image!,voice3: image!, defaultImage:image!)
                }else {
                    self.userAudioButton.changeImages(voice1: placeholder!,voice2: placeholder!,voice3: placeholder!, defaultImage:placeholder!)
                }
            }
        }
        
        userAudioPlayBtn = UIButton(frame: CGRect(x: 0, y: 0, width: audioW, height: audioW))
        userAudioPlayBtn.addTarget(self, action: #selector(playUserAudio), for: .touchUpInside)
        userAudioPlayBtn.setBackgroundImage(UIImage(named: "stop_clear"), for: .normal)
        userAudioPlayBtn.backgroundColor = UIColor.colorFromRGB(102, 102, 102, 0.6)
        userAudioPlayBtn.layer.cornerRadius = audioW / 2
        userAudioPlayBtn.titleLabel?.font = UIFont(name: "GeezaPro-Bold", size: 22)
        userAudioButton.layer.masksToBounds = true
        userAudioButton.imageView?.contentMode = .scaleAspectFit
        
        userAudioBgView.addSubview(userAudioButton)
        userAudioBgView.addSubview(userAudioPlayBtn)
        userAudioBgView.bringSubviewToFront(userAudioPlayBtn)
        recordingView.addSubview(userAudioBgView)
        userAudioButton.delegate = self
        
        let videoWidth:CGFloat = 65
        recordingView_read = RecordignWithProgressView(frame: CGRect(x: ScreenUtils.width / 2 - videoWidth / 2, y: (bottomHeight - videoWidth)/2 , width: videoWidth, height: videoWidth))
        recordingView_read.delegate = self
        recordingView_read.dynamicTime = false
        recordingView.addSubview(recordingView_read)

        videoButton = CircularProgressView(frame: CGRect(x:ScreenUtils.width / 2  - audioW - 60, y:(bottomHeight - audioW)/2, width: audioW, height: audioW), back: UIColor.hex(hex: "E8F0FD"), progressColor: UIColor.hex(hex: "AECFFF"), lineWidth: 2, audioURL: nil, targetObject:self)
        videoButton.layer.cornerRadius = (audioW)/2
        videoButton.layer.masksToBounds = true
        videoButton.playerStarted = {
            if (self.userAudioButton != nil) {
                self.userAudioButton.pause()
                self.userAudioButtonStatus(score: self.score)
                self.recordingView_read.cancelRecording(sender: nil)
            }
        }
        
        videoButton.playerFinishedBlock = {
            
        }
        recordingView.addSubview(videoButton)
    }
        
    func setContent( msg: PractiseMessageModel) {
        self.msg = msg
        let url = msg.audioUrl
        let en = msg.english
        self.score = msg.score
        let chinese = msg.chinese
        let pinyin = msg.pinyin

        english.text = en
        self.chinese.attributedText = chinese
        self.pinyin.text = pinyin
        
        recordingView_read.filename = msg.fileName
        recordingView_read.audioURL = url
        self.videoButton.audioUrl = url
        userAudioButton.audioUrl = DocumentManager.urlFromFilename(filename: "\(recordingView_read.filename).m4a").absoluteString
        userAudioButtonStatus(score: self.score)
        
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func superViewConstraints() {
        
    }
    
    func tapped() {
        
    }
    
    @objc func playUserAudio(_ sender: UIButton) {
        recordingView_read.cancelRecording(sender: nil)
        videoButton.pause()
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            if (userAudioButton != nil) {
                userAudioButton.play()
                self.userAudioButtonStatus(score: -2)
            }
        }else {
            if (userAudioButton != nil) {
                userAudioButton.pause()
                self.userAudioButtonStatus(score: self.score)
            }
        }
    }
    
    //读完用户语音
    func buttonPlayStop() {
        self.userAudioPlayBtn.isSelected = false
        if (userAudioButton != nil) {
            userAudioButton.pause()
            self.userAudioButtonStatus(score: self.score)
        }
    }
    
    func playAudio() {

    }
    
    //开始读用户语音
    func buttonPlayStart() {
        recordingView_read.cancelRecording(sender: nil)
        videoButton.pause()
    }
    
    //开始录音
    func recordingStart() {
        statusLabel.text = "Tap to stop recording"
        if (userAudioButton != nil) {
            userAudioButton.pause()
            userAudioButtonStatus(score: self.score)
        }
        if (videoButton != nil) {
            videoButton.pause()
        }
    }
    
    func recordingAutoCommit() {
        recordingSubmit(duration: 10)
    }
    
    func recordingCancel() {
        statusLabel.text = "Tap the button to repeat"
    }
    
    func recordingSubmit(duration: Double) {
        statusLabel.text = "Tap the button to repeat"
        var keywords = [String]()
        self.pinyinText = msg.pinyin
        self.pinyinGroup = PinyinFormat(msg.pinyin)
        let a = msg.tokens
        let result = a.sorted { (token1, token2) -> Bool  in
            return token1.DifficultyLevel! > token2.DifficultyLevel!
        }
        for (i,token) in result.enumerated() {
            if i < 3 {
                keywords.append(token.Text!)
            }
        }
        if let audioData = try? Data(contentsOf: DocumentManager.urlFromFilename(filename: "\(recordingView_read.filename).m4a")) {
            let byteData = [Byte](audioData)
            //添加##，使打分结果不计入server
            let speechInput = chatRateInput(question: "\(msg.question)##", keywords: keywords, expectedAnswer: "\(msg.question)", data: byteData, speechMimeType: "audio/amr", sampleRate: RecordManager.sharedInstance.sampleRate, lessonId: repeatId, language: AppData.lang)
            ToastAlertView.show("Scoring...")
            CourseManager.shared.rateSpeechScenario(speechInput: speechInput){
                data in
                ToastAlertView.hide()
                if let result = data {
                    if result.Score! < 60 {
                        self.audioWrongPlayer.play()
                    }else {
                        self.audioRightPlayer.play()
                    }
                    let attrstrings = self.getScoredText(result.Details, originText:
                        self.msg.chinese.string, tokens: [IllustrationText]())
                    self.rateFinished?(result.Score!,attrstrings[0])
                    self.score = result.Score!
                    self.chinese.attributedText = attrstrings[0]
                    self.userAudioButtonStatus(score: result.Score!)
                }else {
                    UIApplication.topViewController()?.presentUserToast(message: "Error occured during scoring,please try again.")
                }
            }
        }else {
            UIApplication.topViewController()?.presentUserToast(message: "Error occured during scoring,please try again.")
        }
    }
    func getScoredText(_ detail:SpeechRateData?, originText:String, tokens:[IllustrationText]) -> [NSMutableAttributedString] {
        let attString = NSMutableAttributedString(string: originText, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.speakscoreBlack]))
        let pinyinString = NSMutableAttributedString(string: self.pinyinGroup.joined(separator: " "), attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.speakscoreBlack]))
        if let data = detail {
            self.pinyinGroup.removeAll()
            for word in data.WordDetails! {
                self.pinyinGroup.append(PinyinFormat(word.Word)[0])
            }
            let pat = "[\\u4e00-\\u9fa5]"
            let regex = try! NSRegularExpression(pattern: pat, options: [])
            let matches = regex.matches(in: originText, options: [], range: NSRange(location: 0, length: originText.characters.count))
            if matches.count != data.WordDetails!.count || matches.count != pinyinGroup.count {
                return [attString,pinyinString]
            }
            for (i, word) in data.WordDetails!.enumerated() {
                if word.PronunciationScore! < 40 {
                    attString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.wrongColor, range: matches[i].range)
                }
                else if word.PronunciationScore! >= 60 {
                    attString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.correctColor, range: matches[i].range)
                }
            }
           
        }
        return [attString, pinyinString]
    }
    //打分之后用户语音按钮状态变化
    func userAudioButtonStatus(score:Int)  {
        self.userAudioPlayBtn.setImage(UIImage(named: ""), for: .normal)
        if score == -1 {
            userAudioPlayBtn.isUserInteractionEnabled = false
            userAudioPlayBtn.isSelected = false
            //还没跟读
            self.userAudioPlayBtn.setBackgroundImage(UIImage(named: "stop_clear"), for: .normal)
            userAudioPlayBtn.backgroundColor = UIColor.colorFromRGB(102, 102, 102, 0.6)
            self.userAudioPlayBtn.setTitle("", for: .normal)
            return
        }
        
        userAudioPlayBtn.isUserInteractionEnabled = true
        if score == -2 {
            //正在播放的状态
            self.userAudioPlayBtn.setBackgroundImage(UIImage(named: "play_clear"), for: .normal)
            self.userAudioPlayBtn.setTitle("", for: .normal)
            return
        }
        self.userAudioPlayBtn.setTitleColor(UIColor.white, for: .normal)
        userAudioPlayBtn.isSelected = false
        self.userAudioPlayBtn.isUserInteractionEnabled = true
        
        if (score < 60) {
            self.userAudioPlayBtn.setBackgroundImage(UIImage(named: ""), for: .normal)
            self.userAudioPlayBtn.setImage(UIImage(named: "cry_white"), for: .normal)
            self.userAudioPlayBtn.setTitle("", for: .normal)
            self.userAudioPlayBtn.backgroundColor = UIColor.colorFromRGB(235, 87, 69, 0.6)
        }else if (score >= 60 && score < 80) {
            //黄
            self.userAudioPlayBtn.setBackgroundImage(UIImage(named: ""), for: .normal)
            self.userAudioPlayBtn.setImage(UIImage(named: ""), for: .normal)
            self.userAudioPlayBtn.backgroundColor = UIColor.colorFromRGB(235, 167, 64, 0.6)
            self.userAudioPlayBtn.setTitle("\(score)", for: .normal)
        }else if (score >= 80) {
            //绿
            self.userAudioPlayBtn.setBackgroundImage(UIImage(named: ""), for: .normal)
            self.userAudioPlayBtn.setImage(UIImage(named: ""), for: .normal)
            self.userAudioPlayBtn.backgroundColor = UIColor.colorFromRGB(131, 187, 86, 0.6)
            self.userAudioPlayBtn.setTitle("\(score)", for: .normal)
        }
        
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
