TODO
====

### Clean up
- Consider `Int32` size types for direct insertion into BLAS.
- Fix paths to license file.

### Implement `MetalMultiplicationTask`
- Add `metalBuffer: MTLBuffer` read-only property to `MetalMatrix`.
- Implement metal shader.
- logic test: `MetalMultiplicationTask` construction.
    - Integrate metal shader.
- logic test: `MetalMultiplicationTask` matrix factory.
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
