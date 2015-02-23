//
//  AppDelegate.swift
//  AutomaticWriter
//
//  Created by Raphael on 12.01.15.
//  Copyright (c) 2015 HEAD Geneva. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let projectWindowsManager:ProjectWindowsManager
    
    override init() {
        projectWindowsManager = ProjectWindowsManager()
        super.init()
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        projectWindowsManager.setupMenus()
        
        //let path = "/Users/raphael/Developpement/AutomaticWriting/ANewBook" // manual path
        let projectPath = NSUserDefaults.standardUserDefaults().stringForKey("projectPath")
        if let path = projectPath {
            projectWindowsManager.addWindowForProjectAtPath(path)
        } else {
            projectWindowsManager.openProject(nil)
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func newProject(sender:AnyObject?) {
        projectWindowsManager.newProject(sender)
    }
    @IBAction func openProject(sender:AnyObject?) {
        projectWindowsManager.openProject(sender)
    }

}

