TODO
====

### Implement `MetalPipeline`
- Simplify `CPUPipeline`.
- Add `metalBuffer: MTLBuffer` read-only property to `MetalMatrix`.
- Implement metal shader.
- logic test: `MetalPipeline` construction.
    - Integrate metal shader.
- logic test: `MetalPipeline` matrix factory.
- logic test: `MetalPipeline` multiplication.
    - Execute metal shader.

### Implement `Experiment`
- logic test: `Experiment` construction.
- logic test: `Experiment` operation.
- Integrate randomization.
- Integrate timing.
- Integrate logging.

### Implement Targets
- Implement OSX command-line target.
- Implement iOS app target.
