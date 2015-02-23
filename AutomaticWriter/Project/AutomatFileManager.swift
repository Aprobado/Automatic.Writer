//
//  AutomatFileManager.swift
//  AutomaticWriter
//
//  Created by Raphael on 20.01.15.
//  Copyright (c) 2015 HEAD Geneva. All rights reserved.
//

import Cocoa

protocol AutomatFileManagerDelegate {
    func onFilesAdded(files:[String]);
}

class AutomatFileManager: NSObject {
    
    // ==================================================================
    // MARK: ************   Object functions (instance)   ************
    // ==================================================================
    
    var delegate:AutomatFileManagerDelegate?
    var rootFolderPath:String
    
    /// Initialize with the path of the root folder of the project
    ///
    /// :param: _rootFolderPath path of the folder root
    init(_rootFolderPath:String) {
        rootFolderPath = _rootFolderPath
        super.init()
    }
    
    // ==================================================================
    // MARK: * File Creation
    
    /// Create a file in current project using root folder path
    /// File types have strict paths, described in "* Default files destinations" and "* Default directories for files"
    ///
    /// :param: type "Automatic Writing", "HTML", "css" or "javascript"
    func createNewFileOfType(type:String) {
        var directory:String?
        var defaultFileToCopy:String?
        var destinationPath:String?
        
        if type == "Automatic Writing" {
            directory = automatDirectory()
            defaultFileToCopy = AutomatFileManager.automatDefaultFile()
            let fileDestination = automatFileDestination(nil)
            if let actualFileDestination = fileDestination {
                destinationPath = AutomatFileManager.getValidDestinationPathForFile(actualFileDestination)
            }
        }
        else if type == "HTML" {
            directory = htmlDirectory()
            defaultFileToCopy = AutomatFileManager.htmlDefaultFile()
            let fileDestination = htmlFileDestination(nil)
            if let actualFileDestination = fileDestination {
                destinationPath = AutomatFileManager.getValidDestinationPathForFile(actualFileDestination)
            }
        }
        else if type == "css" {
            directory = cssDirectory()
            defaultFileToCopy = AutomatFileManager.cssDefaultFile()
            let fileDestination = cssFileDestination(nil)
            if let actualFileDestination = fileDestination {
                destinationPath = AutomatFileManager.getValidDestinationPathForFile(actualFileDestination)
            }
        }
        else if type == "javascript" {
            directory = javascriptDirectory()
            defaultFileToCopy = AutomatFileManager.javascriptDefaultFile()
            let fileDestination = javascriptFileDestination(nil)
            if let actualFileDestination = fileDestination {
                destinationPath = AutomatFileManager.getValidDestinationPathForFile(actualFileDestination)
            }
        }
        else {
            println("\(self.className): Error: we can only create new Automatic Writing, HTML, css and javascript files")
            return
        }
        
        // block attemps if we don't have all the informations needed
        if directory == nil {
            println("\(self.className): Error: missing directory to create new file of type \(type)")
            return
        }
        if defaultFileToCopy == nil {
            println("\(self.className): Error: missing defaultFileToCopy to create new file of type \(type)")
            return
        }
        if destinationPath == nil {
            println("\(self.className): Error: missing destinationPath to create new file of type \(type)")
            return
        }
        
        AutomatFileManager.createDirectoryAtPath(directory!)
        
        if AutomatFileManager.createFileAtPath(destinationPath!, fromFile: defaultFileToCopy!) {
            let file:[String] = [destinationPath!]
            // tell the delegate we added a file
            delegate?.onFilesAdded(file)
        }
    }
    
