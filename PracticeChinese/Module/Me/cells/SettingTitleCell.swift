//
//  SettingTitleCell.swift
//  PracticeChinese
//
//  Created by Anika Huo on 7/29/17.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class SettingTitleCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrow: UIImageView!
    @IBOutlet weak var subLabel: UILabel!
    var line:UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(16), type: .Regular)
        titleLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self).offset(20)
        }
        arrow.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(self).offset(-20)
        }
        subLabel.font = FontUtil.getFont(size: FontAdjust().FontSize(16), type: .Regular)
        subLabel.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(self).offset(-40)
        }
        line = UIView()
        line.backgroundColor = UIColor.hex(hex:"#dcdcdc")
        self.addSubview(line)
        
        line.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(titleLabel.snp.left)
            make.right.equalTo(self)
            make.top.equalTo(self.snp.bottom).offset(-1)
            make.height.equalTo(1)
            
        }
        
        line.isHidden = true
    }
}
