//
//  BufferedMatrix.swift
//
//  Created by Otto Schnurr on 12/18/2015.
//  Copyright © 2015 Otto Schnurr. All rights reserved.
//
//  MIT License
//     file: ../../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

protocol Buffer {
    var memory: UnsafeMutableRawPointer? { get }
    var length: Int { get }
}

protocol ResizableBuffer: Buffer {
    func resize(to newLength: Int) -> Bool
}

class BufferedMatrix: Matrix {
    
    let buffer: ResizableBuffer
    fileprivate(set) var rowCount: Int
    fileprivate(set) var columnCount: Int
    fileprivate(set) var paddedRowCount: Int
    fileprivate(set) var paddedColumnCount: Int
    
    var baseAddress: UnsafeMutablePointer<MatrixElement>? {
        // FIXME: Technically, this is undefined behavior.
        return buffer.memory?.assumingMemoryBound(to: MatrixElement.self)
    }
    
    var byteCount: Int {
        let result = paddedRowCount * bytesPerRow
        assert(buffer.length >= result)
        return result
    }
    
    /// Create a buffered matrix with the specified rows and columns of data.
    ///
    /// - parameter alignment:
    ///   A span of rows in each column and a span of floating point elements
    ///   in each row that the matrix should align with.
    ///   When necessary, padding is added to each row and extra rows are
    ///   added to achieve this alignment.
    ///   See `paddedRowCount`, `paddedColumnCount` and `bytesPerRow`.
    init?(
        rowCount: Int,
        columnCount: Int,
        alignment: Int,
        buffer: ResizableBuffer
    ) {
        guard
            let paddedRowCount = rowCount.padded(to: alignment),
            let paddedColumnCount = columnCount.padded(to: alignment),
            let byteCount = _byteCountFor(
                paddedRowCount: paddedRowCount,
                paddedColumnCount: paddedColumnCount
            ), buffer.resize(to: byteCount)
        else {
            self.rowCount = 0
            self.columnCount = 0
            self.paddedRowCount = 0
            self.paddedColumnCount = 0
            self.alignment = 0
            self.buffer = buffer
            return nil
        }
        
        assert(rowCount > 0)
        assert(columnCount > 0)
        assert(paddedColumnCount > 0)
        assert(alignment > 0)
        assert(buffer.length > 0)
        
        self.rowCount = rowCount
        self.columnCount = columnCount
        self.paddedRowCount = paddedRowCount
        self.paddedColumnCount = paddedColumnCount
        self.alignment = alignment
        self.buffer = buffer
        
        assert(bytesPerRow > 0)
    }
    
    // MARK: Private
    fileprivate let alignment: Int

}

class ResizableBufferedMatrix: BufferedMatrix {
    
    func resizeTo(
        rowCount newRowCount: Int, columnCount newColumnCount: Int
    ) -> Bool {
        assert(alignment > 0)
        guard
            newRowCount != rowCount || newColumnCount != columnCount
        else { return true }
        
        guard
            let newPaddedRowCount =
                newRowCount.padded(to: alignment),
            let newPaddedColumnCount =
                newColumnCount.padded(to: alignment),
            let newByteCount = _byteCountFor(
                paddedRowCount: newPaddedRowCount,
                paddedColumnCount: newPaddedColumnCount
            )
        else { return false }
        
        assert(newRowCount > 0)
        assert(newColumnCount > 0)
        assert(newPaddedRowCount > 0)
        assert(newPaddedColumnCount > 0)
        assert(newByteCount > 0)
        
        if buffer.length < newByteCount {
            guard buffer.resize(to: newByteCount) else {
                return false
            }
        }
        
        assert(buffer.length >= newByteCount)
        
        rowCount = newRowCount
        columnCount = newColumnCount
        paddedRowCount = newPaddedRowCount
        paddedColumnCount = newPaddedColumnCount
        
        assert(bytesPerRow > 0)
        return true
    }
    
}


// MARK: - Private
private func _byteCountFor(paddedRowCount: Int, paddedColumnCount: Int) -> Int? {
    guard paddedRowCount > 0 && paddedColumnCount > 0 else { return nil }
    return paddedRowCount * paddedColumnCount * MemoryLayout<MatrixElement>.size
}
