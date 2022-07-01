//
//  ProfileHeaderView.swift
//  PracticeChinese
//
//  Created by Anika Huo on 7/29/17.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

protocol MeItemViewDelegate {
    func tapItem(sender: MeItemView)
}

class MeItemView: UIView {
    var iconImageView: UIImageView!
    var itemTitleView: UILabel!
    var delegate:MeItemViewDelegate?
    var badge: UILabel!
    var viewWidth:CGFloat!
    var viewHeight:CGFloat!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
        viewWidth = SlideMenuOptions.leftViewWidth
        viewHeight = ScreenUtils.size(size: 44)
        iconImageView = UIImageView(frame: CGRect(x: ScreenUtils.size(size: 20), y: (viewHeight - ScreenUtils.size(size: 23))/2, width: ScreenUtils.size(size: 23), height: ScreenUtils.size(size: 23)))
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.image = UserManager.shared.isLoggedIn() ? ChImageAssets.mePageAchievements.image : ChImageAssets.mePageAchievementsGrey.image
        
        addSubview(iconImageView)
        
        itemTitleView = UILabel(frame: CGRect(x: ScreenUtils.size(size: 60), y: ScreenUtils.size(size: 10), width: frame.width - ScreenUtils.widthBySix(x: 130), height: ScreenUtils.size(size: 24)))
        itemTitleView.font = FontUtil.getFont(size: 16, type: .Medium)
        itemTitleView.textColor = UIColor.hex(hex: "#333333")
        itemTitleView.text = "Achievements"
        itemTitleView.textAlignment = .center
        addSubview(itemTitleView)
        
