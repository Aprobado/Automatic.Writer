//
//  TagMatch.swift
//  AutomaticWriter
//
//  Created by Raphael on 16.02.15.
//  Copyright (c) 2015 HEAD Geneva. All rights reserved.
//

import Cocoa

enum MatchType {
    case BLOCK, INLINE
}
enum MatchPosition {
    case OPENING, CLOSING
}

class TagMatch: RegexMatch {
    var type:MatchType
    var position:MatchPosition
    
    override var description:String {
        let posStr = position == .OPENING ? "opening" : "closing"
        let typeStr = type == .BLOCK ? "block" : "inline"
        return "\n\(posStr) \(typeStr) tag with \(super.description)\n"
    }
    
    init(matchType:MatchType, tokens:[Token]) {
        type = matchType
        
        let str = tokens[0].string  // get the full match string
        if str[str.startIndex] == "}" {
            position = MatchPosition.CLOSING
        } else {
            position = MatchPosition.OPENING
        }
        
        super.init(groups: tokens)
    }
}
