//
//  FooterPickerView.swift
//  ChineseLearning
//
//  Created by feiyue on 05/05/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit


protocol FooterPickerViewDelegate {
    func selectItem(index:Int)
}
class PickerRowView:UIView  {
    var iconView:UIImageView!
    var titleLabel:UILabel!
    //var unselectedColor = UIColor(red: 187/255, green: 189/255, blue: 191/255, alpha: 1)
    var unselectedColor = UIColor.textGray
    override init(frame: CGRect) {
        super.init(frame: frame)
        iconView = UIImageView(frame:CGRect(x: 20, y: frame.height / 2 - 10, width: 20, height: 20))
        iconView.image = ChImageAssets.UnselectedGoal.image
        titleLabel = UILabel(frame:CGRect(x: ScreenUtils.widthByRate(x: 0.5), y: 0, width: ScreenUtils.widthByRate(x: 0.5) - 20, height: frame.height))
        titleLabel.textAlignment = .right
        titleLabel.textColor = unselectedColor
        titleLabel.font = FontUtil.getFont(size: 16, type: .Regular)
        addSubview(iconView)
        addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class FooterPickerView:UIView {
    var picker:UIPickerView!
    var titles = [String]() {
        didSet {
            picker.reloadComponent(0)
        }
    }
    var blurView:UIView!
    var okButton:UIButton!
    var titleLabel:UILabel!
    var cancelButton:UIButton!
    var canvasView:UIView!
    var delegate:FooterPickerViewDelegate?
    
    public class var sharedInstance: FooterPickerView {
        struct Singleton {
            static let instance = FooterPickerView(frame: CGRect.zero)
        }
        return Singleton.instance
    }
    
    
    func containerView() -> UIView? {
        return UIApplication.shared.keyWindow
    }


    override init(frame: CGRect) {
        super.init(frame: frame)
        blurView = UIView(frame:CGRect(x:0, y:0, width:ScreenUtils.width, height:ScreenUtils.height))
        blurView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        blurView.isUserInteractionEnabled  = true
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hide))
        //blurView.addGestureRecognizer(tapGesture)
        canvasView = UIView(frame:CGRect(x:0, y:ScreenUtils.heightByRate(y: 0.54), width:ScreenUtils.width, height:ScreenUtils.heightByRate(y: 0.46)))
        canvasView.backgroundColor = UIColor.white
        
        titleLabel = UILabel(frame: CGRect(x:ScreenUtils.widthByRate(x: 0), y: 0, width:ScreenUtils.width, height:ScreenUtils.heightByRate(y: 0.08)))
        titleLabel.backgroundColor = UIColor.groupTableViewBackground
        titleLabel.text = "Set Daily Goal"
        titleLabel.font = FontUtil.getFont(size: 18, type: .Regular)

        titleLabel.textColor = UIColor.textGray
        titleLabel.textAlignment = .center
        canvasView.addSubview(titleLabel)
        
        cancelButton = UIButton(frame: CGRect(x:ScreenUtils.widthByRate(x: 0.96)-20, y: ScreenUtils.heightByRate(y: 0.04) - 10, width:20, height:20))
        cancelButton.setImage(ChImageAssets.CloseIcon.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        cancelButton.tintColor = UIColor.blueTheme
        cancelButton.addTarget(self, action: #selector(hide), for: .touchUpInside)
        canvasView.addSubview(cancelButton)
        
        picker = UIPickerView(frame: CGRect(x:0, y: ScreenUtils.heightByRate(y: 0.08), width:ScreenUtils.width, height:ScreenUtils.heightByRate(y: 0.292)))
        picker.dataSource = self
        picker.delegate = self
        canvasView.addSubview(picker)
        
        okButton = UIButton(frame: CGRect(x:ScreenUtils.widthByRate(x: 0.22), y: ScreenUtils.heightByRate(y: 0.372), width:ScreenUtils.widthByRate(x: 0.56), height:ScreenUtils.heightByRate(y: 0.073)))
        okButton.titleLabel?.textColor = UIColor.white
        okButton.titleLabel?.font = FontUtil.getFont(size: 20, type: .Regular)

        okButton.setTitle("Adjust your plan", for: .normal)
        okButton.backgroundColor = UIColor.blueTheme
        okButton.layer.cornerRadius = ScreenUtils.heightByRate(y: 0.0365)
        okButton.addTarget(self, action: #selector(changeGoal), for: .touchUpInside)
        canvasView.addSubview(okButton)
        
        blurView.addSubview(canvasView)
   
    }
    
    public class func show(titles:[String]) {
        let fpicker = FooterPickerView.sharedInstance
        if let superView = fpicker.containerView() {
            superView.addSubview(fpicker.blurView)
            fpicker.titles = titles
            fpicker.picker.selectRow(titles.count / 2, inComponent: 0, animated: false)
        }
    }
    @objc func hide() {
        let fpicker = FooterPickerView.sharedInstance

        if fpicker.containerView() != nil {
            fpicker.blurView.removeFromSuperview()
        }
    }
    
    @objc func changeGoal() {
       let index = picker.selectedRow(inComponent: 0)
       delegate?.selectItem(index: index)
        hide()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FooterPickerView: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return titles.count
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let rowView = PickerRowView(frame:CGRect(x: 0, y: 0, width: ScreenUtils.width, height: ScreenUtils.heightByRate(y: 0.073)))
        rowView.titleLabel.text = titles[row]
        return rowView
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return ScreenUtils.heightByRate(y: 0.073)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let rowView = pickerView.view(forRow: row, forComponent: component) as! PickerRowView
        rowView.iconView.image = ChImageAssets.SelectedGoal.image
        rowView.titleLabel.textColor = UIColor.textGray
    }
}