    /// Copy files from an array of paths (Strings).
    /// It puts them in the right place according to default directories by type
    /// and makes sure there's never twice the same name
    ///
    /// :param: files array of paths
    func copyFilesFromArray(files:[String]) {
        var fileSuccessfullyCopied:[String] = []
        
        for path in files {
            // TODO: fix the copy for images
            if AutomatFileManager.fileAtPathIsAnImage(path) {
                // create directory
                AutomatFileManager.createDirectoryAtPath(imageDirectory())
                
                // get destination
                let destination = imageFileDestination(path.lastPathComponent)
                if let actualDestination = destination {
                    
                    // add suffixe to destination if necessary
                    let validDestination = AutomatFileManager.getValidDestinationPathForFile(actualDestination)
                    if let actualValidDestination = validDestination {
                        
                        // create file
                        if AutomatFileManager.createFileAtPath(actualValidDestination, fromFile: path) {
                            fileSuccessfullyCopied += [actualValidDestination]
                        }
                    }
                }
            }
            
            else if AutomatFileManager.fileAtPathIsAnAudiovisualContent(path) {
                // just ignore it, we don't manage that for now
            }
            
            else if AutomatFileManager.fileAtPathIsATextFile(path) {
                let fileName = path.lastPathComponent
                var destination:String?
                
                switch path.pathExtension {
                case "html":
                    AutomatFileManager.createDirectoryAtPath(htmlDirectory())
                    let tempDestination = htmlFileDestination(fileName)
                    if let actualTempDestination = tempDestination {
                        destination = AutomatFileManager.getValidDestinationPathForFile(actualTempDestination)
                    }
                    break
                case "css":
                    AutomatFileManager.createDirectoryAtPath(cssDirectory())
                    let tempDestination = cssFileDestination(fileName)
                    if let actualTempDestination = tempDestination {
                        destination = AutomatFileManager.getValidDestinationPathForFile(actualTempDestination)
                    }
                    break
                case "js":
                    AutomatFileManager.createDirectoryAtPath(javascriptDirectory())
                    let tempDestination = javascriptFileDestination(fileName)
                    if let actualTempDestination = tempDestination {
                        destination = AutomatFileManager.getValidDestinationPathForFile(actualTempDestination)
                    }
                    break
                case "automat":
                    AutomatFileManager.createDirectoryAtPath(automatDirectory())
                    let tempDestination = automatFileDestination(fileName)
                    if let actualTempDestination = tempDestination {
                        destination = AutomatFileManager.getValidDestinationPathForFile(actualTempDestination)
                    }
                    break
                default:
                    break
                }
                
                if destination == nil {
                    continue
                }
                
                if AutomatFileManager.createFileAtPath(destination!, fromFile: path) {
                    fileSuccessfullyCopied += [destination!]
                }
            }
        }
        
        // tell the delegate we added files
        delegate?.onFilesAdded(fileSuccessfullyCopied)
    }
    
    // ==================================================================
    // MARK: * Default files destinations
    
    /// Get the default destination path for ".automat" files in the project (owner) and adds the fileName at the end
    /// or the default name if fileName is nil
    ///
    /// :param: fileName name you want to give to the file
    /// :returns: the complete path
    func automatFileDestination(fileName:String?) -> String? {
        if fileName == "" || fileName == nil {
            let defaultName = AutomatFileManager.automatDefaultFile()?.lastPathComponent
            if let actualDefaultName = defaultName {
                return automatDirectory().stringByAppendingPathComponent(actualDefaultName)
            } else {
                println("couldn't retrieve default name for automat file")
                return nil
            }
        } else {
            return automatDirectory().stringByAppendingPathComponent(fileName!)
        }
    }
    
    /// Get the default destination path for ".css" files in the project (owner) and adds the fileName at the end
    /// or the default name if fileName is nil
    ///
    /// :param: fileName name you want to give to the file
    /// :returns: the complete path
    func cssFileDestination(fileName:String?) -> String? {
        if fileName == "" || fileName == nil {
            let defaultName = AutomatFileManager.cssDefaultFile()?.lastPathComponent
            if let actualDefaultName = defaultName {
                return cssDirectory().stringByAppendingPathComponent(actualDefaultName)
            } else {
                println("couldn't retrieve default name for css file")
                return nil
            }
        } else {
            return cssDirectory().stringByAppendingPathComponent(fileName!)
        }
    }
    
