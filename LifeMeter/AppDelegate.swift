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

let LIFE_EXPECTANCY = "lifeExpectancy"
let BIRTH_DATE = "birthDate"
let SHOW_PERCENTAGE = "showPercentage"
let ICON_WIDTH = 21.0
let ICON_HEIGHT = 16.0

let ONE_HOUR : TimeInterval = 60.0 * 60.0

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var timeLeftMenuItem: NSMenuItem!

    let statusItem : NSStatusItem
    var updateTimer : Timer?

    @IBAction func showSettings(_ sender: Any) {
        debugPrint("showing settings")
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(sender)
    }

    override init() {
        statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        super.init()
    }

    func drawStatusIcon(_ pctLeft: Double) -> NSImage {
        //        let img = NSImage(size: NSSize(width: 21, height: 16), flipped: false, drawingHandler: { sz in
        //            NSBezierPath(roundedRect: NSRect(x: 1, y: 2, width: 19, height: 12), xRadius: 2.0, yRadius: 2.0).stroke()
        //            NSBezierPath(rect: NSRect(x: 3, y: 4, width: 15, height: 8)).fill()
        //            return true
        //        })
        //        return img

        let statusImage = NSImage(size: NSSize(width: ICON_WIDTH, height: ICON_HEIGHT), flipped: false, drawingHandler: { rect in
            NSImage(named: "si-bg")?.draw(at: NSZeroPoint, from: NSRect(x: 0, y: 0, width: ICON_WIDTH, height: ICON_HEIGHT), operation: .sourceOver, fraction: 1.0)
            NSImage(named: "si-fill")!.draw(at: NSPoint(x: 0, y:0), from: NSRect(x: 0, y: 0, width: (pctLeft * ICON_WIDTH), height: ICON_HEIGHT), operation: .sourceOver, fraction: 1.0)
            return true
        })
        statusImage.isTemplate = true
        return statusImage
    }

    func watchForChanges() {
        UserDefaults().addObserver(self, forKeyPath: LIFE_EXPECTANCY, options: .new, context: nil)
        UserDefaults().addObserver(self, forKeyPath: BIRTH_DATE, options: .new, context: nil)
        UserDefaults().addObserver(self, forKeyPath: SHOW_PERCENTAGE, options: .new, context: nil)
        updateTimer = Timer.scheduledTimer(withTimeInterval: ONE_HOUR, repeats: true) {_ in
            self.updateTimeLeft()
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        updateTimeLeft()
    }

    deinit {
        UserDefaults().removeObserver(self, forKeyPath: LIFE_EXPECTANCY)
        UserDefaults().removeObserver(self, forKeyPath: BIRTH_DATE)
        UserDefaults().removeObserver(self, forKeyPath: SHOW_PERCENTAGE)
        NSStatusBar.system().removeStatusItem(statusItem)
        updateTimer?.invalidate()
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

        ensureDefaultSettings()
        watchForChanges()
    }

    func updateTimeLeft() {
        debugPrint(Date(), "updating time left")
        let lifeExpectancy = (1...150).clamp(UserDefaults().integer(forKey: LIFE_EXPECTANCY))
        guard let birthDate = UserDefaults().object(forKey: BIRTH_DATE) as? Date else { return }
        guard let eol = Calendar.current.date(byAdding: .year, value: lifeExpectancy, to: birthDate) else { return }
        let timeLeft = Calendar.current.dateComponents([.year, .month, .day], from: Date(), to: eol)
        timeLeftMenuItem.title = formatTimeLeft(timeLeft)

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
        let statusIcon = drawStatusIcon(pctLeft)
        button.image = statusIcon
    }

    func formatTimeLeft(_ timeLeft: DateComponents) -> String {
        return String(format: "%0.2ld years, %0.2ld months, %0.2ld days", timeLeft.year!, timeLeft.month!, timeLeft.day!)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
