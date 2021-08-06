//
//  SeatGeekTests.swift
//  SeatGeekTests
//
//  Created by Elaine Lyons on 8/6/21.
//

import XCTest
@testable import SeatGeek

class SeatGeekTests: XCTestCase {
    
    var seatGeekController = SeatGeekController(testing: true)

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetEvents() throws {
        let expectation = XCTestExpectation(description: "Get events")
        
        seatGeekController.getEvents { events, error in
            XCTAssertNil(error)
            XCTAssertNotNil(events)
            XCTAssertFalse(events?.isEmpty ?? true)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
