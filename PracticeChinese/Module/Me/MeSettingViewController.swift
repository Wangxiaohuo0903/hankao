//
//  MeSettingViewController.swift
//  PracticeChinese
//
//  Created by 费跃 on 8/29/17.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import CocoaLumberjack
import SnapKit

class MeSettingViewController: UIViewController {

    var tableView: UITableView!
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.groupTableViewBackground
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)


        tableView = UITableView(frame: CGRect(x: ScreenUtils.widthBySix(x: 0), y: ScreenUtils.heightBySix(y: 0), width: ScreenUtils.width-ScreenUtils.widthBySix(x: 0), height: ScreenUtils.height-64), style: .grouped)


        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(SettingItemCell.nibObject, forCellReuseIdentifier: SettingItemCell.identifier)
        tableView.register(SettingTitleCell.nibObject, forCellReuseIdentifier: SettingTitleCell.identifier)

        self.view.addSubview(tableView)

//        let page = QuizPairingView(frame: CGRect(x: 0,  y: 0, width: ScreenUtils.width, height: ScreenUtils.height))
//        page.buildUI()
//        self.view.addSubview(page)
//        self.view.backgroundColor = UIColor.blueTheme
    }
    
    @objc func turnUserExperience(sender: UISwitch!) {
        if sender.isOn {
            AppData.setUserExperience(true)
        }
        else {
            AppData.setUserExperience(false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Settings"
        UINavigationBar.appearance().tintColor = UIColor.white

    }
    
    func rateApp() {
        UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/app/viewContentsUserReviews?id=\(AppData.appId)")!)
    }
    

}

extension MeSettingViewController: UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
//        if UserManager.shared.isLoggedIn() {
//        return 4
//        }
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch  section {
        case 0:
            return 2
        case 1:
            return 3
        case 2:
            if UserManager.shared.isLoggedIn() {
                return 2
            }else{
                return 0
            }
        default:
           return 7
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 4 {
            let cell_1 = tableView.dequeueReusableCell(withIdentifier: SettingTitleCell.identifier) as! SettingTitleCell
            let cell_2 = tableView.dequeueReusableCell(withIdentifier: SettingItemCell.identifier) as! SettingItemCell
            cell_2.itemLabel.textColor = UIColor.textGray

            if UserManager.shared.isLoggedIn() {
                    cell_2.itemLabel.text = "Experience Improvement Program"
                    cell_2.itemLabel.font = FontUtil.getFont(size: 17, type: .Regular)
                    cell_2.itemLabel.adjustsFontSizeToFitWidth = true
                    cell_2.itemSwitch.addTarget(self, action: #selector(turnUserExperience), for: .valueChanged)
                    if AppData.userAssessmentEnabled {
                        cell_2.itemSwitch.setOn(true, animated: false)
                    } else {
                        cell_2.itemSwitch.setOn(false, animated: false)
                    }
                    return cell_2
            }
            else {
                cell_2.itemLabel.text = "Experience Improvement Program"
                cell_2.itemLabel.font = FontUtil.getFont(size: 17, type: .Regular)
                cell_2.itemLabel.adjustsFontSizeToFitWidth = true
                cell_2.itemSwitch.addTarget(self, action: #selector(turnUserExperience), for: .valueChanged)
                if AppData.userAssessmentEnabled {
                    cell_2.itemSwitch.setOn(true, animated: false)
                } else {
                    cell_2.itemSwitch.setOn(false, animated: false)
                }
                return cell_2
            }
        }
        else if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingTitleCell.identifier) as! SettingTitleCell
            cell.subLabel.isHidden = true
            cell.titleLabel.textColor = UIColor.textGray
            cell.titleLabel.textAlignment = .left
            let titleArray = ["Grading Colors","Clear Cache","Contact Us","About","Privacy Policy","Terms of Uset","Rate This App"]
            cell.titleLabel.text = titleArray[indexPath.row]
            switch indexPath.row {
            case 0:
                cell.line.isHidden = false
                break
            case 1:

//                let textString = NSMutableAttributedString(string: "Clear Cache (\(String(format: "%.1f", size))M)")
//                let range = NSMakeRange(16, textString.length - 17)
//                textString.addAttributes([NSForegroundColorAttributeName: UIColor.blueTheme], range: range)
//                cell.titleLabel.attributedText = textString
                cell.subLabel.isHidden = false
                cell.subLabel.textAlignment = .right
                if Double(UserManager.shared.getCacheSize()) < 1024*1024 {
                    let size = Double(UserManager.shared.getCacheSize()) / 1024.0
                    cell.subLabel.text = "\(Int(size))K"
                }else {
                    let size = Double(UserManager.shared.getCacheSize()) / (1024.0 * 1024.0)
                    cell.subLabel.text = "\(String(format: "%.1f", size))M"
                }
                break
            case 2:
                cell.line.isHidden = false
                break
            case 3:

                break
            case 4:
                break
            case 5:
                break
            default:
                cell.titleLabel.text = "Rate This App"
                cell.line.isHidden = false
                break
            }
            return cell
        }else if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingTitleCell.identifier) as! SettingTitleCell
            let titleArray = ["Contact Us","Rate This App","About"]
            cell.titleLabel.text = titleArray[indexPath.row]
            cell.titleLabel.textColor = UIColor.textGray
            cell.titleLabel.textAlignment = .left
            switch indexPath.row {
            case 0:
                cell.line.isHidden = false

            case 1:
                cell.line.isHidden = false

            case 2:
                cell.titleLabel.text = "About"

            default:
                cell.titleLabel.text = ""

            }
            return cell
        }else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingTitleCell.identifier) as! SettingTitleCell
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "Privacy"
                cell.titleLabel.textColor = UIColor.textGray
                cell.titleLabel.textAlignment = .left
                cell.line.isHidden = false
                
            default:
                cell.titleLabel.text = "Account"
                cell.titleLabel.textColor = UIColor.textGray
                cell.titleLabel.textAlignment = .left
                
            }
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhone4){
            return ScreenUtils.heightByM(y: 40)
        }else{
            return ScreenUtils.heightByM(y: 45)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ScreenUtils.heightByM(y: 24)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        if section == 0 {
//            let textString = "The program collects information about how you use our product, without interrupting you. This helps us identify which features to improve. No information collected is used to identify or contact you."
//            return textString.height(withConstrainedWidth: ScreenUtils.width - 40, font: FontUtil.getFont(size: 13, type: .Thin)) + 10
//        }
//        else{
            return 0.01
//        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        if section == 0 {
//            let footer = UIView()
//            //y需要自定义高度，暂时暴力写死了
//
//            let label = UILabel(frame: CGRect(x: 15, y: 5, width: ScreenUtils.width - 40, height: 60))
//            label.textColor = UIColor.textGray
//            label.numberOfLines = 0
//            label.font = FontUtil.getFont(size: 12, type: .Thin)
//
//            let textString = "The program collects information about how you use our product, without interrupting you. This helps us identify which features to improve. No information collected is used to identify or contact you."
//            let height = textString.height(withConstrainedWidth: ScreenUtils.width - 40, font: FontUtil.getFont(size: 13, type: .Thin))
//            label.text = textString
//            label.textAlignment = .left
//            label.sizeToFit()
//            footer.addSubview(label)
//            label.snp.makeConstraints { (make) -> Void in
//                make.top.equalTo(footer).offset(UIAdjust().adjustByHeight(10))
//                make.height.equalTo(height)
//                make.left.equalTo(footer).offset(20)
//                make.right.equalTo(footer).offset(-20)
//            }
//            return footer
//        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let vc = GradingColorViewController()
                self.ch_pushViewController(vc, animated: true)
            // DDLogInfo("Grading Colors")
            case 1:
                let Cell = tableView.cellForRow(at: IndexPath(row: indexPath.row, section: indexPath.section)) as? SettingTitleCell
                ChActivityView.show()
                UserManager.shared.clearCache() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        ChActivityView.hide()
                        Cell?.isUserInteractionEnabled = false
                        Cell?.titleLabel.textColor = UIColor.textGray.withAlphaComponent(0.4)
                        Cell?.subLabel.textColor = UIColor.textGray.withAlphaComponent(0.4)
                        Cell?.subLabel.text = "0K"
                        Cell?.reloadInputViews()
                        LCAlertView.show(title: "", message: "Cache has been cleared.", leftTitle: "OK", rightTitle: "OK", style: .oneButton, leftAction: {
                            NotificationCenter.default.post(name: ChNotifications.ReloadPageInfos.notification, object: nil)
                            LCAlertView.hide()
                        }, rightAction: {
                            LCAlertView.hide()
                        })
                    }
                }
