//
//  PipelineError.swift
//
//  Created by Otto Schnurr on 12/30/2015.
//  Copyright © 2015 Otto Schnurr. All rights reserved.
//
//  MIT License
//     file: ../../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

enum PipelineError: Error, CustomStringConvertible {
    case invalidInputDimensions
    case invalidOutputDimensions
    case invalidRepeatCount
    case invalidBuffer
    case incompatibleDevice
    case unsupportedMatrixSize
    
    var description: String {
        switch self {
            case .invalidInputDimensions:  return "invalid input dimensions"
            case .invalidOutputDimensions: return "invalid output dimensions"
            case .invalidRepeatCount:      return "invalid repeat count"
            case .invalidBuffer:           return "invalid buffer"
            case .incompatibleDevice:      return "incompatible device"
            case .unsupportedMatrixSize:   return "unsupported matrix size"
        }
    }
    
}
