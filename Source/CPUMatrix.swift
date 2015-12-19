//
//  CPUMatrix.swift
//
//  Created by Otto Schnurr on 12/14/2015.
//  Copyright © 2015 Otto Schnurr. All rights reserved.
//
//  MIT License
//     file: ../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

import Foundation.NSData

class CPUMatrix: BufferedMatrix<CPUBuffer> {

    init?(rowCount: Int, columnCount: Int, columnCountAlignment: Int) {
        super.init(
            rowCount: rowCount,
            columnCount: columnCount,
            columnCountAlignment: columnCountAlignment,
            buffer: CPUBuffer()
        )
    }
    
}

class CPUBuffer: Buffer {
    
    var memory: UnsafeMutablePointer<Void> {
        guard let data = data else { return nil }
        return data.mutableBytes
    }

    var length: Int { return data?.length ?? 0 }
    
    func resizeToLength(newLength: Int) -> Bool {
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
    private var data: NSMutableData?
    
}


// MARK: - Private
private extension NSMutableData {
    
    func resizeToLength(newLength: Int) {
        guard newLength != length else {
            return
        }
        guard newLength > 0 else {
            setData(NSData())
            return
        }
        
        if newLength > length {
            increaseLengthBy(newLength - length)
        } else {
            let range = NSMakeRange(0, newLength)
            setData(subdataWithRange(range))
        }
    }
    
}
