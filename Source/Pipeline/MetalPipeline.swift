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

private let _threadGroupSize = MTLSize(width: 4, height: 8, depth: 1)

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
        guard
            data.inputDimensionsAreValid
        else { throw PipelineError.InvalidInputDimensions }

        guard
            data.outputDimensionsAreValid
        else { throw PipelineError.InvalidOutputDimensions }

        guard
            repeatCount >= 0
        else { throw PipelineError.InvalidRepeatCount }

        guard
            let bufferA = data.inputA.metalBuffer,
            bufferB = data.inputB.metalBuffer,
            outputBuffer = data.output.metalBuffer
        else { throw PipelineError.InvalidBuffer }

        guard
            bufferA.device == device &&
            bufferB.device == device &&
            outputBuffer.device == device
        else { throw PipelineError.IncompatibleDevice }
        
        // important: One device thread computes an (8x8) sector of output.
        let outputSectorCount = MTLSize(
            width: data.output.paddedColumnCount / countAlignment,
            height: data.output.paddedRowCount / countAlignment,
            depth: 1
        );
        
        guard
            let paddedSectorCount =
                outputSectorCount.paddedToThreadGroupSize(_threadGroupSize)
        else { throw PipelineError.InvalidOutputDimensions }

        try dimensionBuffer.encodeDimensionsForData(data)
        
        let commandBuffer = commandQueue.commandBuffer()
        let encoder = commandBuffer.computeCommandEncoder()
        encoder.setComputePipelineState(state)
        encoder.setBuffer(dimensionBuffer, offset: 0, atIndex: 0)
        encoder.setBuffer(bufferA, offset: 0, atIndex: 1)
        encoder.setBuffer(bufferB, offset: 0, atIndex: 2)
        encoder.setBuffer(outputBuffer, offset: 0, atIndex: 3)
        
        let threadGroupCount = paddedSectorCount / _threadGroupSize
        let count = 1 + repeatCount

        for _ in 1...count {
            encoder.dispatchThreadgroups(
                threadGroupCount, threadsPerThreadgroup: _threadGroupSize
            )
        }
        
        encoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()        
    }

    // MARK: Private
    private let commandQueue: MTLCommandQueue
    private let dimensionBuffer: MTLBuffer!
    private let library: MTLLibrary!
    private let state: MTLComputePipelineState!
    private let countAlignment: Int
    
}


// MARK: - Private
private typealias _Dimension = UInt16
private let _dimensionCount = 6
private let _dimensionBufferByteCount = _dimensionCount * sizeof(_Dimension)

private extension MTLBuffer {

    func encodeDimensionsForData<Data: MultiplicationData>(data: Data) throws {
        guard
            data.inputA.canEncodeDimensions &&
            data.inputB.canEncodeDimensions &&
            data.output.canEncodeDimensions
        else { throw PipelineError.UnsupportedMatrixSize }
        
        let pointer = UnsafeMutablePointer<_Dimension>(contents())
        guard
            _dimensionBufferByteCount <= length && pointer != nil
        else { throw PipelineError.InvalidBuffer }
        
        let dimensions = UnsafeMutableBufferPointer<_Dimension>(
            start: pointer, count: _dimensionCount
        )
        dimensions[0] = _Dimension(data.output.rowCount)
        dimensions[1] = _Dimension(data.output.columnCount)
        dimensions[2] = _Dimension(data.inputB.rowCount)
        dimensions[3] = _Dimension(data.inputA.bytesPerRow)
        dimensions[4] = _Dimension(data.inputB.bytesPerRow)
        dimensions[5] = _Dimension(data.output.bytesPerRow)
    }

}

private extension Matrix {
    
    // important: Don't let Swift crash the app on overflow.
    var canEncodeDimensions: Bool {
        let maxValue = Int(_Dimension.max)
        
        func canEncode(value: Int) -> Bool {
            return 0 <= value && value <= maxValue
        }
        
        return canEncode(bytesPerRow) && canEncode(columnCount)
    }
    
}

private extension MTLSize {
    
    func paddedToThreadGroupSize(groupSize: MTLSize) -> MTLSize? {
        guard
           let paddedWidth = width.paddedToAlignment(groupSize.width),
           paddedHeight = width.paddedToAlignment(groupSize.height),
           paddedDepth = depth.paddedToAlignment(groupSize.depth)
        else { return nil }
        
        return MTLSize(width: paddedWidth, height: paddedHeight, depth: paddedDepth)
    }
    
}

private func /(numerator: MTLSize, denominator: MTLSize) -> MTLSize {
    return MTLSize(
        width: numerator.width / denominator.width,
        height: numerator.height / denominator.height,
        depth: numerator.depth / denominator.depth
    )
}

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
