//
//  PerformanceTest.swift
//
//  Created by Otto Schnurr on 2/4/2016.
//  Copyright © 2016 Otto Schnurr. All rights reserved.
//
//  MIT License
//     file: ../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

import Metal

struct PerformanceTest {
    
    init?(
        device: MTLDevice,
        dimensionCapacity: Int = 2048,
        testCount: Int = 20,
        loopsPerTest: Int = 100
    ) {
        guard
            testCount > 0 && loopsPerTest > 0
        else { return nil }
        
        guard
            let resources = _createResourcesForDevice(
                device, dimensionCapacity: dimensionCapacity
            )
        else { return nil }
        
        self.resources = resources
    }

    // MARK: Private
    let resources: PerformanceTestCase.Resources

}


// MARK: - Private
private func _createResourcesForDevice(
    device: MTLDevice, dimensionCapacity n: Int
) -> PerformanceTestCase.Resources? {
    guard
        let pipeline = MetalPipeline(device: device, countAlignment: 8),
        inputA = pipeline.newMatrixWithRowCount(n, columnCount: n),
        inputB = pipeline.newMatrixWithRowCount(n, columnCount: n),
        metalOutput = pipeline.newMatrixWithRowCount(n, columnCount: n),
        cpuOutput = CPUMatrix(rowCount: n, columnCount: n, countAlignment: 8)
    else { return nil }
    
    return PerformanceTestCase.Resources(
        metalPipeline: pipeline,
        inputA: inputA, inputB: inputB,
        metalOutput: metalOutput, cpuOutput: cpuOutput
    )
}
