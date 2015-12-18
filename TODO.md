TODO
====

### Implement `MetalMatrix`
- logic test: `MetalMatrix` alignment.
- logic test: `MetalMatrix` resizing.

### Factor `BufferedMatrix`
- Rename `[Mutable]PaddedMatrix` to `[Mutable]Matrix`.
- Define new `Buffer` protocol in a new BufferedMatrix.swift.
- Create new `BufferedMatrix<B>`.
- logic test: `CPUBuffer` from CPUMatrix.swift.
- logic test: `MetalBuffer` from MetalMatrix.swift.
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
