//
//  HighlightToken.swift
//  AutomaticWriter
//
//  Created by Raphael on 18.02.15.
//  Copyright (c) 2015 HEAD Geneva. All rights reserved.
//

import Foundation

enum HighlightType {
    case NONE, TITLE, CSSIMPORT, JSIMPORT, BLOCKTAG, INLINETAG, OPENINGBLOCKTAG, OPENINGINLINETAG, CLOSINGBLOCKTAG, CLOSINGINLINETAG, EVENT, TWINE, JSDECLARATION, JS, COMMENT
    var description:String {
        switch self {
        case NONE:
            return "NONE"
        case TITLE:
            return "TITLE"
        case CSSIMPORT:
            return "CSSIMPORT"
        case JSIMPORT:
            return "JSIMPORT"
        case BLOCKTAG:
            return "BLOCKTAG"
        case INLINETAG:
            return "INLINETAG"
        case OPENINGBLOCKTAG:
            return "OPENINGBLOCKTAG"
        case OPENINGINLINETAG:
            return "OPENINGINLINETAG"
        case CLOSINGBLOCKTAG:
            return "CLOSINGBLOCKTAG"
        case CLOSINGINLINETAG:
            return "CLOSINGINLINETAG"
        case EVENT:
            return "EVENT"
        case TWINE:
            return "TWINE"
        case JSDECLARATION:
            return "JSDECLARATION"
        case JS:
            return "JS"
        case COMMENT:
            return "COMMENT"
        default:
            return "UNKNOWN"
        }
    }
}

// A HiglightToken is an object made of the result of a search with a Regular Expression
// the ranges are the regular expression's capture groups
// the type allows the software to apply are different highlighting for each type

class HighlightToken : Printable {
    let ranges:[NSRange]
    let type:HighlightType
    
    init(_ranges:[NSRange], _type:HighlightType) {
        ranges = _ranges
        type = _type
    }
    
    var description:String {
        return "Token type: \"\(type.description)\", with range 0:{loc:\(ranges[0].location), len:\(ranges[0].length)}"
    }
}