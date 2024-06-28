# Y86-64 Processor Architecture

### Authors:
- Harshvardhan Pandey (2022112006)
- Vaishnavi Shivkumar (2022102070)

### Date: March 2024

---

## Introduction

This repository contains the implementation and explanation of both sequential and pipelined versions of the Y86-64 processor. The Y86-64 processor is a simplified version of the x86-64 architecture used for educational purposes.

---

## 1. Sequential Processor

### 1.1 Fetch Stage
- Reads the binary instruction file and fetches the required values.
- Updates the program counter (PC) for the next instruction.

### 1.2 Decode Stage
- Reads values of fetched register indices.
- Stores values in `valA` and `valB`.

### 1.3 Execute Stage
- Executes operations and stores output in `valE`.
- Handles ALU operations and conditional codes.

### 1.4 Memory Stage
- Interacts with memory for reading or writing.
- Writes occur at the clock's negative edge, reads store value in `valM`.

### 1.5 Write Back Stage
- Updates the register file with new values from the execute and memory stages.

### 1.6 PC Update
- Updates the PC value based on the operation.

### 1.7 Test Cases
- Includes various assembly code snippets to test different operations like `rmmovq`, `mrmovq`, `pushq`, `popq`, `call`, and `ret`.

---

## 2. Pipelined Processor

### 2.1 Fetch and PC Prediction
- Fetch register and fetch stage select and predict the next PC value.

### 2.2 Decode and Writeback Stage
- Calculates `d_valA` and `d_valB`.
- Uses data-forwarding and stalling methods.

### 2.3 Execute Stage
- Checks for bubbles and executes instructions accordingly.
- Considers status inputs from memory and writeback stages.

### 2.4 Memory Stage
- Similar to sequential but checks for bubbles.

### 2.5 Control System
- Pipeline registers work in three modes: Normal, Stall, and Bubble.
- Analyzes different control hazards and sets pipeline register modes accordingly.

### 2.6 Pipeline Hazards
- **Data Dependencies**: Uses data-forwarding to handle dependencies.
- **Load-Use Hazard**: Stalls decoding for a cycle and inserts a bubble in the execute register.
- **Branch Misprediction**: Uses a guessing algorithm and flushes wrong instructions.
- **Return**: Stalls the pipeline for 3 clock cycles for return instructions.

### 2.7 Test Cases
- Includes assembly code snippets to test different operations, data dependencies, and hazard handling.

### 2.8 Problems Faced
- Timing issues and handling `valP` for `RET` instructions in the sequential processor.
- Responding to status codes in the pipelined processor and maintaining bubble and stall requirements.

---

## Conclusion

This report provides an in-depth explanation of the Y86-64 processor architecture, covering both sequential and pipelined implementations. It includes various test cases and discusses the challenges faced during development. 

---

Feel free to explore the repository for detailed implementation and test cases. If you have any questions or need further assistance, please reach out to the authors.
