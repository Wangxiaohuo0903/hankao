//
//  LearnedWordCellCell.swift
//  PracticeChinese
//
//  Created by Temp on 2018/7/18.
//  Copyright © 2018年 msra. All rights reserved.
//

import UIKit

class LearnedWordCellCell: UITableViewCell {
    @IBOutlet weak var nativeName: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var pinyn: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    func setData(name:String,pinyin:String,nativeName:String) {
        self.name.text = name
        self.pinyn.text = pinyin
        self.nativeName.text = nativeName
    }

}
