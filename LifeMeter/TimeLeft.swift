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
    
    init(now: Date = Date(), lifeExpectancy: Int, birthDate: Date) {
        let eol = Calendar.current.date(byAdding: .year, value: lifeExpectancy, to: birthDate)!
        timeLeft = Calendar.current.dateComponents([.year, .month, .day], from: Date(), to: eol)
        
        let totalSeconds = Calendar.current.dateComponents([.day], from: birthDate, to: eol)
        let currentSeconds = Calendar.current.dateComponents([.day], from: birthDate, to: Date())
        pctLeft = 1 - Double(currentSeconds.day!) / Double(totalSeconds.day!)
    }

    func formatTimeLeft() -> String {
        return String(format: "%0.2ld years, %0.2ld months, %0.2ld days", timeLeft.year!, timeLeft.month!, timeLeft.day!)
    }
}
