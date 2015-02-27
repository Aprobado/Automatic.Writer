//
//  MyATSTypesetter.swift
//  AutomaticWriter
//
//  Created by Raphael on 24.02.15.
//  Copyright (c) 2015 HEAD Geneva. All rights reserved.
//

import Cocoa

// subclass of NSTypesetter to customize the glyphs layout of the textView
class MyATSTypesetter: NSATSTypesetter {
    
    var fold:Bool = true
    
    override func layoutParagraphAtPoint(lineFragmentOrigin: UnsafeMutablePointer<NSPoint>) -> Int {
        //println("that starts the layout")
        
        return super.layoutParagraphAtPoint(lineFragmentOrigin)
    }
    
    // called multiple times when a file is loaded / window size is modified
    override func layoutGlyphsInLayoutManager(layoutMgr: NSLayoutManager,
        startingAtGlyphIndex startGlyphIndex: Int,
        maxNumberOfLineFragments maxNumLines: Int,
        nextGlyphIndex nextGlyph: UnsafeMutablePointer<Int>) {
            
            //println("\(NSDate()) | layout glyphs in layout manager (start glyph index: \(startGlyphIndex))")
            
            super.layoutGlyphsInLayoutManager(layoutMgr, startingAtGlyphIndex: startGlyphIndex, maxNumberOfLineFragments: maxNumLines, nextGlyphIndex: nextGlyph)
    }
    
    override func layoutCharactersInRange(characterRange: NSRange,
        forLayoutManager layoutManager: NSLayoutManager,
        maximumNumberOfLineFragments maxNumLines: Int) -> NSRange {
            /*
            println("\(NSDate()) | received demand to layout range \(characterRange)")
            
            var firstLetterIsFolded = false
            var foldedRange:NSRange = NSMakeRange(0, 0)
            if let value = attributedString?.attribute(lineFoldingAttributeName, atIndex: characterRange.location, effectiveRange: &foldedRange) as? Bool {
                if value {
                    firstLetterIsFolded = true
                }
            }
            let lastCharLoc = NSMaxRange(characterRange)
            var newRange = characterRange
            if firstLetterIsFolded {
                let loc = min(NSMaxRange(foldedRange), lastCharLoc)
                let length = lastCharLoc - loc
                newRange = NSMakeRange(loc, length)
                println("\(NSDate()) | layout character in range \(newRange) with max nb of line: \(maxNumLines) ignoring folded range")
                let processedRange = super.layoutCharactersInRange(newRange, forLayoutManager: layoutManager, maximumNumberOfLineFragments: maxNumLines)
                println("\(NSDate()) | processed range: \(processedRange)")
                let returnedRange = NSMakeRange(characterRange.location, NSMaxRange(processedRange) - characterRange.location)
                println("\(NSDate()) | returned range: \(returnedRange)")
                return returnedRange
            } else {
                for var i = characterRange.location; i < lastCharLoc; i++ {
                    if let value = attributedString?.attribute(lineFoldingAttributeName, atIndex: i, effectiveRange: nil) as? Bool {
                        if value {
                            newRange.length = i - newRange.location
                            println("\(NSDate()) | layout character in range \(newRange) with max nb of line: \(maxNumLines) stoping before folded range")
                            return super.layoutCharactersInRange(newRange, forLayoutManager: layoutManager, maximumNumberOfLineFragments: maxNumLines)
                        }
                    }
                }
            }
            */
            
            if fold {
                
                var foldGlyph = NSGlyph(391) // this is the ♦︎ glyph for "Courier new" font
                // TODO: try with an enumerate function to see if it's faster
                var iterator:Int = characterRange.location
                while (iterator < NSMaxRange(characterRange)) {
                    var foldedRange = NSMakeRange(0, 0)
                    if let value = attributedString?.attribute(lineFoldingAttributeName, atIndex: iterator, effectiveRange: &foldedRange) as? Bool {
                        if value {
                            var glyphRange = glyphRangeForCharacterRange(foldedRange, actualCharacterRange: nil)
                            // first glyph is NSControlGlyph
                            layoutManager.replaceGlyphAtIndex(glyphRange.location, withGlyph: foldGlyph)
                            // following glyphs are NSNullGlyphs
                            if glyphRange.length > 1 {
                                for var i = glyphRange.location+1; i < NSMaxRange(glyphRange); i++ {
                                    layoutManager.replaceGlyphAtIndex(i, withGlyph: NSGlyph(NSNullGlyph))
                                }
                            }
                            iterator = NSMaxRange(foldedRange)
                            continue
                        }
                    }
                    iterator++
                }
                
            }
            /*
            for i in characterRange.location..<NSMaxRange(characterRange) {
                if let value = attributedString?.attribute(lineFoldingAttributeName, atIndex: i, effectiveRange: nil) as? Bool {
                    if value {
                        let glyphRange = glyphRangeForCharacterRange(NSMakeRange(i, 1), actualCharacterRange: nil)
                        for j in glyphRange.location..<NSMaxRange(glyphRange) {
                            layoutManager.replaceGlyphAtIndex(j, withGlyph: NSGlyph(NSNullGlyph))
                        }
                    }
                }
            }
            */
            /*
            var glyphRange = glyphRangeForCharacterRange(characterRange, actualCharacterRange: nil)
            
            var glyphs = UnsafeMutablePointer<NSGlyph>()
            var characterIndexes = UnsafeMutablePointer<Int>()
            getGlyphsInRange(glyphRange, glyphs: glyphs, characterIndexes: characterIndexes, glyphInscriptions: nil, elasticBits: nil)
            for i in glyphRange.location..<NSMaxRange(glyphRange) {
                
            }
            */
            //println("\(NSDate()) | layout character in range \(characterRange) with max nb of line: \(maxNumLines)")
            
            let processedRange = super.layoutCharactersInRange(characterRange, forLayoutManager: layoutManager, maximumNumberOfLineFragments: maxNumLines)
            
            //println("\(NSDate()) | processed range: \(processedRange)")
            
            /*
            // problem here is that the layout has already been done...
            var iterator:Int = processedRange.location
            while (iterator < NSMaxRange(processedRange)) {
                var foldedRange = NSMakeRange(0, 0)
                if let value = attributedString?.attribute(lineFoldingAttributeName, atIndex: iterator, effectiveRange: &foldedRange) as? Bool {
                    if value {
                        println("folded range found: \(foldedRange)")
                        var glyphRange = glyphRangeForCharacterRange(foldedRange, actualCharacterRange: nil)
                        
                        iterator = NSMaxRange(foldedRange)
                        continue
                    }
                }
                
                iterator++
            }
            */
            return processedRange
    }
    
