//
//  UIViewController+extension.swift
//  ChineseLearning
//
//  Created by feiyue on 15/03/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation

import UIKit

extension UIViewController {
    
    class func initFromNib() -> UIViewController {
        let hasNib:Bool = Bundle.main.path(forResource: self.nameOfClass, ofType: "nib") != nil
        guard hasNib else {
            return UIViewController()
        }
        return self.init(nibName: self.nameOfClass, bundle: nil)
    }
    
    public func ch_pushViewController(_ viewController: UIViewController, animated:Bool) {
        self.navigationController?.pushViewController(viewController, animated:animated)
    }
    
    public func ch_presentViewController(_ viewController:UIViewController,completion:(()->Void)?) {
        let navigationController = UINavigationController(rootViewController: viewController)
        viewController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: completion)
        
    }
    
    
    func ch_getStatusBarHeight() -> CGFloat {//20
        return UIApplication.shared.statusBarFrame.height
    }
    
    func ch_getNavigationBarHeight() -> CGFloat {//44
        if let height = self.navigationController?.navigationBar.frame.height {
            return height
        }
        return 44
    }
    
    func ch_getStatusNavigationHeight() -> CGFloat {
        return ch_getStatusBarHeight() + ch_getNavigationBarHeight()
    }
    
    func ch_getTabBarHeight() -> CGFloat {//49
        if let height = self.tabBarController?.tabBar.frame.height {
            return height
        }
        return 0
    }
    
    //注意：使用该方法会给controller的view添加一个subview并把所有已经添加的view盖住
    //获取带有渐变的 view，需在在把 子view 添加到该 view 之后，才设置该 view 的 layer
    func ch_getGradientViewAndLayer() -> (UIView, CAGradientLayer){
        //这里使用了controller 的 view，如果将来不使用渐变，gradientView的 子 view 的frame 不用改变
        let gradientView = UIView(frame: self.view.frame)
        //设置颜色
        let colour:UIColor = UIColor.hex(hex: "4e80d9")
        let colours:[CGColor] = [colour.withAlphaComponent(0.0).cgColor, colour.cgColor]
        let locations:[NSNumber] = [0.84, 1.0]
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colours
        gradientLayer.locations = locations
        
        gradientLayer.frame = gradientView.frame
        self.view.addSubview(gradientView)
        return (gradientView, gradientLayer)
    }
    
    func ch_getTitleAttribute(textColor: UIColor = UIColor.white) -> [String: Any] {
        var temp: [String: Any] = [convertFromNSAttributedStringKey(NSAttributedString.Key.font): FontUtil.getFont(size: 20, type: .Medium)]
        temp[convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor)] = textColor
        return temp
    }
    
    func ch_getBeginnerAttributedView(content: String) -> UILabel {
        let font = FontUtil.getFont(size: 18, type: .Regular)
        let width = ScreenUtils.widthByRate(x: 0.8)
        let height = content.height(withConstrainedWidth: width, font: font)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        var attributes: [String: Any] = [convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]
        attributes[convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor)] = UIColor.blueTheme
        label.attributedText = NSAttributedString(string: content, attributes: convertToOptionalNSAttributedStringKeyDictionary(attributes))
        return label
    }
    //渐变色
    func gradientColor(gradientView : UIView, frame: CGRect,upTodown:Bool,_ direct: Int = 0) {
        var colorOne = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.0)
        var colorTwo = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        if direct == 1 {
            colorOne = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
            colorTwo = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.0)
        }
        let colors = [colorOne.cgColor, colorTwo.cgColor]
        let gradient = CAGradientLayer()
        //设置开始和结束位置(设置渐变的方向)
        if upTodown {
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 0, y: 1)
        }else {
            gradient.startPoint = CGPoint(x: 1, y: 0)
            gradient.endPoint = CGPoint(x: 0, y: 0)
        }
        gradient.colors = colors
        gradient.frame = frame
        gradientView.layer.insertSublayer(gradient, at: 0)
    }
}

extension UIView {
    func ch_setY(newY: CGFloat) {
        self.frame = CGRect(x: frame.minX, y: newY, width: frame.width, height: frame.height)
    }
    
    func ch_setHeight(newHeight: CGFloat) {
        self.frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: newHeight)
    }
}

extension UINavigationController
{
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        if (self.topViewController?.isKind(of: PractiseLandViewController.self))! ||
           (self.topViewController?.isKind(of: PractiseViewController.self))! ||
           (self.topViewController?.isKind(of: PractiseTurnViewController.self))! ||
           (self.topViewController?.isKind(of: PractiseSummaryViewController.self))! ||
           (self.topViewController?.isKind(of: LearnedLessonsViewController.self))! ||
           (self.topViewController?.isKind(of: AchievementVC.self))! ||
           (self.topViewController?.isKind(of: PractiseLandDetailVC.self))! ||
           (self.topViewController?.isKind(of: LearnCardFlowViewController.self))! ||
            (self.topViewController?.isKind(of: ChallengeIntroViewController.self))! ||
            (self.topViewController?.isKind(of: ChanllenViewController.self))! {
            return .`default`
        }
        return .lightContent
    }
}

class UINavigationWithoutStatusController : UINavigationController {
    override var prefersStatusBarHidden: Bool {
        return false
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
