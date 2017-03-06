//
//  Int+Alignment.swift
//
//  Created by Otto Schnurr on 1/17/2016.
//  Copyright © 2015 Otto Schnurr. All rights reserved.
//
//  MIT License
//     file: ../../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

extension Int {
    
    func padded(to alignment: Int) -> Int? {
        guard self > 0 && alignment > 0 else { return nil }
        
        let remainder = self % alignment
        guard remainder > 0 else { return self }
        
        return self + alignment - remainder
    }
    
}
