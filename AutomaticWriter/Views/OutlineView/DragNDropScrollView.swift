//
//  DragNDropScrollView.swift
//  AutomaticWriter
//
//  Created by Raphael on 26.01.15.
//  Copyright (c) 2015 HEAD Geneva. All rights reserved.
//

import Cocoa

protocol DragNDropScrollViewDelegate {
    func onFilesDrop(files:[String]);
}

class DragNDropScrollView: NSScrollView {

    var delegate:DragNDropScrollViewDelegate?
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    func registerForDragAndDrop(theDelegate:DragNDropScrollViewDelegate) {
        registerForDraggedTypes([NSColorPboardType, NSFilenamesPboardType])
        delegate = theDelegate
    }
    
    // the value returned changes the mouse icon
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        println("drag entered")
        
        let pboard:NSPasteboard = sender.draggingPasteboard()
        let sourceDragMask:NSDragOperation = sender.draggingSourceOperationMask()
        
        // cast the types array from [AnyObject]? to [String]
        var types:[String]? = pboard.types as? [String]
        
        if let actualTypes = types {
            if contains(actualTypes, NSFilenamesPboardType) {
                if (sourceDragMask & NSDragOperation.Link) == NSDragOperation.Link {
                    // we get a link, but we're going to copy files
                    // so we show a "copy" icon
                    return NSDragOperation.Copy
                }
                else if (sourceDragMask & NSDragOperation.Copy) == NSDragOperation.Copy {
                    return NSDragOperation.Copy
                }
            }
        }
        
        return NSDragOperation.None
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        println("perform drag operation")
        let pboard = sender.draggingPasteboard()
        let sourceDragMask = sender.draggingSourceOperationMask()
        
        // cast the types array from [AnyObject]? to [String]
        var types:[String]? = pboard.types as? [String]
        
        if let actualTypes = types {
            if contains(actualTypes, NSFilenamesPboardType) {
                let files: AnyObject? = pboard.propertyListForType(NSFilenamesPboardType)
                
                var paths = files as? [String]
                
                if (sourceDragMask & NSDragOperation.Link) == NSDragOperation.Link {
                    if let actualPaths = paths {
                        println("files dropped: \(actualPaths)")
                        delegate?.onFilesDrop(actualPaths)
                    }
                }
            }
        }
        
        return true
    }
    
}
