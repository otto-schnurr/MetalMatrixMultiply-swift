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

    let rowCount = 0
    let columnCount = 0
    let bytesPerRow = 0
    
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
            let _ = _bytesPerRowForRowCount(
                rowCount,
                columnCount: columnCount,
                columnCountAlignment: columnCountAlignment
            )
        else { return nil }
    }

    func resizeToRowCount(
        newRowCount: Int, columnCount newColumnCount: Int
    ) -> Bool {
        // !!!: implement me
        return false
    }
    
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
