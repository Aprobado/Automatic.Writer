//
//  Project.swift
//  AutomaticWriter
//
//  Created by Raphael on 14.01.15.
//  Copyright (c) 2015 HEAD Geneva. All rights reserved.
//

import Cocoa

class Project: NSObject {
    
    var path : String
    var folderName : String
    
    init(projectPath : String) {
        path = projectPath
        folderName = path.lastPathComponent
        
        super.init()
    }
    
    func addFilesInFolderPath(folderPath:String, intoArray:NSMutableArray) {
        let absolutePath = path.stringByAppendingPathComponent(folderPath)
        
        if let content:NSArray = NSFileManager.defaultManager().contentsOfDirectoryAtPath(absolutePath, error: nil) {
            for file in content {
                if let fileName = file as? String {
                    if fileName[fileName.startIndex] == "." {
                        println("ignore invisible file: \(fileName)")
                    } else if fileName == "automat" {
                        println("ignore automat folder")
                    } else {
                        
                        let fileRelativePath = folderPath.stringByAppendingPathComponent(fileName)
                        let fileAbsolutePath = absolutePath.stringByAppendingPathComponent(fileName)
                        
                        var isDir = ObjCBool(false)
                        if NSFileManager.defaultManager().fileExistsAtPath(fileAbsolutePath, isDirectory: &isDir) {
                            if isDir.boolValue {
                                //println("\(absolutePath) is a folder")
                                // recursively add files
                                addFilesInFolderPath(fileRelativePath, intoArray: intoArray)
                            } else {
                                //println("adding file: \(fileName)")
                                if let attributes : [NSObject : AnyObject] = NSFileManager.defaultManager().attributesOfItemAtPath(fileAbsolutePath, error: nil) {
                                    
                                    let date:NSDate? = attributes[NSFileModificationDate] as? NSDate
                                    if date == nil {
                                        println("\(self.className):addFilesInFolderPath: date is nil, we're stopping the process to avoid unattended behaviours")
                                        return
                                    }
                                    
                                    let fileRelativePathInBook = folderName.stringByAppendingPathComponent(fileRelativePath)
                                    var dico:NSDictionary = ["path": fileRelativePathInBook, "date": date!]
                                    
                                    intoArray.addObject(dico)
                                }
                            }
                        }
                    }
                }
            }
        } else {
            println("can't find content at path: \(absolutePath)")
        }
    }
    
    func getArrayOfFiles() -> NSArray {
        var array : NSMutableArray = []
        addFilesInFolderPath("", intoArray: array)
        return array
    }
    
    func getArrayOfFilesAsNSData() -> NSData {
        let array = getArrayOfFiles()
        let data:NSData = NSKeyedArchiver.archivedDataWithRootObject(array)
        return data
    }
}
