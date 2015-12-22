//
//  MultiplicationData.swift
//
//  Created by Otto Schnurr on 12/19/2015.
//  Copyright © 2015 Otto Schnurr. All rights reserved.
//
//  MIT License
//     file: ../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

/// For computing:
/// ```
/// output = A^T * B
/// ```
protocol MultiplicationData {

    var inputA: Matrix { get }
    var inputB: Matrix { get }
    var output: Matrix { get }

}

extension MultiplicationData {
    
    var inputDimensionsAreValid: Bool {
        return inputA.rowCount == inputB.rowCount
    }
    
    var outputDimensionsAreValid: Bool {
        return output.rowCount == inputA.columnCount &&
               output.columnCount == inputB.columnCount
    }

}
