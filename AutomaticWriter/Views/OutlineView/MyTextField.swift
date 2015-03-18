//
//  MyTextField.swift
//  AutomaticWriter
//
//  Created by Raphael on 21.01.15.
//  Copyright (c) 2015 HEAD Geneva. All rights reserved.
//

import Cocoa

class MyTextField: NSTextField {

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    override func becomeFirstResponder() -> Bool {
        // look for NSSplitView
        var splitview = superview
        while splitview?.className != "NSSplitView" {
            splitview = splitview?.superview
        }
        // look for MyTextView
        if var clipView = splitview?.subviews[1] as? NSView {
            while clipView.className != "NSClipView" {
                if clipView.subviews.count > 0 {
                    if let subview = clipView.subviews[0] as? NSView {
                        clipView = subview
                    } else {
                        break
                    }
                } else {
                    break
                }
            }
            //println("became first responder. looking for clipView: \(clipView)") // when trying, stops at the NSClipView just before the TextView
            if let actualClipView = clipView as? NSClipView {
                if let textView = actualClipView.documentView as? MyTextView {
                    println("became first responder. looking for textView: \(textView)") // we found it!!
                    nextResponder = textView
                    // textView.nextResponder = self // make the app crash
                }
            }
            
            
        }
        //println("became first responder. looking for textview: \(textView)")
        return true
    }
    
}
