//
//  GradingColorViewController.swift
//  PracticeChinese
//
//  Created by Anika Huo on 8/7/17.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit

class GradingColorViewController: UIViewController {
    
    var titleLabel: UILabel!
    var gradingHeaderImage: UIImageView!
    var tableView: UITableView!
    
    override func viewDidLoad() {
        self.title = "Grading Colors"
        self.view.backgroundColor = UIColor.groupTableViewBackground
        
        let headerY:CGFloat = 20
        let headerHeight = ScreenUtils.heightByRate(y: 0.25)
        let headerWidth = ScreenUtils.widthByRate(x: 0.9)
        let headerX = (ScreenUtils.width - headerWidth) / 2
        
        gradingHeaderImage = UIImageView(frame: CGRect(x: headerX, y: headerY, width: headerWidth, height: headerHeight))
        gradingHeaderImage.contentMode = .scaleAspectFit
        self.view.addSubview(gradingHeaderImage)
        
        let tableY = gradingHeaderImage.frame.maxY + 20
        tableView = UITableView(frame: CGRect(x: 0, y: tableY, width: ScreenUtils.width, height: 120))
        
        tableView.register(GradingColorTableCell.self, forCellReuseIdentifier: GradingColorTableCell.identifier)
        tableView.rowHeight = 60
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = UIColor.white
        self.view.addSubview(tableView)
        setGradingHeaderImage(iscolorBlindnessEnabled: AppData.colorBlindnessEnabled)
        
    }
    
    func setGradingHeaderImage(iscolorBlindnessEnabled: Bool) {
        if iscolorBlindnessEnabled {
            gradingHeaderImage.image = ChImageAssets.mePageBlueBlackYellow.image
        }else {
            gradingHeaderImage.image = ChImageAssets.mePageRedBlackGreen.image
        }
    }
}

extension GradingColorViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GradingColorTableCell.identifier) as! GradingColorTableCell
        switch indexPath.row {
        case 0:
            cell.image_1.image = ChImageAssets.mePageGreen.image
            cell.image_2.image = ChImageAssets.mePageRed.image
            cell.image_3.image = ChImageAssets.selectedColor.image
           
            if AppData.colorBlindnessEnabled {
                cell.image_3.isHidden = true
               }else {
                cell.image_3.isHidden = false
            }
        case 1:
            cell.image_1.image = ChImageAssets.mePageBlue.image
            cell.image_2.image = ChImageAssets.mePageYellow.image
            cell.image_3.image = ChImageAssets.selectedColor.image
            
            if AppData.colorBlindnessEnabled {
                cell.image_3.isHidden = false
            }else {
                cell.image_3.isHidden = true
            }
        default:
            cell.image_1.image = ChImageAssets.mePageBlue.image
            cell.image_2.image = ChImageAssets.mePageYellow.image
            cell.image_3.image = ChImageAssets.selectedColor.image
            
            if AppData.colorBlindnessEnabled {
                cell.image_3.isHidden = false
            }else {
                cell.image_3.isHidden = true
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            AppData.setColorBlindness(blind: false)
            self.setGradingHeaderImage(iscolorBlindnessEnabled: false)
            tableView.reloadData()
        default:
            AppData.setColorBlindness(blind: true)
            self.setGradingHeaderImage(iscolorBlindnessEnabled: true)
            tableView.reloadData()

        }
    }
}

class GradingColorTableCell : UITableViewCell {
    
    var image_1: UIImageView!
    var image_2: UIImageView!
    var image_3: UIImageView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        image_1 = UIImageView(frame: CGRect.zero)
        image_1.contentMode = .scaleAspectFit
        contentView.addSubview(image_1)
        
        image_2 = UIImageView(frame: CGRect.zero)
        image_2.contentMode = .scaleAspectFit
        contentView.addSubview(image_2)
        
        image_3 = UIImageView(frame: CGRect.zero)
        image_3.contentMode = .scaleAspectFit
        contentView.addSubview(image_3)
    }
    
    func setSubviewsFrame() {
        image_1.frame = CGRect(x: 20, y: 15, width: 25, height: 30)
        image_2.frame = CGRect(x: image_1.frame.maxX + 5, y: 15, width: 25, height: 30)
        image_3.frame = CGRect(x: ScreenUtils.width - 40, y: 20, width: 20, height: 20)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setSubviewsFrame()
    }
    
}
