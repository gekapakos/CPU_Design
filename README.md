# Project Overview

## Implementation of MNIST Dataset using HLS4ML
- **Description**: Optimizes a Neural Network for the MNIST dataset on an FPGA using HLS4ML, focusing on area reduction via pruning and quantization, implemented in a Jupyter notebook on Ubuntu.
- **Authors**: Tselepi Eleni (etselepi@uth.gr), Georgios Kapakos (gkapakos@uth.gr).
- **Institution**: University of Thessaly (UTH), Volos, Greece.
- **Purpose**: Bridges ML and FPGA design, achieving low-latency, low-power edge deployment with minimal accuracy loss.

## Dataset
- **MNIST**: 60,000 training and 10,000 test images of handwritten digits (28x28, 256 gray levels), split 90% training, 10% validation.

## Methodology

### Setup Dataset
- **Description**: Load MNIST via TensorFlow Datasets, split into train/validation/test sets, and visualize training examples for inspection.

### Model
- **Description**: CNN with Input (28x28x1), 3x[Conv2D-ReLU-MaxPooling], 2x[Dense-ReLU], Dense-Softmax. Flattens input, extracts features via convolution, and classifies across 10 digits.

### Training
- **Description**: Train for 30 epochs, batch size 1024, using categorical crossentropy loss and Adam optimizer (lr=0.003) on MNIST training data.

### Compilation
- **Description**: Convert Keras model to HLS with HLS4ML, setting 16-bit fixed-point precision, latency strategy, reuse factor 1, and io_stream interface. Compile to C++ for FPGA synthesis.

### Synthesis
- **Description**: Build HLS model using Vivado 2019.1, skipping C simulation, running HLS and Vivado synthesis to produce an FPGA-ready bitstream.

## Optimizations

### Pruning
- **Description**: Apply 50% sparsity to Conv2D/Dense layers (excluding output) over 10 epochs using TensorFlow Model Optimization. Gradually prune via PolynomialDecay for minimal accuracy impact.

### Quantization
- **Description**: Reduce precision to 6-bit using QKeras (QConv2DBatchnorm, QActivation) on weights/biases, enhancing efficiency for edge devices with QAT support.

## Results
- **Unoptimized**: 64 BRAM, 2850 DSP, 31,765 FF, 141,367 LUT; Accuracy: 0.9919.
- **Pruned**: 64 BRAM, 1840 DSP (-35%), 27,260 FF (-14%), 88,507 LUT (-37%); Accuracy: 0.9879 (-0.4%).
- **Quantized**: 64 BRAM, 222 DSP (-92%), 24,617 FF (-22.5%), 110,807 LUT (-21%); Accuracy: 0.9603 (-3%).
- **Key Finding**: Quantized model slashes DSP usage by 92% with only 3% accuracy loss.

## Tools
- **HLS4ML**: Converts ML models to FPGA firmware via Vivado HLS backend.
- **Dependencies**: Ubuntu, TensorFlow 2.4+, QKeras, Vivado HLS 2018.2-2020.1.

## Implementation Details
- **Environment**: Ubuntu Linux, Jupyter notebook for model design and optimization.
- **Workflow**: Load data → Define CNN → Train → Convert to HLS → Optimize → Synthesize → Evaluate.
- **Profiling**: Use `hls4ml.model.profiling.numerical` to compare Keras vs. HLS outputs, ensuring numerical fidelity post-conversion.

## Evaluation
- **Metrics**: Resource utilization (BRAM, DSP, FF, LUT), accuracy across 10/20/30 epochs.
- **Visuals**: Weight distribution plots pre/post-compilation, resource usage bar graphs, accuracy curves.
- **Trade-off**: Quantization offers max area savings; pruning balances LUT reduction and accuracy.

## Conclusion
- **Outcome**: Achieved up to 92% DSP reduction with negligible 3% accuracy loss, proving HLS4ML’s efficacy for edge FPGA optimization.

## References
- HLS4ML GitHub: [fastmachinelearning/hls4ml](https://github.com/fastmachinelearning/hls4ml)
- MNIST: Deng, L., IEEE Signal Proc. Mag., 2012.
