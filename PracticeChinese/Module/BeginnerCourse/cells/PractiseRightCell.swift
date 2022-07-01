//
//  PractiseRightCell.swift
//  PracticeChinese
//
//  Created by Temp on 2018/8/27.
//  Copyright © 2018年 msra. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class PractiseRightCell: UITableViewCell {
    //头像
    var avatarImg:UIImageView!
    //英语提示
    var enLabel: UILabel!
    var nameLabel: UILabel!
    var trophyImg: UIImageView!
    
    var bgMastar: UIView!
    //记录excellent个数
    var excellent = 0
    //打分时转圈
    var animateView: NVActivityIndicatorView!
    //埋点
    var Scope = ""
    var Subscope = ""
    var indexPathStr = ""
    var Lessonid = ""
    var Event = ""
    let cardRight: Int = 30
    let cardMaxWidth: Int = Int(AdjustGlobal().CurrentScaleWidth - 60)
    var disabled = false {
        didSet {
            if !disabled {
                UIView.animate(withDuration: 0.2) {
                    self.bgMastar.alpha = 0
                }
            }else {
                UIView.animate(withDuration: 0.2) {
                    self.bgMastar.alpha = 0.9
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none

        avatarImg = UIImageView(frame: CGRect(x: Int(ScreenUtils.width) - cardRight - 40, y: 0, width: 40, height: 40))
        avatarImg.layer.cornerRadius = 20
        avatarImg.layer.masksToBounds = true
        self.addSubview(avatarImg)
        
        nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width - 92, height: avatarImg.frame.height) )
        nameLabel.textColor = UIColor.textBlack333
        nameLabel.font = FontUtil.getFont(size: 14, type: .Regular)
        nameLabel.numberOfLines = 1
        nameLabel.textAlignment = .right
        self.addSubview(nameLabel)
        let animateWidth = 25
        animateView = NVActivityIndicatorView(frame: CGRect(x: Int(cardMaxWidth) - 55 - animateWidth, y: 10, width: animateWidth, height: animateWidth), type: .ballSpinFadeLoader, color: UIColor.hex(hex: "77a4e6"), padding: 0)
        self.addSubview(animateView)
        self.bringSubviewToFront(animateView)
        
        let trophyWidth = 50
        trophyImg = UIImageView(frame: CGRect(x: Int(CGFloat(cardMaxWidth) - 80 - CGFloat(trophyWidth)) - trophyWidth, y: Int(0), width: trophyWidth, height: 40))
        trophyImg.contentMode = .scaleAspectFill
        trophyImg.isHidden = true
        self.addSubview(trophyImg)

        var introFontE = FontUtil.getFont(size: 20, type: .Regular)
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhone4 || AdjustGlobal().CurrentScale == AdjustScale.iPhone5){
            introFontE = FontUtil.getFont(size: 16, type: .Regular)
        }
        enLabel = UILabel(frame: CGRect(x: 0, y: 50, width: 0, height: 0))
        enLabel.textColor = UIColor.textBlack333
        enLabel.font = introFontE
        enLabel.numberOfLines = 0
        enLabel.textAlignment = .left
        self.addSubview(enLabel)
        
        bgMastar = UIView(frame: CGRect(x: 0.0, y: 0.0, width: ScreenUtils.width, height: 0))
        bgMastar.backgroundColor = UIColor.white
        bgMastar.alpha = 0.9
        self.addSubview(bgMastar)
    }
    
    func startMakingScore(start: Bool) {
        if start {
            if (animateView != nil) {
                animateView.startAnimating()
            }
        }else {
            if (animateView != nil) {
                animateView.stopAnimating()
            }
        }
    }
    
    func showScoreResult(show:Bool,score:CGFloat) {
        if show {
            trophyImg.isHidden = false
            if (score < 60) {
                excellent = 0
                trophyImg.image = UIImage(named: "You can do better.")
            }else if (score >= 60 && score < 84) {
                excellent = 0
                trophyImg.image = UIImage(named: "Good")
            }else if (score >= 85) {
                excellent += 1
                if excellent == 1 {
                    trophyImg.image = UIImage(named: "EXCELLENT!")
                }else if  excellent == 2 {
                   trophyImg.image = UIImage(named: "EXCELLENT! x2")
                }else if  excellent == 3 {
                    trophyImg.image = UIImage(named: "EXCELLENT! x3")
                }else if  excellent == 4 {
                    trophyImg.image = UIImage(named: "EXCELLENT! x4")
                }else {
                    trophyImg.image = UIImage(named: "EXCELLENT!")
                }
            }
        }else {
            trophyImg.isHidden = true
        }
    }
    
    func setContent(msg: ChatMessageModel) {
        let en = msg.en
        if UserManager.shared.getAvatarUrl() != nil {
            avatarImg.sd_setImage(with: URL(string: msg.avatarUrl), placeholderImage: ChImageAssets.Placeholder_Avatar.image)
        }else {
            avatarImg.image = ChImageAssets.Placeholder_Avatar.image
        }
        let nameWidth = ("You".wdith(withConstrainedWidth: CGFloat(cardMaxWidth), font: FontUtil.getFont(size: 14, type: .Regular))) + 5
        nameLabel.frame = CGRect(x: ScreenUtils.width - 30 - 40 - 15 - nameWidth , y: 0, width: nameWidth, height: avatarImg.frame.height)
        nameLabel.text = "You"
        trophyImg.frame = CGRect(x: nameLabel.frame.minX - ScreenUtils.heightByM(y: 200), y: 0, width: ScreenUtils.heightByM(y: 200), height: 40)
        trophyImg.contentMode = .scaleAspectFit
        let animateWidth = 25
        self.animateView.frame = CGRect(x: Int(nameLabel.frame.minX - 40), y: 10, width: animateWidth, height: animateWidth)
        var introFontE = FontUtil.getFont(size: 20, type: .Regular)
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhone4 || AdjustGlobal().CurrentScale == AdjustScale.iPhone5){
            introFontE = FontUtil.getFont(size: 16, type: .Regular)
        }
        let englishHeight = en.string.height(withConstrainedWidth: CGFloat(cardMaxWidth), font: introFontE)
        let englishWidth = en.string.wdith(withConstrainedWidth: CGFloat(cardMaxWidth), font: introFontE)
        enLabel.frame = CGRect(x: CGFloat(cardMaxWidth - Int(englishWidth) + 30), y: 50, width: englishWidth, height: englishHeight)
        enLabel.attributedText = en
        
        let cellheight = englishHeight + 60
        bgMastar.frame = CGRect(x: 0.0, y: 0.0, width: ScreenUtils.width, height: cellheight)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
