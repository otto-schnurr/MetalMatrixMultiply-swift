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

guard let device = MTLCreateSystemDefaultDevice() else {
    print("error: Failed to acquire a Metal device.")
    exit(EXIT_FAILURE)
}

var result = EXIT_SUCCESS
print("Hello, World!")
exit(result)
