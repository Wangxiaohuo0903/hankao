//
//  NormalDistribution.swift
//  PracticeChinese
//
//  Created by feiyue on 07/07/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation

class NormalDistribution:NSObject {
    var mu:Double
    var theta:Double
    
    static let shared = NormalDistribution(_mu: 60, _theta:14)
    private init(_mu:Double, _theta:Double) {
        self.mu = _mu
        self.theta = _theta
    }
    
    class func getRank(_ x: Double) -> String {
        let norm = NormalDistribution.shared
        var b = (x - norm.mu) / norm.theta
        var a = 0.5*(1 + erf(b/sqrt(2.0)))
        return String(format:"%.0f", a*100) + "%"

    }
    
    
}
