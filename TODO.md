TODO
====

### Factor `BufferedMatrix`
- Create new `BufferedMatrix<B>`.
- Typealias `CPUMatrix` to be `BufferedMatrix<CPUBuffer>`.
    - Add extension for creating a `CPUMatrix` directly.
- Typealias `MetalMatrix` to be `BufferedMatrix<MetalBuffer>`.
    - Add extension for creating a `MetalMatrix` directly with a device.

### Implement `CPUMatrixMultiply`
- `MatrixMultiply` protocol.
- logic test: `CPUMatrixMultiply` construction.
- logic test: `CPUMatrixMultiply` multiplication.
    - Integrate `cblas_sgemm()`

### Implement `MetalMatrixMultiply`
- Implement metal shader.
- logic test: `MetalMatrixMultiply` construction.
    - Integrate metal shader.
- logic test: `MetalMatrixMultiply` multiplication.
    - Execute metal shader.

### Implement `MatrixMultiplyExperiment`
- logic test: `MatrixExperiment` construction.
- logic test: `MatrixExperiment` operation.
- Integrate randomization.
- Integrate timing.
- Integrate logging.

### Implement Targets
- Implement OSX command-line target.
- Implement iOS app target.
