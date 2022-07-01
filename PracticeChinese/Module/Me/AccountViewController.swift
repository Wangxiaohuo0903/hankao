//
//  AccountViewController.swift
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
import FBSDKLoginKit

class AccountViewController: UIViewController {
    
    var tableView: UITableView!
    var profileView: UIView!
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.groupTableViewBackground
        
        
        
        tableView = UITableView(frame: CGRect(x: ScreenUtils.widthBySix(x: 0), y: 180, width: ScreenUtils.width-ScreenUtils.widthBySix(x: 0), height: ScreenUtils.height-64), style: .grouped)
        
        tableView.backgroundColor = UIColor.clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(SettingItemCell.nibObject, forCellReuseIdentifier: SettingItemCell.identifier)
        tableView.register(SettingTitleCell.nibObject, forCellReuseIdentifier: SettingTitleCell.identifier)
        
        self.view.addSubview(tableView)
        setUpAvatar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Account Settings"
        UINavigationBar.appearance().tintColor = UIColor.white
        
    }
    
    func setUpAvatar(){
        profileView = UIView()
        self.view.addSubview(profileView)
        
        let avatarView = UIImageView()
        avatarView.sd_setImage(with: UserManager.shared.getAvatarUrl(), placeholderImage: ChImageAssets.Placeholder_Avatar.image, options: .refreshCached, completed: nil)
        avatarView.layer.cornerRadius = 50
        avatarView.layer.masksToBounds = true
        profileView.addSubview(avatarView)
        let nameLabel = UILabel()
        nameLabel.textAlignment = .center
        nameLabel.text = UserManager.shared.getName()
        nameLabel.font = FontUtil.getFont(size: 18, type: .Medium)
        nameLabel.sizeToFit()
        nameLabel.textColor = UIColor.blueTheme
        profileView.addSubview(nameLabel)
        profileView.backgroundColor = UIColor.clear
        
        nameLabel.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(profileView)
            make.top.equalTo(avatarView.snp.bottom).offset(5)
            make.height.equalTo(UIAdjust().adjustByHeight(24))
        }
        
        
        avatarView.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(profileView)
            make.centerY.equalTo(profileView)
            make.height.width.equalTo(100)
        }
        
        
        profileView.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(self.view)
            make.height.equalTo(160)
        }
    }
    
}

extension AccountViewController: UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch  section {
        case 0:
            return 1
        case 1:
            return 1
        default:
            return 7
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingTitleCell.identifier) as! SettingTitleCell
        cell.arrow.isHidden = true
        switch indexPath.section {
            
        case 0:
            cell.titleLabel.text = "Delete This Account Permanently"
            cell.titleLabel.textColor = UIColor.red
            cell.titleLabel.textAlignment = .center
            
        case 1:
            cell.titleLabel.text = "Sign out"
            cell.titleLabel.textColor = UIColor.textGray
            cell.titleLabel.textAlignment = .center
            
        default:
            cell.titleLabel.text = ""
            cell.titleLabel.textColor = UIColor.textGray
            cell.titleLabel.textAlignment = .center
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhone4){
            return ScreenUtils.heightByM(y: 40)
        }else{
            return ScreenUtils.heightByM(y: 45)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ScreenUtils.heightBySix(y: 20)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section{
            case 0:
                LCAlertView.show(title: "Permanently Delete Account", message: "All of this application's data will be deleted permanently. This includes all learning data, your profile, settings,etc. This is not reversible.", leftTitle: "Cancel", rightTitle: "Delete", style: .leftred, leftAction: {
                    LCAlertView.hide()
                }, rightAction: {
                    LCAlertView.hide()
                    ChActivityView.show()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        
                        //删除Acount,在Rounter中改参数,根据返回类型，新建Mappable类型，替换UserModel
                        let callback:(UserModel?, Error?, String?)->() = {
                            data, error, raw in
//                            print("DeleteAcount")
                        }
                        RequestManager.shared.performRequest(urlRequest: Router.DeleteAcount(), completionHandler: callback)
                        ChActivityView.hide()
                        if UserManager.shared.getAccountType() == LoginAccountType.FacebookLogin {
                            //logout
                            let loginManager = FBSDKLoginManager()
                            loginManager.logOut()
                        }
                        UserManager.shared.signOutUser(){
                            let mc = self.slideMenuController()?.mainViewController as! UINavigationController
                            let vc = LoginFullViewController()
                            mc.pushViewController(vc, animated: true)
                            LCAlertView.show(title: "", message: "Your account has been deleted.Signing in again will create a new account.", leftTitle: "OK", rightTitle: "OK", style: .oneButton, leftAction: {
                                LCAlertView.hide()
                            }, rightAction: {
                                LCAlertView.hide()
                            })
                        }
                    }
                })
            case 1:
                
                LCAlertView.show(title: "Sign out", message: "Signing out will not delete any data.You can still sign in with this account.", leftTitle: "Sign out", rightTitle: "Cancel", style: .center, leftAction: {
                    UserManager.shared.signOutUser(){
                        if UserManager.shared.getAccountType() == LoginAccountType.FacebookLogin {
                            //logout
                            let loginManager = FBSDKLoginManager()
                            loginManager.logOut()
                        }
                        LCAlertView.hide()
                        CourseManager.shared.isLearnPage = true
                        self.navigationController?.popToRootViewController(animated: true)
//                        CourseManager.shared.loadData()
                    }
                }, rightAction: {LCAlertView.hide()})
            default:
                DDLogInfo("\(indexPath.section)")
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












