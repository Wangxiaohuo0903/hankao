//
//  CollectionViewCell.swift
//  SwiftCollectionView
//
//  Created by 栗子 on 2017/8/22.
//  Copyright © 2017年 http://www.cnblogs.com/Lrx-lizi/. All rights reserved.
//

import UIKit



class CollectionViewCell: UICollectionViewCell {

    var Landbutton = UIButton()
    // 土地背景，
    var LandBgView = UIView()
    // Done！
    var doneLabel = UILabel()

    let clearance = CGFloat(24)
    var shadowLayer = CALayer()
    var collectCellNum: CGFloat = 4
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if AdjustGlobal().CurrentScale == AdjustScale.iPad {
            collectCellNum = 6.0
        }
        self.creareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func creareUI(){
        if AdjustGlobal().CurrentScale == AdjustScale.iPad {
            collectCellNum = 6.0
        }

        let landWidth = (ScreenUtils.width - clearance)/collectCellNum - 8
        let landHeight = (ScreenUtils.width - clearance)/collectCellNum  * 1.1 - 8
        
        self.LandBgView.frame = CGRect(x: 4, y: 4, width: landWidth, height:landHeight)
        self.LandBgView.layer.cornerRadius = 10
        self.LandBgView.layer.masksToBounds = true
        self.LandBgView.backgroundColor = UIColor.hex(hex: "776254")
        self.LandBgView.isUserInteractionEnabled = false
        self.contentView.addSubview(self.LandBgView)
        
        self.Landbutton.frame = CGRect(x: 0, y: 0, width: landWidth, height:landHeight)
        self.Landbutton.isUserInteractionEnabled = false
        LandBgView.addSubview(self.Landbutton)
        
        self.doneLabel.frame = CGRect(x: 0, y: self.Landbutton.frame.maxY, width: landWidth, height:18)
        self.doneLabel.text = "DONE!"
        self.doneLabel.textAlignment = .center
        self.doneLabel.textColor = UIColor.hex(hex: "365B00")
        self.doneLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(12), type: .Medium)
        self.doneLabel.isHidden = true
        LandBgView.addSubview(self.doneLabel)
        
    }
    func setData(course:ScenarioSubLessonInfo?,status:Int) {
        //status 表示状态
        let landWidth = (ScreenUtils.width - clearance)/collectCellNum - 8
        let landHeight = (ScreenUtils.width - clearance)/collectCellNum  * 1.1 - 8
        
        if status == 0 {
            //种子
            self.doneLabel.isHidden = true
            self.Landbutton.frame = CGRect(x: 0, y: 0, width: landWidth, height:landHeight)
            LandBgView.backgroundColor = UIColor.hex(hex: "E2F2CD")
            Landbutton.setBackgroundImage(UIImage(named: "seed"), for: .normal)
        }else if status == 1 {
            //发芽
            self.doneLabel.isHidden = true
            self.Landbutton.frame = CGRect(x: 0, y: 0, width: landWidth, height:landHeight)
            LandBgView.backgroundColor = UIColor.hex(hex: "E2F2CD")
            Landbutton.setBackgroundImage(UIImage(named: "sprout"), for: .normal)
        }else if status == 2 {
            //果实
            self.doneLabel.isHidden = false
            self.Landbutton.frame = CGRect(x: landWidth * 0.15, y: landWidth * 0.10, width: landWidth * 0.7, height:landWidth * 0.7)
            LandBgView.backgroundColor = UIColor.hex(hex: "E2F2CD")
            var url = URL(string: "")
            if let courseData = course {
                if (courseData.ScenarioLessonInfo?.LessonIcons?.count)! > 0 {
                    url = URL(string: (courseData.ScenarioLessonInfo?.LessonIcons?[0])!)
                    Landbutton.sd_setBackgroundImage(with: url, for: .normal, placeholderImage: UIImage(named: "farm_1"), options: .retryFailed, completed: nil)
                }else {
                    if (courseData.ScenarioLessonInfo?.Tags?.count)! > 0 {
                        Landbutton.setBackgroundImage(UIImage(named: "farm_1"), for: .normal)
                    }
                }
            }else {
                Landbutton.setBackgroundImage(UIImage(named: "farm_1"), for: .normal)
            }
            self.doneLabel.frame = CGRect(x: 0, y: self.Landbutton.frame.maxY, width: landWidth, height:18)
        }else {
            //未解锁
            self.doneLabel.isHidden = true
            self.Landbutton.frame = CGRect(x: 0, y: 0, width: landWidth, height:landHeight)
            LandBgView.backgroundColor = UIColor.hex(hex: "E8E8E8")
            Landbutton.setBackgroundImage(UIImage(named: "unknown"), for: .normal)
        }
        
    }

}
class CollectionHeaderViewCell: UICollectionViewCell {

    //水果图片
    var fenceImage = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.creareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func creareUI(){
        self.fenceImage.isUserInteractionEnabled = false
        self.contentView .addSubview(self.fenceImage)
    }
}
