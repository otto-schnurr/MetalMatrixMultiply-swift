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
        // !!!: implement me
        completion(success: false)
    }
    
}