    /// Get the default destination path for ".js" files in the project (owner) and adds the fileName at the end
    /// or the default name if fileName is nil
    ///
    /// :param: fileName name you want to give to the file
    /// :returns: the complete path
    func javascriptFileDestination(fileName:String?) -> String? {
        if fileName == "" || fileName == nil {
            let defaultName = AutomatFileManager.javascriptDefaultFile()?.lastPathComponent
            if let actualDefaultName = defaultName {
                return javascriptDirectory().stringByAppendingPathComponent(actualDefaultName)
            } else {
                println("couldn't retrieve default name for javascript file")
                return nil
            }
        } else {
            return javascriptDirectory().stringByAppendingPathComponent(fileName!)
        }
    }
    
    /// Get the default destination path for ".html" files in the project (owner) and adds the fileName at the end
    /// or the default name if fileName is nil
    ///
    /// :param: fileName name you want to give to the file
    /// :returns: the complete path
    func htmlFileDestination(fileName:String?) -> String? {
        if fileName == "" || fileName == nil {
            let defaultName = AutomatFileManager.htmlDefaultFile()?.lastPathComponent
            if let actualDefaultName = defaultName {
                return htmlDirectory().stringByAppendingPathComponent(actualDefaultName)
            } else {
                println("couldn't retrieve default name for html file")
                return nil
            }
        } else {
            return htmlDirectory().stringByAppendingPathComponent(fileName!)
        }
    }
    
    /// Get the default destination path for image files in the project (owner) and adds the fileName at the end
    /// or name it "unnamed image" if fileName is nil
    ///
    /// :param: fileName name you want to give to the image
    /// :returns: the complete path
    func imageFileDestination(fileName:String?) -> String? {
        var name = fileName
        if fileName == "" || fileName == nil {
            name = "unnamed image"
        }
        return automatDirectory().stringByAppendingPathComponent(name!)
    }
    
    // ==================================================================
    // MARK: * Default directories for files
    
    func automatDirectory() -> String {
        return rootFolderPath.stringByAppendingPathComponent("automat")
    }
    func cssDirectory() -> String {
        return rootFolderPath.stringByAppendingPathComponent("css")
    }
    func javascriptDirectory() -> String {
        return rootFolderPath.stringByAppendingPathComponent("lib")
    }
    func htmlDirectory() -> String {
        return rootFolderPath
    }
    func imageDirectory() -> String {
        return rootFolderPath.stringByAppendingPathComponent("images")
    }
    
    // ==================================================================
    // MARK: ************   Class functions (static)   ************
    // ==================================================================
    
    // ==================================================================
    // MARK: * File Creation
    
    class func createDirectoryAtPath(directoryPath:String) {
        if !NSFileManager.defaultManager().fileExistsAtPath(directoryPath) {
            NSFileManager.defaultManager().createDirectoryAtPath(directoryPath, withIntermediateDirectories: true, attributes: nil, error: nil)
        }
    }
    
    class func createFileAtPath(destinationPath:String, fromFile sourcePath:String) -> Bool {
        var error:NSError?
        if NSFileManager.defaultManager().copyItemAtPath(sourcePath, toPath: destinationPath, error: &error) {
            // if we created an automat file, we need the html equivalent
            if destinationPath.pathExtension == "automat" {
                if generateHtmlFromAutomatFileAtPath(destinationPath) {
                    // copy ok + HTML creation ok
                    return true
                } else {
                    // if we couldn't generate HTML file
                    return false
                }
            } else {
                // it wasn't an automat file, we're good
                return true
            }
        } else {
            // if we couldn't copy the file at all
            if let actualError = error {
                println("\(self.className()): can't copy file - error: \(actualError)")
            }
            return false
        }
    }
    
