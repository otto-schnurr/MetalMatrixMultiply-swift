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
    func resizeToLength(newLength: Int) -> Bool
}

class BufferedMatrix<B: Buffer> {
    
    private(set) var rowCount: Int
    private(set) var columnCount: Int
    private(set) var bytesPerRow: Int
    
    var mutableBaseAddress: UnsafeMutablePointer<Float32> {
        return UnsafeMutablePointer<Float32>(buffer.memory)
    }
    
    var byteCount: Int {
        let result = rowCount * bytesPerRow
        assert(buffer.length >= result)
        return result
    }
    
    /// Create a matrix buffer with the specified rows and columns of data.
    ///
    /// - parameter columnCountAlignment:
    ///   A span of floating point elements that rows of the matrix should
    ///   align with. When necessary, padding is added to each row to achieve
    ///   this alignment. See `bytesPerRow`.
    init?(rowCount: Int, columnCount: Int, columnCountAlignment: Int, buffer: Buffer) {
        guard
            let bytesPerRow = _bytesPerRowForRowCount(
                rowCount,
                columnCount: columnCount,
                columnCountAlignment: columnCountAlignment
            ) where buffer.resizeToLength(rowCount * bytesPerRow)
        else {
            self.rowCount = 0
            self.columnCount = 0
            self.columnCountAlignment = 0
            self.bytesPerRow = 0
            self.buffer = buffer
            return nil
        }
        
        assert(rowCount > 0)
        assert(columnCount > 0)
        assert(bytesPerRow > 0)
        assert(columnCountAlignment > 0)
        assert(buffer.length > 0)
        
        self.rowCount = rowCount
        self.columnCount = columnCount
        self.columnCountAlignment = columnCountAlignment
        self.bytesPerRow = bytesPerRow
        self.buffer = buffer
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
        
        if buffer.length < newByteCount {
            guard buffer.resizeToLength(newByteCount - buffer.length) else {
                return false
            }
        }
        
        assert(buffer.length >= newByteCount)
        self.rowCount = newRowCount
        self.columnCount = newColumnCount
        self.bytesPerRow = newBytesPerRow
        
        return true
    }
    
    // MARK: Private
    private let columnCountAlignment: Int
    private let buffer: Buffer

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
