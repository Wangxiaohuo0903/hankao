//
//  ChatReviewTableCell.swift
//  PracticeChinese
//
//  Created by ThomasXu on 28/06/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation

class ChatReviewTableCell: UITableViewCell {
    
    var appHeadImg: UIImageView!
    var appQuestion: LCVerticalCenterLabel!
    var appQuestionHeader: UIView!
    var appQuestionHeaderCover: UIView!
    static let headImageHeight: CGFloat = 30//头像的高度和宽度固定
    static let userVoiceWidth: CGFloat = 90
    static let rowDis: CGFloat = 10//在一个cell内部，行之间的距离
    static let userDis: CGFloat = 5
    static let cellDis: CGFloat = 10
    static let appQuestionFont = FontUtil.getFont(size: 14, type: .Regular)
    
    var userHeadImg: UIImageView!
    var userVoiceButton: LCVoiceButton!
    var userVoiceButtonUIView: UIView!
    var userVoiceHeader: UIView!
    var userVoiceHeaderCover: UIView!
    private var userScoreView: ReviewMedalScoreView!
    
    var userVoiceResultImg: UIImageView!
    var exampleButton: ChatPlayExampleView!
    var userScore: Int! {
        didSet {
            self.userScoreView.score = userScore
        }
    }
    
