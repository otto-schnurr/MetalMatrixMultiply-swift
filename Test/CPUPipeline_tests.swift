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
    
    func test_pipeline_vendsValidMatrix() {
        let matrix = pipeline.newMatrixWithRowCount(4, columnCount: 4)
        XCTAssertFalse(matrix == nil)
    }
    
    func test_pipeline_doesNotVendInvalidMatrix() {
        let matrix = pipeline.newMatrixWithRowCount(0, columnCount: 4)
        XCTAssertTrue(matrix == nil)
    }
    
    func test_invalidMatrices_failToMultiply() {
        let inputA = CPUMatrix(rowCount: 2, columnCount: 4, columnCountAlignment: 8)!
        let inputB = CPUMatrix(rowCount: 3, columnCount: 6, columnCountAlignment: 8)!
        let output = CPUMatrix(rowCount: 5, columnCount: 6, columnCountAlignment: 8)!
        let data = MultiplicationData(inputA: inputA, inputB: inputB, output: output)
        
        let expectation = expectationWithDescription("multiplication completed")

        pipeline.multiplyAsync(data, repeatCount: 1) { success in
            XCTAssertFalse(success)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1.0) { error in XCTAssertNil(error) }
    }
    
    func test_invalidRepeatCount_failsToMultiply() {
        let inputA = CPUMatrix(rowCount: 2, columnCount: 4, columnCountAlignment: 8)!
        let inputB = CPUMatrix(rowCount: 3, columnCount: 6, columnCountAlignment: 8)!
        let output = CPUMatrix(rowCount: 4, columnCount: 6, columnCountAlignment: 8)!
        let data = MultiplicationData(inputA: inputA, inputB: inputB, output: output)
        
        let expectation = expectationWithDescription("multiplication completed")
        
        pipeline.multiplyAsync(data, repeatCount: -1) { success in
            XCTAssertFalse(success)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0) { error in XCTAssertNil(error) }
    }
    
    func test_successfulMultiplication_hasExpectedOutput() {
        let inputA = CPUMatrix(rowCount: 2, columnCount: 2, columnCountAlignment: 8)!
        let inputB = CPUMatrix(rowCount: 2, columnCount: 2, columnCountAlignment: 8)!
        let output = CPUMatrix(rowCount: 2, columnCount: 2, columnCountAlignment: 8)!
        let data = MultiplicationData(inputA: inputA, inputB: inputB, output: output)
        
        let firstRowA = inputA.baseAddress
        firstRowA[0] = 1.0
        firstRowA[1] = 2.0
        let secondRowA = inputA.baseAddress + inputA.bytesPerRow / sizeof(MatrixElement)
        secondRowA[0] = 3.0
        secondRowA[1] = 4.0
        
        let firstRowB = inputB.baseAddress
        firstRowB[0] = 5.0
        firstRowB[1] = 6.0
        let secondRowB = inputB.baseAddress + inputB.bytesPerRow / sizeof(MatrixElement)
        secondRowB[0] = 7.0
        secondRowB[1] = 8.0

        let expectation = expectationWithDescription("multiplication completed")
        
        pipeline.multiplyAsync(data, repeatCount: 0) { success in
            XCTAssertTrue(success)
            let epsilon = MatrixElement(0.000001)
            
            let firstRow = output.baseAddress
            XCTAssertEqualWithAccuracy(firstRow[0], 26.0, accuracy: epsilon)
            XCTAssertEqualWithAccuracy(firstRow[1], 30.0, accuracy: epsilon)
            let secondRow = output.baseAddress + output.bytesPerRow / sizeof(MatrixElement)
            XCTAssertEqualWithAccuracy(secondRow[0], 38.0, accuracy: epsilon)
            XCTAssertEqualWithAccuracy(secondRow[1], 44.0, accuracy: epsilon)
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0) { error in XCTAssertNil(error) }
    }
}