    class func generateHtmlFromAutomatFileAtPath(path:String) -> Bool {
        // TODO: fill the function when AutomatParser is ready
        // convert automat file
        //let convertedAutomatFile:String? = "Automat converted to HTML" // <- need the AutomatParser function
        let convertedAutomatFile:String? = Parser.automatFileToHtml(path)
        if convertedAutomatFile == nil {
            return false
        }
        
        let htmlFilePath = getHtmlFileOfAutomatFileAtPath(path)
        if let actualHtmlFilePath = htmlFilePath {
            var error:NSError?
            convertedAutomatFile!.writeToFile(actualHtmlFilePath, atomically: true, encoding: NSUTF8StringEncoding, error: &error)
            if let actualError = error {
                println("\(self.className()): error writing converted automat file: \(actualError)")
                return false
            }
        }
        
        return true
    }
    
    // ==================================================================
    // MARK: * File Deletion
    
    class func deleteFile(path:String) {
        // if we're trashing an automat file, trash its html file as well
        if path.pathExtension == "automat" {
            let htmlFilePath = getHtmlFileOfAutomatFileAtPath(path)
            if let actualHtmlFilePath = htmlFilePath {
                let url = NSURL(fileURLWithPath: actualHtmlFilePath)
                if let actualUrl = url {
                    var error:NSError?
                    NSFileManager.defaultManager().trashItemAtURL(actualUrl, resultingItemURL: nil, error: &error)
                    if let actualError = error {
                        println("\(self.className()): Error while deleting file: \(actualError)")
                    }
                }
            }
        }
        
        // if we're trashing an html file, trash its automat file as well if it exists
        if path.pathExtension == "html" {
            let automatFilePath = getAutomatFileOfHtmlFileAtPath(path)
            if let actualAutomatFilePath = automatFilePath {
                if NSFileManager.defaultManager().fileExistsAtPath(actualAutomatFilePath) {
                    let url = NSURL(fileURLWithPath: actualAutomatFilePath)
                    if let actualUrl = url {
                        var error:NSError?
                        NSFileManager.defaultManager().trashItemAtURL(actualUrl, resultingItemURL: nil, error: &error)
                        if let actualError = error {
                            println("\(self.className()): Error while deleting file: \(actualError)")
                        }
                    }
                }
                // else there's no automat file for this html
            }
        }
        
        // then trash the file itself
        let url = NSURL(fileURLWithPath: path)
        if let actualUrl = url {
            var error:NSError?
            NSFileManager.defaultManager().trashItemAtURL(actualUrl, resultingItemURL: nil, error: &error)
            if let actualError = error {
                println("\(self.className()): Error while deleting file: \(actualError)")
            }
        }
    }
    
    // ==================================================================
    // MARK: * Getting file informations
    
    class func getFileInfos(path:String) -> [String:String] {
        var result:[String:String] = [String:String]()
        
        result["directory"] = path.stringByDeletingLastPathComponent
        result["name"] = path.lastPathComponent.stringByDeletingPathExtension
        result["extension"] = path.pathExtension
        
        return result
    }
    
    class func getHtmlFileOfAutomatFileAtPath(path:String) -> String? {
        if (path.pathExtension != "automat") {
            println("file at path \(path) is not an automat file")
            return nil
        }
        
        let infos:[String:String] = getFileInfos(path)
        let dir = infos["directory"]
        let fileName = infos["name"]
        if dir != nil && fileName != nil {
            let htmlDir = dir!.stringByDeletingLastPathComponent
            let htmlFileName = fileName!.stringByAppendingPathExtension("html")
            if let tempHtmlFileName = htmlFileName {
                return htmlDir.stringByAppendingPathComponent(tempHtmlFileName)
            }
        }
        println("couldn't retrieve html file path of automat file at path \(path)")
        return nil
    }
    
