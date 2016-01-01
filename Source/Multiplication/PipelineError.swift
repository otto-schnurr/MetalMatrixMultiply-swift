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

enum PipelineError: ErrorType {
    case InvalidInputDimensions
    case InvalidOutputDimensions
    case InvalidRepeatCount
    case InvalidBuffer
    case IncompatibleDevice
}
