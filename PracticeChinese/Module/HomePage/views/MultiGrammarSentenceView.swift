//
//  MultiGrammarSentenceView.swift
//  PracticeChinese
//
//  Created by ThomasXu on 28/06/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation

class MultiGrammarSentenceView: UIView {
    
    var titleLabel: UILabel!
    var heightNeeded: CGFloat = 0
    var grammarViews = [GrammarSentenceView]()
    var items = [ScenarioLessonLearningItem]() {
        didSet {
            setGrammars()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSubviews() {let titleY: CGFloat = 0
        let titleFont = FontUtil.getFont(size: 16, type: .Regular)
        let titleWidth = frame.width * 1
        let titleX = (frame.width - titleWidth) / 2
        titleLabel = UILabel(frame: CGRect(x: titleX, y: titleY, width: titleWidth, height: titleFont.lineHeight + 10))
        titleLabel.text = "Grammar"
        titleLabel.textAlignment = .center
        titleLabel.backgroundColor = UIColor.hex(hex: "e1edf9")
        self.addSubview(titleLabel)
        setTestGrammars()
    }
    
    func setTestGrammars() {
        self.heightNeeded = titleLabel.frame.maxY + 10
        let sentenceWidth = self.frame.width//contentView.frame.width
        let sentenceX: CGFloat = 0
        let tempHeight: CGFloat = 100
        let dis: CGFloat = 10
        for i in 0...3 {
            let sentenceView = GrammarSentenceView(frame: CGRect(x: sentenceX, y: self.heightNeeded, width: sentenceWidth, height: tempHeight),
                                                   grammar: "恭喜你！你一定激动坏了。恭喜你！你一定激动坏了。",
                                                   native: "english english english english english english ")
            let height = sentenceView.getNewHeight()
            sentenceView.frame = CGRect(x: sentenceX, y: self.heightNeeded, width: sentenceWidth, height: height)
            self.heightNeeded += height + dis
            self.addSubview(sentenceView)
            grammarViews.append(sentenceView)
        }
    }
    
    func setGrammars() {
        self.heightNeeded = titleLabel.frame.maxY + 10
        let sentenceWidth = self.frame.width//contentView.frame.width
        let sentenceX: CGFloat = 0
        let tempHeight: CGFloat = 100
        let dis: CGFloat = 10
        for grammar in self.grammarViews {
            grammar.removeFromSuperview()
        }
        self.grammarViews.removeAll()
        for (i,word) in items.enumerated() {
            if word.ItemType == 1 {
                let sentenceView = GrammarSentenceView(frame: CGRect(x: sentenceX, y: self.heightNeeded, width: sentenceWidth, height: tempHeight),
                                                       grammar: word.Text!,
                                                       native: word.NativeText)
                sentenceView.voiceButton.audioUrl = word.AudioUrl
                let height = sentenceView.getNewHeight()
                sentenceView.frame = CGRect(x: sentenceX, y: self.heightNeeded, width: sentenceWidth, height: height)
                self.heightNeeded += height + dis
                self.addSubview(sentenceView)
                grammarViews.append(sentenceView)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}


class GrammarSentenceView: GrammarItemView {
    
    var grammarSentence: UILabel!
    var nativeLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, grammar: String, native: String?) {
        self.init(frame: frame)
        if nil != native {
            self.setSubviews(grammar: grammar, native: native!)
        } else {
            self.setSubviews(grammar: grammar, native: "")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSubviews(grammar: String, native: String) {
        let voiceWidth: CGFloat = 0//16
        let voiceX = self.frame.width - 4 - voiceWidth
        
        let sentenceX: CGFloat = 6
        let sentenceWidth = voiceX - 4 - sentenceX
        let sentenceY: CGFloat = 0
        let sentenceFont = FontUtil.getFont(size: 16, type: .Regular)
        let sentenceHeight = grammar.height(withConstrainedWidth: sentenceWidth, font: sentenceFont)
        grammarSentence = UILabel(frame: CGRect(x: sentenceX, y: sentenceY, width: sentenceWidth, height: sentenceHeight))
        grammarSentence.font = sentenceFont
        grammarSentence.text = grammar
        grammarSentence.numberOfLines = 0
        grammarSentence.lineBreakMode = .byWordWrapping
        self.addSubview(grammarSentence)
        
        let voiceY = grammarSentence.frame.midY - voiceWidth / 2
        voiceButton = LCVoiceButton(frame: CGRect(x: voiceX, y: voiceY, width: voiceWidth, height: voiceWidth), style:.speaker)
        voiceButton.changeToSpeakerImages()
        
        let nativeFont = FontUtil.getFont(size: 14, type: .Regular)
        let nativeY = grammarSentence.frame.maxY
        let nativeHeight = native.height(withConstrainedWidth: sentenceWidth, font: nativeFont)
        nativeLabel = UILabel(frame: CGRect(x: sentenceX, y: nativeY, width: sentenceWidth, height: nativeHeight))
        nativeLabel.font = nativeFont
        nativeLabel.text = native
        nativeLabel.numberOfLines = 0
        nativeLabel.lineBreakMode = .byWordWrapping
        self.addSubview(nativeLabel)
        
    }
    
    func getNewHeight() -> CGFloat {
        let newHeight = self.nativeLabel.frame.maxY
        return newHeight
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    }
}

protocol GrammarItemViewDelegate {
    func tapAtIndex(index: Int)
}

class GrammarItemView: UIView {
    var voiceButton: LCVoiceButton!
    var delegate : GrammarItemViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapItem))
        gesture.numberOfTouchesRequired = 1
        self.addGestureRecognizer(gesture)
        self.layer.cornerRadius = 6
        self.layer.masksToBounds = true
    }
    @objc func tapItem() {
        self.voiceButton.play()
        self.delegate?.tapAtIndex(index: self.tag)
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/*
class GrammarSentenceView: UIView {
    
    var grammarSentence: UILabel!
    var nativeLabel: UILabel!
    
    var voiceButton: LCVoiceButton!
    var descriptionLabel: UILabel!
    var lineLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, hanziSentence: String, pinyinSentence: String, description: String) {
        self.init(frame: frame)
        
        self.setSubviews(sentence: hanziSentence, pinyin: pinyinSentence, description: description)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSubviews(sentence: String, pinyin: String, description: String) {
        
        let sentenceWidth = frame.width
        let sentenceY: CGFloat = 0
        let sentenceX: CGFloat = 0
        let sentenceFont = FontUtil.getFont(size: 16, type: .Regular)
        let sentenceHeight = sentence.height(withConstrainedWidth: sentenceWidth, font: sentenceFont)
        grammarSentence = UILabel(frame: CGRect(x: sentenceX, y: sentenceY, width: sentenceWidth, height: sentenceHeight))
        grammarSentence.font = sentenceFont
        grammarSentence.text = sentence
        grammarSentence.numberOfLines = 0
        grammarSentence.lineBreakMode = .byWordWrapping
        self.addSubview(grammarSentence)
        
        let pinyinFont = FontUtil.getFont(size: 14, type: .Regular)
        let pinyinY = grammarSentence.frame.maxY
        let pinyinHeight = pinyin.height(withConstrainedWidth: sentenceWidth, font: pinyinFont)
        nativeLabel = UILabel(frame: CGRect(x: sentenceX, y: pinyinY, width: sentenceWidth, height: pinyinHeight))
        nativeLabel.font = pinyinFont
        nativeLabel.text = pinyin
        nativeLabel.numberOfLines = 0
        nativeLabel.lineBreakMode = .byWordWrapping
        self.addSubview(nativeLabel)
        
        let voiceWidth: CGFloat = 20
        let voiceX = self.frame.width - sentenceX - voiceWidth
        let voiceY = grammarSentence.frame.midY
        voiceButton = LCVoiceButton(frame: CGRect(x: voiceX, y: voiceY, width: voiceWidth, height: voiceWidth))
        self.addSubview(voiceButton)
        
        let desY = nativeLabel.frame.maxY
        let descriptionFont = FontUtil.getFont(size: 14, type: .Regular)
        let descriptionWidth = self.frame.width
        let descriptionHeight = description.height(withConstrainedWidth: descriptionWidth, font: descriptionFont)
        descriptionLabel = UILabel(frame: CGRect(x: sentenceX, y: desY, width: descriptionWidth, height: descriptionHeight))
        descriptionLabel.font = descriptionFont
        descriptionLabel.textColor = UIColor(0x5d7ab6)
        descriptionLabel.text = description
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        self.addSubview(descriptionLabel)
    }
    
    func getNewHeight() -> CGFloat {
        let newHeight = self.descriptionLabel.frame.maxY
        return newHeight
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    }
    
}*/

