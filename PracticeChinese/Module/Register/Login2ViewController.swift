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
@IBOutlet weak var code_text:UITextField!
    @IBOutlet weak var user_text:UITextField!
    @IBOutlet weak var im1:UIImageView!
    @IBOutlet weak var Login_Button:UIButton!
    var Radius=20
    var Height=45
    override func viewDidLoad() {

        super.viewDidLoad()
        self.user_text.layer.masksToBounds=true
        self.code_text.layer.masksToBounds=true
        self.user_text.layer.cornerRadius=CGFloat(Radius)
        self.code_text.layer.cornerRadius=CGFloat(Radius)
        self.user_text.height_s=CGFloat(Height)
        self.code_text.height_s=CGFloat(Height)
        self.Login_Button.layer.masksToBounds=true
        self.Login_Button.layer.cornerRadius=CGFloat(Radius)
        self.Login_Button.height_s=CGFloat(Height)
      

    }
    @IBAction func Login_Button_Click(sender:AnyObject){
        
        let user_id=self.user_text.text
        self.code_text.text=user_id
        //dismiss(animated: true, completion: nil)
  
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
