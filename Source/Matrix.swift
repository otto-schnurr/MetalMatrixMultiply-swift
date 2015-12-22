//
//  PaddedMatrix.swift
//
//  Created by Otto Schnurr on 12/14/2015.
//  Copyright © 2015 Otto Schnurr. All rights reserved.
//
//  MIT License
//     file: ../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

/// A row-major matrix of 32-bit floating point numbers.
protocol Matrix {

    /// The number of rows in the matrix.
    var rowCount: Int { get }
    
    /// The number of elements in every row of the matrix.
    var columnCount: Int { get }
    
    /// A constant stride that separates every element within a column
    /// of the matrix.
    ///
    /// - Invariant:
    /// ```
    /// m.columnCount * sizeof(Float32) <= m.bytesPerRow
    /// ```
    var bytesPerRow: Int { get }
    
    var baseAddress: UnsafeMutablePointer<Float32> { get }
    
    /// - Invariant:
    /// ```
    /// m.byteCount == m.rowCount * m.bytesPerRow
    /// ```
    var byteCount: Int { get }
    
}
