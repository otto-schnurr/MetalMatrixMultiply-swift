//
//  Matrix.swift
//
//  Created by Otto Schnurr on 12/14/2015.
//  Copyright © 2015 Otto Schnurr. All rights reserved.
//
//  MIT License
//     file: ../../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

// TODO: Can this somehow be nested as Matrix.Element?
typealias MatrixElement = Float32

/// A row-major matrix of 32-bit floating point numbers.
protocol Matrix: class {

    /// The number of rows of data in the matrix.
    var rowCount: Int { get }
    
    /// The number of elements of data in every row of the matrix.
    var columnCount: Int { get }
    
    /// The total number of rows in the matrix including padded rows.
    ///
    /// - Invariant:
    /// ```
    /// m.paddedRowCount >= m.rowCount
    /// ```
    var paddedRowCount: Int { get }
    
    /// A constant stride of elements that separates every element within
    /// a column of this matrix.
    ///
    /// - Note: BLAS refers to this as the *leading dimension* of the matrix.
    ///
    /// - Invariant:
    /// ```
    /// m.paddedColumnCount >= m.columnCount
    /// ```
    var paddedColumnCount: Int { get }
    
    var baseAddress: UnsafeMutablePointer<MatrixElement>? { get }
    
    /// - Invariant:
    /// ```
    /// m.byteCount == m.paddedRowCount * m.bytesPerRow
    /// ```
    var byteCount: Int { get }
    
}

extension Matrix {
    
    /// A constant stride of bytes that separates every element within
    /// a column of this matrix.
    ///
    /// - Invariant:
    /// ```
    /// m.bytesPerRow == m.paddedColumnCount * sizeof(MatrixElement)
    /// ```
    var bytesPerRow: Int { return paddedColumnCount * MemoryLayout<MatrixElement>.size }

}