    var userAnswerAudioURL: String! {
        didSet {
            userVoiceButton.audioUrl = userAnswerAudioURL
        }
    }
    var correctAnswerAudioURL: String! {
        didSet {
            exampleButton.playButton.audioUrl = correctAnswerAudioURL
        }
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        appHeadImg = UIImageView(frame: CGRect.zero)
        appQuestion = LCVerticalCenterLabel(frame: CGRect.zero)
        appQuestion.text = "   你是哪个国家的人"
        appQuestion.font = ChatReviewTableCell.appQuestionFont
        appQuestion.textColor = UIColor.hex(hex: "6c9ed9")
        appQuestionHeader = UIView(frame: CGRect.zero)
        appQuestionHeaderCover = UIView(frame: CGRect.zero)
        contentView.addSubview(appQuestion)
        contentView.addSubview(appQuestionHeader)
        contentView.addSubview(appQuestionHeaderCover)
        contentView.addSubview(appHeadImg)
        
        userHeadImg = UIImageView(frame: CGRect.zero)
        userVoiceButtonUIView = UIView(frame: CGRect.zero)
        userVoiceButton = LCVoiceButton(frame: CGRect.zero,style: .right)
        userVoiceButton.changeImages(voice1: ChImageAssets.VoiceIconWhite1.image!,voice2: ChImageAssets.VoiceIconWhite2.image!,voice3: ChImageAssets.VoiceIconWhite3.image!,defaultImage:ChImageAssets.VoiceIconWhite3.image!)
        userVoiceHeader = UIView(frame: CGRect.zero)
        userVoiceHeaderCover = UIView(frame: CGRect.zero)
        userScoreView = ReviewMedalScoreView(frame: CGRect.zero)
        userVoiceButtonUIView.addSubview(userVoiceButton)
        contentView.addSubview(userVoiceButtonUIView)
        contentView.addSubview(userVoiceHeader)
        contentView.addSubview(userVoiceHeaderCover)
        contentView.addSubview(userHeadImg)
        contentView.addSubview(userScoreView)
        
        userVoiceResultImg = UIImageView(frame: CGRect.zero)
        self.contentView.addSubview(userVoiceResultImg)
        
        exampleButton = ChatPlayExampleView(frame: CGRect.zero)
        self.contentView.addSubview(exampleButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //因为该cell的变动部分是问题的文本框，所以只需要获得文本框的高度即可
    static func getCellHeight(questionText: String) -> CGFloat {
        let maxSie:CGSize = CGSize(width:CGFloat(240),height:500)
        var height = (questionText as NSString).boundingRect(with: maxSie, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):appQuestionFont]), context: nil).size.height
        height += LCVerticalCenterLabel.textTopAndBottomDis * 2
        return height + rowDis + userDis + headImageHeight * 2 + cellDis//最后加上cellDis是为了 设置 contentView
    }
    
    func setQuestionViews() {
        let frame = self.contentView.frame
        let headImageHeight = ChatReviewTableCell.headImageHeight
        let imgWidth:CGFloat = headImageHeight
        appHeadImg.frame = CGRect(x: 2, y: 0, width: imgWidth, height: headImageHeight)
        appHeadImg.layer.cornerRadius = imgWidth / 2
        appHeadImg.layer.masksToBounds = true
        appHeadImg.image = ChImageAssets.MeIcon2.image
        appHeadImg.isHidden = true
      //  appHeadImg.backgroundColor = UIColor.red
        
        let questionX = CGFloat(15)
        var questionWidth = CGFloat(240)
        
        let questionHeight = self.getLabelheight(labelStr:appQuestion.text,font:appQuestion.font) + LCVerticalCenterLabel.textTopAndBottomDis * 2//文本距离上下边界
//        if (questionHeight < headImageHeight) {
//            questionHeight = headImageHeight
//        }
        
        if(self.getLabelheight(labelStr:appQuestion.text,font:appQuestion.font)<20){
            questionWidth = self.getLabelwidth(labelStr: appQuestion.text, font: appQuestion.font) + appQuestion.rightDis + appQuestion.leftDis
        }
        appQuestion.setframe(frame: CGRect(x: questionX - 5, y: 0, width: questionWidth, height: questionHeight))  //+10在定义中tail
        
        userHeadImg.ch_setY(newY: appQuestion.frame.midY - headImageHeight / 2)
        
//        let bottomViewWidth = appQuestion.frame.minX + appQuestion.layer.cornerRadius - appHeadImg.frame.midX
//        appQuestionHeader.frame = CGRect(x: appHeadImg.frame.midX, y: appHeadImg.frame.midY, width: bottomViewWidth, height: appHeadImg.frame.height / 2)
//
//        appQuestionHeader.backgroundColor = appQuestion.backgroundColor
//
        
//        let coverViewRadius = appQuestion.frame.minX - appHeadImg.frame.midX
//        let coverViewX = appHeadImg.frame.midX - coverViewRadius
//        let coverViewY = appHeadImg.frame.midY - coverViewRadius
//        appQuestionHeaderCover.frame = CGRect(x: coverViewX, y: coverViewY, width: coverViewRadius * 2, height: coverViewRadius * 2)
//        appQuestionHeaderCover.layer.cornerRadius = coverViewRadius
//        appQuestionHeaderCover.layer.masksToBounds = true
//        appQuestionHeaderCover.backgroundColor = UIColor.white
        
//        appQuestion.content.backgroundColor = UIColor.red
        
    }
    
    func getLabelheight(labelStr:String,font:UIFont)->CGFloat{
        let maxSie:CGSize = CGSize(width:240,height:500)
        return (labelStr as NSString).boundingRect(with: maxSie, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):font]), context: nil).size.height
    }
    func getLabelwidth(labelStr:String,font:UIFont)->CGFloat{
        let maxSie:CGSize = CGSize(width:240,height:19.6)
        return (labelStr as NSString).boundingRect(with: maxSie, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):font]), context: nil).size.width
    }
    
    func setUserViews() {
        let userImgY = self.appQuestion.frame.maxY + ChatReviewTableCell.rowDis
        let imgHeight = ChatReviewTableCell.headImageHeight
        let frame = self.contentView.frame
        let imgX = frame.width - imgHeight - 10//和app head 到边界的距离一致
        userHeadImg.frame = CGRect(x: imgX, y: userImgY, width: imgHeight, height: imgHeight)
        userHeadImg.layer.cornerRadius = imgHeight / 2
        userHeadImg.backgroundColor = UIColor.hex(hex: "d2eaff")
        userHeadImg.layer.masksToBounds = true
        userHeadImg.sd_setImage(with: UserManager.shared.getAvatarUrl(), placeholderImage: ChImageAssets.Avatar.image, options: .refreshCached, completed: nil)
        
        
        let voiceButtonWidth = CGFloat(60)
        let voiceButtonX = userHeadImg.frame.minX - 5 - voiceButtonWidth
        let voiceButtonY = userImgY
        
        
        userVoiceButtonUIView.frame = CGRect(x: voiceButtonX, y: voiceButtonY, width: voiceButtonWidth, height: imgHeight)
        userVoiceButtonUIView.backgroundColor = UIColor(0x4e80d9)
        userVoiceButtonUIView.layer.cornerRadius = 6
        userVoiceButtonUIView.layer.masksToBounds = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        self.userVoiceButtonUIView.addGestureRecognizer(gesture)
        
        userVoiceButton.frame = CGRect(x: userVoiceButtonUIView.frame.width - 15, y: userVoiceButtonUIView.frame.height/2 - 5, width: 10, height: 10)
        userVoiceButton.backgroundColor = UIColor(0x4e80d9)
        userVoiceButton.layer.cornerRadius = 6
        userVoiceButton.layer.masksToBounds = true
        
        let scoreWidth = imgHeight
        let scoreX = voiceButtonX - scoreWidth / 2
        userScoreView.frame = CGRect(x: scoreX, y: voiceButtonY, width: scoreWidth, height: scoreWidth)
    //    userScoreView.backgroundColor = UIColor.red
        
//        let bottomX = userVoiceButtonUIView.frame.maxX - userVoiceButtonUIView.layer.cornerRadius
//        let bottomViewWidth = userHeadImg.frame.midX - bottomX
//        userVoiceHeader.frame = CGRect(x: bottomX, y: userVoiceButtonUIView.frame.midY, width: bottomViewWidth, height: userHeadImg.frame.height / 2)
//        userVoiceHeader.backgroundColor = userVoiceButtonUIView.backgroundColor
//
//        let coverViewRadius = userHeadImg.frame.midX - userVoiceButtonUIView.frame.maxX
//        let coverViewY = userHeadImg.frame.midY - coverViewRadius
//        userVoiceHeaderCover.frame = CGRect(x: userVoiceButtonUIView.frame.maxX, y: coverViewY, width: coverViewRadius * 2, height: coverViewRadius * 2)
//        userVoiceHeaderCover.layer.cornerRadius = coverViewRadius
//        userVoiceHeaderCover.layer.masksToBounds = true
//        userVoiceHeaderCover.backgroundColor = UIColor.white//self.contentView.backgroundColor
        
        let resultWidth = imgHeight
        let resultX = userVoiceButtonUIView.frame.minX - resultWidth / 2
        let resultY = userImgY + (imgHeight - resultWidth) / 2
        userVoiceResultImg.frame = CGRect(x: resultX, y: resultY, width: resultWidth, height: resultWidth)
        userVoiceResultImg.layer.cornerRadius = resultWidth / 2
        userVoiceResultImg.layer.masksToBounds = true
        
        let exampleY = userHeadImg.frame.maxY + ChatReviewTableCell.userDis
        let exampleWidth = CGFloat(60)
        let exampleX = voiceButtonX
        exampleButton.frame = CGRect(x: exampleX, y: exampleY, width: exampleWidth, height: imgHeight)
        exampleButton.layer.borderWidth = 1
        exampleButton.layer.borderColor = UIColor(0x6196d6).cgColor
        exampleButton.layer.cornerRadius = 10
        exampleButton.layer.masksToBounds = true
    }

    @objc func tap(){
        self.userVoiceButton.play()
    }
    
    func setViewsFrame() {
        setQuestionViews()
        setUserViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets.init(top: 0, left: 0, bottom: ChatReviewTableCell.cellDis, right: 0))
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        
        setViewsFrame()
    }
}


