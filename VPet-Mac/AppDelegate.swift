//
//  AppDelegate.swift
//  new2
//
//  Created by Just aLoli on 2023/8/27.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var VPET:VPet?
//    var statusBarItem:StatusBarItemController!
    func applicationDidFinishLaunching(_ notification: Notification) {
//        statusBarItem = StatusBarItemController()
//        VPET?.statusBarIcon = statusBarItem
//        VPET?.startup()
    }
    
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}



