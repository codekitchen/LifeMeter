//
//  AppDelegate.swift
//  LifeMeterHelperApp
//
//  Created by Brian Palmer on 11/21/16.
//  Copyright © 2016 Brian Palmer. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let bundlePath = Bundle.main.bundlePath
        let appPath = URL(fileURLWithPath: bundlePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().path
        NSWorkspace.shared().launchApplication(appPath)
        NSApp.terminate(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

