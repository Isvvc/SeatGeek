//
//  SeatGeekTests.swift
//  SeatGeekTests
//
//  Created by Elaine Lyons on 8/6/21.
//

import XCTest
import SwiftyJSON
@testable import SeatGeek

class SeatGeekTests: XCTestCase {
    
    var seatGeekController = SeatGeekController(testing: true)
    var demoEventJSON = JSON()
    
    override func setUpWithError() throws {
        // Load the demo event JSON
        let preloadDataURL = Bundle(for: type(of: self)).url(forResource: "DemoEvent", withExtension: "json")!
        let demoEventJSONData = try Data(contentsOf: preloadDataURL)
        demoEventJSON = try JSON(data: demoEventJSONData)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    /// Test that Events can be created from JSON
    func testCreateEvent() {
        let event = Event(json: demoEventJSON, context: seatGeekController.moc)
        XCTAssertNotNil(event)
        XCTAssertEqual(event?.title, "Young The Giant with Grouplove")
        if let date = event?.date {
            XCTAssertEqual(SeatGeekController.dateFormatter.string(from: date), "2012-03-10T00:00:00")
        } else {
            XCTFail("No date in Event")
        }
        XCTAssertEqual(event?.image?.absoluteString, "https://chairnerd.global.ssl.fastly.net/images/bandshuge/band_8741.jpg")
    }

    func testGetEvents() {
        let expectation = XCTestExpectation(description: "Get events")
        
        seatGeekController.getEvents { events, error in
            XCTAssertNil(error)
            XCTAssertNotNil(events)
            XCTAssertFalse(events?.isEmpty ?? true)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testSearchEvents() {
        let expectation = XCTestExpectation(description: "Search events")
        
        seatGeekController.getEvents { [unowned self] events, error in
            XCTAssertNil(error)
            XCTAssertNotNil(events)
            XCTAssertFalse(events?.isEmpty ?? true)
            
            seatGeekController.getEvents(search: "boston") { searchEvents, error in
                XCTAssertNil(error)
                XCTAssertNotNil(searchEvents)
                XCTAssertFalse(searchEvents?.isEmpty ?? true)
                // Check that the search worked and the results are not the same
                XCTAssertNotEqual(searchEvents, events)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1000.0)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
