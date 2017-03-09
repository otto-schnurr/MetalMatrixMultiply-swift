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

import Dispatch
import Metal

struct PerformanceTest {
    
    init?(
        device: MTLDevice,
        testCount: Int = 5,
        loopsPerTest: Int = 100
    ) {
        guard
            testCount > 0 && loopsPerTest > 0
        else { return nil }
        
        guard
            let resources = _createResources(for: device)
        else { return nil }
        
        self.resources = resources
        self.testCount = testCount
        self.loopsPerTest = loopsPerTest
    }

    func runAsync(_ completion: @escaping (_ success: Bool) -> Void) {
        let background = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)
        
        background.async {
            let result: Bool

            do {
                try self.run()
                result = true
            } catch let error as PipelineError {
                _log("failure: \(error)")
                result = false
            } catch {
                _log("failure: unknown")
                result = false
            }

            completion(result)
        }
    }

    // MARK: Private
    let resources: PerformanceTestCase.Resources
    let testCount: Int
    let loopsPerTest: Int

}


// MARK: - Private
private extension PerformanceTest {
    
    func run() throws {
        let dimensions = IteratorSequence(RandomDimensionGenerator(count: testCount))
        let testCases = dimensions.flatMap {
            PerformanceTestCase(targetDimensions: $0, resources: self.resources)
        }
        guard testCases.count == testCount else { throw PipelineError.unsupportedMatrixSize }
        let flopsToGflops = 1 / 1_000_000_000.0
        
        for testCase in testCases {
            let operationCount =
                Double(testCase.targetDimensions.operationCount) *
                Double(loopsPerTest)
            _log(
                ">> Dimensions: \(testCase.targetDimensions)\n" +
                "   \(loopsPerTest) times -> " +
                "\(operationCount / 1_000_000.0) million operations"
            )
            let result = try testCase.run(repeatCount: loopsPerTest - 1)

            let cpuFlops = operationCount / result.cpuTime
            let cpuResults = NSString(format: "%.1f", cpuFlops * flopsToGflops)

            let metalFlops = operationCount / result.metalTime
            let metalResults = NSString(format: "%.1f", metalFlops * flopsToGflops)
            
            _log(
                "   Accelerate: \(cpuResults) gflops, " +
                "Metal: \(metalResults) gflops"
            )
        }
    }
    
}

private struct RandomDimensionGenerator: IteratorProtocol {

    typealias Element = PerformanceTestCase.Dimensions
    var count: Int

    fileprivate mutating func next() -> RandomDimensionGenerator.Element? {
        guard count > 0 else { return nil }
        count -= 1
        return Element(
            outputRowCount: _randomDimensionLength(),
            outputColumnCount: _randomDimensionLength(),
            innerInputDimension: _randomDimensionLength()
        )
    }

}

private let _min = UInt32(256)
private let _max = UInt32(2048)

private func _randomDimensionLength() -> Int {
    return Int(arc4random_uniform(_max + 1 - _min) + _min)
}

private func _createResources(
    for device: MTLDevice
) -> PerformanceTestCase.Resources? {
    guard
        let pipeline = MetalPipeline(device: device, threadGroupAlignment: 8),
        let inputA = pipeline.createMatrix(rowCount: 1, columnCount: 1),
        let inputB = pipeline.createMatrix(rowCount: 1, columnCount: 1),
        let metalOutput = pipeline.createMatrix(rowCount: 1, columnCount: 1),
        let cpuOutput = CPUMatrix(rowCount: 1, columnCount: 1, alignment: 8)
    else { return nil }
    
    return PerformanceTestCase.Resources(
        metalPipeline: pipeline,
        inputA: inputA, inputB: inputB,
        metalOutput: metalOutput, cpuOutput: cpuOutput
    )
}

private func _log(_ message: String) {
    print(message)
}
