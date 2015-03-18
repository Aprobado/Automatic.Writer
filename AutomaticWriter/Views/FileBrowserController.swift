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
    var editedTextField:MyTextField?
    
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
        myOutlineView.expandItem(rootItem)
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
    
    func outlineView(outlineView: NSOutlineView, shouldSelectItem item: AnyObject) -> Bool {
        if let actualItem = item as? FileSystemItem {
            if actualItem.isRoot() {
                return false
            }
        }
        return true
    }
    
    func outlineView(outlineView: NSOutlineView, shouldCollapseItem item: AnyObject) -> Bool {
        if let actualItem = item as? FileSystemItem {
            if actualItem.isRoot() {
                return false
            }
        }
        return true
    }
    
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
    
    // ==================================================================
    // MARK: * NSTextField delegation implementation (NSControler interface)
    
    var tempFilename = ""
    override func controlTextDidBeginEditing(obj: NSNotification) {
        if let textField = obj.object as? MyTextField {
            editedTextField = textField
            println("begin editing with \(textField.stringValue)")
            tempFilename = textField.stringValue // retain old value to revert change if something unallowed happen
        }
    }
    
    override func controlTextDidEndEditing(obj: NSNotification) {
        if let textField = obj.object as? MyTextField {
            // if we didn't change anything, controlTextDidBeginEditing has not been called.
            // return to avoid unnecessary changes
            if editedTextField != textField {
                editedTextField = nil
                return
            }
            
            println("end editing with \(textField.stringValue)")
            var filename = textField.stringValue    // get new value from textfield
            
            // escape unwanted characters
            filename = filename.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: ".")) // can't start or end filename with a "."
            filename = "-".join(filename.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()))
            filename = "-".join(filename.componentsSeparatedByCharactersInSet(NSCharacterSet.illegalCharacterSet()))
            filename = "-".join(filename.componentsSeparatedByCharactersInSet(NSCharacterSet.controlCharacterSet()))
            filename = "-".join(filename.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: ":/"))) // avoid directory separators (OSX specific, HSF+)
            
            if let item = myOutlineView.itemAtRow(myOutlineView.selectedRow) as? FileSystemItem {
                if AutomatFileManager.renameFile(item.fullPath(), to: filename) {
                    textField.stringValue = filename
                    myOutlineView.reloadData()
                } else {
                    println("failed to change name. Resetting value \(tempFilename)")
                    textField.stringValue = tempFilename
                }
            }
            editedTextField = nil
        }
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
