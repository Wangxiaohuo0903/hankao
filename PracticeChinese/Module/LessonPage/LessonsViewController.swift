//
//  LessonsViewController.swift
//  PracticeChinese
//
//  Created by ThomasXu on 20/06/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit

class LessonHeaderView: UIView {
    
    var courseImage: UIImageView!
    var courseName: UILabel!
    var courseProgressView: LCProgressBar!
    var courseNativeName: UILabel!
    var courseImageUrl:String?
    var courseProgress: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func addSubviews() {
        courseImage = UIImageView(frame: CGRect.zero)
     //   courseImage.image = ChImageAssets.MeIcon2.image
        self.addSubview(courseImage)
        
        let nameFont = FontUtil.getFont(size: 18, type: .Regular)
        courseName = UILabel(frame: CGRect.zero)
        courseName.text = "住宿"
        courseName.textAlignment = .left
        courseName.font = nameFont
        self.addSubview(courseName)
        
        let courseEnglishFont = FontUtil.getFont(size: 14, type: .Regular)
        courseNativeName = UILabel(frame: CGRect.zero)
        courseNativeName.text = "Accommodation"
        courseNativeName.textAlignment = .left
        courseNativeName.font = courseEnglishFont
        courseNativeName.textColor = UIColor.black.withAlphaComponent(0.6)
        self.addSubview(courseNativeName)
        
        courseProgressView = LCProgressBar(frame: CGRect.zero)
        courseProgressView.progress = 0.6
//        self.addSubview(courseProgressView)
        
        let progressFont = FontUtil.getFont(size: 12, type: .Regular)
        courseProgress = UILabel(frame: CGRect.zero)
        courseProgress.text = "Completed 80%"
        courseProgress.textAlignment = .left
        courseProgress.font = progressFont
        courseProgress.textColor = courseNativeName.textColor
//        self.addSubview(courseProgress)
    }
    
    func setSubviewFrame() {
        let contentWidth = self.frame.width
        let contentHeight = self.frame.height
        let imgX: CGFloat = 10
        let imgHeight = contentHeight * 0.9
        let imgY = (contentHeight - imgHeight) / 2
        courseImage.frame = CGRect(x: imgX, y: imgY, width: imgHeight, height: imgHeight)
        courseImage.layer.cornerRadius = imgHeight / 2
        courseImage.layer.masksToBounds = true
        courseImage.contentMode = .scaleAspectFill
        courseImage.sd_setSVGImage(urlString: courseImageUrl)
        
        let labelX = courseImage.frame.maxX + 30
        let nameY = self.frame.height/2 - 20
        let labelWidth = contentWidth - labelX - 15
        courseName.frame = CGRect(x: labelX, y: nameY, width: labelWidth, height: courseName.font.lineHeight)
        
        let courseEnglishY = self.frame.height/2 + 5
        courseNativeName.frame = CGRect(x: labelX, y: courseEnglishY, width: labelWidth, height: courseName.font.lineHeight)
        
        let progressY = courseNativeName.frame.maxY + 20
        courseProgressView.frame = CGRect(x: labelX, y: progressY, width: labelWidth, height: 12)
        
        let progressLabelY = courseProgressView.frame.maxY + 6
        courseProgress.frame = CGRect(x: labelX, y: progressLabelY, width: labelWidth, height: courseProgress.font.lineHeight)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setSubviewFrame()
    }
}


//课程列表（4）
class LessonTableSectionHeader: UITableViewHeaderFooterView {
    
    var staticLabel: UILabel!
    var numberLabel: UILabel!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        staticLabel = UILabel(frame: CGRect.zero)
        staticLabel.font = FontUtil.getFont(size: 18, type: .Regular)
        staticLabel.text = "课程列表"
        self.contentView.addSubview(staticLabel)
        numberLabel = UILabel(frame: CGRect.zero)
        numberLabel.font = FontUtil.getFont(size: 14, type: .Regular)
        numberLabel.textColor = UIColor.black.withAlphaComponent(0.6)
        numberLabel.textAlignment = .left
        self.contentView.addSubview(numberLabel)
        numberLabel.text = "(4)"
    }
    
    func setSubviewFrame() {
        staticLabel.frame = CGRect(x: 0, y: 0, width: 40, height: staticLabel.font.lineHeight)
        staticLabel.sizeToFit()
        
        let numberX = staticLabel.frame.maxX + 4
        let numberY = contentView.frame.height - numberLabel.font.lineHeight
        let numberWidth = contentView.frame.width - staticLabel.frame.width - 20
        numberLabel.frame = CGRect(x: numberX, y: numberY, width: numberWidth, height: numberLabel.font.lineHeight)
     //   numberLabel.backgroundColor = UIColor.red
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let need = self.staticLabel.font.lineHeight
        let verticalDis = (frame.height - need) / 2
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets.init(top: verticalDis, left: 10, bottom: verticalDis, right: 0))
        self.setSubviewFrame()
    }
}

class LessonTableCell : UITableViewCell {
    
    var lessonIndex: UILabel!
    var lessonName: UILabel!
    var lessonIntroduction: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        lessonIndex = UILabel(frame: CGRect.zero)
        lessonIndex.font = FontUtil.getFont(size: 18, type: .Regular)
        lessonIndex.textAlignment = .left
        lessonIndex.text = "12."
        contentView.addSubview(lessonIndex)
        
        lessonName = UILabel(frame: CGRect.zero)
        lessonName.font = lessonIndex.font
        lessonName.textAlignment = .left
        lessonName.text = "介绍公寓"
        contentView.addSubview(lessonName)
        
        lessonIntroduction = UILabel(frame: CGRect.zero)
        lessonIntroduction.font = FontUtil.getFont(size: 12, type: .Regular)
        lessonIntroduction.textColor = UIColor.black.withAlphaComponent(0.6)
        lessonIntroduction.textAlignment = .left
        lessonIntroduction.text = "Introcution to an apartment"
        contentView.addSubview(lessonIntroduction)
    }
    
    func setSubviewsFrame() {
        let nameHeight = lessonName.font.lineHeight
        lessonIndex.frame = CGRect(x: 0, y: 0, width: 30, height: nameHeight)
        
        let nameX = lessonIndex.frame.maxX
        let nameWidth = contentView.frame.width - nameX
        lessonName.frame = CGRect(x: nameX, y: 0, width: nameWidth, height: nameHeight)
        
        let introductionY = contentView.frame.height - lessonIntroduction.font.lineHeight
        lessonIntroduction.frame = CGRect(x: nameX, y: introductionY, width: nameWidth, height: lessonIntroduction.font.lineHeight)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let needed = self.lessonName.font.lineHeight + lessonIntroduction.font.lineHeight + 4
        let verticalDis = (frame.height - needed) / 2
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets.init(top: verticalDis, left: 10, bottom: verticalDis, right: 10))
        
        setSubviewsFrame()
    }
    
    
}
