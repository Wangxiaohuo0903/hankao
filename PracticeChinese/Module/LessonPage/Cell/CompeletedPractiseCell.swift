//
//  CompeletedPractiseCell.swift
//  PracticeChinese
//
//  Created by Temp on 2018/9/28.
//  Copyright © 2018年 msra. All rights reserved.
//

import UIKit

class CompeletedPractiseCell: UITableViewCell {
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var lessonTitle: UILabel!

    @IBOutlet weak var HSK: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 9
        bgView.layer.masksToBounds = true
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
