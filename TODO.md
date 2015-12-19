TODO
====

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
