TODO
====

### Implement `CPUMultiplicationTask`
- logic test: `CPUMultiplicationTask` multiplication.
    - Integrate `cblas_sgemm()`

### Implement `MetalMultiplicationTask`
- Add `metalBuffer: MTLBuffer` read-only property to `MetalMatrix`.
- Implement metal shader.
- logic test: `MetalMultiplicationTask` construction.
    - Integrate metal shader.
- logic test: `MetalMultiplicationTask` multiplication.
    - Execute metal shader.

### Implement `MultiplicationExperiment`
- logic test: `MultiplicationExperiment` construction.
- logic test: `MultiplicationExperiment` operation.
- Integrate randomization.
- Integrate timing.
- Integrate logging.

### Implement Targets
- Implement OSX command-line target.
- Implement iOS app target.
