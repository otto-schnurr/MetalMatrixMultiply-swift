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

    func test_invalidMatrices_failToMultiply() {
        let inputA = CPUMatrix(rowCount: 2, columnCount: 4, countAlignment: 8)!
        let inputB = CPUMatrix(rowCount: 2, columnCount: 6, countAlignment: 8)!
        let output = CPUMatrix(rowCount: 5, columnCount: 6, countAlignment: 8)!
        let badData = MultiplicationData(inputA: inputA, inputB: inputB, output: output)
        
        do {
            try CPUPipeline.multiplyData(badData)
            XCTFail("Multiplied matrices with bad output dimensions.")
        } catch PipelineError.InvalidOutputDimensions {
        } catch {
            XCTFail("Failed to report bad output dimensions.")
        }
    }
    
    func test_invalidRepeatCount_failsToMultiply() {
        let inputA = CPUMatrix(rowCount: 2, columnCount: 4, countAlignment: 8)!
        let inputB = CPUMatrix(rowCount: 2, columnCount: 6, countAlignment: 8)!
        let output = CPUMatrix(rowCount: 4, columnCount: 6, countAlignment: 8)!
        let data = MultiplicationData(inputA: inputA, inputB: inputB, output: output)
        
        do {
            try CPUPipeline.multiplyData(data, repeatCount: -1)
            XCTFail("Multiplied matrices with bad repeat count.")
        } catch PipelineError.InvalidRepeatCount {
        } catch {
            XCTFail("Failed to report bad repeat count.")
        }
    }
    
    func test_successfulMultiplication_hasExpectedOutput() {
        let inputA = CPUMatrix(rowCount: 2, columnCount: 2, countAlignment: 8)!
        let inputB = CPUMatrix(rowCount: 2, columnCount: 2, countAlignment: 8)!
        let output = CPUMatrix(rowCount: 2, columnCount: 2, countAlignment: 8)!
        let data = MultiplicationData(inputA: inputA, inputB: inputB, output: output)
        
        let firstRowA = inputA.baseAddress
        let secondRowA = inputA.baseAddress + inputA.paddedColumnCount
        firstRowA[0] = 1.0
        firstRowA[1] = 2.0
        secondRowA[0] = 3.0
        secondRowA[1] = 4.0
        
        let firstRowB = inputB.baseAddress
        let secondRowB = inputB.baseAddress + inputB.paddedColumnCount
        firstRowB[0] = 5.0
        firstRowB[1] = 6.0
        secondRowB[0] = 7.0
        secondRowB[1] = 8.0

        do {
            try CPUPipeline.multiplyData(data)

            let epsilon = MatrixElement(0.000001)
            let firstRow = output.baseAddress
            let secondRow = output.baseAddress + output.paddedColumnCount

            XCTAssertEqualWithAccuracy(firstRow[0], 26.0, accuracy: epsilon)
            XCTAssertEqualWithAccuracy(firstRow[1], 30.0, accuracy: epsilon)
            XCTAssertEqualWithAccuracy(secondRow[0], 38.0, accuracy: epsilon)
            XCTAssertEqualWithAccuracy(secondRow[1], 44.0, accuracy: epsilon)
        } catch {
            XCTFail("Failed to multiply matrices.")
        }
    }

}
