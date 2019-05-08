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
    /// - parameter threadGroupAlignment:
    ///   A span of floating point elements that rows of every matrix should
    ///   align with. When necessary, padding is added to each row of a matrix
    ///   to achieve this alignment. See `BufferedMatrix`.
    init?(device: MTLDevice, threadGroupAlignment: Int) {
        self.device = device
        commandQueue = self.device.makeCommandQueue()
        dimensionBuffer = device.makeBuffer(
            length: _dimensionBufferByteCount,
            options: MTLResourceOptions()
        )
        library = _loadLibrary(for: device)

        if let kernelFunction = library?.makeFunction(name: "MultiplyMatrices") {
            state = try? device.makeComputePipelineState(function: kernelFunction)
        } else {
            state = nil
        }

        self.threadGroupAlignment = threadGroupAlignment
        
        guard
            self.threadGroupAlignment > 0 && dimensionBuffer != nil &&
            library != nil && state != nil
        else { return nil }
        
        assert(self.threadGroupAlignment > 0)
        assert(library != nil)
        assert(state != nil)
    }
    
    func createMatrix(
        rowCount: Int,
        columnCount: Int
    ) -> MetalMatrix? {
        return MetalMatrix(
            rowCount: rowCount,
            columnCount: columnCount,
            threadGroupAlignment: threadGroupAlignment,
            device: device
        )
    }

    /// - important: Synchronous. Not thread safe.
    func multiply<Data: MultiplicationData>(
        _ data: Data, repeatCount: Int = 0
    ) throws where Data.MatrixType: MetalMatrix {
        guard
            data.inputDimensionsAreValid
        else { throw PipelineError.invalidInputDimensions }

        guard
            data.outputDimensionsAreValid
        else { throw PipelineError.invalidOutputDimensions }

        guard
            repeatCount >= 0
        else { throw PipelineError.invalidRepeatCount }

        guard
            let bufferA = data.inputA.metalBuffer,
            let bufferB = data.inputB.metalBuffer,
            let outputBuffer = data.output.metalBuffer
        else { throw PipelineError.invalidBuffer }

        guard
            bufferA.device == device &&
            bufferB.device == device &&
            outputBuffer.device == device
        else { throw PipelineError.incompatibleDevice }
        
        // important: One device thread computes an (8x8) sector of output.
        let outputSectorCount = MTLSize(
            width: data.output.paddedColumnCount / threadGroupAlignment,
            height: data.output.paddedRowCount / threadGroupAlignment,
            depth: 1
        );
        
        guard
            let paddedSectorCount =
                outputSectorCount.padded(toThreadGroupSize:_threadGroupSize)
        else { throw PipelineError.invalidOutputDimensions }

        try dimensionBuffer.encodeDimensions(for: data)
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        let encoder = commandBuffer.makeComputeCommandEncoder()
        encoder.setComputePipelineState(state)
        encoder.setBuffer(dimensionBuffer, offset: 0, index: 0)
        encoder.setBuffer(bufferA, offset: 0, index: 1)
        encoder.setBuffer(bufferB, offset: 0, index: 2)
        encoder.setBuffer(outputBuffer, offset: 0, index: 3)
        
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
    fileprivate let commandQueue: MTLCommandQueue
    fileprivate let dimensionBuffer: MTLBuffer!
    fileprivate let library: MTLLibrary!
    fileprivate let state: MTLComputePipelineState!
    fileprivate let threadGroupAlignment: Int
    
}


// MARK: - Private
private typealias _Dimension = UInt16
private let _dimensionCount = 6
private let _dimensionBufferByteCount = _dimensionCount * MemoryLayout<_Dimension>.size

private extension MTLBuffer {

    func encodeDimensions<Data: MultiplicationData>(for data: Data) throws {
        guard
            data.inputA.canEncodeDimensions &&
            data.inputB.canEncodeDimensions &&
            data.output.canEncodeDimensions
        else { throw PipelineError.unsupportedMatrixSize }
        
        guard
            _dimensionBufferByteCount <= length
        else { throw PipelineError.invalidBuffer }
        
        // FIXME: Technically, this is undefined behavior.
        let pointer = contents().assumingMemoryBound(to: _Dimension.self)
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
        
        func canEncode(_ value: Int) -> Bool {
            return 0 <= value && value <= maxValue
        }
        
        return canEncode(bytesPerRow) && canEncode(columnCount)
    }
    
}

private extension MTLSize {
    
    func padded(toThreadGroupSize groupSize: MTLSize) -> MTLSize? {
        guard
           let paddedWidth = width.padded(to: groupSize.width),
           let paddedHeight = width.padded(to: groupSize.height),
           let paddedDepth = depth.padded(to: groupSize.depth)
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

private func _loadLibrary(for device: MTLDevice) -> MTLLibrary? {
    let bundle = Bundle(for: MetalPipeline.self)
    guard
        let filePath = bundle.path(forResource: nil, ofType: "metallib")
    else { return nil }
    
    return try? device.makeLibrary(filepath: filePath)
}

private func ==(deviceA: MTLDevice, deviceB: MTLDevice) -> Bool {
    return Unmanaged.passUnretained(deviceA).toOpaque() == Unmanaged.passUnretained(deviceB).toOpaque()
}
