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
    
    init?(device: MTLDevice) {
        self.device = device
    }
    
    func newMatrixWithRowCount(
        rowCount: Int,
        columnCount: Int
    ) -> MetalMatrix? {
        // !!!: implement me
        return nil
    }

    // MARK: Private
    let device: MTLDevice

}
