TODO
====

### Implement `CPUMultiplicationTask`
- Factor Source/Model/ vs Source/Multiplication/.
- Define `MultiplicationTask` protocol.
- logic test: `CPUMultiplicationTask` construction.
- logic test: `CPUMultiplicationTask` multiplication.
    - Integrate `cblas_sgemm()`

### Implement `MetalMultiplicationTask`
- Restore `BufferedMatrix<B: Buffer>` as a template.
- Add `buffer: Buffer` read-only property `BufferedMatrix`.
- Add `MatrixType` assocated type to `MultiplicationData`.
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
