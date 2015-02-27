//
//  ProjectWindowsManager.swift
//  AutomaticWriter
//
//  Created by Raphael on 15.01.15.
//  Copyright (c) 2015 HEAD Geneva. All rights reserved.
//

import Cocoa

class ProjectWindowsManager: NSObject, NSWindowDelegate {
    var windows:[ProjectWindowController] = []
    
    // =============================================
    // MARK: * Panels
    
    func getEmptyProjectPath() -> String? {
        return NSBundle.mainBundle().pathForResource("EmptyProject", ofType: "")
    }
    
    /// Gets the url the panel should be at when it is opened.
    /// Tries to get the directory of the last opened project.
    /// If it fails, the default directory is the user's documents directory.
    ///
    /// :returns: the starting path of the panel
    func panelDefaultDirectory() -> String {
        // get the user's document directory : prefered by default
        let documentPathSearch = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        var preferedPath:String = documentPathSearch[0] as String
        
        // get the directory of the last opened project : overwrite prefered if it exists
        let lastOpenedProjectPath = NSUserDefaults.standardUserDefaults().stringForKey("projectPath")
        if let lastPath = lastOpenedProjectPath {
            if NSFileManager.defaultManager().fileExistsAtPath(lastPath.stringByDeletingLastPathComponent) {
                preferedPath = lastPath.stringByDeletingLastPathComponent
            }
        }
        
        return preferedPath
    }
    
    // called from AppDelegate via IBAction
    func newProject(sender:AnyObject?) {
        // get the default empty template
        var template:String? = getEmptyProjectPath()
        if template == nil {
            println("default Empty Project doesn't exist, no can do")
            return
        }
        // if the sender contains the path to a template, get it
        let menuItem = sender as? NSMenuItem
        if let menu = menuItem {
            if let templatePath = menu.representedObject as? String {
                template = templatePath
            }
        }
        
        var panel:NSSavePanel = NSSavePanel()
        
        panel.directoryURL = NSURL(fileURLWithPath:panelDefaultDirectory())
        panel.prompt = "Create"
        panel.showsTagField = false
        panel.nameFieldLabel = "Project"
        
        switch panel.runModal() {
        case NSFileHandlingPanelOKButton:
            if let destination = panel.directoryURL?.path {
                copyTemplate(template!, to: destination.stringByAppendingPathComponent(panel.nameFieldStringValue))
            }
            break
        case NSFileHandlingPanelCancelButton:
            // do nothing
            break
        default:
            break
        }
    }
    
    func copyTemplate(templatePath:String, to destinationPath:String) {
        var error:NSError?
        if NSFileManager.defaultManager().copyItemAtPath(templatePath, toPath: destinationPath, error: &error) {
            focusOrAddWindowForProjectAtPath(destinationPath)
        }
        if let actualError = error {
            println("\(self.className) error while copying project: \(actualError)")
        }
    }
    
    // called from AppDelegate via IBAction
    func openProject(sender:AnyObject?) {
        // if the sender contains the path to a project, open it
        let menuItem = sender as? NSMenuItem
        if let menu = menuItem {
            if NSFileManager.defaultManager().fileExistsAtPath(menu.title) {
                focusOrAddWindowForProjectAtPath(menu.title)
                return
            }
        }
        
        // else open a panel to choose the project folder
        var panel:NSOpenPanel = NSOpenPanel()
        
        panel.directoryURL = NSURL(fileURLWithPath:panelDefaultDirectory())
        panel.prompt = "Choose"
        panel.title = "Select Project"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        
        switch panel.runModal() {
        case NSOKButton:
            let url = panel.URLs[0] as? NSURL
            if let actualUrl = url {
                focusOrAddWindowForProjectAtURL(actualUrl)
            } else {
                println("\(self.className) error: can't convert chosen url to NSURL")
            }
            break
        case NSCancelButton:
            // do nothing
            break
        default:
            break
        }
    }
    
    // =============================================
    // MARK: * Handle window controllers
    
    func focusOrAddWindowForProjectAtURL(url:NSURL) {
        let path = url.path
        if let actualPath = path {
            focusOrAddWindowForProjectAtPath(actualPath)
        } else {
            println("couldn't convert url to string")
        }
    }
    
    func focusOrAddWindowForProjectAtPath(path:String) {
        let controller = getWindowControllerWithProjectPath(path)
        if controller != nil {
            // the window exists, make focus
            if let window = controller!.window? {
                window.makeKeyAndOrderFront(self)
                NSUserDefaults.standardUserDefaults().setValue(path, forKey: "projectPath")
            }
        } else {
            // the window doesn't exist, create it
            addWindowForProjectAtPath(path)
            NSUserDefaults.standardUserDefaults().setValue(path, forKey: "projectPath")
        }
    }
    
    func addWindowForProjectAtPath(path:String) {
        // check if the folder exists before using it as a project root
        if !NSFileManager.defaultManager().fileExistsAtPath(path) {
            projectFolderMissingAtPath(path)
            return
        }
        
        if let storyboard = NSStoryboard(name: "Main", bundle: nil) {   // get storyboard
            if let controller = storyboard.instantiateControllerWithIdentifier("ProjectWindowController") as? ProjectWindowController {
                controller.setupProjectAtPath(path)
                if let window = controller.window? {
                    window.delegate = self;
                    window.makeKeyAndOrderFront(window)
                }
                windows += [controller]
                addInRecentProjectsMenu(path)
            } else {
                println("\(self.className) couldn't instantiate project window controller")
            }
        }
    }
    
