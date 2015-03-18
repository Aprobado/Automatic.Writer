//
//  myTextView.swift
//  AutomaticWriter
//
//  Created by Raphael on 21.01.15.
//  Copyright (c) 2015 HEAD Geneva. All rights reserved.
//

import Cocoa

class MyTextView: NSTextView {

    var lastKeyEvent:NSEvent?
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    override func becomeFirstResponder() -> Bool {
        println("a \(self.className) became first responder")
        if let nextView = self.nextKeyView {
            println("next is \(nextView)")
        }
        println("selection: \(selectedRange())")
        return true
    }
    
    override func keyDown(theEvent: NSEvent) {
        lastKeyEvent = theEvent
        
        // implement here special behaviour like autocomplete braces and such
        // carefully because every call to insertText calls "textDidChange" on the controller
        /*
        if let chars = theEvent.characters {
            switch chars {
            case "{":
                insertText("}", replacementRange: selectedRange())
                setSelectedRange(NSMakeRange(selectedRange().location-1, 0))
            default:
                break
            }
        }
        */

        self.interpretKeyEvents([theEvent])
        //super.keyUp(theEvent)
    }
}
