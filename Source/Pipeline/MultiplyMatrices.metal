//
//  MultiplyMatrices.metal
//
//  Created by Otto Schnurr on 12/30/2015.
//  Copyright © 2015 Otto Schnurr. All rights reserved.
//
//  MIT License
//     file: ../../LICENSE.txt
//     http://opensource.org/licenses/MIT
//

#include <metal_stdlib>
using namespace metal;

using Dimension = unsigned short;

/// For computing: output = A^T * B.
///
/// All three matrices (inputA, inputB, and output) are assumbed to be
/// row-major 32-bit floating point numbers, each padded to a specified
/// bytes-per-row.
using BufferDimensions = struct
{
    Dimension outputRowCount;
    Dimension outputColumnCount;
    Dimension innerInputDimension;
    Dimension bytesPerRowA;
    Dimension bytesPerRowB;
    Dimension outputBytesPerRow;
};

using Float8 = float4[2];
using Float8x8 = Float8[8];

/// Each thread of this kernel operates on a Float8x8 section of the
/// output buffer. Matrix buffers require padding to accomodate this.
///
/// Requirements:
///
/// The bytes-per-row of each matrix buffer must be padded to a multiple
/// of Float8 (32 bytes). Similarly, the row count of each matrix must be
/// padded to a multiple of 8.
kernel void MultiplyMatrices(
    constant BufferDimensions& dimensions [[ buffer(0) ]],
    
    const device float* inputA [[ buffer(1) ]],
    const device float* inputB [[ buffer(2) ]],
    device float*       output [[ buffer(3) ]],

    ushort2 outputSection [[ thread_position_in_grid ]]
)
{
    // !!!: implement me
}
