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
        let inputA = CPUMatrix(rowCount: 2, columnCount: 4, alignment: 8)!
        let inputB = CPUMatrix(rowCount: 2, columnCount: 6, alignment: 8)!
        let output = CPUMatrix(rowCount: 5, columnCount: 6, alignment: 8)!
        let badData = TestData(inputA: inputA, inputB: inputB, output: output)
        
        do {
            try CPUPipeline.multiply(badData)
            XCTFail("Multiplied matrices with bad output dimensions.")
        } catch PipelineError.invalidOutputDimensions {
        } catch {
            XCTFail("Failed to report bad output dimensions.")
        }
    }
    
    func test_invalidRepeatCount_failsToMultiply() {
        let inputA = CPUMatrix(rowCount: 2, columnCount: 4, alignment: 8)!
        let inputB = CPUMatrix(rowCount: 2, columnCount: 6, alignment: 8)!
        let output = CPUMatrix(rowCount: 4, columnCount: 6, alignment: 8)!
        let data = TestData(inputA: inputA, inputB: inputB, output: output)
        
        do {
            try CPUPipeline.multiply(data, repeatCount: -1)
            XCTFail("Multiplied matrices with bad repeat count.")
        } catch PipelineError.invalidRepeatCount {
        } catch {
            XCTFail("Failed to report bad repeat count.")
        }
    }
    
    func test_successfulMultiplication_hasExpectedOutput() {
        let inputA = CPUMatrix(rowCount: 2, columnCount: 2, alignment: 8)!
        let inputB = CPUMatrix(rowCount: 2, columnCount: 2, alignment: 8)!
        let output = CPUMatrix(rowCount: 2, columnCount: 2, alignment: 8)!
        let data = TestData(inputA: inputA, inputB: inputB, output: output)
        
        let firstRowA = inputA.baseAddress!
        let secondRowA = firstRowA + inputA.paddedColumnCount
        firstRowA[0] = 1.0
        firstRowA[1] = 2.0
        secondRowA[0] = 3.0
        secondRowA[1] = 4.0
        
        let firstRowB = inputB.baseAddress!
        let secondRowB = firstRowB + inputB.paddedColumnCount
        firstRowB[0] = 5.0
        firstRowB[1] = 6.0
        secondRowB[0] = 7.0
        secondRowB[1] = 8.0

        do {
            try CPUPipeline.multiply(data)

            let epsilon = MatrixElement(0.000001)
            let firstRow = output.baseAddress!
            let secondRow = firstRow + output.paddedColumnCount

            XCTAssertEqualWithAccuracy(firstRow[0], 26.0, accuracy: epsilon)
            XCTAssertEqualWithAccuracy(firstRow[1], 30.0, accuracy: epsilon)
            XCTAssertEqualWithAccuracy(secondRow[0], 38.0, accuracy: epsilon)
            XCTAssertEqualWithAccuracy(secondRow[1], 44.0, accuracy: epsilon)
        } catch {
            XCTFail("Failed to multiply matrices.")
        }
    }

}


// MARK: - Private
private struct TestData: MultiplicationData {
    
    typealias MatrixType = BufferedMatrix
    
    let inputA: MatrixType
    let inputB: MatrixType
    let output: MatrixType
    
}
