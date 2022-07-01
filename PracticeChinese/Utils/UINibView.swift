//
//  UINibView.swift
//  ChineseLearning
//
//  Created by feiyue on 22/03/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class UINibView: UIView {
    @IBOutlet weak var view: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }
    
    private func nibSetup() {
        
        view = loadViewFromNib()
        view.frame = bounds        
        addSubview(view)
    }
    
    private func loadViewFromNib() -> UIView {
        return UINib(nibName: self.nameOfClass, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
}
