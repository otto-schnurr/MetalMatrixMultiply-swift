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

class CPUMatrix: MutablePaddedMatrix {

    let rowCount: Int
    let columnCount: Int
    let bytesPerRow: Int
    
    var mutableBaseAddress: UnsafeMutablePointer<Float32> {
        return UnsafeMutablePointer<Float32>(data.bytes)
    }
    
    var byteCount: Int {
        return data.length
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
            self.bytesPerRow = 0
            self.data = NSMutableData()
            return nil
        }

        assert(rowCount > 0)
        assert(columnCount > 0)
        assert(bytesPerRow > 0)
        assert(data.length > 0)
        
        self.rowCount = rowCount
        self.columnCount = columnCount
        self.bytesPerRow = bytesPerRow
        self.data = data
    }
    
    func resizeToRowCount(rowCount: Int, columnCount: Int) -> Bool {
        // !!!: implement me
        return false
    }
    
    // MARK: Private
    private let data: NSMutableData
    
}


// MARK: - Private
private typealias
    _Dimensions = (rowCount: Int, columnCount: Int, bytesPerRow: Int)

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
