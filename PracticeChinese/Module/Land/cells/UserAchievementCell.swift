//
//  UserAchievementCell.swift
//  PracticeChinese
//
//  Created by Temp on 2018/12/7.
//  Copyright © 2018 msra. All rights reserved.
//

import UIKit

class UserAchievementCell: UITableViewCell {
    
    @IBOutlet weak var bgView1: UIView!
    
    @IBOutlet weak var bgView2: UIView!
    
    @IBOutlet weak var bgView3: UIView!
    
    @IBOutlet weak var bgView4: UIView!
    
    @IBOutlet weak var bgView5: UIView!
    
    @IBOutlet weak var image1: UIImageView!
    
    @IBOutlet weak var image2: UIImageView!
    
    @IBOutlet weak var image3: UIImageView!
    
    @IBOutlet weak var image4: UIImageView!
    
    @IBOutlet weak var image5: UIImageView!
    
    
    @IBOutlet weak var count1: UILabel!
    
    @IBOutlet weak var count2: UILabel!
    
    @IBOutlet weak var count3: UILabel!
    
    @IBOutlet weak var count4: UILabel!
    
    @IBOutlet weak var count5: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(lessons:[ScenarioSubLessonInfo?],countArray:[Int]) {
        count1.isHidden = false
        count2.isHidden = false
        count3.isHidden = false
        count4.isHidden = false
        count5.isHidden = false
        for (i,count) in countArray.enumerated() {
            if countArray[i] > 0 {
                switch i {
                case 0:
                    count1.text = "\(count)"
                    for lesson in lessons {
                        let typeArray = lesson?.ScenarioLessonInfo?.LessonIcons![0].split(separator: "_")
                        if (typeArray?.count)! > 1 {
                            if Int(typeArray![1]) == (i + 1)  {
                                var url = URL(string: "")
                                if (lesson?.ScenarioLessonInfo?.LessonIcons?.count)! > 0 {
                                    url = URL(string: (lesson?.ScenarioLessonInfo?.LessonIcons?[0])!)
                                    let array = (lesson?.ScenarioLessonInfo?.LessonIcons![0])!.components(separatedBy: "/")
                                    let colorStringArray = array.last?.components(separatedBy: "_")
                                    let color = colorStringArray?.last!.substring(to: 6)
                                    bgView1.backgroundColor = UIColor.hex(hex: color!)
                                    image1.sd_setImage(with: url, placeholderImage: UIImage(named: ""), options: .retryFailed) { (image, error, type, url) in
                                    }
                                }else {
                                    bgView1.backgroundColor = UIColor.hex(hex: "E7EBF3")
                                    image1.image = UIImage(named: "farm_1")
                                }
                                break
                            }
                        }
                    }
                case 1:
                    count2.text = "\(count)"
                    for lesson in lessons {
                        let typeArray = lesson?.ScenarioLessonInfo?.LessonIcons![0].split(separator: "_")
                        if (typeArray?.count)! > 1 {
                            if Int(typeArray![1]) == (i + 1)  {
                                var url = URL(string: "")
                                if (lesson?.ScenarioLessonInfo?.LessonIcons?.count)! > 0 {
                                    url = URL(string: (lesson?.ScenarioLessonInfo?.LessonIcons?[0])!)
                                    let array = (lesson?.ScenarioLessonInfo?.LessonIcons![0])!.components(separatedBy: "/")
                                    let colorStringArray = array.last?.components(separatedBy: "_")
                                    let color = colorStringArray?.last!.substring(to: 6)
                                    bgView2.backgroundColor = UIColor.hex(hex: color!)
                                    image2.sd_setImage(with: url, placeholderImage: UIImage(named: ""), options: .retryFailed) { (image, error, type, url) in
                                    }
                                }else {
                                    bgView2.backgroundColor = UIColor.hex(hex: "E7EBF3")
                                    image2.image = UIImage(named: "farm_1")
                                }
                                break
                            }
                        }
                    }
                case 2:
                    count3.text = "\(count)"
                    for lesson in lessons {
                        let typeArray = lesson?.ScenarioLessonInfo?.LessonIcons![0].split(separator: "_")
                        if (typeArray?.count)! > 1 {
                            if Int(typeArray![1]) == (i + 1)  {
                                var url = URL(string: "")
                                if (lesson?.ScenarioLessonInfo?.LessonIcons?.count)! > 0 {
                                    url = URL(string: (lesson?.ScenarioLessonInfo?.LessonIcons?[0])!)
                                    let array = (lesson?.ScenarioLessonInfo?.LessonIcons![0])!.components(separatedBy: "/")
                                    let colorStringArray = array.last?.components(separatedBy: "_")
                                    let color = colorStringArray?.last!.substring(to: 6)
                                    bgView3.backgroundColor = UIColor.hex(hex: color!)
                                    image3.sd_setImage(with: url, placeholderImage: UIImage(named: ""), options: .retryFailed) { (image, error, type, url) in
                                    }
                                }else {
                                    bgView3.backgroundColor = UIColor.hex(hex: "E7EBF3")
                                    image3.image = UIImage(named: "farm_1")
                                }
                                break
                            }
                        }
                    }
                case 3:
                    count4.text = "\(count)"
                    for lesson in lessons {
                        let typeArray = lesson?.ScenarioLessonInfo?.LessonIcons![0].split(separator: "_")
                        if (typeArray?.count)! > 1 {
                            if Int(typeArray![1]) == (i + 1)  {
                                var url = URL(string: "")
                                if (lesson?.ScenarioLessonInfo?.LessonIcons?.count)! > 0 {
                                    url = URL(string: (lesson?.ScenarioLessonInfo?.LessonIcons?[0])!)
                                    let array = (lesson?.ScenarioLessonInfo?.LessonIcons![0])!.components(separatedBy: "/")
                                    let colorStringArray = array.last?.components(separatedBy: "_")
                                    let color = colorStringArray?.last!.substring(to: 6)
                                    bgView4.backgroundColor = UIColor.hex(hex: color!)
                                    image4.sd_setImage(with: url, placeholderImage: UIImage(named: ""), options: .retryFailed) { (image, error, type, url) in
                                    }
                                }else {
                                    bgView4.backgroundColor = UIColor.hex(hex: "E7EBF3")
                                    image4.image = UIImage(named: "farm_1")
                                }
                                break
                            }
                        }
                    }
                case 4:
                    count5.text = "\(count)"
                    for lesson in lessons {
                        let typeArray = lesson?.ScenarioLessonInfo?.LessonIcons![0].split(separator: "_")
                        if (typeArray?.count)! > 1 {
                            if Int(typeArray![1]) == (i + 1) {
                                var url = URL(string: "")
                                if (lesson?.ScenarioLessonInfo?.LessonIcons?.count)! > 0 {
                                    url = URL(string: (lesson?.ScenarioLessonInfo?.LessonIcons?[0])!)
                                    let array = (lesson?.ScenarioLessonInfo?.LessonIcons![0])!.components(separatedBy: "/")
                                    let colorStringArray = array.last?.components(separatedBy: "_")
                                    let color = colorStringArray?.last!.substring(to: 6)
                                    bgView5.backgroundColor = UIColor.hex(hex: color!)
                                    image5.sd_setImage(with: url, placeholderImage: UIImage(named: ""), options: .retryFailed) { (image, error, type, url) in
                                    }
                                }else {
                                    bgView5.backgroundColor = UIColor.hex(hex: "E7EBF3")
                                    image5.image = UIImage(named: "farm_1")
                                }
                                break
                            }
                        }
                    }
                default:
                    CWLog("")
                }
            }else {
                switch i {
                case 0:
                    count1.isHidden = true
                    image1.image = UIImage(named: "locked")
                    bgView1.backgroundColor = UIColor.hex(hex: "F4F4F4")
                case 1:
                    count2.isHidden = true
                    image2.image = UIImage(named: "locked")
                    bgView2.backgroundColor = UIColor.hex(hex: "F4F4F4")
                case 2:
                    count3.isHidden = true
                    image3.image = UIImage(named: "locked")
                    bgView3.backgroundColor = UIColor.hex(hex: "F4F4F4")
                case 3:
                    count4.isHidden = true
                    image4.image = UIImage(named: "locked")
                    bgView4.backgroundColor = UIColor.hex(hex: "F4F4F4")
                case 4:
                    count5.isHidden = true
                    image5.image = UIImage(named: "locked")
                    bgView5.backgroundColor = UIColor.hex(hex: "F4F4F4")
                default:
                    CWLog("")
                }
            }
        }
    }
    
}
