//
//  TerminalCommander.swift
//  AutomaticWriter
//
//  Created by Raphael on 28.01.15.
//  Copyright (c) 2015 HEAD Geneva. All rights reserved.
//

import Foundation

class TerminalCommander {
    class func executeTerminalCommand(command:[String], from directoryPath:String, withLaunchPath launchPath:String) -> Bool {
        let task = NSTask()
        task.launchPath = launchPath
        task.arguments = command
        task.currentDirectoryPath = directoryPath
        task.launch()
        
        task.waitUntilExit()
        
        return true
    }
}