//
//  PictureBubbleCell.swift
//  ChineseDev
//
//  Created by summer on 2018/3/23.
//  Copyright © 2018年 msra. All rights reserved.
//
import Foundation
import UIKit
import YYText

class PictureBubbleCell: UITableViewCell {
    var Img:UIImageView!
    var bubbleView: UIView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        self.backgroundColor = UIColor.black
        selectionStyle = .none
        contentView.backgroundColor = UIColor.clear
    }
    
    func setContent(msg: ChatMessageModel) {
        let bubbleViewWidth = 161
        let bubbleViewHeight = 132
        
        bubbleView = UIView(frame: CGRect(x: 50, y: 0, width: bubbleViewWidth, height: bubbleViewHeight))
        bubbleView.layer.cornerRadius = 12.5
        bubbleView.clipsToBounds = true
        bubbleView.backgroundColor = UIColor.hex(hex: "F1F0F0")
        
        Img = UIImageView(frame: CGRect(x:0,y:0,width:bubbleViewWidth,height:bubbleViewHeight))
        if(msg.imageUrl == ""){
            Img.image = UIImage.fromColor(color: UIColor.lightGray)
        }else{
            Img.sd_setImage(with: URL(string: msg.imageUrl), placeholderImage: UIImage(named: "placeholder"), options: .refreshCached, completed: nil)
        }
        Img.contentMode = .scaleToFill


        self.addSubview(bubbleView)
        bubbleView.addSubview(Img)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
