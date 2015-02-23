
//
//  TextViewController.swift
//  AutomaticWriter
//
//  Created by Raphael on 13.01.15.
//  Copyright (c) 2015 HEAD Geneva. All rights reserved.
//

import Cocoa

protocol TextViewControllerDelegate {
    func onFileSaved();
    func onFileUnloaded();
}

class TextViewController: NSViewController, NSTextViewDelegate {
    
    var delegate:TextViewControllerDelegate?
    
    @IBOutlet var myTextView: MyTextView!
    
    var currentFile:String? = nil
    var currentFileAttributes:[NSObject : AnyObject]?
    var textModified = false;
    
    var highlighter:Highlighter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.whiteColor().CGColor
        
        myTextView.automaticQuoteSubstitutionEnabled = false;
        myTextView.delegate = self
        
        highlighter = Highlighter()
        
        print("text view controller did load\n");
    }
    
    func textDidChange(notification: NSNotification) {
        if (currentFile != nil) {
            textModified = true;
            
            /*
            if let chars = myTextView.lastKeyEvent?.characters {
                //println("chars: \"\(chars)\" with unicode value \(chars.utf16[0])")
                
                switch chars.utf16[0] {
                case 127:   // detect backspace
                    println("backspace pressed")
                default:
                    break
                }
            }
            */
            
            //let test = "print whole string"
            //println(test[test.startIndex...test.endIndex.predecessor()])
            
            if countElements(myTextView.string!) >= 2 {
                // looking for double line breaks \n\n before and after. Make a range out of it for highlighting
                var backwardIndex = advance(myTextView.string!.startIndex, myTextView.selectedRange().location)
                // we don't want the cursor to be at an extreme
                if backwardIndex == myTextView.string!.endIndex { backwardIndex = backwardIndex.predecessor() }
                if backwardIndex == myTextView.string!.startIndex { backwardIndex = backwardIndex.successor() }
                var forwardIndex = backwardIndex
                
                while myTextView.string!.substringWithRange(backwardIndex.predecessor()...backwardIndex) != "\n\n" {
                    backwardIndex = backwardIndex.predecessor()
                    if backwardIndex == myTextView.string!.startIndex {
                        break
                    }
                }
                
                while myTextView.string!.substringWithRange(forwardIndex.predecessor()...forwardIndex) != "\n\n" {
                    if forwardIndex.successor() == myTextView.string!.endIndex {
                        break
                    }
                    forwardIndex = forwardIndex.successor()
                }
                
                let range = NSMakeRange(distance(myTextView.string!.startIndex, backwardIndex), distance(backwardIndex, forwardIndex.successor()))
                highlightText(range)
                
            } else {
                let range = NSMakeRange(0, countElements(myTextView.string!))
                highlightText(range)
            }
        }
    }
    
    func unloadFile() {
        currentFile = nil
        currentFileAttributes = nil
        textModified = false
        myTextView!.string = ""
        delegate?.onFileUnloaded()
    }
    
    func loadTextFromFile(filePath:String) -> Bool {
        if !NSFileManager.defaultManager().fileExistsAtPath(filePath) {
            println("\(self.className) error : file at path \(filePath) can't be found")
            return false
        }
        
        if (textModified) {
            // TODO: implement a system with temporary files
            saveCurrentFile()   // save before changing file, automatically for now
            /*
            if (!fileChangeConfirmation()) {
                return false
            }
            */
        }
        
        currentFile = filePath
        let text = String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding, error: nil)
        
        // setting default behaviour of myTextView
        myTextView.textColor = NSColor.blackColor()
        myTextView.editable = true;
        
        // lock the textView if the file is an automatically generated file (html from an automat file)
        if filePath.pathExtension == "html" {
            
            // look for a file with same name in "automat" folder with "automat" extension
            let path = filePath.stringByDeletingLastPathComponent
            let folder = "automat"
            let fileName = filePath.lastPathComponent.stringByDeletingPathExtension
            let ext = "automat"
            
            let automatFilePath = path.stringByAppendingPathComponent(folder).stringByAppendingPathComponent(fileName).stringByAppendingPathExtension(ext)
            
            if let tempFilePath = automatFilePath {
                if NSFileManager.defaultManager().fileExistsAtPath(tempFilePath) {
                    myTextView.textColor = NSColor.grayColor()
                    myTextView.editable = false;
                }
            }
        }
        
        if let actualText = text {
            // we load the text in the text view
            myTextView.string = actualText
            
            // we retain informations about the file we just loaded
            currentFileAttributes = NSFileManager.defaultManager().attributesOfItemAtPath(currentFile!, error: nil)
        } else {
            // TODO: pop an alert?
            println("can't get content of file, might be because of encoding")
            return false
        }
        // set font of text view
        myTextView.font = NSFont(name: "Courier", size: 12)
        // and of text storage
        myTextView.textStorage?.font = NSFont(name: "Courier", size: 12)
        
        if filePath.pathExtension == "automat" {
            highlightText(NSMakeRange(0, countElements(text!)))
        }
        
        textModified = false
        
        return true
    }
    
    @IBAction func saveDocument(sender:AnyObject?) {
        saveCurrentFile()
        if currentFile?.pathExtension == "automat" {
            AutomatFileManager.generateHtmlFromAutomatFileAtPath(currentFile!)
        }
        // tell the delegate that the file has been saved
        delegate?.onFileSaved()
    }
    
    func saveCurrentFile() -> Bool {
        if let currFile = currentFile {
            if let text = myTextView.string {
                if text.writeToFile(currFile, atomically: true, encoding: NSUTF8StringEncoding, error: nil) {
                    return true
                }
            }
        }
        return false
    }
    
    func fileCheck() {
        if currentFile == nil { return }
        
        // does the file still exist?
        if !NSFileManager.defaultManager().fileExistsAtPath(currentFile!) {
            unloadFile()
            return
        }
        
        // did the file change?
        let fileInfos = NSFileManager.defaultManager().attributesOfItemAtPath(currentFile!, error: nil)
        var newDate = fileInfos?[NSFileModificationDate] as? NSDate
        var oldDate = currentFileAttributes?[NSFileModificationDate] as? NSDate
        if newDate != nil && oldDate != nil {
            if !newDate!.isEqualToDate(oldDate!) {
                loadTextFromFile(currentFile!)  // reload file because it has changed
            }
        } else {
            println("\(self.className): error while retrieving modification date for file")
        }
    }
    
    // returns yes if user confirms file change
    func fileChangeConfirmation() -> Bool {
        let alert = NSAlert()
        alert.messageText = "File has been modified, do you want to save it?"
        alert.addButtonWithTitle("Save")
        alert.addButtonWithTitle("Don't Save")
        alert.addButtonWithTitle("Cancel")
        
        alert.alertStyle = NSAlertStyle.WarningAlertStyle
        
        switch alert.runModal() {
        case NSAlertFirstButtonReturn:
            // button Save
            saveCurrentFile()
            return true
        case NSAlertSecondButtonReturn:
            // button Don't Save
            return true
        case NSAlertThirdButtonReturn:
            // button Cancel
            return false
        default:
            break
        }
        
        return false
    }
    
    // MARK: * visual interface
    func highlightText(range:NSRange) {
        if myTextView.string == nil { return }
        
        myTextView.setTextColor(NSColor.blackColor(), range: range)
        
        if let highlights = highlighter?.findHighlightsInRange(range, forText: myTextView.string!) {
            for token in highlights {
                // NONE, TITLE, IMPORT, TAG, EVENT, TWINE, JS, COMMENT
                switch token.type {
                case .TITLE:
                    myTextView.setTextColor(NSColor.greenColor(), range: token.ranges[0])
                case .CSSIMPORT, .JSIMPORT:
                    myTextView.setTextColor(NSColor.orangeColor(), range: token.ranges[0])
                case .OPENINGBLOCKTAG, .CLOSINGBLOCKTAG, .OPENINGINLINETAG, .CLOSINGINLINETAG, .EVENT:
                    myTextView.setTextColor(NSColor.redColor(), range: token.ranges[0])
                case .TWINE:
                    myTextView.setTextColor(NSColor.blueColor(), range: token.ranges[0])
                case .JS, .JSDECLARATION:
                    myTextView.setTextColor(NSColor.magentaColor(), range: token.ranges[0])
                case .COMMENT:
                    myTextView.setTextColor(NSColor.grayColor(), range: token.ranges[0])
                default:
                    myTextView.setTextColor(NSColor.orangeColor(), range: token.ranges[0])
                }
            }
        }
    }
    
    // MARK: * accessor
    func getTextFromTextView() -> String? {
        return myTextView.string
    }
    
    // MARK: * View Navigation
    override func becomeFirstResponder() -> Bool {
        println("became first responoder")
        return true
    }
    
}
