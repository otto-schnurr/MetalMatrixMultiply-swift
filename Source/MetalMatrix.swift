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

class MetalMatrix: MutablePaddedMatrix {

    private(set) var rowCount: Int
    private(set) var columnCount: Int
    private(set) var bytesPerRow: Int
    
    var mutableBaseAddress: UnsafeMutablePointer<Float32> {
        // !!!: implement me
        return nil
    }
    
    var byteCount: Int {
        // !!!: implement me
        return 0
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
    }

    func resizeToRowCount(
        newRowCount: Int, columnCount newColumnCount: Int
    ) -> Bool {
        // !!!: implement me
        return false
    }
    
    // MARK: Private
    private let columnCountAlignment: Int
    
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
