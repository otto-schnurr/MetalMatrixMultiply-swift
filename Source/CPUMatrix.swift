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

class CPUMatrix: PaddedMatrix {

    let rowCount = 0
    let columnCount = 0
    let bytesPerRow = 0
    
    var baseAddress: UnsafePointer<Float32> {
        // !!!: implement me
        return nil
    }

    let byteCount = 0

    /// Create a matrix buffer with the specified rows and columns of data.
    ///
    /// - parameter columnCountAlignment:
    ///   A span of floating point elements that rows of the matrix should
    ///   align with. When necessary, padding is added to each row to achieve
    ///   this alignment. See `bytesPerRow`.
    init?(rowCount: Int, columnCount: Int, columnCountAlignment: Int) {
        guard
            rowCount > 0,
            let _ = CPUMatrix.padCount(
                columnCount, toAlignment: columnCountAlignment
            )
        else { return nil }

        // !!!: implement me
    }
    
}
