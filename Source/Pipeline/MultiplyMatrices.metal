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
constexpr constant Dimension sectorSize = 8;

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

/// note: Even though float4x4 is column-major, we will use
///       its columns to populate a row-major matrix buffer.
static inline void accumulateOuterProduct(
    const device float4& inputA,
    const device float4& inputB,
    thread float4x4& output
)
{
    output[0] += inputA.x * inputB;
    output[2] += inputA.y * inputB;

    output[1] += inputA.z * inputB;
    output[3] += inputA.w * inputB;
}

/// Each thread of this kernel operates on a 8x8 sector of the
/// output buffer. Matrix buffers require padding to accomodate this.
///
/// Requirements:
///
/// The bytes-per-row of each matrix buffer must be padded to a multiple
/// of eight floats (32 bytes). Similarly, the row count of each matrix
/// must be padded to a multiple of eight.
kernel void MultiplyMatrices(
    constant BufferDimensions& dimensions [[ buffer(0) ]],
    
    const device float4* inputA [[ buffer(1) ]],
    const device float4* inputB [[ buffer(2) ]],
    device float4*       output [[ buffer(3) ]],

    ushort2 outputSector [[ thread_position_in_grid ]]
)
{
    const ushort2 outputPosition = outputSector * sectorSize;
    
    if (
        outputPosition.x > dimensions.outputRowCount ||
        outputPosition.y > dimensions.outputColumnCount
    )
    {
        return;
    }

    float4x4 s00 = float4x4(0.f), s01 = float4x4(0.f);
    float4x4 s10 = float4x4(0.f), s11 = float4x4(0.f);
    inputA += outputPosition.x / 4;
    inputB += outputPosition.y / 4;
    
    const Dimension strideA = dimensions.bytesPerRowA / sizeof(float4);
    const Dimension strideB = dimensions.bytesPerRowB / sizeof(float4);
    const device float4* const endOfB = inputB + dimensions.innerInputDimension * strideB;
    
    while (inputB < endOfB) {
        accumulateOuterProduct(inputA[0], inputB[0], s00);
        accumulateOuterProduct(inputA[0], inputB[1], s01);
        accumulateOuterProduct(inputA[1], inputB[0], s10);
        accumulateOuterProduct(inputA[1], inputB[1], s11);

        inputA += strideA;
        inputB += strideB;
    }

    const Dimension outputStride = dimensions.outputBytesPerRow / sizeof(float4);
    output += outputPosition.x * outputStride + outputPosition.y / 4;
    
    output[0] = s00[0]; output[1] = s00[1]; output += outputStride;
    output[0] = s00[2]; output[1] = s00[3]; output += outputStride;
    
    output[0] = s01[0]; output[1] = s01[1]; output += outputStride;
    output[0] = s01[2]; output[1] = s01[3]; output += outputStride;
    
    output[0] = s10[0]; output[1] = s10[1]; output += outputStride;
    output[0] = s10[2]; output[1] = s10[3]; output += outputStride;
    
    output[0] = s11[0]; output[1] = s11[1]; output += outputStride;
    output[0] = s11[2]; output[1] = s11[3];
}
