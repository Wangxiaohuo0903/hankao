//
//  LCWeakTimer.swift
//  PracticeChinese
//
//  Created by ThomasXu on 14/07/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit

class LCWeakTimer {
    
    private var timer: Timer!
    
    
    init(interval: TimeInterval, repeats: Bool, action: @escaping (Timer) -> Void) {
        self.timer = Timer.schedule(timeInterval: interval, repeats: repeats, block: action)
    }
    
    func invalidate() {
        if nil != self.timer {
            self.timer.invalidate()
        }
    }
    
    deinit {
       // print("deinit weak timer")
    }
}
