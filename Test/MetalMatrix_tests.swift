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
        return resizableMatrix
    }
    var resizableMatrix: MetalMatrix!

    override func setUp() {
        super.setUp()
        device = metalDeviceForTesting
        guard device != nil else {
            XCTFail("Failed to acquire Metal device.")
            return
        }
        
        resizableMatrix = MetalMatrix(
            rowCount: 4, columnCount: 4, countAlignment: 8, device: device
        )
    }

    override func tearDown() {
        resizableMatrix = nil
        device = nil
        super.tearDown()
    }

    func test_metalDevice_isAvailable() {
        XCTAssertFalse(device == nil)
    }

    func test_invalidMatrix_isNil() {
        let matrix = MetalMatrix(
            rowCount: 0, columnCount: 0, countAlignment: 0, device: device
        )
        XCTAssertNil(matrix)
    }
    
    func test_validMatrix_isNotNil() {
        XCTAssertNotNil(matrix)
        XCTAssertNotNil(resizableMatrix)
    }

    func test_matrices_havePointers() {
        XCTAssertFalse(matrix.baseAddress == nil)
    }
    
    func test_matrixRows_haveExpectedAlignment() {
        let alignment = 8

        for columnCount in 1...8 {
            let matrix = MetalMatrix(rowCount: 1, columnCount: columnCount, countAlignment: alignment, device: device)!
            XCTAssertEqual(matrix.paddedRowCount, alignment)
            XCTAssertEqual(matrix.paddedColumnCount, alignment)
            XCTAssertEqual(matrix.byteCount, alignment * alignment * MemoryLayout<MatrixElement>.size)
        }
      
        for columnCount in 9...16 {
            let matrix = MetalMatrix(rowCount: 1, columnCount: columnCount, countAlignment: alignment, device: device)!
            XCTAssertEqual(matrix.paddedRowCount, alignment)
            XCTAssertEqual(matrix.paddedColumnCount, 2 * alignment)
            XCTAssertEqual(matrix.byteCount, 2 * alignment * alignment * MemoryLayout<MatrixElement>.size)
        }
    }

    func test_matrices_haveExpectedAlignment() {
        let alignment = 8

        for rowCount in 1...5 {
            let matrix = MetalMatrix(rowCount: rowCount, columnCount: 1, countAlignment: alignment, device: device)!
            XCTAssertEqual(matrix.paddedRowCount, alignment)
            XCTAssertEqual(matrix.paddedColumnCount, alignment)
            XCTAssertEqual(matrix.byteCount, alignment * alignment * MemoryLayout<MatrixElement>.size)
        }

        for rowCount in 9...16 {
            let matrix = MetalMatrix(rowCount: rowCount, columnCount: 1, countAlignment: alignment, device: device)!
            XCTAssertEqual(matrix.paddedRowCount, 2 * alignment)
            XCTAssertEqual(matrix.paddedColumnCount, alignment)
            XCTAssertEqual(matrix.byteCount, 2 * alignment * alignment * MemoryLayout<MatrixElement>.size)
        }
    }

    func test_resizingToInvalidParameters_fails() {
        XCTAssertFalse(resizableMatrix.resizeTo(rowCount: 0, columnCount: 0))
    }

    func test_resizingToValidParameters_succeeds() {
        XCTAssertTrue(resizableMatrix.resizeTo(rowCount: 5, columnCount: 5))
        XCTAssertEqual(matrix.rowCount, 5)
        XCTAssertEqual(matrix.columnCount, 5)
        XCTAssertEqual(matrix.paddedRowCount, 8)
        XCTAssertEqual(matrix.paddedColumnCount, 8)
        XCTAssertFalse(matrix.baseAddress == nil)
    }
    
    func test_resizedMatrices_haveExpectedAlignment() {
        let alignment = 8

        for columnCount in 1...8 {
            XCTAssert(resizableMatrix.resizeTo(rowCount: 1, columnCount: columnCount))
            XCTAssertEqual(matrix.paddedRowCount, alignment)
            XCTAssertEqual(matrix.paddedColumnCount, alignment)
            XCTAssertEqual(matrix.byteCount, alignment * alignment * MemoryLayout<MatrixElement>.size)
        }
        
        for columnCount in 9...16 {
            XCTAssert(resizableMatrix.resizeTo(rowCount: 1, columnCount: columnCount))
            XCTAssertEqual(matrix.paddedRowCount, alignment)
            XCTAssertEqual(matrix.paddedColumnCount, 2 * alignment)
            XCTAssertEqual(matrix.byteCount, 2 * alignment * alignment * MemoryLayout<MatrixElement>.size)
        }

        for rowCount in 1...5 {
            XCTAssert(resizableMatrix.resizeTo(rowCount: rowCount, columnCount: 1))
            XCTAssertEqual(matrix.paddedRowCount, alignment)
            XCTAssertEqual(matrix.paddedColumnCount, alignment)
            XCTAssertEqual(matrix.byteCount, alignment * alignment * MemoryLayout<MatrixElement>.size)
        }

        for rowCount in 9...16 {
            XCTAssert(resizableMatrix.resizeTo(rowCount: rowCount, columnCount: 1))
            XCTAssertEqual(matrix.paddedRowCount, 2 * alignment)
            XCTAssertEqual(matrix.paddedColumnCount, alignment)
            XCTAssertEqual(matrix.byteCount, 2 * alignment * alignment * MemoryLayout<MatrixElement>.size)
        }
    }

}