//            case 2:
//                if !MFMailComposeViewController.canSendMail() {
//                    DDLogInfo("Mail services are not available")
//                    let email = "engkoofb@microsoft.com"
//                    if let url = URL(string: "mailto:\(email)") {
//                        if #available(iOS 10.0, *) {
//                            UIApplication.shared.open(url)
//                        } else {
//                            // Fallback on earlier versions
//                            UIApplication.shared.openURL(url)
//                        }
//                    }
//                    return
//                }
//                let mc = MFMailComposeViewController()
//                mc.mailComposeDelegate = self
//                mc.setToRecipients(["engkoofb@microsoft.com"])
//                mc.setSubject("Learn Chinese Feedback")
//                mc.setMessageBody("", isHTML: false)
//                UINavigationBar.appearance().tintColor = UIColor.blue
//
//                self.present(mc, animated: true, completion: nil)
//            case 3:
//                let vc = AboutUsViewController()
//                self.ch_pushViewController(vc, animated: true)
//            case 4:
//                if #available(iOS 10.0, *) {
//                    UIApplication.shared.open(URL(string: "https://go.microsoft.com/fwlink/?LinkId=521839")!)
//                } else {
//                    UIApplication.shared.openURL(URL(string: "https://go.microsoft.com/fwlink/?LinkId=521839")!)
//
//                    // Fallback on earlier versions
//                }
//            case 5:
//                if #available(iOS 10.0, *) {
//                    UIApplication.shared.open(URL(string: " http://go.microsoft.com/fwlink/?linkid=206977")!)
//                } else {
//                    UIApplication.shared.openURL(URL(string: " http://go.microsoft.com/fwlink/?linkid=206977")!)
//
//                    // Fallback on earlier versions
//                }
//            case 6:
//                DDLogInfo("Rate this APP")
//
            default:
                DDLogInfo("\(indexPath.row)")
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                if !MFMailComposeViewController.canSendMail() {
                    DDLogInfo("Mail services are not available")
                    let email = "engkoofb@microsoft.com"
                    if let url = URL(string: "mailto:\(email)") {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url)
                        } else {
                            // Fallback on earlier versions
                            UIApplication.shared.openURL(url)
                        }
                    }
                    return
                }
                let mc = MFMailComposeViewController()
                mc.mailComposeDelegate = self
                mc.setToRecipients(["engkoofb@microsoft.com"])
                mc.setSubject("Learn Chinese Feedback")
                mc.setMessageBody("", isHTML: false)
                UINavigationBar.appearance().tintColor = UIColor.blue
                mc.modalPresentationStyle = .fullScreen
                self.present(mc, animated: true, completion: nil)
            case 1:
                rateApp()
                DDLogInfo("Rate This APP")
            case 2:
                let vc = AboutUsViewController()
                self.ch_pushViewController(vc, animated: true)
            default:
                DDLogInfo("\(indexPath.row)")
            }
        } else if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                let vc = PrivacyViewController()
                self.ch_pushViewController(vc, animated: true)
            case 1:
                let vc = AccountViewController()
                self.ch_pushViewController(vc, animated: true)
            default:
                DDLogInfo("\(indexPath.row)")
            }
        }
