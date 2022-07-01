//
//  AboutUsViewController.swift
//  PracticeChinese
//
//  Created by Anika Huo on 7/30/17.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire

class AboutUsViewController: UIViewController {
    var tableView: UITableView!
    var bgImg: UIImageView!
    var titleLabel: UILabel!
    var noteLabel: UILabel!
    var isUpdate: Bool = false
    
    override func viewDidLoad() {
        self.title = "About"
        self.view.backgroundColor = UIColor.groupTableViewBackground
        
        bgImg = UIImageView(frame: CGRect(x: ScreenUtils.widthByRate(x: 0.37), y: ScreenUtils.heightByRate(y: 0.09), width: ScreenUtils.widthByRate(x: 0.26), height: ScreenUtils.widthByRate(x: 0.26)))
        bgImg.image = UIImage(named: "heihei")
        self.view.addSubview(bgImg)
        
        titleLabel = UILabel(frame: CGRect(x: ScreenUtils.widthByRate(x: 0.1), y: ScreenUtils.heightByRate(y: 0.12) + ScreenUtils.widthByRate(x: 0.26), width: ScreenUtils.widthByRate(x: 0.8), height: ScreenUtils.widthByRate(x: 0.1)))
        titleLabel.text = "Microsoft Learn Chinese \(AppData.getVersion())"
        titleLabel.font = FontUtil.getFont(size: 17, type: .Regular)
        titleLabel.textColor = UIColor.textGray
        titleLabel.textAlignment = .center
        self.view.addSubview(titleLabel)
        
        noteLabel = UILabel(frame: CGRect(x: ScreenUtils.widthByRate(x: 0.2), y: ScreenUtils.heightByRate(y: 0.33), width: ScreenUtils.widthByRate(x: 0.6), height: ScreenUtils.heightByRate(y: 0.06)))
        noteLabel.layer.cornerRadius = 5
        noteLabel.layer.masksToBounds = true
        noteLabel.text = "This is the latest version"
        noteLabel.font = FontUtil.getFont(size: 16, type: .Regular)
        noteLabel.textColor = UIColor.white
        noteLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        noteLabel.textAlignment = .center
        self.view.addSubview(noteLabel)
        
        tableView = UITableView(frame: CGRect(x: 15, y:ScreenUtils.heightByRate(y: 0.37), width: ScreenUtils.width - 30, height: ScreenUtils.heightByRate(y: 0.29)), style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.backgroundColor = UIColor.groupTableViewBackground
//        self.view.addSubview(tableView)
        
        let bottomText = "© 2019 Microsoft"
        let bottomHeight = bottomText.height(withConstrainedWidth: ScreenUtils.width - 30, font: FontUtil.getFont(size: 11, type: .Regular))
        let bottomLabel = UILabel(frame: CGRect(x: 15, y: ScreenUtils.heightByRate(y: 0.98) - bottomHeight - ch_getStatusNavigationHeight(), width: ScreenUtils.width - 30, height: bottomHeight))
        bottomLabel.numberOfLines = 2
        bottomLabel.textAlignment = .center
        
        bottomLabel.text = "© 2019 Microsoft"
        bottomLabel.font = FontUtil.getFont(size: 11, type: .Regular)
        bottomLabel.textColor = UIColor.lightGray
        self.view.addSubview(bottomLabel)

        noteLabel.isHidden = true
        self.view.bringSubviewToFront(noteLabel)
        
        self.versionCheck(completion: {
            (completion) in
            if(completion)!{
                self.isUpdate = true
            }else{
                self.isUpdate = false
            }
        })
    }
    
}

extension AboutUsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
         return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.font = FontUtil.getFont(size: 17, type: .Regular)

        cell.textLabel?.textColor = UIColor.textGray
        if indexPath.row == 0 {
            cell.textLabel?.text = "Features"
        }
        else if indexPath.row == 1{
            cell.textLabel?.text = "Privacy Policy"
        }else if indexPath.row == 2{
            cell.textLabel?.text = "Terms Of Use"
        }else{
            cell.textLabel?.text = "Check For Updates"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ScreenUtils.heightByRate(y: 0.09)
    }
    
    func versionCheck(completion: @escaping (Bool?)->()){
        let callback:(DataResponse<Data>, Error?, String?)->() = {
            response,error,raw in
            if(response.response?.statusCode == 403){
                completion(true)
            }
            completion(false)
        }
//        RequestManager.shared.versioncheck(completionHandler: callback)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 3 {
            if(!self.isUpdate){
                self.noteLabel.isHidden = false
                if #available(iOS 10.0, *) {
                    let timer = Timer(timeInterval: 2, repeats: false, block: {
                        _ in
                        self.noteLabel.isHidden = true
                    })
                    RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
                    
                } else {
                    // Fallback on earlier versions
                }
            }else{
                //需要更新
//                print("need to update!!!!")
            }
        }
        else  if indexPath.row == 0 {
            let vc = FeatureViewController()
            self.ch_pushViewController(vc, animated: true)
        }else  if indexPath.row == 1 {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: "https://go.microsoft.com/fwlink/?LinkId=521839")!)
            } else {
                UIApplication.shared.openURL(URL(string: "https://go.microsoft.com/fwlink/?LinkId=521839")!)
                
                // Fallback on earlier versions
            }
        }else {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: "http://go.microsoft.com/fwlink/?linkid=206977")!)
            } else {
                UIApplication.shared.openURL(URL(string: "http://go.microsoft.com/fwlink/?linkid=206977")!)
                // Fallback on earlier versions
            }
        }
    }
}























