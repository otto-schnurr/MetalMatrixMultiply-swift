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
    var memory: UnsafeMutablePointer<Void> { get }
    var length: Int { get }
}

protocol ResizableBuffer: Buffer {
    func resizeToLength(newLength: Int) -> Bool
}

class BufferedMatrix: Matrix {
    
    let buffer: ResizableBuffer
    private(set) var rowCount: Int
    private(set) var columnCount: Int
    private(set) var paddedRowCount: Int
    private(set) var paddedColumnCount: Int
    
    var baseAddress: UnsafeMutablePointer<MatrixElement> {
        return UnsafeMutablePointer<MatrixElement>(buffer.memory)
    }
    
    var byteCount: Int {
        let result = paddedRowCount * bytesPerRow
        assert(buffer.length >= result)
        return result
    }
    
    /// Create a buffered matrix with the specified rows and columns of data.
    ///
    /// - parameter countAlignment:
    ///   A span of rows in each column and a span of floating point elements
    ///   in each row that the matrix should align with.
    ///   When necessary, padding is added to each row and extra rows are
    ///   added to achieve this alignment.
    ///   See `paddedRowCount`, `paddedColumnCount` and `bytesPerRow`.
    init?(
        rowCount: Int,
        columnCount: Int,
        countAlignment: Int,
        buffer: ResizableBuffer
    ) {
        guard
            let paddedRowCount = rowCount.paddedToAlignment(countAlignment),
            let paddedColumnCount = columnCount.paddedToAlignment(countAlignment),
            let byteCount = _byteCountForPaddedRowCount(
                paddedRowCount, paddedColumnCount: paddedColumnCount
            ) where buffer.resizeToLength(byteCount)
        else {
            self.rowCount = 0
            self.columnCount = 0
            self.paddedRowCount = 0
            self.paddedColumnCount = 0
            self.countAlignment = 0
            self.buffer = buffer
            return nil
        }
        
        assert(rowCount > 0)
        assert(columnCount > 0)
        assert(paddedColumnCount > 0)
        assert(countAlignment > 0)
        assert(buffer.length > 0)
        
        self.rowCount = rowCount
        self.columnCount = columnCount
        self.paddedRowCount = paddedRowCount
        self.paddedColumnCount = paddedColumnCount
        self.countAlignment = countAlignment
        self.buffer = buffer
        
        assert(bytesPerRow > 0)
    }
    
    // MARK: Private
    private let countAlignment: Int

}

class ResizableBufferedMatrix: BufferedMatrix {
    
    func resizeToRowCount(
        newRowCount: Int, columnCount newColumnCount: Int
    ) -> Bool {
        assert(countAlignment > 0)
        guard
            newRowCount != rowCount || newColumnCount != columnCount
        else { return true }
        
        guard
            let newPaddedRowCount =
                newRowCount.paddedToAlignment(countAlignment),
            let newPaddedColumnCount =
                newColumnCount.paddedToAlignment(countAlignment),
            let newByteCount = _byteCountForPaddedRowCount(
                newPaddedRowCount, paddedColumnCount: newPaddedColumnCount
            )
        else { return false }
        
        assert(newRowCount > 0)
        assert(newColumnCount > 0)
        assert(newPaddedRowCount > 0)
        assert(newPaddedColumnCount > 0)
        assert(newByteCount > 0)
        
        if buffer.length < newByteCount {
            guard buffer.resizeToLength(newByteCount) else {
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
private func _byteCountForPaddedRowCount(
    paddedRowCount: Int, paddedColumnCount: Int
) -> Int? {
    guard paddedRowCount > 0 && paddedColumnCount > 0 else { return nil }
    return paddedRowCount * paddedColumnCount * sizeof(MatrixElement)
}
