//
//  PrivacyViewController.swift
//  PracticeChinese
//
//  Created by 费跃 on 8/29/17.
//  Copyright © 2017 msra. All rights reserved.
//
//隐私设置
import Foundation
import UIKit
import MessageUI
import CocoaLumberjack
import SnapKit
import YYText
import FBSDKLoginKit

class PrivacyViewController: UIViewController {
    
    var tableView: UITableView!
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.groupTableViewBackground
        
        
        
        tableView = UITableView(frame: CGRect(x: ScreenUtils.widthBySix(x: 0), y: ScreenUtils.heightBySix(y: 0), width: ScreenUtils.width-ScreenUtils.widthBySix(x: 0), height: ScreenUtils.height-64), style: .grouped)
        
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(SettingItemCell.nibObject, forCellReuseIdentifier: SettingItemCell.identifier)
        tableView.register(SettingTitleCell.nibObject, forCellReuseIdentifier: SettingTitleCell.identifier)
        
        self.view.addSubview(tableView)
        
        let attributedStr = NSMutableAttributedString(string:"Privacy Policy  |  Terms of Service", attributes: convertToOptionalNSAttributedStringKeyDictionary([ convertFromNSAttributedStringKey(NSAttributedString.Key.font) : FontUtil.getFont(size: FontAdjust().FontSize(12), type: .Regular)]))
        
        attributedStr.yy_setColor(UIColor.blueTheme, range: NSMakeRange (0, 14))
        attributedStr.yy_setColor(UIColor.textGray, range: NSMakeRange (16, 1))
        attributedStr.yy_setColor(UIColor.blueTheme, range: NSMakeRange (19, 16))
        
        attributedStr.yy_setTextHighlight(NSMakeRange (0, 14), color: UIColor.blueTheme, backgroundColor: UIColor.clear) {
            view, text, range, rect in
            self.openBrowser(urlStr: "https://go.microsoft.com/fwlink/?LinkId=521839")
        }
        
        attributedStr.yy_setTextHighlight(NSMakeRange (19, 16), color: UIColor.blueTheme, backgroundColor: UIColor.clear) {
            view, text, range, rect in
            self.openBrowser(urlStr: "http://go.microsoft.com/fwlink/?linkid=206977")
        }
        attributedStr.yy_alignment = .center
        
        var suggestionLabel = YYLabel()
        suggestionLabel.numberOfLines = 3
        suggestionLabel.sizeToFit()
        
        suggestionLabel.frame = CGRect(x: ScreenUtils.widthByRate(x: 0.15), y: ScreenUtils.height - ScreenUtils.heightByM(y: 70), width: ScreenUtils.widthByRate(x: 0.7), height: 70)
        suggestionLabel.attributedText = attributedStr
        self.view.addSubview(suggestionLabel)
        
        suggestionLabel.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(self.view).offset(-20)
            make.height.equalTo(20)
            make.left.right.equalTo(self.view)
        }
    }
    
    @objc func turnUserAssessment(sender: UISwitch!) {
        let deletcell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? SettingTitleCell
        if sender.isOn {
            AppData.setUserAssessment(true)
            deletcell?.isUserInteractionEnabled = true
            deletcell?.titleLabel.textColor = UIColor.red
            deletcell?.reloadInputViews()
        } else {
            LCAlertView.show(title: "Disable Data Collection", message: "This will cancel access to your data collection. All data about your learning performance will be removed. This is not reversible.", leftTitle: "Cancel", rightTitle: "Disable", style: .leftred, leftAction: {
                LCAlertView.hide()
                let switchcell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SettingItemCell
                switchcell?.itemSwitch.setOn(true, animated: true)
            }, rightAction: {
                LCAlertView.hide()
                ChActivityView.show()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    //删除Data,在Rounter中改参数,根据返回类型，新建Mappable类型，替换UserModel
                    let callback:(UserModel?, Error?, String?)->() = {
                        data, error, raw in
//                        print("DeleteData")

                    }
                    RequestManager.shared.performRequest(urlRequest: Router.DeleteData(), completionHandler: callback)
                    ChActivityView.hide()
                    AppData.setUserAssessment(false)

                    if(!AppData.userAssessmentEnabled){
                        deletcell?.isUserInteractionEnabled = false
                        deletcell?.titleLabel.textColor = UIColor.textGray.withAlphaComponent(0.4)
                        deletcell?.reloadInputViews()
                    }
                    LCAlertView.show(title: "", message: "All your data has been deleted. Please login again", leftTitle: "OK", rightTitle: "OK", style: .oneButton, leftAction: {
                        LCAlertView.hide()
                        if UserManager.shared.getAccountType() == LoginAccountType.FacebookLogin {
                            //logout
                            let loginManager = FBSDKLoginManager()
                            loginManager.logOut()
                        }
                        UserManager.shared.signOutUser(){
                            let mc = self.slideMenuController()?.mainViewController as! UINavigationController
                            let vc = LoginFullViewController()
                            mc.pushViewController(vc, animated: true)
                        }
                    }, rightAction: {
                        LCAlertView.hide()
                    })
                }
            })
        }
    }
    
    func turnUserExperience(sender: UISwitch!) {
        let deletcell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? SettingTitleCell
        if sender.isOn {
            AppData.setUserExperience(true)
            deletcell?.isUserInteractionEnabled = true
            deletcell?.titleLabel.textColor = UIColor.red
            deletcell?.reloadInputViews()
        }
        else {
            AppData.setUserExperience(false)
        }
    }
    
    private func openBrowser(urlStr: String) {
        let url = URL(string: urlStr)!
        if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
                
                // Fallback on earlier versions
            }
        } else {
            self.presentUserToast(message: "cannot open url")
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Privacy Settings"
        UINavigationBar.appearance().tintColor = UIColor.white
        
    }
    
    
}

