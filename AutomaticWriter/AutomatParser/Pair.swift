//
//  Pair.swift
//  AutomaticWriter
//
//  Created by Raphael on 30.01.15.
//  Copyright (c) 2015 HEAD Geneva. All rights reserved.
//

import Foundation

class Pair: Printable {
    
    var a:AnyObject
    var b:AnyObject
    
    var description: String {
        return "pair(a: \(a), b: \(b))"
    }
    
    init(_a:AnyObject, _b:AnyObject) {
        a = _a
        b = _b
    }
    
}
