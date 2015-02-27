//
//  Highlighter.swift
//  AutomaticWriter
//
//  Created by Raphael on 18.02.15.
//  Copyright (c) 2015 HEAD Geneva. All rights reserved.
//

import Cocoa

class Highlighter: NSObject {
    
    // MARK: * patterns for regular expressions
    struct RegexPattern {
        static let title = "(?:(?<=\\n)|(?<=\\A)):: (.+?)(?:(?=\\n)|(?=\\Z))"
                         // (?:(?<=\n)|(?<=\A)):: (.+?)(?:(?=\n)|(?=\Z))
        
        static let cssImports = "(?:(?<=\\n)|(?<=\\A))#import \"([^\"]+?.css)\" ?((?://)?.*?)?(?:(?=\\n)|(?=\\Z))"
                              // (?:(?<=\n)|(?<=\A))#import "([^"]+?.css)" ?((?://)?.*?)?(?:(?=\n)|(?=\Z))
        
        static let jsImports = "(?:(?<=\\n)|(?<=\\A))#import \"([^\"]+?.js)\" ?((?://)?.*?)?(?:(?=\\n)|(?=\\Z))"
                             // (?:(?<=\n)|(?<=\A))#import "([^"]+?.js)" ?((?://)?.*?)?(?:(?=\n)|(?=\Z))
        
        static let jsVars = "(?:(?<=\\n)|(?<=\\A))(var \\w+? ?= ?[^;\\n]+?; ?(?://.*?)?)(?:(?=\\n)|(?=\\Z))"
                          // (?:(?<=\n)|(?<=\A))(var \w+? ?= ?[^;\n]+?; ?(?://.*?)?)(?:(?=\n)|(?=\Z))
        
        static let jsFunctions = "(?:(?<=\\n)|(?<=\\A))(var \\w+? ?= ?function ?\\(.*?\\) ?\\{ ?(?://.*?)?)(?:(?=\\n)|(?=\\Z))"
                               // (?:(?<=\n)|(?<=\A))(var \w+? ?= ?function ?\(.*?\) ?\{ ?(?://.*?)?)(?:(?=\n)|(?=\Z))
        
        
        static let jsFunctionCalls = "(?:(?<=\\n)|(?<=\\A))(\\w+\\([^\\)]*\\); ?(?://.*?)?)(?:(?=\\n)|(?=\\Z))"
                                   // (?:(?<=\n)|(?<=\A))(\w+\([^\)]+\); ?(?://.*?)?)(?:(?=\n)|(?=\Z))
        
        
        static let events = "(?:(?<=\\n)|(?<=\\A)) *([^\\n\\t\\{\\}\\\\\\/\\?!<]*?) *< *([\\w]+) *= *\"?([\\w]+) *(?:\\(([\\w, ]*)\\))?\"? *>[ \\t]*(?://(.*?))?(?:(?=\\n)|(?=\\Z))"
                          // (?:(?<=^)) *([^\n\t\{\}\\\/\?!<]*?) *< *([\w]+) *= *"?([\w]+) *(?:\(([\w, ]*)\))?"? *>[ \t]*(?://(.*?))?(?:(?=\n)|(?=\Z))
        
        static let twine = "\\[\\[(\\w+)\\|?(\\w+)?\\]\\[?([^\\]]+)?\\]?\\]"
                         // \[\[(\w+)\|?(\w+)?\]\[?([^\]]+)?\]?\]
        
        static let commentLines = "(?:(?<=\\n)|(?<=\\A))//([^\\n]*)"
                                // (?:(?<=\n)|(?<=\A))//([^\n]*)
        static let comments = "(?:(?<=\\n)|(?<=\\A))[ \\t]*?// *?([^\\n]*)"
                           // " *?// *?([^\n]*)"
                           // "(?:(?<=\n)|(?<=\A))[ \t]*?// *?([^\n]*)"
        
        static let blockOpeningTags = "(?:(?<=\\n)|(?<=\\A))([#\\.])([^.# ]+[^\\{])\\{{2}"
                                   // (?:(?<=\n)|(?<=\A))([#\.])([^.# ]+)\{\{
                                   // (?:(?<=\n)|(?<=\A))([#\.])([^.# ]+[^\{])\{{2}
        
        static let inlineOpeningTags = "(?<=[^\\n])([#\\.])([^.# ]+[^\\{])\\{{2}"
                                    // (?<= )([#\.])([^.# ]+)\{\{
                                    // (?<= )([#\.])([^.# ]+[^\{])\{{2}
                                    // (?<=[^\n])([#\.])([^.# ]+[^\{])\{{2}
        
