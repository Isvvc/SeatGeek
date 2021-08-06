//
//  SeatGeekTests.swift
//  SeatGeekTests
//
//  Created by Elaine Lyons on 8/6/21.
//

import XCTest
@testable import SeatGeek

class SeatGeekTests: XCTestCase {
    
    var seatGeekController = SeatGeekController()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetEvents() throws {
        seatGeekController.getEvents { json, error in
            XCTAssertNil(error)
            XCTAssertNotNil(json)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
