//
//  TimeLeftTests.swift
//  LifeMeter
//
//  Created by Brian Palmer on 12/1/16.
//  Copyright © 2016 Brian Palmer. All rights reserved.
//

import XCTest
@testable import LifeMeter

class TimeLeftTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testHappyPath() {
        let birthDate = Date.init(timeIntervalSince1970: 386146800)
        let now2016 = Date.init(timeIntervalSince1970: 1480625478)
        let timeLeft = TimeLeft(now: now2016, lifeExpectancy: 85, birthDate: birthDate)
        XCTAssert(timeLeft.pctLeft >= 0.59 && timeLeft.pctLeft < 0.60)
        XCTAssert(timeLeft.timeLeft.year! == 50)
        XCTAssert(timeLeft.timeLeft.month! == 3)
        XCTAssert(timeLeft.timeLeft.day! == 26)
    }

    func testExpired() {
        let birthDate = Date.init(timeIntervalSince1970: 386146800)
        let now2016 = Date.init(timeIntervalSince1970: 1480625478)
        let timeLeft = TimeLeft(now: now2016, lifeExpectancy: 30, birthDate: birthDate)
        XCTAssert(timeLeft.pctLeft == 0.0)
        XCTAssert(timeLeft.timeLeft.year! == 0)
        XCTAssert(timeLeft.timeLeft.month! == 0)
        XCTAssert(timeLeft.timeLeft.day! == 0)
    }

    func testFutureBirth() {
        let now2016 = Date.init(timeIntervalSince1970: 1480625478)
        let birthDate = Calendar.current.date(byAdding: .year, value: 1, to: now2016)!
        let timeLeft = TimeLeft(now: now2016, lifeExpectancy: 85, birthDate: birthDate)
        XCTAssert(timeLeft.pctLeft == 1.0)
        XCTAssert(timeLeft.timeLeft.year! == 85)
        XCTAssert(timeLeft.timeLeft.month! == 0)
        XCTAssert(timeLeft.timeLeft.day! == 0)
    }

    func testNegativeLifeExpectancy() {
        // lifeExpectancy is capped to 1
        let birthDate = Date.init(timeIntervalSince1970: 386146800)
        let now2016 = Date.init(timeIntervalSince1970: 1480625478)
        let timeLeft = TimeLeft(now: now2016, lifeExpectancy: -2, birthDate: birthDate)
        XCTAssert(timeLeft.pctLeft == 0)
        XCTAssert(timeLeft.timeLeft.year! == 0)
        XCTAssert(timeLeft.timeLeft.month! == 0)
        XCTAssert(timeLeft.timeLeft.day! == 0)
    }

    func testSuperLongLifeExpectancy() {
        // lifeExpectancy is capped to 150
        let birthDate = Date.init(timeIntervalSince1970: 386146800)
        let now2016 = Date.init(timeIntervalSince1970: 1480625478)
        let timeLeft = TimeLeft(now: now2016, lifeExpectancy: 3000, birthDate: birthDate)
        XCTAssert(timeLeft.pctLeft >= 0.76 && timeLeft.pctLeft < 0.77)
        XCTAssert(timeLeft.timeLeft.year! == 115)
        XCTAssert(timeLeft.timeLeft.month! == 3)
        XCTAssert(timeLeft.timeLeft.day! == 26)
    }

    func testDisplayString() {
        let birthDate = Date.init(timeIntervalSince1970: 386146800)
        let now2016 = Date.init(timeIntervalSince1970: 1480625478)
        let timeLeft = TimeLeft(now: now2016, lifeExpectancy: 85, birthDate: birthDate)
        XCTAssert(timeLeft.formatTimeLeft() == "50 years, 3 months, 26 days")
    }
}
