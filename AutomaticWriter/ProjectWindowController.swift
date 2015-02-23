//
//  ProjectWindowController.swift
//  AutomaticWriter
//
//  Created by Raphael on 12.01.15.
//  Copyright (c) 2015 HEAD Geneva. All rights reserved.
//

import Cocoa

class ProjectWindowController: NSWindowController, NSSplitViewDelegate, FileBrowserControllerDelegate, TextViewControllerDelegate {
    
    var myFileBrowserController : FileBrowserController?
    var myTextViewController : TextViewController?
    var myWebViewController : WebViewController?
    
    var project : Project?
    var mySplitView : NSSplitView?
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    func setupProjectAtPath(path:String) {
        
        // setting project
        project = Project(projectPath: path)
        
        // resizing window
        if let myWindow = window {
            myWindow.title = path.lastPathComponent
            var size = NSSize(width: 1024, height: 600)
            var frame = myWindow.frame
            frame.origin.y += frame.size.height // remove the old height
            frame.origin.y -= size.height // add the new height
            frame.size = size
            myWindow.setFrame(frame, display: true)
        }
        
        // setting views
        if let storyboard = NSStoryboard(name: "Main", bundle: nil) {   // get storyboard
            
            mySplitView = window?.contentView.subviews[0] as NSSplitView?
            if let splitView = mySplitView { // window?.contentView.subviews[0] as? NSSplitView {    // get splitview (set manually in storyboard)
                splitView.delegate = self
                
                // create controllers
                myFileBrowserController = storyboard.instantiateControllerWithIdentifier("FileBrowserController") as FileBrowserController?
                myTextViewController = storyboard.instantiateControllerWithIdentifier("TextViewController") as TextViewController?
                myWebViewController = storyboard.instantiateControllerWithIdentifier("WebViewController") as WebViewController?
                
                if myFileBrowserController == nil || myTextViewController == nil || myWebViewController == nil {
                    println("can't setup views properly")
                    return
                }
                
                // set file browser
                splitView.addSubview(myFileBrowserController!.view)
                myFileBrowserController!.setRootFolder(path)
                myFileBrowserController!.delegate = self
                myFileBrowserController!.view.nextKeyView = myTextViewController!.myTextView
                
                // set text view
                splitView.addSubview(myTextViewController!.view)
                myTextViewController!.delegate = self;
                myTextViewController!.myTextView.editable = false
                myTextViewController!.myTextView.nextKeyView = myFileBrowserController!.view
                
                // set web view
                splitView.addSubview(myWebViewController!.view)
                
                splitView.adjustSubviews()
                let positionZero:CGFloat = 200
                let positionOne = ((splitView.frame.width - 200) / 2) + 200
                splitView.setPosition(positionZero, ofDividerAtIndex: 0)
                splitView.setPosition(positionOne, ofDividerAtIndex: 1)
            }
        }
    }
    
    // this function is called by the ProjectWindowsManager (the delegate of all the windows)
    func onBecomeKeyWindow() {
        myFileBrowserController?.myOutlineView.reloadData()
        myTextViewController?.fileCheck()
    }
    
    /// Description of func
    ///
    /// :param: numberOfParts first int
    /// :param: numberOfSubparts a float
    /// :returns: value returned
    func printString(aString : String, nTimes : Int) -> Bool {
        for (var i = 0; i < nTimes; i++) {
            println(aString)
        }
        return true;
    }
    
    // =============================================
    // MARK: * Preview in Applications (because network is not yet implemented)
    
    @IBAction func viewInApplication(sender:AnyObject?) {
        let item = sender as? NSMenuItem
        let appName = item?.title
        if let actualAppName = appName {
            if let appPath = NSWorkspace.sharedWorkspace().fullPathForApplication(actualAppName) {
                if let webView = myWebViewController {
                    if webView.hasUrl {
                        // TODO: 
                        let filePath = webView.wkWebView?.URL?.path
                        if let path = filePath {
                            NSWorkspace.sharedWorkspace().openFile(path, withApplication: actualAppName)
                        }
                        //let filePath = webView.webView.mainFrameURL.stringByReplacingOccurrencesOfString("file://", withString: "")
                        //NSWorkspace.sharedWorkspace().openFile(filePath, withApplication: actualAppName)
                    }
                }
            } else {
                println("app with name \"\(actualAppName)\" doesn't exist")
            }
        }
    }
    
    // =============================================
    // MARK: * FileBrowserControllerDelegate
    
    func onFileSelected(path:String) {
        if AutomatFileManager.fileAtPathIsATextFile(path) {
            myTextViewController?.loadTextFromFile(path)
            if path.pathExtension == "html" {
                myWebViewController?.loadFile(path)
            }
            if path.pathExtension == "automat" {
                let htmlPath = AutomatFileManager.getHtmlFileOfAutomatFileAtPath(path)
                if let actualHtmlPath = htmlPath {
                    myWebViewController?.loadFile(actualHtmlPath)
                }
            }
            if let myWindow = window {
                if let myProject = project {
                    myWindow.title = "\(myProject.folderName) - \(path.lastPathComponent)"
                }
            }
        }
        else if AutomatFileManager.fileAtPathIsAnImage(path) {
            myWebViewController?.loadFile(path)
        }
    }
    