class ReviewMedalScoreView: UIView {
    var imageView: UIImageView!
    var textLabel: UILabel!
    var score:Int = 0 {
        didSet {
            setContent()
        }
    }
    override init(frame: CGRect) {
        super.init(frame:frame)
        imageView = UIImageView(frame:CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        imageView.contentMode = .scaleAspectFill
        textLabel = UILabel(frame:CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        
        textLabel.textColor = UIColor.white
        textLabel.textAlignment = .center
        textLabel.font = FontUtil.getFont(size: 12, type: .Regular)
        addSubview(imageView)
        addSubview(textLabel)
        
    }
    
    func setFrames() {
        imageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        textLabel.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }
    
    func setContent() {
        if score < 60 {
            imageView.image = ChImageAssets.medalGray.image
        }
        else {
            imageView.image = ChImageAssets.medalGolden.image
        }
        textLabel.text = "\(score)"
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setFrames()
    }
}

class ChatPlayExampleView: UIView {
    var playButton: LCVoiceButton!
    var exampleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        playButton = LCVoiceButton(frame: CGRect.zero, style: .right)
        self.addSubview(playButton)
        exampleLabel = UILabel(frame: CGRect.zero)
        self.addSubview(exampleLabel)
        
        isUserInteractionEnabled = true
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(play))
        addGestureRecognizer(recognizer)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func play() {
        playButton.play()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let buttonWidth: CGFloat = 10
        let buttonX:CGFloat = self.frame.width - buttonWidth - 5
        let buttonY = (frame.height - buttonWidth) / 2
        playButton.frame = CGRect(x: buttonX, y: buttonY, width: buttonWidth, height: buttonWidth)
        
        exampleLabel.frame = CGRect(x: 10, y: 0,
                                             width: 60,
                                             height: frame.height)
//        exampleLabel.font = FontUtil.getFont(size: 8, type: .Medium)
        exampleLabel.text = "Model"
        exampleLabel.textAlignment = .left
        exampleLabel.font = FontUtil.getFont(size: 9, type: .Medium)
        exampleLabel.textColor = UIColor.hex(hex: "6c9ed9")
    }
}

class LCVerticalCenterLabel: UIView {
    var content: UILabel!
    var leftDis: CGFloat = 6
    var rightDis: CGFloat = 6
    var backView: UIView!
    var tailImage: UIImageView!
    static let textTopAndBottomDis: CGFloat = 6
    var text: String = "" {
        didSet {
            self.content.text = text
        }
    }
    var font: UIFont = FontUtil.getFont(size: 12, type: .Regular){
        didSet {
            self.content.font = font
        }
    }
    var textColor: UIColor = UIColor.black {
        didSet {
            self.content.textColor = textColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backView = UIView(frame: frame)
        tailImage = UIImageView(frame: frame)
        backView.layer.cornerRadius = 10
        backView.backgroundColor = UIColor.hex(hex: "e2ebf7")
        tailImage.image = UIImage(named: "tail")
        self.addSubview(tailImage)
        self.addSubview(backView)
        content = UILabel(frame: CGRect.zero)
        content.numberOfLines = 0
        content.lineBreakMode = .byWordWrapping
        content.text = ""
//        self.clipsToBounds = false
        backView.addSubview(content)
        
        
//        self.addSubview(bubble)
//
//        bubble.backgroundColor = UIColor.red
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentWidth = frame.width - leftDis - rightDis
        let contentHeight = self.content.text!.height(withConstrainedWidth: contentWidth, font: content.font)
        let contentY = (frame.height - contentHeight) / 2
        
        content.frame = CGRect(x: leftDis, y: contentY, width: contentWidth, height: contentHeight)
    }
    
    func setframe(frame:CGRect){
        self.frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
        backView.frame = CGRect(x: 5, y: 0, width: frame.width, height: frame.height)
        tailImage.frame = CGRect(x: 0, y: frame.height-20, width: 20, height: 20)
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
