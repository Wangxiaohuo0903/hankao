
//  LearnPageViewController.swift
//  PracticeChinese
//
//  Created by 费跃 on 8/31/17.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper
import Alamofire
import SDWebImage
import MJRefresh
import FBSDKLoginKit
import NVActivityIndicatorView

enum CompletedStatus {
    case none
    case onlyLearn
    case onlySpeak
    case both
}


class LearnPageViewController: UIViewController,NetworkRequestFailedLoadDelegate {
    func reloadData() {
        refreshCurrentView()
    }
    
    func reloadTableView() {
        self.tableView.reloadData()
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    //加载失varvar的返回
    func backClick() {
        
    }
    /** 顶部刷新 */
    let header = MJRefreshNormalHeader()
    var lessons = [Lesson]()
    var showJuniorLesson = true
    var tableView: UITableView!
    var iconButton: UIButton!
    var landView: LandView!
    var sunNum : Int = 0
    var sunButton = UIButton()
    var contentOfSet = CGPoint(x: 0, y: 0)
    //转圈
    var animateView: NVActivityIndicatorView!
    let alertView = AlertNetworkRequestFailedView.init(frame: CGRect(x: 0, y: 60, width: ScreenUtils.width, height: ScreenUtils.height - 60))
    var progressViewArray = [LearnProgressView]()
    var imageViewArray = [UIImageView]()
    var headerView = UIView()
    var challengeLockStatus = [Bool]()
    var lockStatus = [Bool]() {
        didSet {
            if UserManager.shared.isLoggedIn() {
                newLand(learnSuccess: false)
            }else {
                self.navigationItem.setRightBarButton(nil, animated: true)
            }
        }
    }

    var beginnerCourseList = [[ScenarioSubLessonInfo?]]()
    
    func convertHeight(height:Int) -> Int {
        if (AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax || AdjustGlobal().CurrentScale == AdjustScale.iPad) {
            return Int(CGFloat(height)/667*736)
        }else {
            return Int(ScreenUtils.heightByM(y: CGFloat(height)))
        }
        
    }
    func checkUnlockLand() {
        //看看有没有新的解锁课程
        if(AppData.userAssessmentEnabled && UserManager.shared.isLoggedIn()){
            CourseManager.shared.getRecommendLessons { (lessons) in
                if lessons.count > 0 {
                    //重新下载数据
                    //                    self.presentUserToast(message: "完成课程检测到\(lessons.count)个新的土地")
                    RequestManager.shared.refresh = true
                    CourseManager.shared.SetCoursesList(update: true)
                    
                    self.newLand(learnSuccess:true)
                    
                    LCAlertView.show(title: "New Conversation Unlocked", message: "Congratulations! You unlocked \(lessons.count) new conversation(s).", leftTitle: "Check It Out", rightTitle: "Later", style: .center, leftAction: {
                        LCAlertView.hide()
                        self.practiseButtonClick(lessons:lessons)
                    }, rightAction: {
                        LCAlertView.hide()
                    })
                }else {
                    //                    self.presentUserToast(message: "完成课程没有新的土地")
                }
            }
        }
    }
    var scenarioCourseList = [ScenarioSubLessonInfo?]() {//被添加到plan中，而且没有完成的课程
        didSet {
            self.endRefresh()
        }
    }
    //登陆或者退出后更新头像和阳光值
    
    @objc func userIcon() {
        iconButton = UIButton(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        iconButton.layer.cornerRadius = 18
        iconButton.layer.masksToBounds = true
        iconButton.applyNavBarConstraints(size: (width: 36, height: 36))
        if(!AppData.userAssessmentEnabled && !UserManager.shared.isLoggedIn())
        {
            if (self.landView != nil) {
                self.landView.redDot.isHidden = true
            }
        }
        if UserManager.shared.isLoggedIn(){
            if UserManager.shared.getAvatarUrl() != nil {
                //有头像
                iconButton.sd_setImage(with: UserManager.shared.getAvatarUrl(), for: .normal, placeholderImage: ChImageAssets.Placeholder_Avatar.image, options: .refreshCached) { (image, error, type, url) in
                    self.iconButton.setBackgroundImage(image, for: .normal)
                    self.iconButton.setBackgroundImage(image, for: .selected)
                    self.iconButton.setBackgroundImage(image, for: .highlighted)
                }
            }else {
                iconButton.setBackgroundImage(ChImageAssets.Placeholder_Avatar.image, for: .normal)
                iconButton.setBackgroundImage(ChImageAssets.Placeholder_Avatar.image, for: .selected)
                iconButton.setBackgroundImage(ChImageAssets.Placeholder_Avatar.image, for: .highlighted)
            }
        }else {
            iconButton.setBackgroundImage(ChImageAssets.Avatar.image, for: .normal)
            iconButton.setBackgroundImage(ChImageAssets.Avatar.image, for: .selected)
            iconButton.setBackgroundImage(ChImageAssets.Avatar.image, for: .highlighted)
        }
//      iconButton.addTarget(self, action: #selector(testlogin(btn:)), for: .touchUpInside)
     iconButton.addTarget(self, action: #selector(self.showleft), for: .touchUpInside)
     self.navigationItem.setLeftBarButton(UIBarButtonItem(customView:iconButton), animated: true)
        makeSunNum()
    }
    @objc func testlogin(btn:UIButton){
        self.present(Login2ViewController(),animated: false,completion: nil)
    }
    @objc func startAnimation() {
        if UserManager.shared.isLoggedIn() && AppData.userAssessmentEnabled {
            self.navigationItem.setRightBarButton(UIBarButtonItem(customView: animateView), animated: true)
            animateView.startAnimating()
        }else {
            animateView.stopAnimating()
            self.navigationItem.setRightBarButton(nil, animated: true)
            return
        }
    }
    @objc func makeSunNum() {
        startAnimation()
        if UserManager.shared.isLoggedIn() && AppData.userAssessmentEnabled {
            self.refreshSunNum()
        }else {
            self.sunNum = 0
            animateView.stopAnimating()
            self.navigationItem.setRightBarButton(nil, animated: true)
        }
    }
    func refreshSunNum() {
        if let coin = UserManager.shared.getCoin() {
            self.sunNum = coin
            if coin <= 0 {
                UserManager.shared.setAppShowedCoin()
                self.sunNum = 0
                self.sunButton.setTitle(" \(self.sunNum)", for: .normal)
                self.navigationItem.setRightBarButton(UIBarButtonItem(customView:self.sunButton),animated: true)
                self.animateView.stopAnimating()
            }else {
                if UserManager.shared.isAppFirstOpenedShowCoin() {
                    UserManager.shared.setAppShowedCoin()
                    LCAlertView_Land.show(title: "", message: "\(coin)", leftTitle: "", rightTitle: "", style: .imageBack, leftAction: {
                        //OK
                        LCAlertView_Land.hide()
                    }, rightAction: {
                        LCAlertView_Land.hide()
                    }, disapperAction: {
                        LCAlertView_Land.hide()
                    })
                }
                self.sunButton.setTitle(" \(self.sunNum)", for: .normal)
                self.navigationItem.setRightBarButton(UIBarButtonItem(customView:self.sunButton), animated: true)
                self.animateView.stopAnimating()
            }
        }else {
            self.sunNum = 0
            self.sunButton.setTitle(" \(self.sunNum)", for: .normal)
            self.navigationItem.setRightBarButton(UIBarButtonItem(customView:self.sunButton),animated: true)
        }
    }
    
    func _updateContent(notification: Notification?) {
        
    }
    
    func _accessTokenChanged(notification: Notification?) {
        
        let token = notification?.userInfo![FBSDKAccessTokenChangeNewKey] as? FBSDKAccessToken
        if token == nil {
            FBSDKAccessToken.setCurrent(nil)
            FBSDKProfile.setCurrent(nil)
        } else {
            var urlRequest: URLRequestConvertible!
            urlRequest = Router.FacebookLogIn(FBSDKAccessToken.current().tokenString)
            let callback: (FacebookUserModel?, Error?, String?)->() = {
                result, error, raw in
                ChActivityView.hide(ActivityViewType.ShowNavigationbar)
                if result != nil{
                    if result?.accessToken != nil {
                        CourseManager.shared.isLearnPage = true
                        UserManager.shared.signInUser(result!, LoginAccountType.FacebookLogin)
                    }
                    self.navigationController?.dismiss(animated: true) {
                    }
                }else{
                    print("error")
                }
            }
            RequestManager.shared.performRequest(urlRequest: urlRequest, completionHandler: callback)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.headerView.frame = CGRect(x: 0, y: 0, width: Int(ScreenUtils.width), height: convertHeight(height: 150 * 14 - 40))
        self.headerView.backgroundColor = UIColor.white
        animateView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 25, height: 25), type: .ballSpinFadeLoader, color: UIColor.hex(hex: "FFAC1A"), padding: 0)
        sunButton.frame = CGRect(x: 0, y: 0, width:100, height: 25)
        sunButton.setImage(UIImage(named: "sunNew"), for: .normal)
        sunButton.setTitleColor(UIColor.hex(hex: "FFC543"), for: .normal)
        sunButton.titleLabel?.font = FontUtil.getFont(size: 18, type: .Bold)
        sunButton.imageView?.contentMode = .scaleAspectFit
        sunButton.titleLabel?.adjustsFontSizeToFitWidth = true
        sunButton.contentHorizontalAlignment = .right
        sunNum = 0
        
        self.view.backgroundColor = UIColor.white
        userIcon()
        
        tableView = UITableView(frame: CGRect(x: ScreenUtils.widthBySix(x: 0), y: ScreenUtils.heightBySix(y: 0), width: ScreenUtils.width , height: ScreenUtils.height - self.ch_getStatusNavigationHeight()), style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        view.addSubview(tableView)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(userIcon), name: ChNotifications.UserSignedIn.notification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startAnimation), name: ChNotifications.UpdateSunNumber.notification, object: nil)
        //退出后重新加载数据
        NotificationCenter.default.addObserver(self, selector: #selector(updateHome), name: ChNotifications.UserSignedOut.notification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateHome), name: ChNotifications.UpdateHomePage.notification, object: nil)
        //更新阳光值
        NotificationCenter.default.addObserver(self, selector: #selector(makeSunNum), name: ChNotifications.UpdateHomePageCoin.notification, object: nil)
        //network error
        NotificationCenter.default.addObserver(self, selector: #selector(showNetworkFailedRequestView), name: ChNotifications.NetworkFailedRequest_HomePage.notification, object: nil)
        //end loading
        NotificationCenter.default.addObserver(self, selector: #selector(endRefresh), name: ChNotifications.NetworkEndLoading.notification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshCurrentView), name: ChNotifications.ReloadPageInfos.notification, object: nil)
        
        
        if CourseManager.shared.beginnerLessonInfo != nil && CourseManager.shared.beginnerLessonInfo.SubLessons?.count != 0 {
            self.beginnerCourseList.removeAll()
            var courseList = [ScenarioSubLessonInfo?]()
            self.lockStatus = CourseManager.shared.getBasicLessonLockStatus()
            for (i,course) in CourseManager.shared.beginnerLessonInfo!.SubLessons!.enumerated() {
                course.ScenarioLessonInfo?.isFinished = self.lockStatus[i]
                courseList.append(course)
                if (course.SubLessons?[0].ScenarioLessonInfo!.Tags?.contains("ChallengeLesson") ?? false) {
                    self.beginnerCourseList.append(courseList)
                    courseList.removeAll()
                }
            }
            reloadTableView()
        }
        if !NetworkReachabilityManager()!.isReachable {
            showNetworkFailedRequestView(noti: nil)
        }
        header.stateLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(12), type: .Regular)
        header.lastUpdatedTimeLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(12), type: .Regular)
        header.mj_h = 34
        header.stateLabel.textColor = UIColor.lightText
        header.lastUpdatedTimeLabel.textColor = UIColor.lightText
        
        refresh()
        //        //学以致用
        var landViewHeight = ScreenUtils.heightByM(y: 140)
        var landViewWidth = ScreenUtils.heightByM(y: 90)
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhone4){
            landViewHeight = ScreenUtils.heightByM(y: 180)
            landViewWidth = ScreenUtils.heightByM(y: 120)
        }else if(AdjustGlobal().CurrentScale == AdjustScale.iPhone5){
            landViewHeight = ScreenUtils.heightByM(y: 180)
            landViewWidth = ScreenUtils.heightByM(y: 110)
        }else if(AdjustGlobal().CurrentScale == AdjustScale.iPhone){
            landViewHeight = ScreenUtils.heightByM(y: 160)
        }
        landView = Bundle.main.loadNibNamed("LandView", owner: self, options: nil)?.first as! LandView
        landView.frame = CGRect(x: ScreenUtils.width - landViewWidth, y: ScreenUtils.height - landViewHeight, width: landViewWidth, height: landViewHeight)
        landView.practiseBtn.addTarget(self, action: #selector(self.practiseClick), for: .touchUpInside)
        self.view.addSubview(landView)
        startAnimation()
    }
    
    func newUnlockLand() {
        if(AppData.userAssessmentEnabled && UserManager.shared.isLoggedIn()){
            CourseManager.shared.getRecommendLessons { (lessons) in
                if lessons.count > 0 {
                    //                    self.presentUserToast(message: "启动检测\(lessons.count)个新的土地")
                    RequestManager.shared.refresh = true
                    CourseManager.shared.SetCoursesList(update: true)
                    //未做过
                    self.landView.redDot.isHidden = false
                    self.landView.newLandToast.alpha = 1
                    UIView.animate(withDuration: 3, animations: {
                        
                    }) { (finished) in
                        self.landView.newLandToast.alpha = 0
                    }
                }else {
                    //                    self.presentUserToast(message: "启动检测没有新的土地")
                }
            }
        }
    }
    
    //跳转到土地页面
    @objc func practiseClick() {
        let vc = PractiseLandViewController()
        vc.achievement = sunNum
//        let nav1 = UINavigationController(rootViewController: vc)
//        SlideMenuOptions.rightViewWidth = ScreenUtils.width / 4 * 3
//        let slideMenuController = SlideMenuController(mainViewController: nav1, rightMenuViewController: CompletedLandVC())
//        slideMenuController.modalPresentationStyle = .fullScreen
//        self.present(slideMenuController, animated: false) {
//
//        }
//跳转到Story Board的方法
        if #available(iOS 13.0, *) {
            guard let myViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateViewController(identifier: "Login2ViewController") as? Login2ViewController else {
                fatalError("Unable to Instantiate My View Controller")
            };
            myViewController.modalPresentationStyle = .fullScreen
            present(myViewController, animated: true)
        } else {
            // Fallback on earlier versions
        }

    }
    
    func practiseButtonClick(lessons:[ScenarioSubLesson]? = nil) {
        let vc = PractiseLandViewController()
        vc.achievement = sunNum
        if lessons != nil {
            vc.unlockLesson = lessons!
        }
        let nav1 = UINavigationController(rootViewController: vc)
        SlideMenuOptions.rightViewWidth = ScreenUtils.width / 4 * 3
        let slideMenuController = SlideMenuController(mainViewController: nav1, rightMenuViewController: CompletedLandVC())
        slideMenuController.modalPresentationStyle = .fullScreen
        self.present(slideMenuController, animated: false) {
            
        }
    }
    
    /** 设置刷新 */
    func refresh() {
        // 现在的版本要用mj_header
        tableView.mj_header = header
        header.setRefreshingTarget(self, refreshingAction: #selector(LearnPageViewController.headerRefresh))
    }
    @objc func headerRefresh() {
        RequestManager.shared.refresh = true
        CourseManager.shared.SetCoursesList(update: true)
    }
    func enterForegroundRefresh() {
        RequestManager.shared.refresh = true
        CourseManager.shared.SetCoursesList(update: true)
    }
    @objc func endRefresh() {
        animateView.stopAnimating()
        if (tableView.mj_header != nil) {
            tableView.mj_header.endRefreshing()
        }
    }
    @objc func showNetworkFailedRequestView(noti: Notification?) {
        var alertText = NetworkRequestFailedText.NetworkError
        if noti != nil {
            let notiDic = noti!.object as! Dictionary<String, Any>
            alertText = notiDic["text"] as! String
        }
        endRefresh()
        if self.view.subviews.contains(alertView.blurView) {
            return
        }
        if CourseManager.shared.isLearnPage {
            alertView.delegate = self
            alertView.show(frame: CGRect(x: 0, y: ScreenUtils.heightBySix(y: 0), width: ScreenUtils.width, height: ScreenUtils.height - ScreenUtils.heightBySix(y: 0) - self.ch_getStatusBarHeight()),superView:self.view,alertText:alertText,textColor:UIColor.loadingTextColor,bgColor: UIColor.loadingBgColor)
            ChActivityView.hide(.HomePage)
        }
    }
    
    @objc func refreshCurrentView() {
        if self.view.subviews.contains(alertView.blurView) {
            alertView.hide()
        }
        self.navigationController?.navigationItem.leftBarButtonItem = nil
        userIcon()
        RequestManager.shared.reLoad = true
        CourseManager.shared.SetCoursesList(update: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CourseManager.shared.isLearnPage = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CourseManager.shared.isLearnPage = true
        //设置回退按钮为白色
        
        self.navigationItem.title = "Learn"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        //设置回退按钮为白色
        self.navigationController?.navigationBar.tintColor = UIColor.white
        //隐藏底部 tab 栏
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.fromColor(color: UIColor.blueTheme), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary(self.ch_getTitleAttribute(textColor: UIColor.white))// temp
        UINavigationBar.appearance().tintColor = UIColor.white
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary(self.ch_getTitleAttribute(textColor: UIColor.white))// temp
        UINavigationBar.appearance().tintColor = UIColor.white
    }
    @objc func showleft(){
        self.slideMenuController()?.openLeft()
    }
    
    @objc func updateHome() {
        //更新阳光值
        makeSunNum()
        userIcon()
        if CourseManager.shared.beginnerLessonInfo != nil && CourseManager.shared.beginnerLessonInfo.SubLessons?.count != 0 {
            self.beginnerCourseList.removeAll()
            self.lockStatus = CourseManager.shared.getBasicLessonLockStatus()
            var courseList = [ScenarioSubLessonInfo?]()
            for (i,course) in CourseManager.shared.beginnerLessonInfo!.SubLessons!.enumerated() {
                course.ScenarioLessonInfo?.isFinished = self.lockStatus[i]
                courseList.append(course)
                if (course.SubLessons?[0].ScenarioLessonInfo!.Tags?.contains("ChallengeLesson") ?? false) {
                    self.beginnerCourseList.append(courseList)
                    courseList.removeAll()
                }
                if i == CourseManager.shared.beginnerLessonInfo!.SubLessons!.count - 1 && courseList.count > 0 {
                    self.beginnerCourseList.append(courseList)
                    courseList.removeAll()
                }
            }
            reloadTableView()
        }
        else {
            return
        }
        //停止刷新
        self.endRefresh()
        //断网状态
        if NetworkReachabilityManager()!.isReachable{
            if self.view.subviews.contains(self.alertView.blurView) {
                self.alertView.hide()
            }
        }
    }
}

extension LearnPageViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.beginnerCourseList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: HomeLessonCell.identifier) as? HomeLessonCell
            if (cell == nil) {
                cell = HomeLessonCell.init(style: .default, reuseIdentifier: HomeLessonCell.identifier,coursesArray:self.beginnerCourseList[indexPath.row] as! [ScenarioSubLessonInfo], indexPath: indexPath)
            }
            cell?.delegate = self
            cell?.selectionStyle = .none
            cell?.courseArray = self.beginnerCourseList[indexPath.row]
            cell?.index = indexPath
            return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.beginnerCourseList[indexPath.row].count {
        case 4:
            return 180 * 2.5 - 10
        case 5:
            return 180 * 2.5 - 10
        case 6:
            return 180 * 3.5 - 10
        case 7:
            return 180 * 3.5 - 10
        default:
            return CGFloat((self.beginnerCourseList[indexPath.row].count + 1) / 2 * 180)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if self.beginnerCourseList.count > 0{
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenUtils.width, height: 60))
            let footerLabel = UILabel(frame: CGRect(x: 0, y: 10, width: ScreenUtils.width, height: 30))
            footerLabel.text = "More Lessons are on the way..."
            footerView.addSubview(footerLabel)
            footerLabel.textColor = UIColor.lightText
            footerLabel.textAlignment = .center
            footerLabel.font = FontUtil.getFont(size: 13, type: .Regular)
            footerView.backgroundColor = UIColor.white
            return footerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.contentOfSet = scrollView.contentOffset
    }
    //每次进来
    func newLand(learnSuccess: Bool = false) {
        if(AppData.userAssessmentEnabled && UserManager.shared.isLoggedIn() && !learnSuccess)
        {
            //有新的解锁土地，显示红点
            if CourseManager.shared.practicalLessonInfo != nil && CourseManager.shared.practicalLessonInfo.SubLessons?.count != 0 {
                let practiseArray: [ScenarioSubLessonInfo]?
                practiseArray =  CourseManager.shared.practicalLessonInfo!.SubLessons![0].SubLessons! +  CourseManager.shared.practicalLessonInfo!.SubLessons![1].SubLessons! +  CourseManager.shared.practicalLessonInfo!.SubLessons![2].SubLessons! +  CourseManager.shared.practicalLessonInfo!.SubLessons![3].SubLessons!
                self.landView.redDot.isHidden = true
                for course in practiseArray! {
                    if course.ScenarioLessonInfo?.Name != "" && course.ScenarioLessonInfo?.Name != nil {
                        if (course.ScenarioLessonInfo?.Progress)! == -1 {
                            continue
                        }
                        if (course.ScenarioLessonInfo?.Progress)! < 1{
                            //未做过
                            self.landView.redDot.isHidden = false
                            self.landView.newLandToast.alpha = 1
                            UIView.animate(withDuration: 3, animations: {
                                
                            }) { (finished) in
                                self.landView.newLandToast.alpha = 0
                            }
                            return
                        }else {
                            //已解锁，做过，没及格
                            if (course.ScenarioLessonInfo?.Score)! < 60 {
                                self.landView.redDot.isHidden = false
                                self.landView.newLandToast.alpha = 1
                                UIView.animate(withDuration: 3, animations: {
                                    
                                }) { (finished) in
                                    self.landView.newLandToast.alpha = 0
                                }
                                return
                            }
                        }
                        
                    }
                }
            }
            return
        }
        if learnSuccess == true {
            self.landView.redDot.isHidden = false
            self.landView.newLandToast.alpha = 1
            UIView.animate(withDuration: 0.3, animations: {
                self.landView.newLandToast.alpha = 0
            })
            return
        }
        //没开启权限和未登录，不显示红点
        landView.redDot.isHidden = true
        landView.newLandToast.alpha = 0
    }
    
    //点击挑战按钮
    func toChanllengeVC(course:ScenarioSubLessonInfo) {
        //跳转到conversation challenge
        if !UserManager.shared.isLoggedIn(){
            let vc = LoginFullViewController()
            let mc = self.slideMenuController()?.mainViewController as! UINavigationController
            mc.pushViewController(vc, animated: true)
            return
        }
        let vc = ChallengeIntroViewController()
        vc.courseId = CourseManager.shared.getBeginnerChatCourseId(course.SubLessons!)
        vc.unlock = Bool(course.ScenarioLessonInfo?.isFinished ?? true)
        //埋点：从Homepage进入ConversationChallenge
        let info = ["Scope" : "ConversationChallenge","Lessonid" : vc.courseId,"Event" : "Enter"]
        UserManager.shared.logUserClickInfo(info)
        let nav = UINavigationController(rootViewController: vc)
        nav.hidesBottomBarWhenPushed = true
        nav.modalTransitionStyle = .crossDissolve
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: {
            
        })
        return
    }
}

