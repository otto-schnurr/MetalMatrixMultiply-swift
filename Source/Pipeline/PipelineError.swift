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

enum PipelineError: ErrorType, CustomStringConvertible {
    case InvalidInputDimensions
    case InvalidOutputDimensions
    case InvalidRepeatCount
    case InvalidBuffer
    case IncompatibleDevice
    case UnsupportedMatrixSize
    
    var description: String {
        switch self {
            case .InvalidInputDimensions:  return "invalid input dimensions"
            case .InvalidOutputDimensions: return "invalid output dimensions"
            case .InvalidRepeatCount:      return "invalid repeat count"
            case .InvalidBuffer:           return "invalid buffer"
            case .IncompatibleDevice:      return "incompatible device"
            case .UnsupportedMatrixSize:   return "unsupported matrix size"
        }
    }
    
}
