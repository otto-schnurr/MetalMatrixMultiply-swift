//
//  CPUPipeline.swift
//
//  Created by Otto Schnurr on 12/29/2015.
//  Copyright © 2015 Otto Schnurr. All rights reserved.
//
//  MIT License
//     file: ../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

class CPUPipeline: MultiplicationPipeline {

    func newMatrix(rowCount: Int, columnCount: Int) -> ResizableBufferedMatrix? {
        // !!!: implement me
        return nil
    }
    
    func multiplyAsync(
        data: MultiplicationData,
        repeatCount: Int,
        completion: (success: Bool) -> Void
    ) {
        // !!!: implement me
        completion(success: false)
    }
    
}
