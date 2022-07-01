//
//  MePageViewController.swift
//  PracticeChinese
//
//  Created by Anika Huo on 7/29/17.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import DCAnimationKit


class MePageViewController: UIViewController,UIScrollViewDelegate,SettingViewDelegate,UITableViewDelegate, UITableViewDataSource{
    func superViewConstraints() {
        
    }
    
    var profileView: ProfileHeaderView!
    var toastView = UILabel()
    var tableView: UITableView!
    var scroll:UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scroll = UIScrollView(frame: self.view.bounds)
        scroll.delegate = self
        scroll.isScrollEnabled = true
        self.scroll.backgroundColor = UIColor.white
        self.view.addSubview(scroll)
        scroll.snp.makeConstraints { (make) -> Void in
            make.left.bottom.right.top.equalTo(self.view)
        }
        
        self.view.backgroundColor = UIColor.groupTableViewBackground
        profileView = ProfileHeaderView(frame: CGRect(x: ScreenUtils.widthBySix(x: 20), y: ScreenUtils.heightBySix(y: 20), width: ScreenUtils.width - ScreenUtils.widthBySix(x: 40), height: ScreenUtils.heightBySix(y: 630)))
        self.scroll.addSubview(profileView)
        

        profileView.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.scroll)
            make.left.equalTo(self.scroll)
            make.right.equalTo(self.scroll)
            make.top.equalTo(self.scroll)
            make.height.equalTo(UIAdjust().adjustByHeight(130) + 45)
        }
        
        tableView = UITableView(frame: CGRect(x: 0, y: profileView.frame.maxY, width: ScreenUtils.width - ScreenUtils.widthBySix(x: 40), height: ScreenUtils.height - profileView.frame.maxY), style: .grouped)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.hex(hex: "f2f2f2")
        tableView.showsVerticalScrollIndicator = false
        tableView.register(MePageCell.self, forCellReuseIdentifier: "MePageCell")

        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.scroll)
            make.left.equalTo(self.scroll)
            make.right.equalTo(self.scroll)
            make.top.equalTo(profileView.snp.bottom).offset(UIAdjust().adjustByWidth(0))
            make.bottom.equalTo(self.scroll)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(reloadUserInfo), name: ChNotifications.UserSignedIn.notification, object: nil)
        //退出后重新加载数据