        itemTitleView.sizeToFit()
        badge = UILabel(frame: CGRect(x: 0, y: ScreenUtils.size(size: 12), width:ScreenUtils.size(size: 20), height: ScreenUtils.size(size: 20)))
        badge.text = String(0)
        badge.backgroundColor = UIColor.hex(hex: "#F2C94C")
        badge.textColor = UIColor.white
        badge.layer.cornerRadius = ScreenUtils.size(size: 10)
        badge.layer.masksToBounds = true
        badge.textAlignment = .center
        badge.font = FontUtil.getFont(size: FontAdjust().FontSize(12), type: .Regular)
        addSubview(badge)
        if(AppData.userAssessmentEnabled && UserManager.shared.isLoggedIn()){
            badge.isHidden = false
        }else{
            badge.isHidden = true
        }
    }
    func setContent(image:UIImage, title:String) {
        iconImageView.image = image
        itemTitleView.text = title
        itemTitleView.sizeToFit()
        reloadMeItemView()
    }
    
    func getLabelWidth(labelStr:NSString,font:UIFont)->CGFloat{
        let maxSie:CGSize = CGSize(width:self.frame.width,height:ScreenUtils.size(size: 30))
        return labelStr.boundingRect(with: maxSie, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):font]), context: nil).size.width
    }
    
    func setContent(image:UIImage,title:String, count:Int) {
        iconImageView.image = image
        itemTitleView.text = title
        badge.text = String(count)
        var labelWidth = getLabelWidth(labelStr: "\(String(count))" as NSString, font: FontUtil.getFont(size: FontAdjust().FontSize(12), type: .Regular))
        labelWidth += ScreenUtils.size(size: 15)
        if labelWidth < ScreenUtils.size(size: 20) {
            labelWidth = ScreenUtils.size(size: 20)
        }
        
        badge.frame = CGRect(x: viewWidth - ScreenUtils.size(size: 15) - labelWidth, y: badge.frame.origin.y, width: labelWidth, height: ScreenUtils.size(size: 20))
        itemTitleView.sizeToFit()
        badge.isHidden = false
        reloadMeItemView()
        if count == -1 {
            badge.isHidden = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadMeItemView(){
        if(AppData.userAssessmentEnabled && UserManager.shared.isLoggedIn()){
            badge.isHidden = false
        }else{
            badge.isHidden = true
        }
    }
}



class ExpProgressView: UIView {
    
    var bgColor = UIColor.hex(hex: "#afdcb2") {
        didSet {
            deltaBar.backgroundColor = bgColor
        }
    }
    
    var fgColor = UIColor.hex(hex: "#6dc772") {
        didSet {
            pastBar.backgroundColor = fgColor
            titleLable.textColor = fgColor
            unitLabel.textColor = fgColor
            countLabel.textColor = fgColor
            deltaLabel.textColor = bgColor
            
        }
    }
    
    var titleLable:UILabel!
    var unitLabel:UILabel!
    var countLabel:UILabel!
    var deltaLabel:UILabel!
    var levelLabel:UILabel!
    
    var totalBar:UIView!
    var pastBar:UIView!
    var deltaBar:UIView!
    
    var totalWidth:CGFloat!
    
    var medalImageView:UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        let medalWidth = ScreenUtils.widthBySix(x: 85)
        let medalHeight = ScreenUtils.heightBySix(y: 82)
        let medalX = frame.width - medalWidth
        
        
        levelLabel = UILabel(frame: CGRect(x: medalX - ScreenUtils.widthBySix(x: 26), y: ScreenUtils.heightBySix(y: 20), width: medalWidth, height: medalHeight))
        levelLabel.font = FontUtil.getFont(size: 15, type: .Regular)
        
        levelLabel.textColor = UIColor.black
        levelLabel.textAlignment = .center
        levelLabel.text = ""
        
        medalImageView = UIImageView(frame: CGRect(x: medalX - ScreenUtils.widthBySix(x: 26), y: ScreenUtils.heightBySix(y: 24), width: medalWidth, height: medalHeight))
        
        medalImageView.image = ChImageAssets.medalGray.image
        levelLabel.textColor = UIColor.white
        
        if(UserManager.shared.isLoggedIn()){
            levelLabel.isHidden = false
        }else{
            levelLabel.isHidden = true
        }
        medalImageView.contentMode = .scaleAspectFit
        
        totalWidth = medalX - ScreenUtils.widthBySix(x: 130)
        
        titleLable = UILabel(frame: CGRect(x: 0, y: ScreenUtils.heightBySix(y: 31), width: ScreenUtils.widthBySix(x: 125), height: ScreenUtils.heightBySix(y: 36)))
        titleLable.font = FontUtil.getFont(size: 12, type: .Regular)
        titleLable.textColor = fgColor
        titleLable.textAlignment = .center
        addSubview(titleLable)
        
        unitLabel = UILabel(frame: CGRect(x: 0, y: ScreenUtils.heightBySix(y: 77), width: ScreenUtils.widthBySix(x: 120), height: ScreenUtils.heightBySix(y: 36)))
        unitLabel.font = FontUtil.getFont(size: 12, type: .Regular)
        unitLabel.textColor = fgColor
        unitLabel.textAlignment = .center
        addSubview(unitLabel)
        
        countLabel = UILabel(frame: CGRect(x: ScreenUtils.widthBySix(x: 130), y: ScreenUtils.heightBySix(y: 77), width: ScreenUtils.widthBySix(x: 120), height: ScreenUtils.heightBySix(y: 36)))
        countLabel.font = FontUtil.getFont(size: 12, type: .Regular)
        countLabel.textColor = fgColor
        countLabel.textAlignment = .center
        addSubview(countLabel)
        
        deltaLabel = UILabel(frame: CGRect(x: ScreenUtils.widthBySix(x: 130), y: ScreenUtils.heightBySix(y: 77), width: ScreenUtils.widthBySix(x: 120), height: ScreenUtils.heightBySix(y: 36)))
        deltaLabel.font = FontUtil.getFont(size: 12, type: .Regular)
        deltaLabel.textColor = bgColor
        deltaLabel.textAlignment = .left
        addSubview(deltaLabel)
        
        
        totalBar = UIView(frame: CGRect(x: ScreenUtils.widthBySix(x: 130), y: ScreenUtils.heightBySix(y: 40), width: medalX - ScreenUtils.widthBySix(x: 130), height: ScreenUtils.heightBySix(y: 18)))
        totalBar.layer.cornerRadius = ScreenUtils.heightBySix(y: 9)
        totalBar.backgroundColor = UIColor.hex(hex: "#dcdcdc")
        addSubview(totalBar)
        
        deltaBar = UIView(frame: CGRect(x: ScreenUtils.widthBySix(x: 130), y: ScreenUtils.heightBySix(y: 40), width: 40, height: ScreenUtils.heightBySix(y: 18)))
        deltaBar.layer.cornerRadius = ScreenUtils.heightBySix(y: 9)
        deltaBar.backgroundColor = bgColor
        addSubview(deltaBar)
        
        pastBar = UIView(frame: CGRect(x: ScreenUtils.widthBySix(x: 130), y: ScreenUtils.heightBySix(y: 40), width: 30, height: ScreenUtils.heightBySix(y: 18)))
        pastBar.layer.cornerRadius = ScreenUtils.heightBySix(y: 9)
        pastBar.backgroundColor = fgColor
        addSubview(pastBar)
        
        addSubview(medalImageView)
        
        addSubview(levelLabel)
        
    }
    
    func setContent(title:String, unit:String, count:Int, delta:Int, limit:Int, level:Int) {
        titleLable.text = title
        unitLabel.text = unit
        levelLabel.text = String(level)
        countLabel.text = "\(count-delta)"
        var countLabelW:CGFloat = CGFloat(130)
        
        if(limit != 0){
            deltaBar.frame = CGRect(x: deltaBar.frame.minX, y: deltaBar.frame.minY, width: totalWidth * CGFloat(count) / CGFloat(limit), height: deltaBar.frame.height)
            pastBar.frame = CGRect(x: pastBar.frame.minX, y: pastBar.frame.minY, width: totalWidth * CGFloat(count-delta) / CGFloat(limit), height: pastBar.frame.height)
        }else{
            deltaBar.frame = CGRect(x: deltaBar.frame.minX, y: deltaBar.frame.minY, width: 0, height: deltaBar.frame.height)
            pastBar.frame = CGRect(x: pastBar.frame.minX, y: pastBar.frame.minY, width: 0, height: pastBar.frame.height)
        }
        
        countLabelW = deltaBar.frame.maxX - deltaBar.frame.minX
        
        if(countLabelW < countLabel.intrinsicContentSize.width){
            countLabelW = countLabel.intrinsicContentSize.width
        }
        
        countLabel.frame = CGRect(x: ScreenUtils.widthBySix(x: CGFloat(130)), y: ScreenUtils.heightBySix(y: 77), width: countLabelW, height: ScreenUtils.heightBySix(y: 36))
        
        
        if (delta > 0) {
            deltaLabel.text = "+\(delta)"
            deltaLabel.frame = CGRect(x: max(countLabel.frame.maxX+10, pastBar.frame.maxX), y: ScreenUtils.heightBySix(y: 77), width: deltaLabel.intrinsicContentSize.width, height: ScreenUtils.heightBySix(y: 36))
            
        }
        
        if(level == 0){
            medalImageView.image = ChImageAssets.medalGray.image
        }else{
            medalImageView.image = ChImageAssets.mePageMedal.image
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class ProfileHeaderView: UIView {
    var bgView:UIView!
    var avatarView: UIImageView!
    var nameLabel: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.masksToBounds = true
        
        self.backgroundColor = UIColor.white
        
        bgView = UIView(frame:CGRect(x: 0, y: 0, width: frame.width, height: ScreenUtils.heightBySix(y: 264)))
        bgView.backgroundColor = UIColor.blueTheme
        addSubview(bgView)
        
        bgView.snp.makeConstraints { (make) -> Void in
            make.top.bottom.left.right.equalTo(self)
        }
        
        avatarView = UIImageView(frame: CGRect(x: frame.width * 0.5 - ScreenUtils.heightBySix(y: 67.5), y: ScreenUtils.heightBySix(y: 35), width: ScreenUtils.heightBySix(y: 135), height: ScreenUtils.heightBySix(y: 135)))
        avatarView.sd_setImage(with: UserManager.shared.getAvatarUrl(), placeholderImage: ChImageAssets.Avatar.image, options: .refreshCached, completed: nil)
        avatarView.layer.cornerRadius = UIAdjust().adjustByHeight(37.5)
        avatarView.layer.masksToBounds = true
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapSignIn))
        avatarView.addGestureRecognizer(recognizer)
        avatarView.isUserInteractionEnabled = true
        bgView.addSubview(avatarView)
        nameLabel = UILabel(frame: CGRect(x: ScreenUtils.widthBySix(x: 20), y: ScreenUtils.heightBySix(y: 170), width: ScreenUtils.widthBySix(x: 40), height: ScreenUtils.heightBySix(y: 80)))
        nameLabel.textAlignment = .center
        nameLabel.text = UserManager.shared.getName()
        nameLabel.font = FontUtil.getFont(size: 18, type: .Medium)
        nameLabel.sizeToFit()
        nameLabel.textColor = UIColor.white
        bgView.addSubview(nameLabel)
        
        
        nameLabel.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(bgView)
            make.left.equalTo(avatarView.snp.right).offset(UIAdjust().adjustByWidth(20))
            make.height.equalTo(UIAdjust().adjustByHeight(24))
        }
        
        
        avatarView.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(bgView)
            make.left.equalTo(bgView).offset(UIAdjust().adjustByWidth(20))
            make.height.width.equalTo(UIAdjust().adjustByHeight(75))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tapSignIn(sender: UITapGestureRecognizer!) {
        if !UserManager.shared.isLoggedIn() {
            let vc = LoginFullViewController()
            let mc = self.yy_viewController?.slideMenuController()?.mainViewController as! UINavigationController
            self.yy_viewController?.slideMenuController()?.closeLeftWithVelocity(1000)
            mc.pushViewController(vc, animated: true)
        }
    }
    
    func reload() {
        nameLabel.text = UserManager.shared.getName()
        if UserManager.shared.isLoggedIn(){
            avatarView.sd_setImage(with: UserManager.shared.getAvatarUrl(), placeholderImage: ChImageAssets.Placeholder_Avatar.image, options: .refreshCached, completed: nil)
        }else {
            avatarView.sd_setImage(with: UserManager.shared.getAvatarUrl(), placeholderImage: ChImageAssets.Avatar.image, options: .refreshCached, completed: nil)
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
