//
//  BufferedMatrix.swift
//
//  Created by Otto Schnurr on 12/18/2015.
//  Copyright © 2015 Otto Schnurr. All rights reserved.
//
//  MIT License
//     file: ../LICENSE.txt
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
    
    private(set) var rowCount: Int
    private(set) var columnCount: Int
    private(set) var paddedColumnCount: Int
    
    var baseAddress: UnsafeMutablePointer<MatrixElement> {
        return UnsafeMutablePointer<MatrixElement>(buffer.memory)
    }
    
    var byteCount: Int {
        let result = rowCount * bytesPerRow
        assert(buffer.length >= result)
        return result
    }
    
    /// Create a buffered matrix with the specified rows and columns of data.
    ///
    /// - parameter columnCountAlignment:
    ///   A span of floating point elements that rows of the matrix should
    ///   align with. When necessary, padding is added to each row to achieve
    ///   this alignment. See `paddedColumnCount` and `bytesPerRow`.
    init?(
        rowCount: Int,
        columnCount: Int,
        columnCountAlignment: Int,
        buffer: ResizableBuffer
    ) {
        guard
            let paddedColumnCount = _padCount(
                columnCount, toAlignment: columnCountAlignment
            ),
            let byteCount = _byteCountForRowCount(
                rowCount, paddedColumnCount: paddedColumnCount
            ) where buffer.resizeToLength(byteCount)
        else {
            self.rowCount = 0
            self.columnCount = 0
            self.paddedColumnCount = 0
            self.columnCountAlignment = 0
            self.buffer = buffer
            return nil
        }
        
        assert(rowCount > 0)
        assert(columnCount > 0)
        assert(paddedColumnCount > 0)
        assert(columnCountAlignment > 0)
        assert(buffer.length > 0)
        
        self.rowCount = rowCount
        self.columnCount = columnCount
        self.columnCountAlignment = columnCountAlignment
        self.paddedColumnCount = paddedColumnCount
        self.buffer = buffer
        
        assert(bytesPerRow > 0)
    }
    
    // MARK: Private
    private let columnCountAlignment: Int
    private let buffer: ResizableBuffer

}

class ResizableBufferedMatrix: BufferedMatrix {
    
    func resizeToRowCount(
        newRowCount: Int, columnCount newColumnCount: Int
    ) -> Bool {
        assert(columnCountAlignment > 0)
        guard
            newRowCount != rowCount || newColumnCount != columnCount
        else { return true }
        
        guard
            let newPaddedColumnCount = _padCount(
                newColumnCount, toAlignment: columnCountAlignment
            ),
            let newByteCount = _byteCountForRowCount(
                newRowCount, paddedColumnCount: newPaddedColumnCount
            )
        else { return false }
        
        assert(newRowCount > 0)
        assert(newColumnCount > 0)
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
        paddedColumnCount = newPaddedColumnCount
        
        assert(bytesPerRow > 0)
        return true
    }
    
}


// MARK: - Private
private func _padCount(count: Int, toAlignment alignment: Int) -> Int? {
    guard count > 0 && alignment > 0 else { return nil }
    
    let remainder = count % alignment
    guard remainder > 0 else { return count }
    
    return count + alignment - remainder
}

private func _byteCountForRowCount(rowCount: Int, paddedColumnCount: Int) -> Int? {
    guard rowCount > 0 && paddedColumnCount > 0 else { return nil }
    return rowCount * paddedColumnCount * sizeof(MatrixElement)
}