    func getWindowControllerWithProjectPath(path:String) -> ProjectWindowController? {
        for controller in windows {
            if controller.project?.path == path {
                return controller
            }
        }
        return nil
    }
    
    // =============================================
    // MARK: * Menu Modifications
    
    func setupMenus() {
        setupTemplateMenu()
        setupRecentProjectMenu()
    }
    
    // template menu creation
    func setupTemplateMenu() {
        let templatePath = NSBundle.mainBundle().pathForResource("Templates", ofType: "")
        if templatePath == nil {
            println("error while retrieving Template folder in resources")
            return
        }
        let templates = NSFileManager.defaultManager().contentsOfDirectoryAtPath(templatePath!, error: nil) as? [String]
        if templates == nil {
            println("error while retrieving or converting Templates paths to String")
            return
        }
        
        let mainMenu = NSApp.mainMenu
        if let menu = mainMenu {
            let fileMenu = menu?.itemWithTitle("File")?.submenu?.itemWithTitle("Templates")?.submenu
            if let actualFileMenu = fileMenu {
                for (index, template) in enumerate(templates!) {
                    let mi = NSMenuItem(title: template, action: "newProject:", keyEquivalent: "")
                    mi.representedObject = templatePath!.stringByAppendingPathComponent(template)
                    actualFileMenu.addItem(mi)
                }
            }
        }
    }
    
    // recent project menu creation
    func setupRecentProjectMenu() {
        let pathsObject:AnyObject? = NSUserDefaults.standardUserDefaults().valueForKey("recentProjects")
        if let paths = pathsObject as? [String] {
            let count = countElements(paths)
            if count < 3 {
                return
            }
            for var i = count-3; i >= 0; --i { // add backwards to keep the correct order
                if NSFileManager.defaultManager().fileExistsAtPath(paths[i]) {
                    addInRecentProjectsMenu(paths[i])
                }
            }
        }
    }
    
    // max recent projects in the "Recent Projects" menu
    let maxRecentProjects = 5
    
    // path must be a valid project path
    func addInRecentProjectsMenu(path:String) {
        let mainMenu = NSApp.mainMenu
        if let menu = mainMenu {
            let openRecentMenu = menu?.itemWithTitle("File")?.submenu?.itemWithTitle("Recent Projects")?.submenu
            if let recentMenu = openRecentMenu {
                let recentItem = recentMenu.itemWithTitle(path)
                if let item = recentItem {
                    recentMenu.removeItem(item)
                }
                let mi = NSMenuItem(title: path, action: "openProject:", keyEquivalent: "")
                mi.representedObject = path
                recentMenu.insertItem(mi, atIndex: 0)
                
                if countElements(recentMenu.itemArray) > maxRecentProjects+2 {
                    recentMenu.removeItemAtIndex(maxRecentProjects)
                }
                
                // save recent projects to user default as array
                var paths:[AnyObject] = []
                for item in recentMenu.itemArray {
                    let it = item as NSMenuItem
                    paths += [it.title]
                }
                NSUserDefaults.standardUserDefaults().setValue(paths, forKey: "recentProjects")
            }
        }
    }
    
    @IBAction func clearRecentProjectsMenu(sender:AnyObject?) {
        let mainMenu = NSApp.mainMenu
        if let menu = mainMenu {
            let openRecentMenu = menu?.itemWithTitle("File")?.submenu?.itemWithTitle("Recent Projects")?.submenu
            if let recentMenu = openRecentMenu {
                recentMenu.removeAllItems()
                let mi = NSMenuItem(title: "Clear Recent Projects", action: "clearRecentProjectsMenu:", keyEquivalent: "")
                recentMenu.addItem(NSMenuItem.separatorItem())
                recentMenu.addItem(mi)
                
                NSUserDefaults.standardUserDefaults().setValue(nil, forKey: "recentProjects")
            }
        }
    }
    
    // =============================================
    // MARK: * Alert Panels
    
    func projectFolderMissingAtPath(path:String) {
        var alert = NSAlert()
        alert.informativeText = "The folder at path \"\(path)\" doesn't exist. Open or create another one."
        alert.messageText = "Project missing"
        alert.addButtonWithTitle("Open Existing")
        alert.addButtonWithTitle("Create New")
        
        switch alert.runModal() {
        case NSAlertFirstButtonReturn:
            openProject(self)
            break
        case NSAlertSecondButtonReturn:
            newProject(self)
            break
        default:
            break
        }
    }
    
    // =============================================
    // MARK: * NSWindowDelegate implementation
    
    // When a window is closed, we remove its controller from the windows array
    func windowWillClose(notification: NSNotification) {
        if let window = notification.object as? NSWindow {
            for (index, windowController:ProjectWindowController) in enumerate(windows) {
                if windowController.window == window {
                    windowController.myTextViewController?.saveCurrentFile()
                    windows.removeAtIndex(index)
                    break
                }
            }
        } else {
            fatalError("error in \(self.className): couldn't retrieve window from notification")
        }
    }
    
    func windowDidBecomeKey(notification: NSNotification) {
        if let window = notification.object as? NSWindow {
            for (index, windowController:ProjectWindowController) in enumerate(windows) {
                if windowController.window == window {
                    windowController.onBecomeKeyWindow()
                    break
                }
            }
        } else {
            fatalError("error in \(self.className): couldn't retrieve window from notification")
        }
    }
    
}
