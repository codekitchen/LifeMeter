//
//  LifeMeterTests.swift
//  LifeMeterTests
//
//  Created by Brian Palmer on 11/19/16.
//  Copyright © 2016 Brian Palmer. All rights reserved.
//

import XCTest
@testable import LifeMeter

class LifeMeterTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        let birthDate = Date.init(timeIntervalSince1970: 386146800)
        let now2016 = Date.init(timeIntervalSince1970: 1480625478)
        let timeLeft = TimeLeft(now: now2016, lifeExpectancy: 85, birthDate: birthDate)
        XCTAssert(timeLeft.pctLeft >= 0.59 && timeLeft.pctLeft < 0.60)
    }
}
