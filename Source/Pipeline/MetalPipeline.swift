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
    
    let device: MTLDevice

    /// Create a Metal pipeline that vends matrices with the specified alignment.
    ///
    /// - parameter countAlignment:
    ///   A span of floating point elements that rows of every matrix should
    ///   align with. When necessary, padding is added to each row of a matrix
    ///   to achieve this alignment. See `BufferedMatrix`.
    init?(device: MTLDevice, countAlignment: Int) {
        self.device = device
        commandQueue = self.device.newCommandQueue()
        dimensionBuffer = device.newBufferWithLength(
            _dimensionBufferByteCount,
            options: .CPUCacheModeDefaultCache
        )
        library = _loadLibraryForDevice(device)

        if let kernelFunction = library?.newFunctionWithName("MultiplyMatrices") {
            state = try? device.newComputePipelineStateWithFunction(kernelFunction)
        } else {
            state = nil
        }

        self.countAlignment = countAlignment
        
        guard
            self.countAlignment > 0 && dimensionBuffer != nil &&
            library != nil && state != nil
        else { return nil }
        
        assert(self.countAlignment > 0)
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
            countAlignment: countAlignment,
            device: device
        )
    }

    /// - important: Synchronous. Not thread safe.
    func multiplyData<
        Data: MultiplicationData where Data.MatrixType: MetalMatrix
    >(data: Data, repeatCount: Int = 0) throws {
        guard data.inputDimensionsAreValid else {
            throw PipelineError.InvalidInputDimensions
        }
        guard data.outputDimensionsAreValid else {
            throw PipelineError.InvalidOutputDimensions
        }
        guard repeatCount >= 0 else {
            throw PipelineError.InvalidRepeatCount
        }
        guard
            let bufferA = data.inputA.metalBuffer,
            bufferB = data.inputB.metalBuffer,
            outputBuffer = data.output.metalBuffer
        else {
            throw PipelineError.InvalidBuffer
        }
        guard
            bufferA.device == device &&
            bufferB.device == device &&
            outputBuffer.device == device
        else {
            throw PipelineError.IncompatibleDevice
        }
        
        // !!!: implement me
//        let count = 1 + repeatCount
//        for _ in 1...count { _multiply(data) }
    }

    // MARK: Private
    private let commandQueue: MTLCommandQueue
    private let dimensionBuffer: MTLBuffer!
    private let library: MTLLibrary!
    private let state: MTLComputePipelineState!
    private let countAlignment: Int
}


// MARK: Private
private typealias _Dimension = UInt16
private let _dimensionBufferByteCount = 6 * sizeof(_Dimension)

private func _loadLibraryForDevice(device: MTLDevice) -> MTLLibrary? {
    let bundle = NSBundle(forClass: MetalPipeline.self)
    guard
        let filePath = bundle.pathForResource(nil, ofType: "metallib")
    else { return nil }
    
    return try? device.newLibraryWithFile(filePath)
}

private func ==(deviceA: MTLDevice, deviceB: MTLDevice) -> Bool {
    return unsafeAddressOf(deviceA) == unsafeAddressOf(deviceB)
}
