//
//  Token.swift
//  AutomaticWriter
//
//  Created by Raphael on 30.01.15.
//  Copyright (c) 2015 HEAD Geneva. All rights reserved.
//

import Foundation

class Token : Printable {
    var string:String
    var range:NSRange
    
    init(_string:String, _range:NSRange) {
        string = _string
        range = _range
    }
    
    var description:String {
        return "Token string: \"\(string)\", with range:{loc:\(range.location), len:\(range.length)}"
    }
}