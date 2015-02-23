//
//  RegexResult.swift
//  AutomaticWriter
//
//  Created by Raphael on 30.01.15.
//  Copyright (c) 2015 HEAD Geneva. All rights reserved.
//

import Foundation



class RegexMatch : Printable {
    // in groups :
    // groups[0] is the full match ($0)
    // the following groups are the capture groups of the regex ($1, $2 etc.)
    let groups:[Token]
    
    init(groups:[Token]) {
        self.groups = groups
    }
    
    var description:String {
        var result = "\nregex match groups :"
        for group in groups {
            result += "\n\t\(group)"
        }
        return result
    }
}