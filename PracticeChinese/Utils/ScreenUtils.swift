//
//  ScreenUtils.swift
//  ChineseLearning
//
//  Created by feiyue on 15/03/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit

class ScreenUtils:NSObject {
    class var pinyinFont:Double {
        return 16.0
    }
    class var englishFont:Double {
        return 14.0
    }
    class var chineseFont:Double {
        return 32.0
    }
    
    class var bottomButtonWidth:Double {
        return 150.0
    }
    class var audioBeforeTime:CGFloat {
        return 0.0
    }
    class var audioAfterTime:Int {
        return 0
    }
    class var width:CGFloat {
        return UIScreen.main.bounds.width
    }
    class var height:CGFloat {
        return UIScreen.main.bounds.height
    }
    class var progressWidth:CGFloat {
        return UIScreen.main.bounds.width - 100
    }
    static func widthByRate(x:CGFloat) -> CGFloat {
        return x*ScreenUtils.width
    }
    
    static func heightByM(y:CGFloat) -> CGFloat {
        return y/667*(ScreenUtils.height)
    }
    
    static func widthByM(x:CGFloat) -> CGFloat {
        return x/375*(ScreenUtils.width)
    }
    
    static func heightByRate(y:CGFloat) -> CGFloat {
        return y*(ScreenUtils.height)
    }
    static func widthBySix(x:CGFloat) -> CGFloat {
        return (x/414.0)/1.88*ScreenUtils.width
    }
    
    static func widthBySixForX(x:CGFloat) -> CGFloat {
        if(AdjustGlobal().CurrentScale == AdjustScale.iPhoneX_XS || AdjustGlobal().CurrentScale == AdjustScale.iPhoneXR_XSMax){
            return (x/414.0)/1.88*ScreenUtils.width*0.75
        }else{
            return (x/414.0)/1.88*ScreenUtils.width
        }
    }
    
    static func heightBySix(y:CGFloat) -> CGFloat {
        return (y/736.0)/1.88*(ScreenUtils.height)
    }
    static func size(size:CGFloat) -> CGFloat {
        if AdjustGlobal().isiPad {
            return size * 1.5
        }
        return size
    }

    static func rectWithRate(x:CGFloat = 0, y:CGFloat = 0, width:CGFloat = 0, height:CGFloat = 0) -> CGRect {
        return CGRect(x: widthByRate(x: x), y: heightByRate(y: y), width: widthByRate(x: width), height: heightByRate(y:height))
    }
    
    
}
