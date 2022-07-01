//
//  NSObject+Extension.swift
//  ChineseLearning
//
//  Created by feiyue on 15/03/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit

extension NSObject {
    var nameOfClass: String {
        return String(describing: type(of: self))
    }
    
    class var nameOfClass: String {
        return String(describing: self)
    }
    
    var identifier: String {
        return String(describing: type(of: self))
    }
    
    class var identifier: String {
        return String(describing: self)
    }
    
    class var nibObject: UINib {
        return UINib(nibName: self.identifier, bundle: nil)
    }
    
}
