//
//  MetalMatrix.swift
//
//  Created by Otto Schnurr on 12/17/2015.
//  Copyright © 2015 Otto Schnurr. All rights reserved.
//
//  MIT License
//     file: ../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

import Metal.MTLDevice

class MetalMatrix: MutableMatrix {

    private(set) var rowCount: Int
    private(set) var columnCount: Int
    private(set) var bytesPerRow: Int
    
    var mutableBaseAddress: UnsafeMutablePointer<Float32> {
        return UnsafeMutablePointer<Float32>(buffer.contents())
    }
    
    var byteCount: Int {
        let result = rowCount * bytesPerRow
        assert(buffer.length >= result)
        return result
    }

    /// Create a matrix buffer with the specified rows and columns of data
    /// for the specified devices.
    ///
    /// - parameter columnCountAlignment:
    ///   A span of floating point elements that rows of the matrix should
    ///   align with. When necessary, padding is added to each row to achieve
    ///   this alignment. See `bytesPerRow`.
    init?(
        rowCount: Int,
        columnCount: Int,
        columnCountAlignment: Int,
        device: MTLDevice
    ) {
        guard
            let bytesPerRow = _bytesPerRowForRowCount(
                rowCount,
                columnCount: columnCount,
                columnCountAlignment: columnCountAlignment
            )
        else {
            self.rowCount = 0
            self.columnCount = 0
            self.columnCountAlignment = 0
            self.bytesPerRow = 0
            self.device = nil
            self.buffer = nil
            return nil
        }

        assert(rowCount > 0)
        assert(columnCount > 0)
        assert(bytesPerRow > 0)
        assert(columnCountAlignment > 0)

        self.rowCount = rowCount
        self.columnCount = columnCount
        self.columnCountAlignment = columnCountAlignment
        self.bytesPerRow = bytesPerRow
        self.device = device
        self.buffer = device.newBufferWithLength(
            rowCount * bytesPerRow,
            options: .CPUCacheModeDefaultCache
        )
    }

    func resizeToRowCount(
        newRowCount: Int, columnCount newColumnCount: Int
    ) -> Bool {
        assert(columnCountAlignment > 0)
        guard
            newRowCount != rowCount || newColumnCount != columnCount
        else { return true }
        
        guard
            let newBytesPerRow = _bytesPerRowForRowCount(
                newRowCount,
                columnCount: newColumnCount,
                columnCountAlignment: columnCountAlignment
            )
        else { return false }
        
        assert(newRowCount > 0)
        assert(newColumnCount > 0)
        assert(newBytesPerRow > 0)
        let newByteCount = newRowCount * newBytesPerRow
        
        self.buffer = device.newBufferWithLength(
            newRowCount * newBytesPerRow,
            options: .CPUCacheModeDefaultCache
        )
        assert(buffer.length >= newByteCount)
        
        self.rowCount = newRowCount
        self.columnCount = newColumnCount
        self.bytesPerRow = newBytesPerRow
        
        return true
    }
    
    // MARK: Private
    private let columnCountAlignment: Int
    private let device: MTLDevice!
    private var buffer: MTLBuffer!
    
}


// MARK: - Private
private func _bytesPerRowForRowCount(
    rowCount: Int,
    columnCount: Int,
    columnCountAlignment: Int
) -> Int? {
    guard
        rowCount > 0,
        let columnsPerRow = CPUMatrix.padCount(
            columnCount, toAlignment: columnCountAlignment
        )
        else { return nil }
    
    return columnsPerRow * sizeof(Float32)
}

private class MetalBuffer: Buffer {
    
    var memory: UnsafeMutablePointer<Void> {
        guard let buffer = buffer else { return nil }
        return buffer.contents()
    }
    
    var length: Int {
        get { return buffer?.length ?? 0 }
        set {
            guard newValue != length else {
                return
            }
            guard newValue > 0 else {
                buffer = nil
                return
            }
            guard let buffer = buffer else {
                self.buffer = device.newBufferWithLength(
                    newValue, options: .CPUCacheModeDefaultCache
                )
                return
            }
            
            self.buffer = buffer.resizedToLength(newValue)
        }
    }
    
    init(device: MTLDevice) { self.device = device }
    
    // MARK: - Private
    private let device: MTLDevice
    private var buffer: MTLBuffer?
    
}

private extension MTLBuffer {
    
    func resizedToLength(newLength: Int) -> MTLBuffer? {
        guard newLength != length else {
            return self
        }
        guard newLength > 0 else {
            return nil
        }
        
        let newBuffer: MTLBuffer
        
        if newLength > length {
            newBuffer = device.newBufferWithBytes(
                self.contents(),
                length: newLength,
                options: .CPUCacheModeDefaultCache
            )
        } else {
            newBuffer = device.newBufferWithLength(
                newLength, options: .CPUCacheModeDefaultCache
            )
            newBuffer.contents().assignFrom(self.contents(), count: newLength)
        }
        
        return newBuffer
    }
    
}
