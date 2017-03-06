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

private func _log(_ message: String) {
    print("error: \(message)")
}

guard let device = MTLCreateSystemDefaultDevice() else {
    _log("Failed to acquire a Metal device.")
    exit(EXIT_FAILURE)
}

guard let test = PerformanceTest(device: device) else {
    _log("Failed create performance test.")
    exit(EXIT_FAILURE)
}

let signal = DispatchSemaphore(value: 0)
var result = EXIT_SUCCESS

test.runAsync { success in
    if !success { result = EXIT_FAILURE }
    signal.signal()
}

let _ = signal.wait(timeout: DispatchTime.distantFuture)
exit(result)
