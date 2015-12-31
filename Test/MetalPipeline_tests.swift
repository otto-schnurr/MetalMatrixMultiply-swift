//
//  MetalPipeline_tests.swift
//
//  Created by Otto Schnurr on 12/30/15.
//  Copyright © 2015 Otto Schnurr. All rights reserved.
//

import XCTest

class MetalPipeline_tests: XCTestCase {

    var pipeline: MetalPipeline!
    
    override func setUp() {
        super.setUp()
        if let device = _metalDeviceForPipelineTesting {
            pipeline = MetalPipeline(device: device, columnCountAlignment: 8)
        }
    }
    
    override func tearDown() {
        pipeline = nil
        super.tearDown()
    }
    
    func test_pipeline_isAvailable() {
        XCTAssertFalse(pipeline == nil)
    }

    func test_pipelineWithBadAlignment_cannnotBeCreated() {
        let device = _metalDeviceForPipelineTesting!
        let pipeline = MetalPipeline(device: device, columnCountAlignment: 0)
        XCTAssertTrue(pipeline == nil)
    }

    func test_pipeline_vendsValidMatrix() {
        let matrix = pipeline.newMatrixWithRowCount(4, columnCount: 4)
        XCTAssertFalse(matrix == nil)
    }
    
    func test_pipeline_doesNotVendInvalidMatrix() {
        let matrix = pipeline.newMatrixWithRowCount(0, columnCount: 4)
        XCTAssertTrue(matrix == nil)
    }
    
}


// MARK: - Private

// critical: Creating a Metal pipeline more than once with a discrete GPU
//           appears to cause a kernel panic on OSX. Using the integrated
//           device for testing when available.
private var _metalDeviceForPipelineTesting: MTLDevice? = {
#if os(OSX)
    if let device = MTLCopyAllDevices().filter({ $0.lowPower }).first {
        return device
    }
#endif

    return MTLCreateSystemDefaultDevice()
}()
