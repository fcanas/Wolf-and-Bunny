//
//  AppDelegate.swift
//  Foxes
//
//  Created by Fabian Canas on 8/24/15.
//  Copyright © 2015 Fabian Canas. All rights reserved.
//

import Cocoa
import Accelerate

let worldSize :vImagePixelCount = 255

let __f :UnsafeMutablePointer<Void> = malloc(Int(worldSize * worldSize))
let __b :UnsafeMutablePointer<Void> = malloc(Int(worldSize * worldSize))
let __i :UnsafeMutablePointer<Void> = malloc(Int(worldSize * worldSize))

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

