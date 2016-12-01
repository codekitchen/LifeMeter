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
let SEEN_SETTINGS = "seenSettings"

let ONE_HOUR = TimeInterval(60.0 * 60.0)

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
        if (!UserDefaults.standard.bool(forKey: SEEN_SETTINGS)) {
            debugPrint("first launch, showing the settings window")
            showSettings(self)
            UserDefaults.standard.set(true, forKey: SEEN_SETTINGS)
        }
    }

    func registerDefaultSettings() {
        let twentyYearsAgo = Calendar.current.date(byAdding: .year, value: -20, to: Date())!
        UserDefaults.standard.register(defaults: [
            LIFE_EXPECTANCY: 80,
            BIRTH_DATE: twentyYearsAgo,
            SHOW_PERCENTAGE: true,
            SEEN_SETTINGS: false,
        ])
    }

    func updateTimeLeft() {
        let lifeExpectancy = (1...150).clamp(UserDefaults.standard.integer(forKey: LIFE_EXPECTANCY))
        let showPercentage = UserDefaults.standard.bool(forKey: SHOW_PERCENTAGE)
        guard let birthDate = UserDefaults.standard.object(forKey: BIRTH_DATE) as? Date else { return }

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