    class func getAutomatFileOfHtmlFileAtPath(path:String) -> String? {
        if path.pathExtension != "html" {
            println("file at path \(path) is not an html file")
            return nil
        }
        
        let infos:[String:String] = getFileInfos(path)
        let dir = infos["directory"]
        let fileName = infos["name"]
        if dir != nil && fileName != nil {
            let automatDir = dir!.stringByAppendingPathComponent("automat")
            let automatFileName = fileName!.stringByAppendingPathExtension("automat")
            if let actualAutomatFileName = automatFileName {
                return automatDir.stringByAppendingPathComponent(actualAutomatFileName)
            }
        }
        println("couldn't retrieve automat file path of html file at path \(path)")
        return nil
    }
    
    // ==================================================================
    // MARK: * File Modification
    
    class func renameFile(filePath:String, to fileName:String) {
        // when renaming we can't add path component, so avoid "/"
        var newName = fileName.stringByReplacingOccurrencesOfString("/", withString: "")
        
        // TODO: decide by usage if changing extension should be permitted
        // force keeping the same extension
        if filePath.pathExtension != newName.pathExtension {
            newName.stringByDeletingPathExtension.stringByAppendingPathExtension(filePath.pathExtension)
        }
        
        let newPath = filePath.stringByDeletingLastPathComponent.stringByAppendingPathComponent(newName)
        
        if NSFileManager.defaultManager().fileExistsAtPath(newPath) {
            // TODO: show an alert?
            println("can't change name to an existing name")
            return;
        }
        
        // if it's an automat file, modify the corresponding html file as well
        if newPath.pathExtension == "automat" {
            let htmlFilePath = getHtmlFileOfAutomatFileAtPath(filePath)
            let htmlNewFilePath = getHtmlFileOfAutomatFileAtPath(newPath)
            if htmlFilePath == nil || htmlNewFilePath == nil {
                println("couldn't retrieve html file path from automat file path")
                return
            }
            
            if NSFileManager.defaultManager().fileExistsAtPath(htmlNewFilePath!) {
                // TODO: show an alert?
                println("an html with that name already exists")
                return;
            }
            
            // modifiy html name by moving the file
            var error:NSError?
            NSFileManager.defaultManager().moveItemAtPath(htmlFilePath!, toPath: htmlNewFilePath!, error: &error)
            if let actualError = error {
                println("Error while moving file: \(actualError)")
            }
        }
        
        // if it's an html file, modify the corresponding automat file as well if it exists
        if newPath.pathExtension == "html" {
            let automatFilePath = getAutomatFileOfHtmlFileAtPath(filePath)
            if let actualAutomatFilePath = automatFilePath {
                // only if the file exists
                if NSFileManager.defaultManager().fileExistsAtPath(actualAutomatFilePath) {
                    let automatNewFilePath = getAutomatFileOfHtmlFileAtPath(newPath)
                    if automatNewFilePath == nil {
                        println("couldn't retrieve automat file path from html new file path")
                        return
                    }
                    if NSFileManager.defaultManager().fileExistsAtPath(automatNewFilePath!) {
                        // TODO: show an alert?
                        println("an automat file with that name already exists")
                        return;
                    }
                    
                    // modifiy automat name by moving the file
                    var error:NSError?
                    NSFileManager.defaultManager().moveItemAtPath(actualAutomatFilePath, toPath: automatNewFilePath!, error: &error)
                    if let actualError = error {
                        println("Error while moving file: \(actualError)")
                    }
                }
            }
        }
        
        // modifiy file name by moving the file
        var error:NSError?
        NSFileManager.defaultManager().moveItemAtPath(filePath, toPath: newPath, error: &error)
        if let actualError = error {
            println("Error while moving file: \(actualError)")
        }
    }
    
