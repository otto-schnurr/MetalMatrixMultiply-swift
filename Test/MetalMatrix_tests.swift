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
    var matrix: Matrix! {
        return mutableMatrix
    }
    var mutableMatrix: MetalMatrix!

    override func setUp() {
        super.setUp()
        device = MTLCreateSystemDefaultDevice()
        guard device != nil else {
            XCTFail("Failed to acquire Metal device.")
            return
        }
        
        mutableMatrix = MetalMatrix(
            rowCount: 4, columnCount: 4, columnCountAlignment: 8, device: device
        )
    }

    override func tearDown() {
        mutableMatrix = nil
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
        XCTAssertNotNil(mutableMatrix)
    }

    func test_matrices_havePointers() {
        XCTAssertFalse(matrix.baseAddress == nil)
        XCTAssertFalse(mutableMatrix.mutableBaseAddress == nil)
    }
    
    func test_matrixRows_haveExpectedAlignment() {
        let alignment = 8

        for columnCount in 1...8 {
            let matrix = MetalMatrix(rowCount: 1, columnCount: columnCount, columnCountAlignment: alignment, device: device)!
            XCTAssertEqual(matrix.bytesPerRow, alignment * sizeof(Float32))
            XCTAssertEqual(matrix.byteCount, alignment * sizeof(Float32))
        }
      
        for columnCount in 9...16 {
            let matrix = MetalMatrix(rowCount: 1, columnCount: columnCount, columnCountAlignment: alignment, device: device)!
            XCTAssertEqual(matrix.bytesPerRow, 2 * alignment * sizeof(Float32))
            XCTAssertEqual(matrix.byteCount, 2 * alignment * sizeof(Float32))
        }
    }

    func test_matrices_haveExpectedAlignment() {
        let alignment = 8

        for rowCount in 1...5 {
            let matrix = MetalMatrix(rowCount: rowCount, columnCount: 1, columnCountAlignment: alignment, device: device)!
            XCTAssertEqual(matrix.bytesPerRow, alignment * sizeof(Float32))
            XCTAssertEqual(matrix.byteCount, rowCount * alignment * sizeof(Float32))
        }
    }

    func test_resizingToInvalidParameters_fails() {
        XCTAssertFalse(mutableMatrix.resizeToRowCount(0, columnCount: 0))
    }

    func test_resizingToValidParameters_succeeds() {
        XCTAssertTrue(mutableMatrix.resizeToRowCount(5, columnCount: 5))
        XCTAssertEqual(matrix.rowCount, 5)
        XCTAssertEqual(matrix.columnCount, 5)
        XCTAssertEqual(matrix.bytesPerRow, 8 * sizeof(Float32))
        XCTAssertFalse(matrix.baseAddress == nil)
    }
    
    func test_resizedMatrices_haveExpectedAlignment() {
        let alignment = 8

        for columnCount in 1...8 {
            mutableMatrix.resizeToRowCount(1, columnCount: columnCount)
            XCTAssertEqual(matrix.bytesPerRow, alignment * sizeof(Float32))
            XCTAssertEqual(matrix.byteCount, alignment * sizeof(Float32))
        }
        
        for columnCount in 9...16 {
            mutableMatrix.resizeToRowCount(1, columnCount: columnCount)
            XCTAssertEqual(matrix.bytesPerRow, 2 * alignment * sizeof(Float32))
            XCTAssertEqual(matrix.byteCount, 2 * alignment * sizeof(Float32))
        }

        for rowCount in 1...5 {
            mutableMatrix.resizeToRowCount(rowCount, columnCount: 1)
            XCTAssertEqual(matrix.bytesPerRow, alignment * sizeof(Float32))
            XCTAssertEqual(matrix.byteCount, rowCount * alignment * sizeof(Float32))
        }
    }

}
