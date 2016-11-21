//
//  AppDelegate.swift
//  LifeMeter
//
//  Created by Brian Palmer on 11/19/16.
//  Copyright © 2016 Brian Palmer. All rights reserved.
//

import Cocoa

extension ClosedRange {
    func clamp(_ value : Bound) -> Bound {
        return self.lowerBound > value ? self.lowerBound
            : self.upperBound < value ? self.upperBound
            : value
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var statusMenu: NSMenu!

    let statusItem : NSStatusItem

    let LIFE_EXPECTANCY = "lifeExpectancy"
    let BIRTH_DATE = "birthDate"
    let SHOW_PERCENTAGE = "showPercentage"

    @IBAction func quit(_ sender: Any) {
        NSApp.terminate(self)
    }

    @IBAction func showSettings(_ sender: Any) {
        debugPrint("showing settings")
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(sender)
    }

    override init() {
        statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)

        super.init()
        ensureDefaultSettings()
        watchForChanges()
    }

    func drawStatusIcon(_ pctLeft: Double) -> NSImage {
        //        let img = NSImage(size: NSSize(width: 21, height: 16), flipped: false, drawingHandler: { sz in
        //            NSBezierPath(roundedRect: NSRect(x: 1, y: 2, width: 19, height: 12), xRadius: 2.0, yRadius: 2.0).stroke()
        //            NSBezierPath(rect: NSRect(x: 3, y: 4, width: 15, height: 8)).fill()
        //            return true
        //        })
        //        return img

        let statusImage = NSImage(named: "si-bg")!.copy() as! NSImage
        statusImage.lockFocus()
        NSImage(named: "si-fill")!.draw(at: NSPoint(x: 0, y:0), from: NSRect(x: 0, y: 0, width: (pctLeft * 21.0), height: 16), operation: .sourceOver, fraction: 1.0)
        statusImage.unlockFocus()
        //statusImage.isTemplate = true
        return statusImage
    }

    func watchForChanges() {
        UserDefaults().addObserver(self, forKeyPath: LIFE_EXPECTANCY, options: .new, context: nil)
        UserDefaults().addObserver(self, forKeyPath: BIRTH_DATE, options: .new, context: nil)
        UserDefaults().addObserver(self, forKeyPath: SHOW_PERCENTAGE, options: .new, context: nil)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        updateTimeLeft()
    }

    deinit {
        UserDefaults().removeObserver(self, forKeyPath: LIFE_EXPECTANCY)
        UserDefaults().removeObserver(self, forKeyPath: BIRTH_DATE)
        NSStatusBar.system().removeStatusItem(statusItem)
    }

    func ensureDefaultSettings() {
        UserDefaults().register(defaults: [
            LIFE_EXPECTANCY: 80,
            BIRTH_DATE: Date.init(timeIntervalSince1970: 386146800),
            SHOW_PERCENTAGE: true,
        ])
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.menu = statusMenu
    }

    func updateTimeLeft() {
        let lifeExpectancy = (1...150).clamp(UserDefaults().integer(forKey: LIFE_EXPECTANCY))
        guard let birthDate = UserDefaults().object(forKey: BIRTH_DATE) as? Date else { return }
        guard let eol = Calendar.current.date(byAdding: .year, value: lifeExpectancy, to: birthDate) else { return }
        let _ = Calendar.current.dateComponents([.year, .month, .day], from: Date(), to: eol)

        let totalSeconds = Calendar.current.dateComponents([.day], from: birthDate, to: eol)
        let currentSeconds = Calendar.current.dateComponents([.day], from: birthDate, to: Date())
        let pctLeft = 1 - Double(currentSeconds.day!) / Double(totalSeconds.day!)

        guard let button = statusItem.button else { return }

        if UserDefaults().bool(forKey: SHOW_PERCENTAGE) {
            button.title = "\(Int(pctLeft * 100))% "
        } else {
            button.title = ""
        }

        button.imagePosition = .imageRight
        button.image = drawStatusIcon(pctLeft)
    }

    func formatTimeLeft(_ timeLeft: DateComponents) -> String {
        return String(format: "%0.2ld:%0.2ld:%0.2ld", timeLeft.year!, timeLeft.month!, timeLeft.day!)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
