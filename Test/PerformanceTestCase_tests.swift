//
//  PerformanceTestCase_tests.swift
//
//  Created by Otto Schnurr on 1/25/2016.
//  Copyright © 2016 Otto Schnurr. All rights reserved.
//

import XCTest

class PerformanceTestCase_tests: XCTestCase {

    var resources: PerformanceTestCase.Resources!
    
    override func setUp() {
        super.setUp()
        if let device = _metalDeviceForTesting {
            resources = _createResourcesForDevice(device, dimensionCapacity: 16)
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


// MARK: - Private

// critical: Creating a Metal pipeline more than once with a discrete GPU
//           appears to cause a kernel panic on OSX. Using the integrated
//           device for testing when available.
private var _metalDeviceForTesting: MTLDevice? = {
#if os(OSX)
    if let device = MTLCopyAllDevices().filter({ $0.lowPower }).first {
        return device
    }
#endif
    
    return MTLCreateSystemDefaultDevice()
}()

private func _createResourcesForDevice(
    device: MTLDevice, dimensionCapacity n: Int
) -> PerformanceTestCase.Resources? {
    guard
        let pipeline = MetalPipeline(device: device, countAlignment: 8),
        inputA = pipeline.newMatrixWithRowCount(n, columnCount: n),
        inputB = pipeline.newMatrixWithRowCount(n, columnCount: n),
        metalOutput = pipeline.newMatrixWithRowCount(n, columnCount: n),
        cpuOutput = CPUMatrix(rowCount: n, columnCount: n, countAlignment: 8)
    else { return nil }
    
    return PerformanceTestCase.Resources(
        inputA: inputA, inputB: inputB,
        metalOutput: metalOutput, cpuOutput: cpuOutput
    )
}
