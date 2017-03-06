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
        if let device = metalDeviceForTesting {
            pipeline = MetalPipeline(device: device, countAlignment: 8)
        }
    }
    
    override func tearDown() {
        pipeline = nil
        super.tearDown()
    }
    
    func test_pipeline_isAvailable() {
        XCTAssertFalse(pipeline == nil)
    }

    func test_pipelineWithBadAlignment_cannnotBeCreated() {
        let device = metalDeviceForTesting!
        let pipeline = MetalPipeline(device: device, countAlignment: 0)
        XCTAssertTrue(pipeline == nil)
    }

    func test_pipeline_vendsValidMatrix() {
        let matrix = pipeline.createMatrix(rowCount: 4, columnCount: 4)
        XCTAssertFalse(matrix == nil)
    }
    
    func test_pipeline_doesNotVendInvalidMatrix() {
        let matrix = pipeline.createMatrix(rowCount: 0, columnCount: 4)
        XCTAssertTrue(matrix == nil)
    }
    
    func test_invalidMatrices_failToMultiply() {
        let inputA = pipeline.createMatrix(rowCount: 2, columnCount: 4)!
        let inputB = pipeline.createMatrix(rowCount: 2, columnCount: 6)!
        let output = pipeline.createMatrix(rowCount: 5, columnCount: 6)!
        let badData = MetalData(inputA: inputA, inputB: inputB, output: output)
        
        do {
            try pipeline.multiply(badData)
            XCTFail("Multiplied matrices with bad output dimensions.")
        } catch PipelineError.invalidOutputDimensions {
        } catch {
            XCTFail("Failed to report bad output dimensions.")
        }
    }
    
    func test_invalidRepeatCount_failsToMultiply() {
        let inputA = pipeline.createMatrix(rowCount: 2, columnCount: 4)!
        let inputB = pipeline.createMatrix(rowCount: 2, columnCount: 6)!
        let output = pipeline.createMatrix(rowCount: 4, columnCount: 6)!
        let data = MetalData(inputA: inputA, inputB: inputB, output: output)
        
        do {
            try pipeline.multiply(data, repeatCount: -1)
            XCTFail("Multiplied matrices with bad repeat count.")
        } catch PipelineError.invalidRepeatCount {
        } catch {
            XCTFail("Failed to report bad repeat count.")
        }
    }
    
    func test_incompatibleDevice_failsToMultiply() {
        let defaultDevice = MTLCreateSystemDefaultDevice()!
        let canCreateIncompatibleDevice =
            Unmanaged.passUnretained(defaultDevice).toOpaque() != Unmanaged.passUnretained(pipeline.device).toOpaque()
        guard canCreateIncompatibleDevice else { return }
        
        let inputA = MetalMatrix(rowCount: 2, columnCount: 4, countAlignment: 8, device: defaultDevice)!
        let inputB = MetalMatrix(rowCount: 2, columnCount: 6, countAlignment: 8, device: defaultDevice)!
        let output = MetalMatrix(rowCount: 4, columnCount: 6, countAlignment: 8, device: defaultDevice)!
        let data = MetalData(inputA: inputA, inputB: inputB, output: output)
        
        do {
            try pipeline.multiply(data)
            XCTFail("Multiplied matrices with incompatible device.")
        } catch PipelineError.incompatibleDevice {
        } catch {
            XCTFail("Failed to report incompatible device.")
        }
    }
    
    func test_simpleMultiplication_hasExpectedOutput() {
        let inputA = pipeline.createMatrix(rowCount: 2, columnCount: 2)!
        let inputB = pipeline.createMatrix(rowCount: 2, columnCount: 2)!
        let output = pipeline.createMatrix(rowCount: 2, columnCount: 2)!
        let data = MetalData(inputA: inputA, inputB: inputB, output: output)
        
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
            try pipeline.multiply(data)

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

    func test_multiplications_haveExpectedOutput() {
        let inputA = pipeline.createMatrix(rowCount: 17, columnCount: 17)!
        let inputB = pipeline.createMatrix(rowCount: 17, columnCount: 17)!
        let output = pipeline.createMatrix(rowCount: 17, columnCount: 17)!
        let metalData = MetalData(inputA: inputA, inputB: inputB, output: output)

        let referenceOutput = CPUMatrix(rowCount: 17, columnCount: 17, countAlignment: 8)!
        let referenceData = CPUData(inputA: inputA, inputB: inputB, output: referenceOutput)
    
        for n in [7, 8, 9, 15, 16, 17] {
            XCTAssert(inputA.resizeTo(rowCount: n, columnCount: n))
            XCTAssert(inputB.resizeTo(rowCount: n, columnCount: n))
            XCTAssert(output.resizeTo(rowCount: n, columnCount: n))
            XCTAssert(referenceOutput.resizeTo(rowCount: n, columnCount: n))
            
            for rowIndex in 0 ..< inputA.rowCount {
                let row = inputA.baseAddress! + rowIndex * inputA.paddedColumnCount
                for columnIndex in 0 ..< inputA.columnCount {
                    row[columnIndex] = rowIndex == columnIndex ? 1.0 : 0.0
                }
            }
            
            for rowIndex in 0 ..< inputB.rowCount {
                let row = inputB.baseAddress! + rowIndex * inputB.paddedColumnCount
                for columnIndex in 0 ..< inputB.columnCount {
                    row[columnIndex] = Float(rowIndex) * 100.0 + Float(columnIndex)
                }
            }
            
            do {
                try pipeline.multiply(metalData)
                try CPUPipeline.multiply(referenceData)
                
                let epsilon = MatrixElement(0.001)
                
                for rowIndex in 0 ..< output.rowCount {
                    let row = output.baseAddress! + rowIndex * output.paddedColumnCount
                    let referenceRow = referenceOutput.baseAddress! + rowIndex * referenceOutput.paddedColumnCount

                    for columnIndex in 0 ..< output.columnCount {
                        XCTAssertEqualWithAccuracy(
                            row[columnIndex],
                            referenceRow[columnIndex],
                            accuracy: epsilon,
                            "\(n)x\(n): failed at \(rowIndex), \(columnIndex)"
                        )
                    }
                }
            } catch {
                XCTFail("Failed to multiply matrices.")
            }
        }
    }

}


// MARK: - Private

private struct MetalData: MultiplicationData {
    
    typealias MatrixType = MetalMatrix
    
    let inputA: MatrixType
    let inputB: MatrixType
    let output: MatrixType
    
}

private struct CPUData: MultiplicationData {
    
    typealias MatrixType = BufferedMatrix
    
    let inputA: MatrixType
    let inputB: MatrixType
    let output: MatrixType
    
}
