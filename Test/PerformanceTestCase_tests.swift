//
//  PerformanceTestCase_tests.swift
//
//  Created by Otto Schnurr on 1/25/2016.
//  Copyright © 2016 Otto Schnurr. All rights reserved.
//
//  MIT License
//     file: ../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

import XCTest

class PerformanceTestCase_tests: XCTestCase {

    var resources: PerformanceTestCase.Resources!
    
    override func setUp() {
        super.setUp()
        if let device = metalDeviceForTesting {
            resources = _createResources(for: device, dimensionCapacity: 16)
        }
    }
    
    override func tearDown() {
        resources = nil
        super.tearDown()
    }

    func test_resources_areAvailable() {
        XCTAssertFalse(resources == nil)
    }

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
    
    func test_dimensions_haveExpectedOperationCount() {
        let dimensions = PerformanceTestCase.Dimensions(
            outputRowCount: 4,
            outputColumnCount: 6,
            innerInputDimension: 2
        )!
        XCTAssertEqual(dimensions.operationCount, 2 * 4 * 6 * 2)
    }

    func test_currentResourceSize_runsSuccessfully() {
        let dimensions = PerformanceTestCase.Dimensions(
            outputRowCount: resources.inputA.columnCount,
            outputColumnCount: resources.inputB.columnCount,
            innerInputDimension: resources.inputB.rowCount
        )!
        let testCase = PerformanceTestCase(
            targetDimensions: dimensions,
            resources: resources
        )
        
        do {
            let results = try testCase.run()
            XCTAssertGreaterThan(results.cpuTime, 0.0)
            XCTAssertGreaterThan(results.metalTime, 0.0)
        } catch { XCTFail("Failed to invoke test case.") }
    }
    
    func test_smallerTargetSize_runsSuccessfully() {
        let dimensions = PerformanceTestCase.Dimensions(
            outputRowCount: resources.inputA.columnCount / 2,
            outputColumnCount: resources.inputB.columnCount / 2,
            innerInputDimension: resources.inputB.rowCount / 2
        )!
        let testCase = PerformanceTestCase(
            targetDimensions: dimensions,
            resources: resources
        )

        do {
            let results = try testCase.run()
            XCTAssertGreaterThan(results.cpuTime, 0.0)
            XCTAssertGreaterThan(results.metalTime, 0.0)
        } catch { XCTFail("Failed to invoke test case.") }
    }
    
    func test_largerTargetSize_runsSuccessfully() {
        let dimensions = PerformanceTestCase.Dimensions(
            outputRowCount: resources.inputA.columnCount * 40,
            outputColumnCount: resources.inputB.columnCount * 80,
            innerInputDimension: resources.inputB.rowCount * 40
        )!
        let testCase = PerformanceTestCase(
            targetDimensions: dimensions,
            resources: resources
        )

        do {
            let results = try testCase.run()
            XCTAssertGreaterThan(results.cpuTime, 0.0)
            XCTAssertGreaterThan(results.metalTime, 0.0)
        } catch { XCTFail("Failed to invoke test case.") }
    }
    
    func test_validRepeatCount_runsSuccessfully() {
        let dimensions = PerformanceTestCase.Dimensions(
            outputRowCount: resources.inputA.columnCount,
            outputColumnCount: resources.inputB.columnCount,
            innerInputDimension: resources.inputB.rowCount
        )!
        let testCase = PerformanceTestCase(
            targetDimensions: dimensions,
            resources: resources
        )
        
        do {
            let results = try testCase.run(repeatCount: 5)
            XCTAssertGreaterThan(results.cpuTime, 0.0)
            XCTAssertGreaterThan(results.metalTime, 0.0)
        } catch { XCTFail("Failed to invoke test case.") }
    }
    
}


// MARK: - Private

private func _createResources(
    for device: MTLDevice, dimensionCapacity n: Int
) -> PerformanceTestCase.Resources? {
    guard
        let pipeline = MetalPipeline(device: device, countAlignment: 8),
        let inputA = pipeline.createMatrix(rowCount: n, columnCount: n),
        let inputB = pipeline.createMatrix(rowCount: n, columnCount: n),
        let metalOutput = pipeline.createMatrix(rowCount: n, columnCount: n),
        let cpuOutput = CPUMatrix(rowCount: n, columnCount: n, countAlignment: 8)
    else { return nil }
    
    return PerformanceTestCase.Resources(
        metalPipeline: pipeline,
        inputA: inputA, inputB: inputB,
        metalOutput: metalOutput, cpuOutput: cpuOutput
    )
}
