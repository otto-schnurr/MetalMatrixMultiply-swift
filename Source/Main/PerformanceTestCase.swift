//
//  PerformanceTestCase.swift
//
//  Created by Otto Schnurr on 1/25/2016.
//  Copyright © 2016 Otto Schnurr. All rights reserved.
//
//  MIT License
//     file: ../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

import QuartzCore.CABase
import Dispatch

/// An operation for comparing Metal and CPU performance for
/// matrix multiplication.
struct PerformanceTestCase {
    
    struct Dimensions: CustomStringConvertible {
    
        let outputRowCount: Int
        let outputColumnCount: Int
        let innerInputDimension: Int
        
        var operationCount: Int64 {
            // Mutlipy and accumulate each inner product.
            return
                2  * Int64(innerInputDimension) *
                Int64(outputRowCount) * Int64(outputColumnCount)
        }
        
        init?(
            outputRowCount: Int,
            outputColumnCount: Int,
            innerInputDimension: Int
        ) {
            guard
                outputRowCount > 0 &&
                outputColumnCount > 0 &&
                innerInputDimension > 0
            else { return nil }
            
            self.outputRowCount = outputRowCount
            self.outputColumnCount = outputColumnCount
            self.innerInputDimension = innerInputDimension
        }
        
        var description: String {
            return
               "[\(innerInputDimension) x \(outputRowCount)]T" +
               "[\(innerInputDimension) x \(outputColumnCount)] -> " +
               "[\(outputRowCount) x \(outputColumnCount)]"
        }
        
    }
    
    struct Resources {
    
        let metalPipeline: MetalPipeline
        let inputA: MetalMatrix
        let inputB: MetalMatrix
        let metalOutput: MetalMatrix
        let cpuOutput: CPUMatrix
        
    }
    
    let targetDimensions: Dimensions
    let resources: Resources
    
    /// Sets up and executes a matrix matrix multiplication operation on Metal
    /// and the CPU and logs performance.
    func run(
        repeatCount repeatCount: Int = 0
    ) throws -> (cpuTime: CFTimeInterval, metalTime: CFTimeInterval) {
        guard
            repeatCount >= 0
        else { throw PipelineError.InvalidRepeatCount }

        guard
            resources.inputA.resizeToRowCount(
                targetDimensions.innerInputDimension,
                columnCount: targetDimensions.outputRowCount
            ) &&
            resources.inputB.resizeToRowCount(
                targetDimensions.innerInputDimension,
                columnCount: targetDimensions.outputColumnCount
            ) &&
            resources.metalOutput.resizeToRowCount(
                targetDimensions.outputRowCount,
                columnCount: targetDimensions.outputColumnCount
            ) &&
            resources.cpuOutput.resizeToRowCount(
                targetDimensions.outputRowCount,
                columnCount: targetDimensions.outputColumnCount
            )
        else { throw PipelineError.UnsupportedMatrixSize }
        
        resources.inputA.randomize()
        resources.inputB.randomize()
        
        let cpuData = CPUData(
            inputA: resources.inputA,
            inputB: resources.inputB,
            output: resources.cpuOutput
        )
        let metalData = MetalData(
            inputA: resources.inputA,
            inputB: resources.inputB,
            output: resources.metalOutput
        )
        
        let cpuStart = CACurrentMediaTime()
        try CPUPipeline.multiplyData(cpuData, repeatCount: repeatCount)
        let metalStart = CACurrentMediaTime()
        try resources.metalPipeline.multiplyData(metalData, repeatCount: repeatCount)
        let metalEnd = CACurrentMediaTime()
        
        return (cpuTime: metalStart - cpuStart, metalTime: metalEnd - metalStart)
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

private extension Matrix {
    
    func randomize() {
        guard rowCount * columnCount > 0 else { return }
    
        let seed = time(nil)
        srand48(seed)
        let queue = dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)
        
        dispatch_apply(rowCount, queue) {
            rowIndex in
            assert(rowIndex < self.rowCount)
            let pRow = self.baseAddress + rowIndex * self.paddedColumnCount

            for columnIndex in 0 ..< self.columnCount {
                pRow[columnIndex] = MatrixElement.randomValue()
            }
        }
    }
    
}

private let _maxDeviation = MatrixElement(5.0)
private let _mean = _maxDeviation / 2.0

private extension MatrixElement {
    
    static func randomValue() -> MatrixElement {
        return MatrixElement(drand48()) * _maxDeviation - _mean
    }
    
}
