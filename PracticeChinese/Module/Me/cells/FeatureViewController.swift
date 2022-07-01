//
//  FeatureViewController.swift
//  PracticeChinese
//
//  Created by Anika Huo on 7/30/17.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit

class FeatureViewController: UIViewController {
    var tableView:UITableView!
    var bgImg:UIImageView!
    var titleLabel:UILabel!
    
    override func viewDidLoad() {
        self.title = "Features"
        self.view.backgroundColor = UIColor.groupTableViewBackground
        
        bgImg = UIImageView(frame: CGRect(x: ScreenUtils.widthByRate(x: 0.37), y: ScreenUtils.heightByRate(y: 0.09), width: ScreenUtils.widthByRate(x: 0.26), height: ScreenUtils.widthByRate(x: 0.26)))
        bgImg.image = UIImage(named: "heihei")
        self.view.addSubview(bgImg)
        
        titleLabel = UILabel(frame: CGRect(x: ScreenUtils.widthByRate(x: 0.1), y: ScreenUtils.heightByRate(y: 0.12) + ScreenUtils.widthByRate(x: 0.26), width: ScreenUtils.widthByRate(x: 0.8), height: ScreenUtils.widthByRate(x: 0.1)))
        titleLabel.text = "Microsoft Learn Chinese 1.1"
        titleLabel.font = FontUtil.getFont(size: 18, type: .Medium)

        titleLabel.textColor = UIColor.textGray
        titleLabel.textAlignment = .center
        self.view.addSubview(titleLabel)
        
        
        tableView = UITableView(frame: CGRect(x: ScreenUtils.widthByRate(x: 0.1), y: ScreenUtils.heightByRate(y: 0.37), width: ScreenUtils.widthByRate(x: 0.8), height: ScreenUtils.heightByRate(y: 0.556)), style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.groupTableViewBackground
        tableView.estimatedRowHeight = 80
        self.view.addSubview(tableView)
        
        let bottomText = "微软亚洲研究院 版权所有 \n Copyright 2017 MSRA. All Rights Reserved."
        let bottomHeight = bottomText.height(withConstrainedWidth: ScreenUtils.width - 30, font: FontUtil.getFont(size: 13, type: .Regular))
        let bottomLabel = UILabel(frame: CGRect(x: 15, y: ScreenUtils.heightByRate(y: 0.98) - bottomHeight - 64, width: ScreenUtils.width - 30, height: bottomHeight))
        bottomLabel.numberOfLines = 2
        bottomLabel.textAlignment = .center
        
        bottomLabel.text = "微软亚洲研究院 版权所有 \n Copyright 2017 MSRA. All Rights Reserved."
        bottomLabel.font = FontUtil.getFont(size: 13, type: .Regular)

        bottomLabel.textColor = UIColor.textGray
//        self.view.addSubview(bottomLabel)
    }
}

extension FeatureViewController:UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.font = FontUtil.getFont(size: 15, type: .Regular)

        cell.textLabel?.textColor = UIColor.textGray
        if indexPath.row == 0 {
            cell.textLabel?.text = "1.Speech Recognition: The advanced grading system provides instant feedback."
            cell.textLabel?.numberOfLines = 0
        }
        else if indexPath.row == 1  {
            cell.textLabel?.text = "2.Professional Course Material: Designed by experienced teachers; and aligned with the HSK difficulty classification."
            cell.textLabel?.numberOfLines = 0
        }
        else {
            cell.textLabel?.text = "3.Conversational Interface: A virtual teacher you can interact with anytime, powered by cutting-edge AI technology."
            cell.textLabel?.numberOfLines = 0
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}
