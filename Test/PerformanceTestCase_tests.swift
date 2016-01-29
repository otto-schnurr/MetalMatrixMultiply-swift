//
//  PerformanceTestCase_tests.swift
//
//  Created by Otto Schnurr on 1/25/2016.
//  Copyright © 2016 Otto Schnurr. All rights reserved.
//

import XCTest

class PerformanceTestCase_tests: XCTestCase {

    func test_validDimensions_areNotNil() {
        let dimensions = PerformanceTestCase.Dimensions(
            outputRowCount: 4,
            outputColumnCount: 6,
            innerInputDimension: 2
        )
        XCTAssertNotNil(dimensions)
    }

    func test_invalidDimensions_areNil() {
        let dimensions = PerformanceTestCase.Dimensions(
            outputRowCount: 4,
            outputColumnCount: 6,
            innerInputDimension: 0
        )
        XCTAssertNil(dimensions)
    }
    
    func test_dimensions_haveExpectedFlops() {
        let dimensions = PerformanceTestCase.Dimensions(
            outputRowCount: 4,
            outputColumnCount: 6,
            innerInputDimension: 2
        )!
        XCTAssertEqualWithAccuracy(
            dimensions.flops, 2.0 * 4.0 * 6.0 * 2.0, accuracy: 0.001
        )
    }

}
