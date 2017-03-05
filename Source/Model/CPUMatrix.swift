//
//  CPUMatrix.swift
//
//  Created by Otto Schnurr on 12/14/2015.
//  Copyright © 2015 Otto Schnurr. All rights reserved.
//
//  MIT License
//     file: ../../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

import Foundation.NSData

class CPUMatrix: ResizableBufferedMatrix {

    init?(rowCount: Int, columnCount: Int, countAlignment: Int) {
        super.init(
            rowCount: rowCount,
            columnCount: columnCount,
            countAlignment: countAlignment,
            buffer: CPUBuffer()
        )
    }
    
}

class CPUBuffer: ResizableBuffer {
    
    var memory: UnsafeMutableRawPointer {
        guard let data = data else { return nil }
        return data.mutableBytes
    }

    var length: Int { return data?.length ?? 0 }
    
    func resizeToLength(_ newLength: Int) -> Bool {
        guard newLength >= 0 else { return false }
        guard newLength != length else { return true }
        
        if newLength == 0 {
            data = nil
        } else if let data = data {
            data.resizeToLength(newLength)
        } else {
            data = NSMutableData(length: newLength)
        }

        return true
    }

    // MARK: Private
    fileprivate var data: NSMutableData?
    
}


// MARK: - Private
private extension NSMutableData {
    
    func resizeToLength(_ newLength: Int) {
        guard newLength != length else {
            return
        }
        guard newLength > 0 else {
            setData(Data())
            return
        }
        
        if newLength > length {
            increaseLength(by: newLength - length)
        } else {
            let range = NSMakeRange(0, newLength)
            setData(subdata(with: range))
        }
    }
    
}
