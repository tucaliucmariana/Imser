//
//  ImageBrowserTests.swift
//  ImageBrowserTests
//
//  Created by Mariana TUCALIUC on 02.02.2023.
//

import XCTest
@testable import ImageBrowser

final class ImageBrowserTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testConversionForTwo() {
      let result = 2 + 2
      XCTAssertEqual(result, 4)
    }
    
    func testConversionForOne() {
      let result = 1 + 1
      XCTAssertEqual(result, 2)
    }

}