        static let blockClosingTags = "\\}{2}(?:<(.*?)>)?(?:(?=\\n)|(?=\\Z))"
                                    // \}{2}(?:<(.*?)>)?(?:(?=\n)|(?=\Z))
        
        static let inlineClosingTags = "(?<!\\n)\\}{2}(?:<([^>\\n]+?)>)?[:punct:]*?(?!(\\Z|\\n))"
                                     // (?<!\n)\}{2}(?:<([^>\n]+?)>)?[:punct:]*?(?!(\Z|\n))
    }
    
    // MARK: * properties
    var fullText:String?
    
    // MARK: * Utility functions
    func rangeIsValid(range:NSRange) -> Bool {
        return !NSEqualRanges(range, NSMakeRange(NSNotFound, 0))
    }
    
    // MARK: * Regex handling
    func initRegex(pattern:String, options:NSRegularExpressionOptions) -> NSRegularExpression? {
        var error:NSError?
        let regex = NSRegularExpression(pattern: pattern, options: options, error: &error)
        if let actualError = error {
            println("\(self.className) - error while trying to find regex \"\(pattern)\" in string")
            return nil
        } else {
            return regex
        }
    }
    
    func getFirstTokenForPattern(pattern:String, ofType type:HighlightType, inRange range:NSRange) -> HighlightToken? {
        if let regex = initRegex(pattern, options: NSRegularExpressionOptions.CaseInsensitive) {
            if let match = regex.firstMatchInString(fullText!, options: NSMatchingOptions.ReportProgress, range: range) {
                var ranges:[NSRange] = [NSRange]()
                for var i = 0; i < match.numberOfRanges; ++i {
                    ranges += [match.rangeAtIndex(i)]
                }
                return HighlightToken(_ranges: ranges, _type: type)
            }
        }
        return nil  // pattern not found in range
    }
    
    func getTokensForPattern(pattern:String, ofType type:HighlightType, inRange range:NSRange) -> [HighlightToken] {
        var tokens = [HighlightToken]()
        if let regex = initRegex(pattern, options: NSRegularExpressionOptions.CaseInsensitive) {
            let matches = regex.matchesInString(fullText!, options: NSMatchingOptions.ReportProgress, range: range)
            for result in matches {
                let match = result as NSTextCheckingResult
                var ranges:[NSRange] = [NSRange]()
                for var i = 0; i < match.numberOfRanges; ++i {
                    ranges += [match.rangeAtIndex(i)]
                }
                tokens += [HighlightToken(_ranges: ranges, _type: type)]
            }
        }
        return tokens
    }
    
    // MARK: * Highlights search
    func findHighlightsInRange(range:NSRange, forText text:String) -> [HighlightToken] {
        fullText = text
        var highlights = [HighlightToken]()
        
        if let titleToken = getFirstTokenForPattern(RegexPattern.title, ofType: HighlightType.TITLE, inRange: range) {
            highlights += [titleToken]
        }
        highlights += getTokensForPattern(RegexPattern.cssImports, ofType: HighlightType.CSSIMPORT, inRange: range)
        highlights += getTokensForPattern(RegexPattern.jsImports, ofType: HighlightType.JSIMPORT, inRange: range)
        highlights += getTokensForPattern(RegexPattern.jsVars, ofType: HighlightType.JSDECLARATION, inRange: range)
        highlights += findJsFunctions(range)
        highlights += getTokensForPattern(RegexPattern.jsFunctionCalls, ofType: HighlightType.JS, inRange: range)
        highlights += getTokensForPattern(RegexPattern.events, ofType: HighlightType.EVENT, inRange: range)
        highlights += getTokensForPattern(RegexPattern.twine, ofType: HighlightType.TWINE, inRange: range)
        highlights += findTags(range)
        highlights += getTokensForPattern(RegexPattern.comments, ofType: HighlightType.COMMENT, inRange: range) // end with comments to override color
        
        //let start = NSDate()
        //let end = NSDate()
        //let timeInterval:Double = end.timeIntervalSinceDate(start)
        //println("highlights found in \(timeInterval*1000) milliseconds")
        
        return highlights
    }
    