extension LearnPageViewController: CourseClickDelegate {
    func courseClick(course: ScenarioSubLessonInfo?) {
        if course  == nil {
            self.presentUserToast(message: "Load lesson error.")
            return
        }
        let courseId = CourseManager.shared.getBeginnerPracticeCourseId(course!.SubLessons!)
        let repeatId = CourseManager.shared.getBeginnerChatCourseId(((course?.SubLessons!)!)).replacingOccurrences(of: "s-CN", with: "r-CN")
        
        let cardVC = LearnCardFlowViewController()
        cardVC.courseId = courseId
        cardVC.repeatId = repeatId
        cardVC.lessonInfo = course
        cardVC.finishLearning = { (coinValue,completed) in
            if coinValue > 0 {
                if(AppData.userAssessmentEnabled && UserManager.shared.isLoggedIn()){
                    if let coin = UserManager.shared.getCoin() {
                        self.sunNum = coin
                        self.sunButton.setTitle(" \(self.sunNum)", for: .normal)
                        self.navigationItem.setRightBarButton(UIBarButtonItem(customView:self.sunButton),animated: true)
                        self.animateView.stopAnimating()
                    }
                    //首先展示阳光值鼓励图，鼓励图消失后，查询是否有新解锁的土地
                    LCAlertView_Land.show(title: "", message: "\(coinValue)", leftTitle: "", rightTitle: "", style: .image, leftAction: {
                        //OK
                        LCAlertView_Land.hide()
                    }, rightAction: {
                        LCAlertView_Land.hide()
                    }, disapperAction: {
                        LCAlertView_Land.hide()
                        if completed {
                            self.checkUnlockLand()
                        }
                    })
                }
            }
        }
        cardVC.titleString = "\((course?.ScenarioLessonInfo?.NativeName)!)"
        let nav = UINavigationWithoutStatusController(rootViewController: cardVC)
        nav.hidesBottomBarWhenPushed = true
        nav.modalTransitionStyle = .crossDissolve
        
        //埋点：从Homepage进入Learn
        let info = ["Scope" : "Learn","Lessonid" : courseId,"Subscope" : "Learn","Event" : "Enter"]
        UserManager.shared.logUserClickInfo(info)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: {
            
        })
    }
    func chanllengeCourseClick(course: ScenarioSubLessonInfo?) {
        if course  == nil {
            self.presentUserToast(message: "Load lesson error.")
            return
        }
        self.toChanllengeVC(course: (course ?? nil)!)
        
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
