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
    
    override func layoutParagraphAtPoint(lineFragmentOrigin: UnsafeMutablePointer<NSPoint>) -> Int {
        println("that starts the layout")
        
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
            
            //println("\(NSDate()) | layout character in range \(characterRange) with max nb of line: \(maxNumLines)")
            
            return super.layoutCharactersInRange(characterRange, forLayoutManager: layoutManager, maximumNumberOfLineFragments: maxNumLines)
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