extension PrivacyViewController: UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch  section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        default:
            return 7
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingItemCell.identifier) as! SettingItemCell
            cell.itemLabel.text = "Data Collection and Permission"
            cell.itemLabel.font = FontUtil.getFont(size: 17, type: .Regular)
            cell.itemLabel.adjustsFontSizeToFitWidth = true
            cell.itemSwitch.addTarget(self, action: #selector(turnUserAssessment), for: .valueChanged)
            if AppData.userAssessmentEnabled {
                cell.itemSwitch.setOn(true, animated: false)
            } else {
                cell.itemSwitch.setOn(false, animated: false)
            }
            return cell
        case 1:
//            let cell = tableView.dequeueReusableCell(withIdentifier: SettingItemCell.identifier) as! SettingItemCell
//            cell.itemLabel.text = "Experience Improvement Program"
//            cell.itemLabel.font = FontUtil.getFont(size: 17, type: .Regular)
//            cell.itemLabel.adjustsFontSizeToFitWidth = true
//            cell.itemSwitch.addTarget(self, action: #selector(turnUserExperience), for: .valueChanged)
//            if AppData.userExperienceEnabled {
//                cell.itemSwitch.setOn(true, animated: false)
//            } else {
//                cell.itemSwitch.setOn(false, animated: false)
//            }
//            return cell
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingTitleCell.identifier) as! SettingTitleCell
            cell.arrow.isHidden = true
            cell.titleLabel.text = "Delete All Your Data"
            cell.titleLabel.textColor = UIColor.red
            cell.titleLabel.textAlignment = .center
            if(!AppData.userAssessmentEnabled){
                cell.isUserInteractionEnabled = false
                cell.titleLabel.textColor = UIColor.textGray.withAlphaComponent(0.4)
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingTitleCell.identifier) as! SettingTitleCell
            cell.arrow.isHidden = true
            cell.titleLabel.text = "Delete All Your Data"
            cell.titleLabel.textColor = UIColor.red
            cell.titleLabel.textAlignment = .center
            if(!AppData.userAssessmentEnabled){
                cell.isUserInteractionEnabled = false
                cell.titleLabel.textColor = UIColor.textGray.withAlphaComponent(0.4)
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
        if section == 0{
            return ScreenUtils.heightBySix(y: 10)
        }
        if section == 1{
            return ScreenUtils.heightBySix(y: 40)
        }
        return ScreenUtils.heightBySix(y: 40)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            var textString = String.PrivacyConsent
//            if section == 1 {
//                textString = "The program collects information about your speech to improve our scoring model. It also collects information about how you use our product to improve its quality and reliability. No information collected is used to identify or contact you."
//            }
            return textString.height(withConstrainedWidth: ScreenUtils.width - 40, font: FontUtil.getFont(size: 12, type: .Regular)) + 20
        }
        else{
            return 10
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let footer = UIView()
            //y需要自定义高度，暂时暴力写死了
            
            let label = UILabel(frame: CGRect(x: 15, y: 0, width: ScreenUtils.width - 40, height: 60))
            label.textColor = UIColor.textGray
            label.numberOfLines = 0
            label.font = FontUtil.getFont(size: 12, type: .Regular)
            var textString = String.PrivacyConsent
            if section == 1 {
                textString =  "The program collects information about your speech to improve our scoring model. It also collects information about how you use our product to improve its quality and reliability. No information collected is used to identify or contact you."
            }
            let height = textString.height(withConstrainedWidth: ScreenUtils.width - 40, font: FontUtil.getFont(size: 12, type: .Regular)) + 20
            label.text = textString
            label.textAlignment = .left
            label.sizeToFit()
            footer.addSubview(label)
            label.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(footer).offset(0)
                make.height.equalTo(height)
                make.left.equalTo(footer).offset(20)
                make.right.equalTo(footer).offset(-20)
            }
            return footer
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if(indexPath.section == 1){
            let Cell = tableView.cellForRow(at: IndexPath(row: indexPath.row, section: indexPath.section)) as? SettingTitleCell
            LCAlertView.show(title: "Delete Data", message: "All of this application's data will be deleted permanently. This includes all your learning performance. This is not reversible.", leftTitle: "Cancel", rightTitle: "Delete", style: .leftred, leftAction: {
                LCAlertView.hide()
            }, rightAction: {
                LCAlertView.hide()
                ChActivityView.show()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    //删除Data,在Rounter中改参数,根据返回类型，新建Mappable类型，替换UserModel
                    let callback:(UserModel?, Error?, String?)->() = {
                        data, error, raw in
//                        print("DeleteData")
                    }
                    RequestManager.shared.performRequest(urlRequest: Router.DeleteData(), completionHandler: callback)
                    ChActivityView.hide()
                    Cell?.isUserInteractionEnabled = false
                    Cell?.titleLabel.textColor = UIColor.textGray.withAlphaComponent(0.4)
                    Cell?.reloadInputViews()
                    LCAlertView.show(title: "", message: "All your data has been deleted. Please login again.", leftTitle: "OK", rightTitle: "OK", style: .oneButton, leftAction: {
                        LCAlertView.hide()
                        if UserManager.shared.getAccountType() == LoginAccountType.FacebookLogin {
                            //logout
                            let loginManager = FBSDKLoginManager()
                            loginManager.logOut()
                        }
                        UserManager.shared.signOutUser(){
                            let mc = self.slideMenuController()?.mainViewController as! UINavigationController
                            let vc = LoginFullViewController()
                            mc.pushViewController(vc, animated: true)
                        }

                    }, rightAction: {
                        LCAlertView.hide()
                    })
                }
            })
        }
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












// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