    func findJsFunctions(range:NSRange) -> [HighlightToken] {
        var tokens = [HighlightToken]()
        
        // first we need the beginning of the function
        let funcOpenings = getTokensForPattern(RegexPattern.jsFunctions, ofType: HighlightType.JSDECLARATION, inRange: range)
        let fullTextLength = countElements(fullText!)
        
        // then we must find the closing part for each function
        for opening in funcOpenings {
            // search begin at the end of the opening match
            let newRangeLocation = opening.ranges[0].location+opening.ranges[0].length
            let newRange = NSMakeRange(newRangeLocation, fullTextLength - newRangeLocation)
            
            // use pattern \{|\} to find opening or closing braces
            if let regex = initRegex("\\{|\\}", options: NSRegularExpressionOptions.CaseInsensitive) {
                var nestedLevel = 0
                // enumerate results and stop when we find what we need
                regex.enumerateMatchesInString(fullText!, options: NSMatchingOptions.ReportProgress, range: newRange) {
                    match, flags, stop in
                    if match == nil { return }
                    if self.fullText![advance(self.fullText!.startIndex, match.range.location)] == "{" {
                        nestedLevel++
                    } else {
                        if nestedLevel > 0 {
                            nestedLevel--
                        } else {
                            // we found the closing curly brace
                            var ranges:[NSRange] = [NSRange]()
                            let fullRangeLength = (match.range.location + match.range.length) - opening.ranges[0].location
                            ranges += [NSMakeRange(opening.ranges[0].location, fullRangeLength)]    // full range
                            ranges += opening.ranges                                                // ranges of opening token
                            ranges += [match.range]                                                 // range of closing curly brace
                            
                            tokens += [HighlightToken(_ranges: ranges, _type: HighlightType.JSDECLARATION)]
                            stop.memory = true
                        }
                    }
                }
            }
        }
        return tokens
    }
    
    func findTags(range:NSRange) -> [HighlightToken] {
        var tokens = [HighlightToken]()
        
        tokens += getTokensForPattern(RegexPattern.blockOpeningTags, ofType: HighlightType.OPENINGBLOCKTAG, inRange: range)
        tokens += getTokensForPattern(RegexPattern.inlineOpeningTags, ofType: HighlightType.OPENINGINLINETAG, inRange: range)
        tokens += getTokensForPattern(RegexPattern.blockClosingTags, ofType: HighlightType.CLOSINGBLOCKTAG, inRange: range)
        tokens += getTokensForPattern(RegexPattern.inlineClosingTags, ofType: HighlightType.CLOSINGINLINETAG, inRange: range)
        
        tokens.sort({$0.ranges[0].location < $1.ranges[0].location})
        
        var pairs = [Pair]()
        
        while(countElements(tokens) > 1) {
            // remove closing tags that could be leading the array
            while tokenIsAClosingTag(tokens[0]) {
                //println("remove token \(tokens[0])")
                tokens.removeAtIndex(0)
                if countElements(tokens) == 0 { break; }
            }
            if countElements(tokens) < 2 { break; } // can't find pairs with less than 2 elements
            
            var pairFound = 0
            var openingTagIndex = -1
            var nestLevel = 0
            var tokensToRemove = [Int]()
            
            for (index, token) in enumerate(tokens) {
                if openingTagIndex == -1 {  // we're looking for a tag opening
                    if (!tokenIsAClosingTag(token)) {
                        openingTagIndex = index // that's the opening token
                        nestLevel = 0
                        continue
                    } else {
                        continue
                    }
                }
                
                if tokenIsAClosingTag(token) {
                    if nestLevel > 0 {
                        nestLevel--
                    } else {
                        // pair ok
                        pairs += [Pair(_a: tokens[openingTagIndex], _b: token)]
                        tokensToRemove.insert(openingTagIndex, atIndex: 0) // insert inverted
                        
                        // reset index for next tag
                        nestLevel = 0
                        openingTagIndex = -1
                    }
                } else {
                    nestLevel++
                }
            }
            if tokensToRemove.isEmpty && openingTagIndex > -1 {
                tokens.removeAtIndex(openingTagIndex)
            }
            for removeIndex in tokensToRemove {
                tokens.removeAtIndex(removeIndex)
            }
        }
        
        // insert back pairs into tokens
        tokens.removeAll(keepCapacity: false)
        for pair in pairs {
            let a:HighlightToken = pair.a as HighlightToken
            let b:HighlightToken = pair.b as HighlightToken
            tokens += [a, b]
            //println([a, b])
        }
        
        return tokens
    }
    
    func tokenIsAClosingTag(token:HighlightToken) -> Bool {
        return token.type == HighlightType.CLOSINGBLOCKTAG || token.type == HighlightType.CLOSINGINLINETAG
    }
    
}
