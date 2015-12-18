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

    var matrix: PaddedMatrix! {
        return mutableMatrix
    }
    var mutableMatrix: CPUMatrix!
    
    override func setUp() {
        super.setUp()
        mutableMatrix = CPUMatrix(rowCount: 4, columnCount: 4, columnCountAlignment: 8)
    }
    
    override func tearDown() {
        mutableMatrix = nil
        super.tearDown()
    }
    
    func test_invalidMatrix_isNil() {
        let matrix = CPUMatrix(rowCount: 0, columnCount: 0, columnCountAlignment: 0)
        XCTAssertNil(matrix)
    }
    
    func test_validMatrix_isNotNil() {
        XCTAssertNotNil(matrix)
        XCTAssertNotNil(mutableMatrix)
    }

    func test_matrices_havePointers() {
        XCTAssertFalse(matrix.baseAddress == nil)
    }

    func test_matrixRows_haveExpectedAlignment() {
        let alignment = 8

        for columnCount in 1...8 {
            let matrix = CPUMatrix(rowCount: 1, columnCount: columnCount, columnCountAlignment: alignment)!
            XCTAssertEqual(matrix.bytesPerRow, alignment * sizeof(Float32))
            XCTAssertEqual(matrix.byteCount, alignment * sizeof(Float32))
        }
      
        for columnCount in 9...16 {
            let matrix = CPUMatrix(rowCount: 1, columnCount: columnCount, columnCountAlignment: alignment)!
            XCTAssertEqual(matrix.bytesPerRow, 2 * alignment * sizeof(Float32))
            XCTAssertEqual(matrix.byteCount, 2 * alignment * sizeof(Float32))
        }
    }

    func test_matrices_haveExpectedAlignment() {
        let alignment = 8

        for rowCount in 1...5 {
            let matrix = CPUMatrix(rowCount: rowCount, columnCount: 1, columnCountAlignment: alignment)!
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
