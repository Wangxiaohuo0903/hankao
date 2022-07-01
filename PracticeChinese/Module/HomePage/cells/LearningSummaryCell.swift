//
//  LearningSummaryCell.swift
//  PracticeChinese
//
//  Created by Temp on 2018/12/3.
//  Copyright © 2018 msra. All rights reserved.
//

import UIKit

class LearningSummaryCell: UITableViewCell {
    @IBOutlet weak var statusImageView: UIImageView!
    
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var english: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var chinese: UILabel!
    var headerCircle : MLMCircleView!
    var progressLabel = UILabel()
    @IBOutlet weak var line: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let circleWidth = CGFloat(45.0)
        headerCircle = MLMCircleView(frame: CGRect(x: 0 , y: 0, width: circleWidth, height: circleWidth), startAngle: 270, endAngle: 630)
        headerCircle?.center = CGPoint(x: circleWidth/2, y: circleWidth/2)
        headerCircle?.bottomWidth = 2
        headerCircle?.progressWidth = 3
        headerCircle?.fillColor = UIColor.hex(hex: "4E80D9")
        headerCircle?.bgColor = UIColor.hex(hex: "E2E2E2")
        headerCircle?.dotDiameter = 20;
        headerCircle?.edgespace = 5;
        headerCircle?.drawProgress()
        progressView.addSubview(headerCircle!)
        
        progressLabel.frame = CGRect(x: 0 , y: 0, width: circleWidth, height: circleWidth)
        progressLabel.backgroundColor = UIColor.clear
        progressLabel.textColor = UIColor.blueTheme
        progressLabel.textAlignment = .center
        progressLabel.font = FontUtil.getFont(size: 12, type: .Regular)
        progressView.addSubview(progressLabel)
    }
    func setData(score: [String : Double]) {
        chinese.text = score.first?.key
        if (score.first?.value)! >= Double(1.0) {
            statusImageView.isHidden = false
            progressView.alpha = 0
        }else {
            statusImageView.isHidden = true
            progressView.alpha = 1
            let progress = Int((score.first?.value)! * 100)
            progressLabel.text = "\(progress)%"
            headerCircle?.setProgress(CGFloat(Double((score.first?.value)!)))
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
