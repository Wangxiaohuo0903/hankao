//
//  LessonsCacheMap.swift
//  PracticeChinese
//
//  Created by summer on 2017/9/20.
//  Copyright © 2017年 msra. All rights reserved.
//

import Foundation
import ObjectMapper

class LessonsCacheMap : Mappable
{
    var id: String?
    var subLessons: String?
    
    required init?(map: Map)
    {
    }
    
    func mapping(map: Map)
    {
        id <- map["id"]
        subLessons <- map["subLessons"]
    }
}


