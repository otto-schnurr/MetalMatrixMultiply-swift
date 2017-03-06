//
//  TestHarness.swift
//
//  Created by Otto Schnurr on 2/3/2016.
//  Copyright © 2016 Otto Schnurr. All rights reserved.
//
//  MIT License
//     file: ../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

import Metal

// critical: Creating a Metal pipeline more than once with a discrete GPU
//           appears to cause a kernel panic on OSX. Using the integrated
//           device for testing when available.
var metalDeviceForTesting: MTLDevice? = {
    #if os(OSX)
        if let device = MTLCopyAllDevices().filter({ $0.isLowPower }).first {
            return device
        }
    #endif
    
    return MTLCreateSystemDefaultDevice()
}()
