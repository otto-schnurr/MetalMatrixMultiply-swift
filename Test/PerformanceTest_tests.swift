//
//  PerformanceTest_tests.swift
//
//  Created by Otto Schnurr on 2/4/2016.
//  Copyright © 2016 Otto Schnurr. All rights reserved.
//
//  MIT License
//     file: ../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

import XCTest

class PerformanceTest_tests: XCTestCase {

    func test_invalidTest_isNil() {
        let device = metalDeviceForTesting!
        let test = PerformanceTest(device: device, testCount: 0, loopsPerTest: 0)
        XCTAssertNil(test)
    }
    
    func test_validTest_isNotNil() {
        let device = metalDeviceForTesting!
        let test = PerformanceTest(device: device, testCount: 20, loopsPerTest: 100)
        XCTAssertNotNil(test)
    }

    func test_defaultTest_isNotNil() {
        let device = metalDeviceForTesting!
        let test = PerformanceTest(device: device)
        XCTAssertNotNil(test)
    }

    func test_validTest_completesSuccessfully() {
        let device = metalDeviceForTesting!
        let test = PerformanceTest(device: device, testCount: 2, loopsPerTest: 2)!
        let expectation = expectationWithDescription("complete performance test")

        test.runAsync { success in
            XCTAssertTrue(success)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(60) { error in XCTAssertNil(error) }
    }

}
