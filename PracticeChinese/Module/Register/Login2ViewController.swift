//
//  Login2ViewController.swift
//  PracticeChinese
//
//  Created by huohuo on 2022/6/30.
//  Copyright © 2022 msra. All rights reserved.
//

import UIKit

class Login2ViewController: UIViewController {
//@IBOutlet weak var label1:UILabel!
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
        self.Login_Button.alpha=0.5
        self.Login_Button.layer.opacity=0.5


    }
    @IBAction func Login_Button_Click(sender:AnyObject){
        
        let User_id=self.user_text.text
        let Code = self.code_text.text
        if(User_id?.isEmpty == true || Code?.isEmpty == true)
        {
            ShowAlert(Ch_Message: "账号/密码不得为空", En_Message: "The account number/password must not be empty",Button_text: "确认 OK")
        }
        //dismiss(animated: true, completion: nil)
        
    }
    func ShowAlert(Ch_Message:String,En_Message:String,Button_text:String){
        let alert = UIAlertController(
            title:Ch_Message,
            message:En_Message,
            preferredStyle: .alert)
        let action=UIAlertAction(
            title:Button_text,
            style:.default,
            handler:nil)
        alert.addAction(action)
        present(alert,animated: true,completion: nil)
    }
    @IBAction func TransferEnterState(sender:AnyObject){
        self.user_text.layer.borderWidth=1
        self.user_text.layer.borderColor = UIColor.blue.cgColor
        self.code_text.layer.borderWidth=0
        self.Login_Button.alpha=1
        self.Login_Button.layer.opacity=1
    }
    @IBAction func TransferEnterState2(sender:AnyObject){
        self.code_text.layer.borderWidth=1
        self.code_text.layer.borderColor = UIColor.blue.cgColor
        self.user_text.layer.borderWidth=0
        self.Login_Button.alpha=1
        self.Login_Button.layer.opacity=1
    }
//游客模式
    @IBAction func AnonymousMode(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
//register
    @IBAction func Register(_ sender: Any) {
        if #available(iOS 13.0, *) {
            guard let myViewController = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(identifier: "RegisterViewController") as? RegisterViewController else {
                fatalError("Unable to Instantiate My View Controller")
            };
            myViewController.modalPresentationStyle = .fullScreen

            self.present(myViewController,animated:true)
        } else {
            // Fallback on earlier versions
        }
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
