//
//  FileSystemItem.swift
//  AutomaticWriter
//
//  Created by Raphael on 19.01.15.
//  Copyright (c) 2015 HEAD Geneva. All rights reserved.
//

import Cocoa

let leafNode:[FileSystemItem] = []

/*
func ==(left:FileSystemItem, right:FileSystemItem) -> Bool {
    return left.relativePath == right.relativePath
}
*/

class FileSystemItem: NSObject {
    
    var relativePath:String
    var parent:FileSystemItem?
    var children:[FileSystemItem] = []
    
    init(path:String, parentItem:FileSystemItem?) {
        relativePath = path
        parent = parentItem
        super.init()
    }
    
    
    
    func isRoot() -> Bool {
        return parent == nil
    }
    
    func isDirectory() -> Bool {
        return numberOfChildren() > -1
    }
    
    func numberOfChildren() -> Int {
        reloadChildren()
        return (children == leafNode) ? -1 : countElements(children)
    }
    
    func getParent() -> FileSystemItem? {
        return parent
    }
    
    func isFileInChildren(path:String) -> Bool {
        for child in children {
            if child.relativePath == path {
                return true
            }
        }
        return false
    }
    
    func cleanChildren() {
        let count = countElements(children)
        for (var i = count-1; i >= 0; i--) {
            if !NSFileManager.defaultManager().fileExistsAtPath(children[i].fullPath()) {
                children.removeAtIndex(i)
            }
        }
    }
    
    func fullPath() -> String {
        let fullPath = parent?.fullPath()
        if let tmpFullPath = fullPath {
            return tmpFullPath.stringByAppendingPathComponent(relativePath)
        }
        return relativePath
    }
    
    func sortChildren() {
        children.sort(childrenSorter)
    }
    
    func childrenSorter(this:FileSystemItem, that:FileSystemItem) -> Bool {
        switch this.relativePath.localizedCaseInsensitiveCompare(that.relativePath) {
        case .OrderedAscending:
            return true
        case .OrderedDescending:
            return false
        case .OrderedSame:
            return false
        default:
            return false
        }
    }
    
    func reloadChildren() {
        let path = fullPath()
        var valid : Bool = false
        var isDir : ObjCBool = false
        valid = NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDir)
        
        if valid == true && isDir.boolValue == true {
            cleanChildren()
            
            let directoryContent:[AnyObject]? = NSFileManager.defaultManager().contentsOfDirectoryAtPath(path, error: nil)
            if let content = directoryContent {
                let numChildren:Int = countElements(content)
                for (index, child) in enumerate(content) {
                    let fileName:String? = child as? String
                    if let name = fileName {
                        if countElements(name) < 1 { continue; }
                        if name[name.startIndex] == "." { continue; }
                        
                        if !isFileInChildren(name) {
                            let newChild = FileSystemItem(path: name, parentItem: self)
                            children += [newChild]
                        }
                    }
                }
                sortChildren()
            }
        } else {
            children = leafNode
        }
    }
    
    func getChildOfItem(item:FileSystemItem, path:String) -> FileSystemItem? {
        if (item.numberOfChildren() > 0) {
            for child in item.children {
                if child.relativePath.lastPathComponent == path {
                    return child
                }
            }
        }
        return nil
    }
    
    func getItemWithPath(path:String) -> FileSystemItem? {
        // work only from rootItem, so we look for it within a while loop
        var rootItem : FileSystemItem = self
        while !rootItem.isRoot() {
            rootItem = rootItem.parent!
        }
        
        let relativeItemPath : String = path.stringByReplacingOccurrencesOfString(rootItem.fullPath(), withString: "")
        let pathComponents = relativeItemPath.pathComponents
        var returnedItem:FileSystemItem? = rootItem
        
        for component:String in pathComponents {
            if component == "/" { continue; } // we don't consider a "/" as a path component for the search
            returnedItem = getChildOfItem(returnedItem!, path: component)
            if (returnedItem == nil) { return nil }
        }
        
        return returnedItem
    }
    
    func childAtIndex(index:Int) -> AnyObject? {
        if index > countElements(children)-1 { return nil }
        return children[index]
    }
    
}
