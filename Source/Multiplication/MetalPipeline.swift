//
//  MetalPipeline.swift
//
//  Created by Otto Schnurr on 12/30/2015.
//  Copyright © 2015 Otto Schnurr. All rights reserved.
//
//  MIT License
//     file: ../../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

import Metal

/// An interface for vending GPU matrices and performing matrix multiplication
/// on the GPU.
///
/// A Metal pipeline and its associated matrices are heavy-weight objects
/// that are intended to be created once and used multiple times.
class MetalPipeline {
    
    /// Create a Metal pipeline that vends matrices with the specified alignment.
    ///
    /// - parameter columnCountAlignment:
    ///   A span of floating point elements that rows of every matrix should
    ///   align with. When necessary, padding is added to each row of a matrix
    ///   to achieve this alignment. See `BufferedMatrix`.
    init?(device: MTLDevice, columnCountAlignment: Int) {
        self.device = device
        self.columnCountAlignment = columnCountAlignment
        guard self.columnCountAlignment > 0 else { return nil }
    }
    
    func newMatrixWithRowCount(
        rowCount: Int,
        columnCount: Int
    ) -> MetalMatrix? {
        return MetalMatrix(
            rowCount: rowCount,
            columnCount: columnCount,
            columnCountAlignment: columnCountAlignment,
            device: device
        )
    }

    // MARK: Private
    let device: MTLDevice
    let columnCountAlignment: Int

}
