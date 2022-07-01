//
//  SettingItemCell.swift
//  PracticeChinese
//
//  Created by Anika Huo on 7/29/17.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class SettingItemCell: UITableViewCell {
    
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var itemSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        itemSwitch.onTintColor = UIColor.blueTheme
        itemSwitch.isOn = false
        
        itemLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self).offset(20)
        }
        itemSwitch.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(self).offset(-20)
        }
        
    }
}
