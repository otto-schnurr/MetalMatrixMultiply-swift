//
//  CPUPipeline.swift
//
//  Created by Otto Schnurr on 12/29/2015.
//  Copyright © 2015 Otto Schnurr. All rights reserved.
//
//  MIT License
//     file: ../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

import Accelerate.vecLib

private let _columnCountAlignment = 8

struct CPUPipeline: MultiplicationPipeline {

    func newMatrixWithRowCount(
        rowCount: Int,
        columnCount: Int
    ) -> ResizableBufferedMatrix? {
        return CPUMatrix(
            rowCount: rowCount,
            columnCount: columnCount,
            columnCountAlignment: _columnCountAlignment
        )
    }
    
    func multiplyAsync(
        data: MultiplicationData,
        repeatCount: Int,
        completion: (success: Bool) -> Void
    ) {
        guard
            data.inputDimensionsAreValid &&
            data.outputDimensionsAreValid &&
            repeatCount >= 0
        else {
            completion(success: false)
            return
        }
    
        let queue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)

        dispatch_async(queue) {
            assert(!NSThread.isMainThread())
            let count = 1 + repeatCount
            for _ in 1 ... count { _multiply(data) }
            completion(success: true)
        }
    }
    
}


// MARK: Private
private func _multiply(data: MultiplicationData) {
    assert(data.inputDimensionsAreValid)
    assert(data.outputDimensionsAreValid)
    
    cblas_sgemm(
        CblasRowMajor, CblasTrans, CblasNoTrans,
        Int32(data.output.rowCount), Int32(data.output.columnCount),
        Int32(data.inputB.rowCount),
        1.0,
        data.inputA.baseAddress, Int32(data.inputA.bytesPerRow / sizeof(Float32)),
        data.inputB.baseAddress, Int32(data.inputB.bytesPerRow / sizeof(Float32)),
        0.0,
        data.output.baseAddress, Int32(data.output.bytesPerRow / sizeof(Float32))
    )
}
