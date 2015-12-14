//
//  CPUMatrix_tests.swift
//
//  Created by Otto Schnurr on 12/14/2015.
//  Copyright © 2015 Otto Schnurr. All rights reserved.
//
//  MIT License
//     file: ../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

import XCTest

class CPUMatrix_tests: XCTestCase {

    var matrix: CPUMatrix!
    
    override func setUp() {
        super.setUp()
        matrix = CPUMatrix(rowCount: 4, columnCount: 4, columnCountAlignment: 8)
    }
    
    override func tearDown() {
        matrix = nil
        super.tearDown()
    }
    
    func test_invalidMatrix_isNil() {
        let matrix = CPUMatrix(rowCount: 0, columnCount: 0, columnCountAlignment: 0)
        XCTAssertNil(matrix)
    }
    
    func test_validMatrix_isNotNil() {
        XCTAssertNotNil(matrix)
    }

}
