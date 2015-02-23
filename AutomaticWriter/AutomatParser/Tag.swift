//
//  File.swift
//  AutomaticWriter
//
//  Created by Raphael on 30.01.15.
//  Copyright (c) 2015 HEAD Geneva. All rights reserved.
//

import Foundation

enum TagAttribute {
    case ID, CLASS, NONE
}

class Tag : Printable {
    var automatTag:String
    var name:String
    var type:String
    var attribute:TagAttribute
    
    var description:String {
        return "tag name: \(name), with type: \(type), and attribute: \(attribute)"
    }
    
    init(_automatTag:String, _name:String, _type:String, _attribute:TagAttribute) {
        automatTag = _automatTag
        name = _name
        type = _type
        attribute = _attribute
    }
}