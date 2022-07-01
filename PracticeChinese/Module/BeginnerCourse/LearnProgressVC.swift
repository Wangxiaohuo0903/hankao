//
//  LearnProgressVC.swift
//  PracticeChinese
//
//  Created by Temp on 2018/12/18.
//  Copyright © 2018 msra. All rights reserved.
//
//学习进度
import UIKit

class LearnProgressVC: UIViewController {
    var currentLearnProgress = 0 //当前学习到的进度，不可减少
    var courseId: String = "L2-1-1-1-s-CN"
    var repeatId: String = "L2-1-1-1-r-CN"
    var lessonInfo: ScenarioSubLessonInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.red
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let cardVC = LearnCardFlowViewController()
        cardVC.courseId = courseId
        cardVC.repeatId = repeatId
        cardVC.lessonInfo = lessonInfo
        self.navigationController?.pushViewController(cardVC, animated: true)
        var subVCs = self.navigationController?.viewControllers
        if (subVCs?.count)! > 1 {
            subVCs?.remove(at: 0)
            self.navigationController?.viewControllers = subVCs!
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}
