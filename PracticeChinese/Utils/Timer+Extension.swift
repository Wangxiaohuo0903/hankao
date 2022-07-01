//
//  Timer+Extension.swift
//  ChineseLearning
//
//  Created by feiyue on 06/06/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation

private class TimerActor {
    var block: (Timer) -> Void
    init(block: @escaping (Timer) -> Void) {
        self.block = block
    }
    
    @objc dynamic func fire(sender: Timer) {
        block(sender)
    }
}

private extension Selector {
    static let fire = #selector(TimerActor.fire)
}

extension Timer {
    class func schedule(timeInterval: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Void) -> Timer {
        let actor = TimerActor(block: block)
        return Timer.scheduledTimer(timeInterval: timeInterval, target: actor, selector: .fire, userInfo: nil, repeats: repeats)
    }
    
    class func getCurrentMillisec()->Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}
