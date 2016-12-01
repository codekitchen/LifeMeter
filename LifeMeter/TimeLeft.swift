//
//  TimeLeft.swift
//  LifeMeter
//
//  Created by Brian Palmer on 11/22/16.
//  Copyright © 2016 Brian Palmer. All rights reserved.
//

import Foundation

class TimeLeft {
    let timeLeft: DateComponents
    let pctLeft: Double

    init(now: Date = Date(), lifeExpectancy lifeExpectancy_: Int, birthDate birthDate_: Date) {
        let now = Date()

        var lifeExpectancy = lifeExpectancy_
        if lifeExpectancy > 150 {
            lifeExpectancy = 150
        }
        
        var birthDate = birthDate_
        if birthDate > now {
            birthDate = now
        }

        var eol = Calendar.current.date(byAdding: .year, value: lifeExpectancy, to: birthDate)!
        if eol < now {
            eol = now
        }

        timeLeft = Calendar.current.dateComponents([.year, .month, .day], from: now, to: eol)

        let totalSeconds = Calendar.current.dateComponents([.day], from: birthDate, to: eol)
        let currentSeconds = Calendar.current.dateComponents([.day], from: birthDate, to: now)
        pctLeft = 1 - Double(currentSeconds.day!) / Double(totalSeconds.day!)
    }

    func formatTimeLeft() -> String {
        return String(format: "%ld years, %ld months, %ld days", timeLeft.year!, timeLeft.month!, timeLeft.day!)
    }
}
