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
        commandQueue = self.device.newCommandQueue()
        library = _loadLibraryForDevice(device)

        if let kernelFunction = library?.newFunctionWithName("MultiplyMatrices") {
            state = try? device.newComputePipelineStateWithFunction(kernelFunction)
        } else {
            state = nil
        }

        self.columnCountAlignment = columnCountAlignment
        
        guard
            self.columnCountAlignment > 0 && library != nil && state != nil
        else { return nil }
        
        assert(self.columnCountAlignment > 0)
        assert(library != nil)
        assert(state != nil)
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
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let library: MTLLibrary!
    private let state: MTLComputePipelineState!
    private let columnCountAlignment: Int
}


// MARK: Private
private func _loadLibraryForDevice(device: MTLDevice) -> MTLLibrary? {
    let bundle = NSBundle(forClass: MetalPipeline.self)
    guard
        let filePath = bundle.pathForResource(nil, ofType: "metallib")
    else { return nil }
    
    return try? device.newLibraryWithFile(filePath)
}
