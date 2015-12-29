//
//  CPUPipeline_tests.swift
//
//  Created by Otto Schnurr on 12/14/2015.
//  Copyright © 2015 Otto Schnurr. All rights reserved.
//
//  MIT License
//     file: ../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

import XCTest

class CPUPipeline_tests: XCTestCase {

    var pipeline: CPUPipeline!
    
    override func setUp() {
        super.setUp()
        pipeline = CPUPipeline()
    }
    
    override func tearDown() {
        pipeline = nil
        super.tearDown()
    }
    
    func test_pipeline_initializesSuccessfully() {
        XCTAssertNotNil(pipeline)
    }
    
}
