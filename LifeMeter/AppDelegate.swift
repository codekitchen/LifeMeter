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

let ONE_HOUR : TimeInterval = 60.0 * 60.0

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var settingsWindow: NSWindow!
    @IBOutlet weak var statusItem: StatusItem!

    var updateTimer : Timer?

    @IBAction func showSettings(_ sender: Any) {
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow.makeKeyAndOrderFront(sender)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        registerDefaultSettings()
        updateTimeLeft()
        watchForChanges()
    }

    func registerDefaultSettings() {
        UserDefaults().register(defaults: [
            LIFE_EXPECTANCY: 80,
            BIRTH_DATE: Date.init(timeIntervalSince1970: 386146800),
            SHOW_PERCENTAGE: true,
            ])
    }

    func updateTimeLeft() {
        let lifeExpectancy = (1...150).clamp(UserDefaults().integer(forKey: LIFE_EXPECTANCY))
        let showPercentage = UserDefaults().bool(forKey: SHOW_PERCENTAGE)
        guard let birthDate = UserDefaults().object(forKey: BIRTH_DATE) as? Date else { return }
        
        debugPrint(Date(), "updateTimeLeft()", lifeExpectancy, showPercentage, birthDate)

        let timeLeft = TimeLeft(lifeExpectancy: lifeExpectancy, birthDate: birthDate)
        statusItem.update(timeLeft: timeLeft, showPercentage: showPercentage)
    }

    func watchForChanges() {
        NotificationCenter.default.addObserver(self, selector: #selector(defaultsDidChange(note:)), name: UserDefaults.didChangeNotification, object: nil)
        updateTimer = Timer.scheduledTimer(withTimeInterval: ONE_HOUR, repeats: true) {_ in
            self.updateTimeLeft()
        }
    }

    func defaultsDidChange(note : NSNotification) {
        // TODO: I'm seeing odd behavior where if I call updateTimeLeft() synchronously in this notification,
        // then UserDefaults().integer(forKey:) returns the registered default value instead of the user
        // value (even though an earlier call in the same process returned the correct value).
        // Google has been no help here, so I'm punting for now and scheduling the function to run
        // soon in the future, which appears to fix the problem.
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { _ in self.updateTimeLeft() }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
}
