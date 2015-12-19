//
//  CPUMatrix.swift
//
//  Created by Otto Schnurr on 12/14/2015.
//  Copyright © 2015 Otto Schnurr. All rights reserved.
//
//  MIT License
//     file: ../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

import Foundation.NSData

class CPUMatrix: MutableMatrix {

    private(set) var rowCount: Int
    private(set) var columnCount: Int
    private(set) var bytesPerRow: Int
    
    var mutableBaseAddress: UnsafeMutablePointer<Float32> {
        return UnsafeMutablePointer<Float32>(data.bytes)
    }
    
    var byteCount: Int {
        let result = rowCount * bytesPerRow
        assert(data.length >= result)
        return result
    }

    /// Create a matrix buffer with the specified rows and columns of data.
    ///
    /// - parameter columnCountAlignment:
    ///   A span of floating point elements that rows of the matrix should
    ///   align with. When necessary, padding is added to each row to achieve
    ///   this alignment. See `bytesPerRow`.
    init?(rowCount: Int, columnCount: Int, columnCountAlignment: Int) {
        guard
            let bytesPerRow = _bytesPerRowForRowCount(
                rowCount,
                columnCount: columnCount,
                columnCountAlignment: columnCountAlignment
            ),
            data = NSMutableData(length: rowCount * bytesPerRow)
        else {
            self.rowCount = 0
            self.columnCount = 0
            self.columnCountAlignment = 0
            self.bytesPerRow = 0
            self.data = NSMutableData()
            return nil
        }

        assert(rowCount > 0)
        assert(columnCount > 0)
        assert(bytesPerRow > 0)
        assert(columnCountAlignment > 0)
        assert(data.length > 0)
        
        self.rowCount = rowCount
        self.columnCount = columnCount
        self.columnCountAlignment = columnCountAlignment
        self.bytesPerRow = bytesPerRow
        self.data = data
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
        
        if data.length < newByteCount {
            data.increaseLengthBy(newByteCount - data.length)
        }

        guard data.length >= newByteCount else { return false }

        self.rowCount = newRowCount
        self.columnCount = newColumnCount
        self.bytesPerRow = newBytesPerRow

        return true
    }
    
    // MARK: Private
    private let columnCountAlignment: Int
    private let data: NSMutableData
    
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

private class CPUBuffer: Buffer {
    
    var memory: UnsafeMutablePointer<Void> {
        guard let data = data else { return nil }
        return data.mutableBytes
    }

    var length: Int { return data?.length ?? 0 }
    
    func resizeToLength(newLength: Int) -> Bool {
        guard newLength >= 0 else { return false }
        guard newLength != length else { return true }
        
        if newLength == 0 {
            data = nil
        } else if let data = data {
            data.resizeToLength(newLength)
        } else {
            data = NSMutableData(length: newLength)
        }

        return true
    }

    // MARK: - Private
    private var data: NSMutableData?
    
}

private extension NSMutableData {
    
    func resizeToLength(newLength: Int) {
        guard newLength != length else {
            return
        }
        guard newLength > 0 else {
            setData(NSData())
            return
        }
        
        if newLength > length {
            increaseLengthBy(newLength - length)
        } else {
            let range = NSMakeRange(0, newLength)
            setData(subdataWithRange(range))
        }
    }
    
}
