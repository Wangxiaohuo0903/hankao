//
//  TextTipCell.swift
//  PracticeChinese
//
//  Created by 费跃 on 9/12/17.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit
import YYText

class TextTipCell: UITableViewCell {
    var titleLabel: YYLabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        titleLabel = YYLabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        titleLabel.textAlignment = .center
        titleLabel.backgroundColor = UIColor.hex(hex: "A5A5A5")
        titleLabel.layer.cornerRadius = 12.5
        titleLabel.numberOfLines = 0
        
        contentView.addSubview(titleLabel)
    }
    
    func setContent(msg: ChatMessageModel, image: UIImage?) {

        let text = msg.text.string
        let attributedString =  NSMutableAttributedString(string: text, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.white]))
        let range1 = "Here you can say:"
        let range2 = "These words may help you:"
        text.enumerateSubstrings(in: text.startIndex..<text.endIndex, options: .byLines) {
            (substring, substringRange, _, _) in
            if substring == range1 {
                attributedString.yy_setColor(UIColor.hex(hex: "#FFEEA6"), range: NSRange(substringRange, in: text))
            }
            if substring == range2 {
                attributedString.yy_setColor(UIColor.hex(hex: "#FFEEA6"), range: NSRange(substringRange, in: text))
            }
        }
        attributedString.yy_font = FontUtil.getDescFont()
        attributedString.yy_alignment = .center
        let textWidth = msg.text.string.wdith(withConstrainedWidth: ScreenUtils.width - ScreenUtils.widthBySix(x: 60), font: FontUtil.getTextFont()) + 40
        let textHeight = msg.text.string.height(withConstrainedWidth: ScreenUtils.width - ScreenUtils.widthBySix(x: 60), font: FontUtil.getTextFont())  + ScreenUtils.heightBySix(y: 20)

        if image != nil {
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 0, y: 0, width: textHeight, height: textHeight)
            let attachments = NSMutableAttributedString.yy_attachmentString(withContent: imageView, contentMode: .center , attachmentSize: CGSize(width: ScreenUtils.widthBySix(x: 16), height: ScreenUtils.widthBySix(x: 16)), alignTo: FontUtil.getTextFont(), alignment: .center)
            attributedString.append(attachments)
        }
        titleLabel.frame = CGRect(x: ScreenUtils.width / 2 - ScreenUtils.widthBySix(x: 20) - (textWidth / 2), y: 0, width: textWidth, height: textHeight)
        titleLabel.attributedText = attributedString
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
