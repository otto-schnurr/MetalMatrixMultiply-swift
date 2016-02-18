//
//  main.swift
//
//  Created by Otto Schnurr on 12/9/2015.
//  Copyright © 2015 Otto Schnurr. All rights reserved.
//
//  MIT License
//     file: ../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

import Metal

private func _logErrorMessage(message: String) {
    print("error: \(message)")
}

guard let device = MTLCreateSystemDefaultDevice() else {
    _logErrorMessage("Failed to acquire a Metal device.")
    exit(EXIT_FAILURE)
}

guard let test = PerformanceTest(device: device, testCount: 5) else {
    _logErrorMessage("Failed create performance test.")
    exit(EXIT_FAILURE)
}

let signal = dispatch_semaphore_create(0)
var result = EXIT_SUCCESS

test.runAsync { success in
    if !success { result = EXIT_FAILURE }
    dispatch_semaphore_signal(signal)
}

dispatch_semaphore_wait(signal, DISPATCH_TIME_FOREVER)
exit(result)
