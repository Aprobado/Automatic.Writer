
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

class TextViewController: NSViewController, NSTextViewDelegate, NSLayoutManagerDelegate {
    
    var delegate:TextViewControllerDelegate?
    
    @IBOutlet var myTextView: MyTextView!
    
    var currentFile:String? = nil
    var currentFileAttributes:[NSObject : AnyObject]?
    var textModified = false;
    
    var highlighter:Highlighter?
    let lineFoldedAttributeName = "lineFolding"
    let lineFoldableAttributeName = "lineFoldable"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.whiteColor().CGColor
        
        myTextView.automaticQuoteSubstitutionEnabled = false
        myTextView.delegate = self
        //myTextView.layoutManager?.delegate = self
        //var layoutManager = MyLayoutManager()
        //layoutManager.typesetter = MyATSTypesetter()
        //myTextView.textContainer?.replaceLayoutManager(layoutManager)
        //myTextView.textStorage?.addLayoutManager(layoutManager)
        
        if let actualLayoutManager = myTextView.layoutManager {
            actualLayoutManager.typesetter = MyATSTypesetter()
            //actualLayoutManager.glyphGenerator = LineFoldingGlyphGenerator(glyphStorage: actualLayoutManager)
        }
        
        highlighter = Highlighter()
        
        print("text view controller did load\n");
    }
    
    @IBAction func toggleTokenFolding(sender:AnyObject?) {
        if let typeSetter = myTextView.layoutManager?.typesetter as? MyATSTypesetter {
            typeSetter.fold = !typeSetter.fold
            if let layoutManager = myTextView.layoutManager {
                layoutManager.invalidateGlyphsForCharacterRange(NSMakeRange(0, layoutManager.textStorage!.length), changeInLength: 0, actualCharacterRange: nil)
            }
        }
    }
    
    func textDidChange(notification: NSNotification) {
        if currentFile != nil {
            textModified = true
            
            // MARK: disable text did change notification by returning
            
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
                
                // MARK: -- deactivating highlighting
                //println("\(self.className): ================================")
                //println("\(self.className): highlight for range \(range)")
                highlightText(range)
            } else {
                //println("\(self.className): ================================")
                //println("\(self.className): highlight for whole file")
                let range = NSMakeRange(0, countElements(myTextView.string!))
                // MARK: -- deactivating highlighting
                highlightText(range)
            }
        }
    }
    
    // textviewdelegation
    func textViewDidChangeSelection(notification: NSNotification) {
        if let text = myTextView.textStorage {
            if text.length < 2 {
                return
            }
            text.beginEditing()
            
            // get old selected range
            var oldRange = notification.userInfo?.values.first as NSRange
            if NSMaxRange(oldRange) < text.length { // when we load a new file, the old range can be out of bounds.
                //println("\(self.className): ================================")
                //println("\(self.className): remove foldable and add folded attribute in range \(oldRange)")
                removeAttribute(lineFoldableAttributeName, andAdd: lineFoldedAttributeName, touchingRange: oldRange, inTextStorage: text)
            }
            
            var ranges = myTextView.selectedRanges as [NSRange]
            //println("\(self.className): ================================")
            //println("\(self.className): remove folded and add foldable attribute in range \(ranges[0])")
            removeAttribute(lineFoldedAttributeName, andAdd: lineFoldableAttributeName, touchingRange: ranges[0], inTextStorage: text)
            
            text.endEditing()
        }
    }
    
    func removeAttribute(attributeRemoved:String, andAdd attributeAdded:String, touchingRange range:NSRange, inTextStorage text:NSTextStorage) {
        // the range is adjusted to test one character before the selection a|b
        // testing "a" as well as "b", "|" being the selection point
        var adjustedRange = range
        if adjustedRange.location != 0 {
            adjustedRange.location -= 1
            adjustedRange.length += 1
        }
        if NSMaxRange(adjustedRange) < text.length {
            adjustedRange.length += 1
        }
        
        var rangeIterator = adjustedRange.location
        var rangeEnd = NSMaxRange(adjustedRange)
        while (rangeIterator < rangeEnd) {
            var effectiveRange = NSMakeRange(0, 0)
            if let value = text.attribute(attributeRemoved, atIndex: rangeIterator, effectiveRange: &effectiveRange) as? Bool {
                if value {
                    text.removeAttribute(attributeRemoved, range: effectiveRange)
                    text.addAttribute(attributeAdded, value: true, range: effectiveRange)
                    rangeIterator = NSMaxRange(effectiveRange)
                    continue
                }
            }
            rangeIterator++
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
        myTextView.font = NSFont(name: "Courier New", size: 12)
        // and of text storage
        myTextView.textStorage?.font = NSFont(name: "Courier New", size: 12)
        
        if filePath.pathExtension == "automat" {
            // MARK: -- deactivating highlighting
            //println("\(self.className): ================================")
            //println("\(self.className): highlight from loading file")
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
        
        if let text = myTextView.textStorage {
            text.beginEditing()
            
            //myTextView.setTextColor(NSColor.blackColor(), range: range)
            text.addAttribute(NSForegroundColorAttributeName, value: NSColor.blackColor(), range: range)
            text.removeAttribute(lineFoldedAttributeName, range: range)
            text.removeAttribute(lineFoldableAttributeName, range: range)
            
            if let highlights = highlighter?.findHighlightsInRange(range, forText: myTextView.string!) {
                for token in highlights {
                    var attributeName = lineFoldedAttributeName
                    if NSLocationInRange(myTextView.selectedRange().location, token.ranges[0]) {
                        attributeName = lineFoldableAttributeName
                    }
                    
                    // NONE, TITLE, IMPORT, TAG, EVENT, TWINE, JS, COMMENT
                    switch token.type {
                    case .TITLE:
                        //myTextView.setTextColor(NSColor.greenColor(), range: token.ranges[0])
                        text.addAttribute(NSForegroundColorAttributeName, value: NSColor.greenColor(), range: token.ranges[0])
                    case .CSSIMPORT, .JSIMPORT:
                        //myTextView.setTextColor(NSColor.orangeColor(), range: token.ranges[0])
                        text.addAttribute(NSForegroundColorAttributeName, value: NSColor.orangeColor(), range: token.ranges[0])
                    case .EVENT:
                        text.addAttribute(NSForegroundColorAttributeName, value: NSColor.redColor(), range: token.ranges[0])
                    case .OPENINGBLOCKTAG, .CLOSINGBLOCKTAG, .OPENINGINLINETAG, .CLOSINGINLINETAG:
                        //myTextView.setTextColor(NSColor.redColor(), range: token.ranges[0])
                        text.addAttribute(NSForegroundColorAttributeName, value: NSColor.redColor(), range: token.ranges[0])
                        text.addAttribute(attributeName, value: true, range: token.ranges[0])
                    case .TWINE:
                        //myTextView.setTextColor(NSColor.blueColor(), range: token.ranges[0])
                        text.addAttribute(NSForegroundColorAttributeName, value: NSColor.blueColor(), range: token.ranges[0])
                        text.addAttribute(attributeName, value: true, range: token.ranges[2])
                        text.addAttribute(attributeName, value: true, range: token.ranges[3])
                    case .JS:
                        text.addAttribute(NSForegroundColorAttributeName, value: NSColor.magentaColor(), range: token.ranges[0])
                    case .JSDECLARATION:
                        //myTextView.setTextColor(NSColor.magentaColor(), range: token.ranges[0])
                        text.addAttribute(NSForegroundColorAttributeName, value: NSColor.magentaColor(), range: token.ranges[0])
                        if token.ranges.count > 3 {
                            let startRange = NSMaxRange(token.ranges[1]) - 1
                            text.addAttribute(attributeName, value: true, range: NSMakeRange(startRange, NSMaxRange(token.ranges[0]) - startRange))
                        }
                    case .COMMENT:
                        //myTextView.setTextColor(NSColor.grayColor(), range: token.ranges[0])
                        text.addAttribute(NSForegroundColorAttributeName, value: NSColor.grayColor(), range: token.ranges[0])
                    default:
                        //myTextView.setTextColor(NSColor.orangeColor(), range: token.ranges[0])
                        text.addAttribute(NSForegroundColorAttributeName, value: NSColor.orangeColor(), range: token.ranges[0])
                    }
                    
                }
            }
            
            text.endEditing()
        }
    }
    
    /*
    func testLayoutManagerUnderlining(range:NSRange) {
        // test with NSLayoutManager
        //let glyphRange = NSMakeRange(range.location, 1)
        var lineFragGlyphRange:NSRange = NSMakeRange(0, 0)
        let lineFragRect = myTextView?.layoutManager?.lineFragmentRectForGlyphAtIndex(range.location, effectiveRange: &lineFragGlyphRange)
        if lineFragRect == nil {
            println("line fragment rect not found")
            return
        }
        //println(myTextView?.layoutManager)
        myTextView?.layoutManager?.underlineGlyphRange(range, underlineType: (NSUnderlinePatternSolid | NSUnderlineStyleSingle), lineFragmentRect: lineFragRect!, lineFragmentGlyphRange: lineFragGlyphRange, containerOrigin: myTextView!.textContainerOrigin)
    }
    */
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
