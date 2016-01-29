//
//  PerformanceTestCase.swift
//
//  Created by Otto Schnurr on 1/25/2016.
//  Copyright © 2016 Otto Schnurr. All rights reserved.
//
//  MIT License
//     file: ../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

/// An operation for comparing Metal and CPU performance for
/// matrix multiplication.
struct PerformanceTestCase {
    
    struct Dimensions {
    
        let outputRowCount: Int
        let outputColumnCount: Int
        let innerInputDimension: Int
        
        var flops: Double {
            // !!!: implemet me
            return 0
        }
        
        init?(
            outputRowCount: Int,
            outputColumnCount: Int,
            innerInputDimension: Int
        ) {
            guard
                outputRowCount > 0 &&
                outputColumnCount > 0 &&
                innerInputDimension > 0
            else { return nil }
            
            self.outputRowCount = outputRowCount
            self.outputColumnCount = outputColumnCount
            self.innerInputDimension = innerInputDimension
        }
        
    }
    
    struct Resources {
    
        let inputA: MetalMatrix
        let inputB: MetalMatrix
        let metalOutput: MetalMatrix
        let cpuOutput: CPUMatrix
        
    }
    
    let targetDimensions: Dimensions
    let resources: Resources
    
    /// Sets up and executes a matrix matrix multiplication operation on Metal
    /// and the CPU and logs performance.
    func invoke() {
        // !!!: implement me
    }
    
}
