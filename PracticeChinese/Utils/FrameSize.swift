//
//  FrameSize.swift
//  ChineseLearning
//
//  Created by feiyue on 20/03/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit


class SizeUtils {
    static func widthByRate(x:CGFloat) -> CGFloat {
        return x*ScreenUtils.width
    }
    
    static func heightByRate(y:CGFloat) -> CGFloat {
        return y*ScreenUtils.height
    }

}