//        }else {
//            LCAlertView.show(title: "Are your sure to sign out?", message: "Sign out will not delete any data.You can still sign in with this account.", leftTitle: "Sign out", rightTitle: "Cancel", style: .signout, leftAction: {
//                UserManager.shared.signOutUser()
//                LCAlertView.hide()
//                self.tabBarController?.selectedIndex = 0
//                self.navigationController?.popToRootViewController(animated: true)
//            }, rightAction: {LCAlertView.hide()})
//        }
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if error != nil {
            DDLogInfo("send mail error")
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView,  cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //Top Left Right Corners
        let maskPathTop = UIBezierPath(roundedRect: cell.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 15.0, height: 15.0))
        let shapeLayerTop = CAShapeLayer()
        shapeLayerTop.frame = cell.bounds
        shapeLayerTop.path = maskPathTop.cgPath
        
        //Bottom Left Right Corners
        let maskPathBottom = UIBezierPath(roundedRect: cell.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 15.0, height: 15.0))
        let shapeLayerBottom = CAShapeLayer()
        shapeLayerBottom.frame = cell.bounds
        shapeLayerBottom.path = maskPathBottom.cgPath
        
        //All Corners
        let maskPathAll = UIBezierPath(roundedRect: cell.bounds, byRoundingCorners: [.topLeft, .topRight, .bottomRight, .bottomLeft], cornerRadii: CGSize(width: 15.0, height: 15.0))
        let shapeLayerAll = CAShapeLayer()
        shapeLayerAll.frame = cell.bounds
        shapeLayerAll.path = maskPathAll.cgPath
        
        if (indexPath.row == 0 && indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1)
        {
            cell.layer.mask = shapeLayerAll
        }
        else if (indexPath.row == 0)
        {
            cell.layer.mask = shapeLayerTop
        }
        else if (indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1)
        {
            cell.layer.mask = shapeLayerBottom
        }
        
    }
    
}










