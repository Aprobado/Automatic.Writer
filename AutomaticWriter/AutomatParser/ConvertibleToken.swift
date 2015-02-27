//
//  ConvertibleToken.swift
//  AutomaticWriter
//
//  Created by Raphael on 19.02.15.
//  Copyright (c) 2015 HEAD Geneva. All rights reserved.
//

import Foundation

class ConvertibleToken: HighlightToken {
    var captureGroups:[String]
    
    init(_ranges: [NSRange], _type: HighlightType, _text:String) {
        captureGroups = [String]()
        for range in _ranges {
            if range.length == 0 {
                captureGroups += [""]
                continue
            }
            let begining = advance(_text.startIndex, range.location)
            let end = advance(begining, range.length-1)
            captureGroups += [_text.substringWithRange(begining...end)]
        }
        
        super.init(_ranges: _ranges, _type: _type)
    }
    
    override var description:String {
        var descr = "Token type: \"\(type.description)\", with range 0:{loc:\(ranges[0].location), len:\(ranges[0].length)}, text:\n"
        for element in captureGroups {
            descr += "\"\(element)\"\n"
        }
        
        return descr
    }
}