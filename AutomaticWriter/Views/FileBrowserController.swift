//
//  FileBrowserController.swift
//  AutomaticWriter
//
//  Created by Raphael on 13.01.15.
//  Copyright (c) 2015 HEAD Geneva. All rights reserved.
//

import Cocoa

protocol FileBrowserControllerDelegate {
    func onFileSelected(path:String);
}

class FileBrowserController: NSViewController, NSOutlineViewDelegate, NSOutlineViewDataSource, DragNDropScrollViewDelegate, AutomatFileManagerDelegate {
    
    var delegate:FileBrowserControllerDelegate?
    
    @IBOutlet weak var myOutlineView: NSOutlineView!
    @IBOutlet weak var scrollView: DragNDropScrollView!

    var rootFolderPath : String?
    var rootItem : FileSystemItem?
    var fileManager:AutomatFileManager?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        // register for drag and drop on the scroll view
        scrollView.registerForDragAndDrop(self)
        
        print("file browser controller did load\n");
    }
    
    func setRootFolder(rootFolder:String) {
        rootFolderPath = rootFolder
        if let tRootFolderPath = rootFolderPath {
            rootItem = FileSystemItem(path: tRootFolderPath, parentItem: nil)
            fileManager = AutomatFileManager(_rootFolderPath: tRootFolderPath)
            fileManager?.delegate = self
        } else {
            println("\(self.className): error while trying to set root item of file browser")
            return
        }
        
        myOutlineView.setDataSource(self)
        myOutlineView.setDelegate(self)
        myOutlineView.reloadData()
        
        // TODO: setup myFileManager
    }
    
    // ==================================================================
    // MARK: * NSOutlineView manipulations
    
    func expandItemFromRoot(item:FileSystemItem) {
        // a temp item that will go up to root
        var tempItem:FileSystemItem? = item
        
        // create a list of items to expand
        var items:[FileSystemItem] = []
        while tempItem != nil {
            tempItem = tempItem!.getParent()
            if let actualTempItem = tempItem {
                items += [actualTempItem]
            }
        }
        // expand in reverse order
        for var i:Int = countElements(items)-1; i >= 0; i-- {
            myOutlineView.expandItem(items[i])
        }
    }
    
    // ==================================================================
    // MARK: * File Management with AutomatFileManager
    
    func createNewFileOfType(type:String) {
        fileManager?.createNewFileOfType(type)
    }
    
    @IBAction func deleteFile(sender:AnyObject?) {
        deleteSelectedFile()
    }
    
    // only allows to delete one file at a time. Takes last selected item
    func deleteSelectedFile() {
        let selectedItemRow = myOutlineView.selectedRow
        let selectedItem = myOutlineView.itemAtRow(selectedItemRow) as? FileSystemItem
        if let item = selectedItem {
            if !item.isRoot() {
                AutomatFileManager.deleteFile(item.fullPath())
                let trashSound = NSSound(contentsOfFile: "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/dock/drag to trash.aif", byReference: true)
                if let sound = trashSound {
                    sound.play()
                }
            }
        }
        myOutlineView.reloadData()
    }
    
    // ==============================================
    // MARK: * NSOutlineViewDelegate implementation
    
    func outlineViewSelectionDidChange(notification: NSNotification) {
        let item = myOutlineView.itemAtRow(myOutlineView.selectedRow) as? FileSystemItem
        if let actualItem = item {
            if !actualItem.isDirectory() {
                delegate?.onFileSelected(actualItem.fullPath())
            }
        }
    }
    
    func outlineView(outlineView: NSOutlineView, shouldEditTableColumn tableColumn: NSTableColumn?, item : AnyObject) -> Bool {
        let systemItem = item as FileSystemItem
        if systemItem.isRoot() { return false }
        else { return true }
    }
    
    // ==============================================
    // MARK: * NSOutlineViewDataSource implementation
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        let fileSystemItem = item as? FileSystemItem
        if let tFileSystemItem = fileSystemItem {
            tFileSystemItem.reloadChildren()
            return tFileSystemItem.numberOfChildren()
        } else {
            return 1 // TODO: check this... weird...
        }
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        return item.numberOfChildren() != -1
    }
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if let tempItem = item as? FileSystemItem {
            if let childItem:AnyObject = tempItem.childAtIndex(index) {
                return childItem
            }
        }
        return rootItem!
    }
    
    func outlineView(outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject? {
        if let fileSystemItem = item as? FileSystemItem {
            if fileSystemItem.isRoot() {
                return fileSystemItem.relativePath.lastPathComponent
            } else {
                return fileSystemItem.relativePath
            }
        }
        return "project root"
    }
    
    // TODO: add file renaming
    func outlineView(outlineView: NSOutlineView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) {
        
        println("\(self.className) - set new file name")
        //TODO: rename file at path with the newName
        // if we can, change the relative path of item
        // if we can't (because it's a file we don't have the right to change, like an html generated by the software) cancel the edit
        
        // rename file by settings object(aString) to item.relativePath.lastPathComponent, then
        if let newName = object as? String {
            if let fileSystemItem = item as? FileSystemItem {
                let path = fileSystemItem.relativePath.stringByDeletingLastPathComponent
                fileSystemItem.relativePath = path.stringByAppendingPathComponent(newName)
                
                
            }
        }
        
        myOutlineView.reloadData()
    }
    
    // ==================================================================
    // MARK: * DragNDropScrollViewDelegate implementation
    
    func onFilesDrop(files:[String]) {
        fileManager?.copyFilesFromArray(files)
    }
    
    // ==================================================================
    // MARK: * AutomatFileManagerDelegate implementation
    
    // received from fileManager after we called .copyFilesFromArray(files)
    func onFilesAdded(files:[String]) {
        // select files in outlineView
        
        // reload
        myOutlineView.reloadData()
        // deselect everything
        myOutlineView.deselectAll(nil)
        
        // select the created files
        for file in files {
            let itemToSelect = rootItem?.getItemWithPath(file)
            if let item = itemToSelect {
                expandItemFromRoot(item)
                let row = myOutlineView.rowForItem(item)
                // add item to selection
                myOutlineView.selectRowIndexes(NSIndexSet(index: row), byExtendingSelection: false)
            }
        }
    }
    
}
