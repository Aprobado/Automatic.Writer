//
//  LineFoldingGlyphGenerator.swift
//  AutomaticWriter
//
//  Created by Raphael on 25.02.15.
//  Copyright (c) 2015 HEAD Geneva. All rights reserved.
//

import Cocoa

class LineFoldingGlyphGenerator: NSGlyphGenerator, NSGlyphStorage {
    var destination:NSGlyphStorage
    
    init(glyphStorage:NSGlyphStorage) {
        destination = glyphStorage
    }
    
    override func generateGlyphsForGlyphStorage(glyphStorage: NSGlyphStorage, desiredNumberOfCharacters nChars: Int, glyphIndex: UnsafeMutablePointer<Int>, characterIndex charIndex: UnsafeMutablePointer<Int>) {
        
        let instance = NSGlyphGenerator.sharedGlyphGenerator()
        
        //destination = glyphStorage
        
        instance.generateGlyphsForGlyphStorage(self, desiredNumberOfCharacters: nChars, glyphIndex: glyphIndex, characterIndex: charIndex)
        
        //destination = nil
    }
    
    func attributedString() -> NSAttributedString {
        return destination.attributedString()
    }
    
    func layoutOptions() -> Int {
        return destination.layoutOptions()
    }
    
    func insertGlyphs(glyphs: UnsafePointer<NSGlyph>, length: Int, forStartingGlyphAtIndex glyphIndex: Int, characterIndex charIndex: Int) {
        
        println("insert \(length) glyphs for starting glyphs at index \(glyphIndex) and char index \(charIndex)")
        //let layoutManager = destination as NSLayoutManager
        //println("right now, there's \(layoutManager.numberOfGlyphs) glyphs in the buffer")
        
        
        //var myGlyphs = UnsafeMutablePointer<NSGlyph>.alloc(length)
        //var glyphIterator = glyphs
        //myGlyphs.memory = NSGlyph(NSControlGlyph)
        //myGlyphs++
        
        let layoutManager = destination as NSLayoutManager
        //var myGlyphs = UnsafeMutablePointer<NSGlyph>(glyphs)
        var myGlyphs = [NSGlyph]()
        for var i = 0; i < length; i++ {
            // get char attribute
            
            //glyphs.successor() = glyphs
            //myGlyphs.memory = glyphs.advancedBy(i).memory
            //let indexOfChar = layoutManager.characterIndexForGlyphAtIndex(i)
            
            if let value = layoutManager.textStorage?.attribute("lineFolding", atIndex: charIndex+i, effectiveRange: nil) as? Bool {
                if value {
                    println("char at index \(charIndex+i) must be lineFolded")
                    //myGlyphs.advancedBy(i).memory = NSGlyph(NSNullGlyph)
                } else {
                    // not line folded, add the glyph
                    myGlyphs += [glyphs.advancedBy(glyphIndex+i).memory]
                }
            } else {
                // not line folded, add the glyph
                myGlyphs += [glyphs.advancedBy(glyphIndex+i).memory]
            }
            
            /*
            if i == 0 {
                myGlyphs.memory = NSGlyph(NSControlGlyph)
            }
            else if i < 4 {
                myGlyphs.memory = NSGlyph(NSNullGlyph)
            }
            */
            //myGlyphs++
        }
        
        //layoutManager?.replaceGlyphAtIndex(glyphRange.location, withGlyph: NSGlyph(NSControlGlyph))
        //layoutManager?.replaceGlyphAtIndex(glyphRange.location+1, withGlyph: NSGlyph(NSNullGlyph))
        
        
        //let layoutManager = destination as NSLayoutManager
        //layoutManager.setNotShownAttribute(true, forGlyphAtIndex: glyphIndex)
        /*
        // custom glyph code here
        
        if let value = layoutManager.textStorage?.attribute("lineFolding", atIndex: charIndex, effectiveRange: nil) as? Bool {
            if value {
                for var i = 0; i < length; i++ {
        
                    layoutManager.replaceGlyphAtIndex(glyphIndex+i, withGlyph: NSGlyph(NSNullGlyph))
                }
            }
        }
        */
        destination.insertGlyphs(&myGlyphs, length: countElements(myGlyphs), forStartingGlyphAtIndex: glyphIndex, characterIndex: charIndex)
        
        //myGlyphs.destroy(length)
        //myGlyphs.dealloc(length)
    }
    
    func setIntAttribute(attributeTag: Int, value val: Int, forGlyphAtIndex glyphIndex: Int) {
        destination.setIntAttribute(attributeTag, value: val, forGlyphAtIndex: glyphIndex)
    }
    
}
