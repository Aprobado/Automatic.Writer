//
//  MyLayoutManager.swift
//  AutomaticWriter
//
//  Created by Raphael on 24.02.15.
//  Copyright (c) 2015 HEAD Geneva. All rights reserved.
//

import Cocoa

class MyLayoutManager: NSLayoutManager {
    
    /*
    override func insertGlyphs(glyphs: UnsafePointer<NSGlyph>,
        length glyphIndex: Int,
        forStartingGlyphAtIndex length: Int,
        characterIndex charIndex: Int) {
            
            println("insert glyphs at char index: \(charIndex)")
            
            super.insertGlyphs(glyphs, length: glyphIndex, forStartingGlyphAtIndex: length, characterIndex: charIndex)
    }
*/
    /*
    override func generateGlyphsForGlyphStorage(glyphStorage: NSGlyphStorage, desiredNumberOfCharacters nChars: Int, glyphIndex: UnsafeMutablePointer<Int>, characterIndex charIndex: UnsafeMutablePointer<Int>) {
        
        //let instance = NSGlyphGenerator.sharedGlyphGenerator()
        
        destination = glyphStorage
        
        instance.generateGlyphsForGlyphStorage(self, desiredNumberOfCharacters: nChars, glyphIndex: glyphIndex, characterIndex: charIndex)
        
        destination = nil
    }

    override func insertGlyphs(glyphs: UnsafePointer<NSGlyph>, length: Int, forStartingGlyphAtIndex glyphIndex: Int, characterIndex charIndex: Int) {
        
        // custom glyph code here
        //let layoutManager = destination as NSLayoutManager
        println("insert \(length) glyphs for starting glyphs at index \(glyphIndex) and char index \(charIndex)")
        
        if let value = attributedString?.attribute("lineFolding", atIndex: charIndex, effectiveRange: nil) as? Bool {
            if value {
                for var i = 0; i < length; i++ {
                    replaceGlyphAtIndex(glyphIndex+i, withGlyph: NSGlyph(NSNullGlyph))
                }
            }
        }
        
        super.insertGlyphs(glyphs, length: length, forStartingGlyphAtIndex: glyphIndex, characterIndex: charIndex)
    }
    */
    /*
    override func drawGlyphsForGlyphRange(glyphsToShow: NSRange,
        atPoint origin: NSPoint) {
            
            println("\(NSDate()) | draw glyphs in range \(glyphsToShow)")
            
            //replaceGlyphAtIndex(0, withGlyph: 1)
            
            super.drawGlyphsForGlyphRange(glyphsToShow, atPoint: origin)
    }
    
    override func insertGlyphs(glyphs: UnsafePointer<NSGlyph>,
        length glyphIndex: Int,
        forStartingGlyphAtIndex length: Int,
        characterIndex charIndex: Int) {
            
            if glyphs != nil {
                println("\(NSDate()) | insert glyph \(glyphs)")
                // try with this
                //replaceGlyphAtIndex()
            }
            
            super.insertGlyphs(glyphs, length: glyphIndex, forStartingGlyphAtIndex: length, characterIndex: charIndex)
    }
    */
}