//        NotificationCenter.default.addObserver(self, selector: #selector(reloadUserInfo), name: ChNotifications.UserSignedOut.notification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCounts), name: ChNotifications.UpdateMePage.notification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCounts), name: ChNotifications.UpdateCourseProgress.notification, object: nil)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MePageCell") as! MePageCell
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.setContent(image: UserManager.shared.isLoggedIn() ? ChImageAssets.mePageLearnedWords.image! : ChImageAssets.mePageLearnedWordsGray.image! , title: "My Words",count:CourseManager.shared.getFinishedWordCount())
            }else {
                cell.setContent(image: UserManager.shared.isLoggedIn() ? ChImageAssets.mePageCompletedLessons.image! : ChImageAssets.mePageCompletedLessonsGray.image!, title: "My Work",count:CourseManager.shared.getFinishedLessonCount() + CourseManager.shared.getFinishedPractiseLessonCount())
            }
        }else {
            cell.setContent(image: ChImageAssets.mePageSetting.image!, title: "Settings", count: -1)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ScreenUtils.size(size: 44)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2:1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        if section == 1 {
            let seperatorLine1 = UIView(frame: CGRect(x: 20, y: 10, width: ScreenUtils.width - ScreenUtils.widthBySix(x: 40) - ScreenUtils.widthBySix(x: 100), height: ScreenUtils.heightBySix(y: 1)))
            seperatorLine1.backgroundColor = UIColor.hex(hex:"#dcdcdc")
            view.addSubview(seperatorLine1)
            seperatorLine1.snp.makeConstraints { (make) -> Void in
                make.right.equalTo(view).offset(-20)
                make.left.equalTo(view).offset(20)
                make.top.equalTo(view.snp.top).offset(10)
                make.height.equalTo(1)
            }
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if !UserManager.shared.isLoggedIn() && indexPath.section != 1 {
            self.profileView.avatarView.tada(nil)
            return
        }
        if indexPath.section == 1 {
//            UserManager.shared.logUserClick(["AppClick":"Setting"])
            
            let vc = MeSettingViewController()
            vc.hidesBottomBarWhenPushed = true
            self.slideMenuController()?.closeLeftWithVelocity(1000)
            let mc = self.slideMenuController()?.mainViewController as! UINavigationController
            mc.pushViewController(vc, animated: true)
            return
        }
        switch (indexPath.row) {
        case 0:
//            UserManager.shared.logUserClick(["AppClick":"LearnedWords"])
            
            let vc = LearnedWordsViewController()
            vc.hidesBottomBarWhenPushed = true
            self.slideMenuController()?.closeLeftWithVelocity(1000)
            let mc = self.slideMenuController()?.mainViewController as! UINavigationController
            mc.pushViewController(vc, animated: true)
            
        case 1:
//            UserManager.shared.logUserClick(["AppClick":"LearnedLesson"])
            
            let vc = LearnedLessonsViewController()
            let nv = UINavigationController(rootViewController: vc)
            vc.hidesBottomBarWhenPushed = true
            self.slideMenuController()?.closeLeftWithVelocity(1000)
            let mc = self.slideMenuController()?.mainViewController as! UINavigationController
            
            mc.pushViewController(vc, animated: true)

        default:
            break
        }
    }
    @objc func updateCounts(){
        self.reloadMeItemView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Me"
        self.navigationController?.navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary(self.ch_getTitleAttribute())
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.fromColor(color: UIColor.blueTheme), for: .default)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.profileView.reload()
        self.reloadMeItemView()
        //设置开车模式
        
        let customButton = UIButton(frame: CGRect(x: 0, y: 0, width: 21, height: 18))
        customButton.applyNavBarConstraints(size: (width: 21, height: 18))
        customButton.tintColor = UIColor.white
        customButton.setImage(ChImageAssets.HeadSet.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        customButton.addTarget(self, action: #selector(testButton), for: .touchUpInside)
        let rightButton = UIBarButtonItem(customView: customButton)
        self.navigationItem.setRightBarButton(rightButton, animated: false)
        customButton.isHidden = true
    }
   
    @objc func testButton(){
        let view = SettingView(frame: CGRect.zero)
        UIApplication.shared.keyWindow!.addSubview(view)
        view.delegate = self
        view.snp.makeConstraints { (make) -> Void in
            make.left.right.top.bottom.equalTo(UIApplication.shared.keyWindow!)
        }
    }
    
    func travelStartEvent(sender: AnyObject) {
        /*let vc = HandsFreeViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.lid = AppData.chatScenarioId
        self.ch_pushViewController(vc, animated: true)*/
    }

    @objc func reloadUserInfo() {
        self.profileView.reload()
        self.reloadMeItemView()
        CourseManager.shared.SetCoursesList()

    }
    
    func reloadMeItemView(){
        tableView.reloadData()
    }
    
}

class MePageCell:UITableViewCell {
    var itemView:MeItemView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        itemView = MeItemView(frame: CGRect(x: 0, y: 0, width: SlideMenuOptions.leftViewWidth, height:  self.bounds.height))
        contentView.addSubview(itemView)
        backgroundColor = UIColor.hex(hex: "f2f2f2")
    }
    
    func setContent(image:UIImage,title:String, count:Int) {
        itemView.setContent(image: image, title: title, count:count)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        itemView.badge.backgroundColor = UIColor.hex(hex: "#F2C94C")
    }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        itemView.badge.backgroundColor = UIColor.hex(hex: "#F2C94C")
    }
    
}
















// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
