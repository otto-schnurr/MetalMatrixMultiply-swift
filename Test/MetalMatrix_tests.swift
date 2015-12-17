//
//  MetalMatrix_tests.swift
//
//  Created by Otto Schnurr on 12/17/2015.
//  Copyright © 2015 Otto Schnurr. All rights reserved.
//
//  MIT License
//     file: ../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

import Metal.MTLDevice
import XCTest

class MetalMatrix_tests: XCTestCase {

    var device: MTLDevice!
    var matrix: MetalMatrix!

    override func setUp() {
        super.setUp()
        device = MTLCreateSystemDefaultDevice()
        guard device != nil else {
            XCTFail("Failed to acquire Metal device.")
            return
        }
        
        matrix = MetalMatrix(
            rowCount: 4, columnCount: 4, columnCountAlignment: 8, device: device
        )
    }

    override func tearDown() {
        device = nil
        super.tearDown()
    }

    func test_metalDevice_isAvailable() {
        XCTAssertFalse(device == nil)
    }

    func test_invalidMatrix_isNil() {
        let matrix = MetalMatrix(
            rowCount: 0, columnCount: 0, columnCountAlignment: 0, device: device
        )
        XCTAssertNil(matrix)
    }
    
    func test_validMatrix_isNotNil() {
        XCTAssertNotNil(matrix)
    }

}