    override func getGlyphsInRange(glyphsRange: NSRange, glyphs glyphBuffer: UnsafeMutablePointer<NSGlyph>, characterIndexes charIndexBuffer: UnsafeMutablePointer<Int>, glyphInscriptions inscribeBuffer: UnsafeMutablePointer<NSGlyphInscription>, elasticBits elasticBuffer: UnsafeMutablePointer<ObjCBool>) -> Int {
        
        //println("get glyphs in range \(glyphsRange)")
        
        return super.getGlyphsInRange(glyphsRange, glyphs: glyphBuffer, characterIndexes: charIndexBuffer, glyphInscriptions: inscribeBuffer, elasticBits: elasticBuffer)
    }
    
    override func willSetLineFragmentRect(lineRect: UnsafeMutablePointer<NSRect>, forGlyphRange glyphRange: NSRange, usedRect: UnsafeMutablePointer<NSRect>, baselineOffset: UnsafeMutablePointer<CGFloat>) {
        
        //println("will set line fragment rect for glyph range: \(glyphRange) with first glyph: \(layoutManager?.glyphAtIndex(glyphRange.location))")
        
        /*
        //if let font = layoutManager?.textStorage?.font {
        //println("there's a font")
        if glyphRange.length > 2 {
            //var myGlyph = UnsafeMutablePointer<NSGlyph>.alloc(1)
            //myGlyph.initialize(NSGlyph(NSNullGlyph))
            layoutManager?.replaceGlyphAtIndex(glyphRange.location, withGlyph: NSGlyph(NSControlGlyph))
            layoutManager?.replaceGlyphAtIndex(glyphRange.location+1, withGlyph: NSGlyph(NSNullGlyph))
            //substituteGlyphsInRange(NSMakeRange(glyphRange.location, 1), withGlyphs: myGlyph)
            //myGlyph.destroy()
            //myGlyph.dealloc(1)
        }
        */
        //}
        
    }
    
    let lineFoldingAttributeName = "lineFolding"
    override func actionForControlCharacterAtIndex(charIndex: Int) -> NSTypesetterControlCharacterAction {
        /*
        if let value = attributedString?.attribute(lineFoldingAttributeName, atIndex: charIndex, effectiveRange: nil) as? Bool {
            if value {
                return NSTypesetterControlCharacterAction.ZeroAdvancementAction
            }
        }
        */
        return super.actionForControlCharacterAtIndex(charIndex)
    }
    
}
