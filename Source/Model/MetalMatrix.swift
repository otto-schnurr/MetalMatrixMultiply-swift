//
//  MetalMatrix.swift
//
//  Created by Otto Schnurr on 12/17/2015.
//  Copyright © 2015 Otto Schnurr. All rights reserved.
//
//  MIT License
//     file: ../../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

import Metal.MTLDevice

class MetalMatrix: ResizableBufferedMatrix {

    var metalBuffer: MTLBuffer? { return (buffer as? MetalBuffer)?.buffer }

    init?(
        rowCount: Int,
        columnCount: Int,
        countAlignment: Int,
        device: MTLDevice
    ) {
        super.init(
            rowCount: rowCount,
            columnCount: columnCount,
            countAlignment: countAlignment,
            buffer: MetalBuffer(device: device)
        )
    }

}

class MetalBuffer: ResizableBuffer {
    
    let device: MTLDevice
    
    var memory: UnsafeMutableRawPointer? {
        guard let buffer = buffer else { return nil }
        return buffer.contents()
    }
    
    var length: Int { return buffer?.length ?? 0 }
    
    func resize(to newLength: Int) -> Bool {
        guard newLength >= 0 else { return false }
        guard newLength != length else { return true }
        
        if newLength == 0 {
            buffer = nil
        } else if let buffer = buffer {
            self.buffer = buffer.resized(to: newLength)
        } else {
            buffer = device.makeBuffer(
                length: newLength, options: MTLResourceOptions()
            )
        }
        
        return true
    }
    
    init(device: MTLDevice) { self.device = device }

    // MARK: Private
    fileprivate var buffer: MTLBuffer?

}


// MARK: - Private
private extension MTLBuffer {
    
    func resized(to newLength: Int) -> MTLBuffer? {
        guard newLength != length else {
            return self
        }
        guard newLength > 0 else {
            return nil
        }
        
        let newBuffer: MTLBuffer
        
        if newLength <= length {
            newBuffer = device.makeBuffer(
                bytes: self.contents(),
                length: newLength,
                options: MTLResourceOptions()
            )
        } else {
            newBuffer = device.makeBuffer(
                length: newLength, options: MTLResourceOptions()
            )
            let newBytes = UnsafeMutableRawBufferPointer(
                start: newBuffer.contents(), count: length
            )
            let oldBytes = UnsafeMutableRawBufferPointer(
                start: self.contents(), count: length
            )
            newBytes.copyBytes(from: oldBytes)
        }
        
        return newBuffer
    }
    
}
