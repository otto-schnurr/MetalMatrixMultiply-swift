//
//  BufferedMatrix.swift
//
//  Created by Otto Schnurr on 12/18/2015.
//  Copyright © 2015 Otto Schnurr. All rights reserved.
//
//  MIT License
//     file: ../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

protocol Buffer {
    var memory: UnsafeMutablePointer<Void> { get }
    var length: Int { get set }
}