    class func moveFile(filePath:String, to folderPath:String) -> Bool {
        if filePath.stringByDeletingLastPathComponent == folderPath {
            println("don't need to move file in its own folder")
            return false
        }
        
        let newPath = folderPath.stringByAppendingPathComponent(filePath.lastPathComponent)
        if NSFileManager.defaultManager().fileExistsAtPath(newPath) {
            // TODO: how to handle this? Give choice to cancel/overwrite/keep both?
            println("a file with same name already exists")
            return false
        }
        
        var error:NSError?
        NSFileManager.defaultManager().moveItemAtPath(filePath, toPath: newPath, error: &error)
        if let actualError = error {
            println("Error while moving file: \(actualError)")
            return false
        }
        
        return true
    }
    
    // ==================================================================
    // MARK: * Utilities for managing files with same name
    
    class func suffixeOfNextFileForFile(path:String) -> String? {
        let fileInfos = getFileInfos(path)
        
        let dir = fileInfos["directory"]
        let fileName = fileInfos["name"]
        let ext = fileInfos["extension"]
        
        if dir != nil && fileName != nil && ext != nil {
            var suffixe = ""
            
            var index = 1
            while NSFileManager.defaultManager().fileExistsAtPath("\(dir!)/\(fileName!)\(suffixe).\(ext!)") {
                index++
                suffixe = "\(index)"
            }
            
            return suffixe
        } else {
            println("\(self.className()): couldn't find file infos from path: \(path)")
            return nil
        }
    }
    
    class func getValidDestinationPathForFile(path:String) -> String? {
        var suffixe:String?
        
        if path.pathExtension == "automat" {
            // automat files generate html files. So we need to check if html pages exist instead of automat pages.
            let htmlFilePath = getHtmlFileOfAutomatFileAtPath(path)
            if let actualHtmlFilePath = htmlFilePath {
                suffixe = suffixeOfNextFileForFile(actualHtmlFilePath)
            }
        } else {
            suffixe = suffixeOfNextFileForFile(path)
        }
        
        // unwrap the suffixe and create the valid destination path
        if let actualSuffixe = suffixe {
            let ext = path.pathExtension
            return path.stringByDeletingPathExtension.stringByAppendingString(actualSuffixe).stringByAppendingPathExtension(ext)
        } else {
            println("\(self.className()): impossible to get a valid destination for file \(path)")
            return nil
        }
    }
    
    // ==================================================================
    // MARK: * Paths for default files
    
    class func automatDefaultFile() -> String? {
        return NSBundle.mainBundle().pathForResource("page", ofType: ".automat", inDirectory: "DefaultFiles")
    }
    class func cssDefaultFile() -> String? {
        return NSBundle.mainBundle().pathForResource("default", ofType: ".css", inDirectory: "DefaultFiles")
    }
    class func javascriptDefaultFile() -> String? {
        return NSBundle.mainBundle().pathForResource("script", ofType: ".js", inDirectory: "DefaultFiles")
    }
    class func htmlDefaultFile() -> String? {
        return NSBundle.mainBundle().pathForResource("page", ofType: ".html", inDirectory: "DefaultFiles")
    }
    
    // ==================================================================
    // MARK: * File Type Tests
    
    class func getFileUTI(path:String) -> CFString {
        var fileExtension:CFString = path.pathExtension as NSString
        return UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, nil).takeUnretainedValue()
    }
    
    class func fileAtPathIsAnImage(path:String) -> Bool {
        return UTTypeConformsTo(getFileUTI(path), kUTTypeImage) != 0
    }
    
    class func fileAtPathIsAnAudiovisualContent(path:String) -> Bool {
        return UTTypeConformsTo(getFileUTI(path), kUTTypeAudiovisualContent) != 0
    }
    
    class func fileAtPathIsATextFile(path:String) -> Bool {
        if path.pathExtension == "automat" { return true }
        return UTTypeConformsTo(getFileUTI(path), kUTTypeText) != 0
    }
    
}
