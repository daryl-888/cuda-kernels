# CUDA Kernels

This is my personal learning journey into GPU programming with CUDA. I'm working through concepts from the ground up.
If you're also learning, please feel free to take anything useful from here.

## What This Is

A collection of CUDA kernels I've written while learning GPU programming. Some are exercises from *Programming Massively Parallel Processors*, which will be under PMPP directory ,some are small projects. Nothing here is polished, but ill try to. It'll grow as I do.

## Contents

### `vecAdd/`
Vector addition — "Hello World" of CUDA.

### `grayscale/`
Converting an RGB image to grayscale on the GPU. A simple but satisfying first visual application.

### `blur/`
Box blur applied to a full color (RGB) image on the GPU. Each thread handles one pixel, averaging its neighbors across all 3 channels. Reads a PPM file, writes a blurred PPM file.

### `PMPP/`
Exercises from the book *Programming Massively Parallel Processors*. Working through each chapter.

- **Ch3exercises.cu** — Matrix multiplication variants: per-thread row kernel, per-thread column kernel, and analysis of memory access patterns (coalesced vs non-coalesced).

## Who This Is For

Anyone learning CUDA. If you're a beginner like me, hopefully seeing the progression and the mistakes along the way helps. If you're more experienced and spot something wrong, feel free to open an issue.

## Resources I'm Using

- *Programming Massively Parallel Processors* (PMPP) by Kirk & Hwu
- CUDA Documentation: https://docs.nvidia.com/cuda/

## Setup

You'll need:
- NVIDIA GPU
- CUDA Toolkit
- On Windows: Visual Studio (for `cl.exe`) + run `vcvars64.bat` before compiling

Compile with:
```
nvcc filename.cu -o output
```
