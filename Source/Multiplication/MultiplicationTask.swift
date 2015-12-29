//
//  MultiplicationTask.swift
//
//  Created by Otto Schnurr on 12/22/2015.
//  Copyright © 2015 Otto Schnurr. All rights reserved.
//
//
//  MIT License
//     file: ../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

/// The interface for a transient, single-use object that can perform
/// the matrix multiplication implied by a `MultiplicationData` object.
protocol MultiplicationTask {

    /// Asynchronously multiply the specified matrices.
    ///
    /// - parameter repeatCount:
    ///   The number of *additional* times to perform the matrix
    ///   multiplication before calling the completion handler.
    func multiplyDataAsync(
        data: MultiplicationData,
        repeatCount: Int,
        completion: (success: Bool) -> Void
    )

}
