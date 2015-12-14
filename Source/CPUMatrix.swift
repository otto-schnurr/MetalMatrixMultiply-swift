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

struct CPUMatrix: PaddedMatrix {

    let rowCount: Int
    let columnCount: Int
    let bytesPerRow: Int
    
    var baseAddress: UnsafePointer<Float32> {
        return UnsafePointer<Float32>(data.bytes)
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
            rowCount > 0,
            let columnsPerRow = CPUMatrix.padCount(
                columnCount, toAlignment: columnCountAlignment
            )
        else { return nil }

        assert(columnCount > 0)
        self.rowCount = rowCount
        self.columnCount = columnCount
        bytesPerRow = columnsPerRow * sizeof(Float32)
        
        guard
            let data = NSMutableData(length: rowCount * bytesPerRow)
        else { return nil }
        
        self.data = data
    }
    
    // MARK: Private
    private let data: NSData
    
}
