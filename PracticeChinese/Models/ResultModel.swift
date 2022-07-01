//
//  ResultModel.swift
//  ChineseLearning
//
//  Created by feiyue on 10/04/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import ObjectMapper

class ResultModel<T:Mappable>:Mappable{
    var code:Int?
    var data:T?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        code    <- map["errcode"]
        data    <- map["data"]
    }
}
