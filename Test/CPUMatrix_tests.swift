//
//  CPUMatrix_tests.swift
//
//  Created by Otto Schnurr on 12/14/2015.
//  Copyright © 2015 Otto Schnurr. All rights reserved.
//
//  MIT License
//     file: ../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

import XCTest

class CPUMatrix_tests: XCTestCase {

    var matrix: Matrix! {
        return resizableMatrix
    }
    var resizableMatrix: CPUMatrix!
    
    override func setUp() {
        super.setUp()
        resizableMatrix = CPUMatrix(rowCount: 4, columnCount: 4, countAlignment: 8)
    }
    
    override func tearDown() {
        resizableMatrix = nil
        super.tearDown()
    }
    
    func test_invalidMatrix_isNil() {
        let matrix = CPUMatrix(rowCount: 0, columnCount: 0, countAlignment: 0)
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
            let matrix = CPUMatrix(rowCount: 1, columnCount: columnCount, countAlignment: alignment)!
            XCTAssertEqual(matrix.paddedRowCount, alignment)
            XCTAssertEqual(matrix.paddedColumnCount, alignment)
            XCTAssertEqual(matrix.byteCount, alignment * alignment * MemoryLayout<MatrixElement>.size)
        }
      
        for columnCount in 9...16 {
            let matrix = CPUMatrix(rowCount: 1, columnCount: columnCount, countAlignment: alignment)!
            XCTAssertEqual(matrix.paddedRowCount, alignment)
            XCTAssertEqual(matrix.paddedColumnCount, 2 * alignment)
            XCTAssertEqual(matrix.byteCount, 2 * alignment * alignment * MemoryLayout<MatrixElement>.size)
        }
    }

    func test_matrices_haveExpectedAlignment() {
        let alignment = 8

        for rowCount in 1...5 {
            let matrix = CPUMatrix(rowCount: rowCount, columnCount: 1, countAlignment: alignment)!
            XCTAssertEqual(matrix.paddedRowCount, alignment)
            XCTAssertEqual(matrix.paddedColumnCount, alignment)
            XCTAssertEqual(matrix.byteCount, alignment * alignment * MemoryLayout<MatrixElement>.size)
        }

        for rowCount in 9...16 {
            let matrix = CPUMatrix(rowCount: rowCount, columnCount: 1, countAlignment: alignment)!
            XCTAssertEqual(matrix.paddedRowCount, 2 * alignment)
            XCTAssertEqual(matrix.paddedColumnCount, alignment)
            XCTAssertEqual(matrix.byteCount, 2 * alignment * alignment * MemoryLayout<MatrixElement>.size)
        }
    }

    func test_resizingToInvalidParameters_fails() {
        XCTAssertFalse(resizableMatrix.resizeToRowCount(0, columnCount: 0))
    }

    func test_resizingToValidParameters_succeeds() {
        XCTAssertTrue(resizableMatrix.resizeToRowCount(5, columnCount: 5))
        XCTAssertEqual(matrix.rowCount, 5)
        XCTAssertEqual(matrix.columnCount, 5)
        XCTAssertEqual(matrix.paddedRowCount, 8)
        XCTAssertEqual(matrix.paddedColumnCount, 8)
        XCTAssertFalse(matrix.baseAddress == nil)
    }
    
    func test_resizedMatrices_haveExpectedAlignment() {
        let alignment = 8

        for columnCount in 1...8 {
            resizableMatrix.resizeToRowCount(1, columnCount: columnCount)
            XCTAssertEqual(matrix.paddedRowCount, alignment)
            XCTAssertEqual(matrix.paddedColumnCount, alignment)
            XCTAssertEqual(matrix.byteCount, alignment * alignment * MemoryLayout<MatrixElement>.size)
        }
        
        for columnCount in 9...16 {
            resizableMatrix.resizeToRowCount(1, columnCount: columnCount)
            XCTAssertEqual(matrix.paddedRowCount, alignment)
            XCTAssertEqual(matrix.paddedColumnCount, 2 * alignment)
            XCTAssertEqual(matrix.byteCount, 2 * alignment * alignment * MemoryLayout<MatrixElement>.size)
        }

        for rowCount in 1...5 {
            resizableMatrix.resizeToRowCount(rowCount, columnCount: 1)
            XCTAssertEqual(matrix.paddedRowCount, alignment)
            XCTAssertEqual(matrix.paddedColumnCount, alignment)
            XCTAssertEqual(matrix.byteCount, alignment * alignment * MemoryLayout<MatrixElement>.size)
        }

        for rowCount in 9...16 {
            resizableMatrix.resizeToRowCount(rowCount, columnCount: 1)
            XCTAssertEqual(matrix.paddedRowCount, 2 * alignment)
            XCTAssertEqual(matrix.paddedColumnCount, alignment)
            XCTAssertEqual(matrix.byteCount, 2 * alignment * alignment * MemoryLayout<MatrixElement>.size)
        }
    }
    
}
