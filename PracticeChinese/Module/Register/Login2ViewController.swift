//
//  Login2ViewController.swift
//  PracticeChinese
//
//  Created by huohuo on 2022/6/30.
//  Copyright © 2022 msra. All rights reserved.
//

import UIKit

class Login2ViewController: UIViewController {
@IBOutlet weak var label1:UILabel!
@IBOutlet weak var text1:UITextField!
    @IBOutlet weak var im1:UIImageView!
    override func viewDidLoad() {
//        label1.text?="A";
        super.viewDidLoad()
//        self.view.backgroundColor = UIColor.red
//        self.label1.text?="A"
//        label1.text?="A"
        // Do any additional setup after loading the view.
//        print(self.label1.text)
    }
    @IBAction func bu1(sender:AnyObject){
        label1.text=text1.text
//        let nav1 = UINavigationController(rootViewController: LearnPageViewController())
//
//        SlideMenuOptions.contentViewScale = 1
//        SlideMenuOptions.hideStatusBar = false
//        SlideMenuOptions.contentViewDrag = true
//        if(AdjustGlobal().isiPad){
//            SlideMenuOptions.leftViewWidth = 270 * 2
//        }
//        let slideMenuController = SlideMenuController(mainViewController: nav1, leftMenuViewController: MePageViewController())
//        present(slideMenuController,animated:true)
        dismiss(animated: true, completion: nil)
       // UINavigationController.popViewController(animated:true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
