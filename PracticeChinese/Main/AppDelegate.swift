//
//  AppDelegate.swift
//  PracticeChinese
//
//  Created by feiyue on 15/06/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import UIKit
import CocoaLumberjack
import AVFoundation
import CoreTelephony
import UserNotifications
import Alamofire
import FBSDKCoreKit
import FBSDKLoginKit

//#if DEV
//    let SERVICE_URL = "https://dev-service.mtutor.engkoo.com/"
//#elseif PROD
//    let SERVICE_URL = "https://service.mtutor.engkoo.com/"
//#else
//    let SERVICE_URL = "http://mtutor-prod-dev.cloudapp.net/"
//#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,ChActivityViewCancleDelegate {

    var window: UIWindow?
    let NetworkManager = NetworkReachabilityManager(host: "www.baidu.com")
    static let appStartNotification = NSNotification.Name(rawValue: "appstart")
    let home1 = LearnPageViewController()

    @objc func canStartApp() {
        NotificationCenter.default.removeObserver(self, name: AppDelegate.appStartNotification, object: nil)
        startApp()
    }
    @objc func showActivityViewInHomePage() {
        ChActivityView.show(.HomePage, home1.view, UIColor.hex(hex: "f2f2f2"), ActivityViewText.HomePageLoading)
    }
    func cancleLoading() {
        
    }

    func startApp() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            //swift convert
            //            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, with: [AVAudioSession.CategoryOptions.defaultToSpeaker, AVAudioSession.CategoryOptions.allowBluetooth])
            //swift convert
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [AVAudioSession.CategoryOptions.defaultToSpeaker, AVAudioSession.CategoryOptions.allowBluetooth])
            try audioSession.setActive(true)
            
        } catch {
            DDLogError("failed to set audio session category, \(error)")
        }
        
        
        let nav1 = UINavigationController(rootViewController: home1)

        SlideMenuOptions.contentViewScale = 1
        SlideMenuOptions.hideStatusBar = false
        SlideMenuOptions.contentViewDrag = true
        if(AdjustGlobal().isiPad){
            SlideMenuOptions.leftViewWidth = 270 * 2
        }
        let slideMenuController = SlideMenuController(mainViewController: nav1, leftMenuViewController: MePageViewController())
        self.window?.rootViewController = slideMenuController

        
        self.window?.makeKeyAndVisible()
        self.window?.backgroundColor = UIColor.white
        self.window?.makeKeyAndVisible()
        //      huohuo:  跳转到登陆界面,首次运行时注释掉，第二次运行时取消注释，之后初始界面就是登陆注册，点击button回到主界面
            if #available(iOS 13.0, *) {
                guard let myViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateViewController(identifier: "Login2ViewController") as? Login2ViewController else {
                    fatalError("Unable to Instantiate My View Controller")
                };
                myViewController.modalPresentationStyle = .fullScreen

                self.window?.rootViewController!.present(myViewController,animated:true)
            } else {
                // Fallback on earlier versions
            }

        

    }
    @available(iOS 9.0, *)
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        switch shortcutItem.type {
        case "type1":
            break
        case "type2":
            break
        case "type3":
            break
        case "type4":
            break
        default:
            break
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //faceBook登录
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        FBSDKProfile.enableUpdates(onAccessTokenChange: true)
        FBSDKSettings.setAppID("661584137380947")

        NetworkManager!.startListening()
        
        DDLog.add(DDTTYLogger.sharedInstance)
        DDLog.add(DDASLLogger.sharedInstance)
        //语音设置
        UserDefaults.standard.set(Int(1), forKey: UserDefaultsKeyManager.readAudio)
        UINavigationBar.appearance().tintColor = UIColor.white
        UIApplication.shared.statusBarStyle = .lightContent
        LCConfigManager.shared.loadConfig()
        let fileLogger: DDFileLogger = DDFileLogger()
        fileLogger.rollingFrequency = TimeInterval(60*60*24)
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)//加上这一句以显示首页
        /** 注册通知 */
        registerAppNotificationSettings(launchOptions: launchOptions)
        
        //开启通知
        if #available(iOS 8.0, *) {
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound],
                                                      categories: nil)
            application.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        // idk y, but i have to set InterfaceStyle with code, or it wont work on device
        if #available(iOS 13, *) {
            window!.overrideUserInterfaceStyle = .light
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(showActivityViewInHomePage), name: ChNotifications.ShowActivityViewInHomePage.notification, object: nil)
        AppData.checkVersion()
        if UserManager.shared.isAppFirstOpened() {
            //首次启动- 游客登录 - 下载数据
            if !UserManager.shared.isLoggedIn() {
                UserManager.shared.logInAsVisitor()
            }
            else {
                CourseManager.shared.loadData(true)
            }
            NotificationCenter.default.addObserver(self, selector: #selector(canStartApp), name: AppDelegate.appStartNotification, object: nil)
            UserDefaults.standard.set(AppData.getVersion(), forKey: "AppVersion")
            UserDefaults.standard.synchronize()
            window?.rootViewController = StartPageViewController()
            
            window?.makeKeyAndVisible()
            return true
        } else {
            CourseManager.shared.loadData(true)
            UserDefaults.standard.set(AppData.getVersion(), forKey: "AppVersion")
            UserDefaults.standard.synchronize()
            
            CacheDataManager.shared.getUserInfo(completionInfo: {
                (completionInfo) in
            })
            startApp()
            DDLogInfo("cachePath: \(CacheManager.shared.cacheBasePath)")
            return true
        }
    }

    func userLogin() {
    }
    
    func application(_ application: UIApplication,
                     didReceive notification: UILocalNotification) {
        //设定Badge数目
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        let info = notification.userInfo as! [String:Int]
        let number = info["ItemID"]
        
        let alertController = UIAlertController(title: "本地通知",
                                                message: "消息内容：\(notification.alertBody)用户数据：\(number)",
            preferredStyle: .alert)
        
        self.window?.rootViewController!.present(alertController, animated: true,
                                                 completion: nil)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token = "\(deviceToken as NSData)".trimmingCharacters(in: ["<", ">"]).replacingOccurrences(of: " ", with: "")
        //TODO: mitigrate service to mTutor
        Alamofire.request(URL(string: "https://apnsportal.azurewebsites.net/addToken")!, method: .post, parameters: ["token": token], encoding: URLEncoding.default, headers: ["Content-Type":"application/x-www-form-urlencoded"]).validate().response { (_) in
        }
        
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        UIApplication.shared.applicationIconBadgeNumber = 0

        if let mini_version = userInfo["mini_version"] as? NSString {
            UserDefaults.standard.set(String(mini_version), forKey: "mini_version");
            UserDefaults.standard.synchronize();
        }
        if application.applicationState == .active {
            return
        }

        if let aps = userInfo["aps"] as? NSDictionary {
            if let alert = aps["alert"] as? NSDictionary {
            } else if let alert = aps["alert"] as? NSString {
                UserDefaults.standard.set(alert, forKey: "remote_notify");
                UserDefaults.standard.synchronize();
                //Do stuff
            }
        }
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        return handled
    }
 
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }


    func applicationWillEnterForeground(_ application: UIApplication) {
        //后台进入前台刷新
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            self.home1.enterForegroundRefresh()
        }
    }
    func applicationDidEnterBackground(_ application: UIApplication) {

    }
    


    func applicationDidBecomeActive(_ application: UIApplication) {
        AppData.checkUpdates()
//        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func networkReachability(){
        NetworkManager!.listener = { status in

            switch status {
            case .notReachable:
                CWLog("notReachable")
                break
            case .unknown:
                CWLog("unknown")

                break
            case .reachable(.ethernetOrWiFi):
                CWLog("reachableethernetOrWiFi")
                self.home1.headerRefresh()
                break
            case .reachable(.wwan):
                CWLog("reachablewwan")
                self.home1.headerRefresh()
                break
            default:

            break
            }
        }
    }
}
extension AppDelegate:UNUserNotificationCenterDelegate {
     func registerAppNotificationSettings(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        if #available(iOS 10.0, *) {
            //iOS10以上注册通知
            let notifiCenter = UNUserNotificationCenter.current()
            notifiCenter.delegate = self
            let types = UNAuthorizationOptions(arrayLiteral: [.alert,.sound,.badge])
            notifiCenter.requestAuthorization(options: types) { (flag, error) in
                if flag {
                    CWLog("iOS request notification success")
                }else{
                    CWLog(" iOS 10 request notification fail")
                }
            }
        }
        else {
            //iOS8,iOS9注册通知
            let setting  =  UIUserNotificationSettings(types: [.alert,.sound,.badge], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(setting)
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    //iOS10新增：处理前台收到通知的代理方法
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void) {
        let userInfo = notification.request.content.userInfo
        completionHandler([.sound,.alert])
    }
    
    //iOS10新增：处理后台点击通知的代理方法
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Swift.Void) {
        let userInfo = response.notification.request.content.userInfo
        completionHandler()
    }
    //iOS8和iOS9只需要执行以下方法就好了
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        if application.applicationState == UIApplication.State.active {
            // 代表从前台接受消息app
        }else{
            // 代表从后台接受消息后进入app
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        completionHandler(.newData)
        
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
    return input.rawValue
}
