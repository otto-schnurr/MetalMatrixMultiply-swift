//
//  PaddedMatrix.swift
//
//  Created by Otto Schnurr on 12/14/2015.
//  Copyright © 2015 Otto Schnurr. All rights reserved.
//

/// A row-major matrix of read-only 32-bit floating point numbers.
protocol PaddedMatrix {

    /// The number of rows in the matrix.
    var rowCount: Int { get }
    
    /// The number of elements in every row of the matrix.
    var columnCount: Int { get }
    
}
