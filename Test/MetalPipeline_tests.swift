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
        if let device = MTLCreateSystemDefaultDevice() {
            pipeline = MetalPipeline(device: device, columnCountAlignment: 8)
        }
    }
    
    override func tearDown() {
        pipeline = nil
        super.tearDown()
    }
    
    func test_pipeline_isAvailable() {
        XCTAssertNotNil(pipeline)
    }

    func test_pipelineWithBadAlignment_cannnotBeCreated() {
        let device = MTLCreateSystemDefaultDevice()!
        let pipeline = MetalPipeline(device: device, columnCountAlignment: 0)
        XCTAssertTrue(pipeline == nil)
    }

}