    // =============================================
    // MARK: * TextViewControllerDelegate
    
    func onFileSaved() {
        if let webView = myWebViewController {
            webView.reload()
        }
    }
    
    func onFileUnloaded() {
        if let myWindow = window {
            if let myProject = project {
                myWindow.title = myProject.folderName
            }
        }
    }
    
    // =============================================
    // MARK: * Actions for toolbar buttons
    
    @IBAction func gitCommit(sender:AnyObject?) {
        let launchPath = "/usr/bin/git"
        if NSFileManager.defaultManager().fileExistsAtPath(launchPath) {
            if project == nil {
                println("project is not setup, can't commit")
                return
            }
            if NSFileManager.defaultManager().fileExistsAtPath(project!.path.stringByAppendingPathComponent(".git")) {
                // git init has already been done
                var alert = NSAlert()
                alert.messageText = "Commit message."
                alert.informativeText = ""
                alert.addButtonWithTitle("Commit")
                alert.addButtonWithTitle("Cancel")
                
                let input:NSTextField = NSTextField(frame: NSMakeRect(0, 0, 200, 24))
                input.stringValue = ""
                alert.accessoryView = input
                
                var message = ""
                switch alert.runModal() {
                case NSAlertFirstButtonReturn:
                    input.validateEditing()
                    message = input.stringValue
                    TerminalCommander.executeTerminalCommand(["add", "-A"], from: project!.path, withLaunchPath: launchPath)
                    TerminalCommander.executeTerminalCommand(["commit", "-m", message], from: project!.path, withLaunchPath: launchPath)
                    break
                case NSAlertSecondButtonReturn:
                    // do nothing
                    break
                default:
                    break
                }
            } else {
                // we need to git init and do the first commit
                TerminalCommander.executeTerminalCommand(["init"], from: project!.path, withLaunchPath: launchPath)
                TerminalCommander.executeTerminalCommand(["add", "."], from: project!.path, withLaunchPath: launchPath)
                TerminalCommander.executeTerminalCommand(["commit", "-m", "First commit"], from: project!.path, withLaunchPath: launchPath)
            }
        } else {
            alertNoGit()
        }
    }
    
    func alertNoGit() {
        var alert = NSAlert()
        alert.informativeText = "Git is not installed on this machine. Get it on http://git-scm.com/ if you want to use versioning."
        alert.messageText = "Git can't be found"
        alert.addButtonWithTitle("Ok")
        
        alert.runModal()
    }
    
    // =============================================
    // MARK: * File Menu responders
    @IBAction func createNewFile(sender:AnyObject?) {
        let menuItem = sender as? NSMenuItem
        if let item = menuItem {
            myFileBrowserController?.createNewFileOfType(item.title)
        }
    }
    
    // =============================================
    // MARK: * NSSplitView Delegate implementation
    func splitView(splitView: NSSplitView, constrainMinCoordinate proposedMin: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        return proposedMin + 200
    }
    func splitView(splitView: NSSplitView, constrainMaxCoordinate proposedMax: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        return proposedMax - 200
    }
    func splitView(splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
        if subview == splitView.subviews[1] as NSView {
            return false
        }
        return true
    }
    func splitView(splitView: NSSplitView, shouldAdjustSizeOfSubview subview: NSView) -> Bool {
        if subview == splitView.subviews[0] as NSView {
            return false
        }
        return true
    }
    
    // =============================================
    // MARK: * Navigation between views
    // TODO: make navigation between views work...
    override func insertTab(sender: AnyObject?) {
        println("insert tab")
    }
    
    // =============================================
    // MARK: * Show/Hide views
    @IBAction func toggleFileBrowser(sender:AnyObject?) {
        println("\(window?.firstResponder)")
        
        if let splitView = mySplitView {
            if let fileBrowserController = myFileBrowserController {
                if splitView.isSubviewCollapsed(fileBrowserController.view) {
                    splitView.setPosition(200, ofDividerAtIndex: 0)
                } else {
                    splitView.setPosition(0, ofDividerAtIndex: 0)
                    
                    // make the text view the first responder
                    if let myWindow = window {
                        if let textViewController = myTextViewController {
                            myWindow.makeFirstResponder(textViewController.myTextView)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func toggleWebView(sender:AnyObject?) {
        if let splitView = mySplitView {
            if let webViewController = myWebViewController {
                if splitView.isSubviewCollapsed(webViewController.view) {
                    var browserWidth : CGFloat = 0
                    if let fileBrowserController = myFileBrowserController {
                        browserWidth = splitView.isSubviewCollapsed(fileBrowserController.view) ? 0 : splitView.subviews[0].frame.width
                    }
                    let position = (splitView.subviews[1].frame.width / 2) + browserWidth
                    splitView.setPosition(position, ofDividerAtIndex: 1)
                } else {
                    let position = splitView.frame.width
                    splitView.setPosition(position, ofDividerAtIndex: 1)
                    
                    // make the text view the first responder
                    if let myWindow = window {
                        if let textViewController = myTextViewController {
                            myWindow.makeFirstResponder(textViewController.myTextView)
                        }
                    }
                    
                }
            }
        }
    }
    
}
