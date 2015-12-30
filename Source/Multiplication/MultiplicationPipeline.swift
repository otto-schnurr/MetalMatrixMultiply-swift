//
//  MultiplicationPipeline.swift
//
//  Created by Otto Schnurr on 12/22/2015.
//  Copyright © 2015 Otto Schnurr. All rights reserved.
//
//
//  MIT License
//     file: ../../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

/// An interface for vending resizable matrices and performing matrix
/// multiplication.
///
/// A pipeline and its associated matrices are heavy-weight objects
/// that are intended to be created once and used multiple times.
protocol MultiplicationPipeline {

    func newMatrixWithRowCount(
        rowCount: Int,
        columnCount: Int
    ) -> ResizableBufferedMatrix?

    /// Asynchronously multiply the specified matrices.
    ///
    /// - parameter repeatCount:
    ///   The number of *additional* times to perform the matrix
    ///   multiplication before calling the completion handler.
    ///
    /// - parameter completion:
    ///   Receives `false` if the data is inconsistent or incompatible
    ///   with this pipeline.
    func multiplyAsync(
        data: MultiplicationData,
        repeatCount: Int,
        completion: (success: Bool) -> Void
    )

}
