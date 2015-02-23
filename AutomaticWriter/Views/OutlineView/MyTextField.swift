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
        println("became first responder")
        return true
    }
    
}
