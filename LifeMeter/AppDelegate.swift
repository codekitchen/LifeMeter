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
    let statusItem : NSStatusItem
    @IBOutlet weak var statusMenu: NSMenu!
    
    let LIFE_EXPECTANCY = "lifeExpectancy"
    let BIRTH_DATE = "birthDate"
    
    @IBAction func quit(_ sender: Any) {
        NSApp.terminate(self)
    }
    
    override init() {
        statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        super.init()
        ensureDefaultSettings()
        watchForChanges()
    }
    
    func watchForChanges() {
        UserDefaults().addObserver(self, forKeyPath: LIFE_EXPECTANCY, options: NSKeyValueObservingOptions.new, context: nil)
        UserDefaults().addObserver(self, forKeyPath: BIRTH_DATE, options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        updateTimeLeft()
    }
    
    deinit {
        UserDefaults().removeObserver(self, forKeyPath: LIFE_EXPECTANCY)
        UserDefaults().removeObserver(self, forKeyPath: BIRTH_DATE)
    }
    
    func ensureDefaultSettings() {
        UserDefaults().register(defaults: [
            LIFE_EXPECTANCY: 80,
            BIRTH_DATE: Date.init(timeIntervalSince1970: 386146800),
            ])
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.title = "LifeTimer"
        }
        statusItem.menu = statusMenu
    }
    
    func updateTimeLeft() {
        let lifeExpectancy = (1...150).clamp(UserDefaults().integer(forKey: LIFE_EXPECTANCY))
        guard let birthDate = UserDefaults().object(forKey: BIRTH_DATE) as? Date else { return }
        guard let eol = Calendar.current.date(byAdding: .year, value: lifeExpectancy, to: birthDate) else { return }
        let timeLeft = Calendar.current.dateComponents([.year, .month, .day], from: Date(), to: eol)
        
        let totalSeconds = Calendar.current.dateComponents([.day], from: birthDate, to: eol)
        let currentSeconds = Calendar.current.dateComponents([.day], from: birthDate, to: Date())
        let pctDone = Double(currentSeconds.day!) / Double(totalSeconds.day!)
        
        guard let button = statusItem.button else { return }
        button.title = formatTimeLeft(timeLeft)
    }
    
    func formatTimeLeft(_ timeLeft: DateComponents) -> String {
        return String.init(format: "%0.2ld:%0.2ld:%0.2ld", timeLeft.year!, timeLeft.month!, timeLeft.day!)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

