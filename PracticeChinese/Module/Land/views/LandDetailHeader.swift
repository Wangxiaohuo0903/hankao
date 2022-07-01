//
//  LandDetailHeader.swift
//  PracticeChinese
//
//  Created by Temp on 2018/10/24.
//  Copyright © 2018年 msra. All rights reserved.
//

import UIKit
import YYText

class LandDetailHeader: UIView {
    @IBOutlet weak var score: UIButton!
    @IBOutlet weak var introduce: UILabel!
    
    @IBOutlet weak var headerTitle: UIView!
    var label: YYLabel!
    var courseStatusDictionary : [String : [String:Any]]?
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
    func setData(scenario: ScenarioLesson) {
        let text = NSMutableAttributedString()
        let font = FontUtil.getFont(size: 18, type: .Medium)
        let title = "\(scenario.NativeName!)  "
        text.append(NSMutableAttributedString(string: title, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.textBlack333, convertFromNSAttributedStringKey(NSAttributedString.Key.font) : FontUtil.getFont(size: 18, type: .Medium)])))
        
        let HSKBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 38, height: 14))
        if let level = scenario.DifficultyLevel {
            let diffLevel = level > 0 ? level : 1
            HSKBtn.setTitle("HSK\(diffLevel)", for: .normal)
        }else {
            HSKBtn.setTitle("HSK1", for: .normal)
        }
        HSKBtn.titleLabel?.font = FontUtil.getFont(size: 11, type: .Bold)
        HSKBtn.backgroundColor = UIColor.hex(hex: "78ABFF")
        HSKBtn.layer.cornerRadius = 4
        let attachText = NSMutableAttributedString.yy_attachmentString(withContent: HSKBtn, contentMode: .center, attachmentSize: CGSize(width: 33, height: 40), alignTo: font, alignment: .center)
        text.append(attachText)
        text.append(NSMutableAttributedString(string: "\n", attributes: nil))
        
        let Introducation = scenario.Introducation?.NativeText
        text.append(NSMutableAttributedString(string: Introducation!, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.textGray, convertFromNSAttributedStringKey(NSAttributedString.Key.font) : FontUtil.getFont(size: 14, type: .Regular)])))
        self.label = YYLabel()
        label.isUserInteractionEnabled = false
        label.numberOfLines = 0
        label.textVerticalAlignment = .center
        label.frame = CGRect(x: 0, y: 0, width: ScreenUtils.width - 130, height: 140)
        label.attributedText = text
        headerTitle.addSubview(label)
        //最高分
        score.setTitle("\(CourseManager.shared.getCourseScore(scenario.Id!))", for: .normal)
        
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
