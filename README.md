## Y86-64 Processor Architecture Project Structure

### Project Structure Overview
The project is organized into various directories and files, each serving a specific purpose in the development and testing of the Y86-64 processor. Below is a brief explanation of the structure and important components.

### Root Directory
- **README.md**: General information and instructions about the project.
- **Report.pdf**: Detailed report on the sequential and pipelined versions of the Y86-64 processor.
- **hextobin.py**: Python script for converting hexadecimal to binary format.

### Directories and Important Files

#### ALU
Contains the Arithmetic Logic Unit (ALU) implementation and testbenches.
- **ALU.v**: Main ALU module.
- **tb_addition.v**, **tb_subtraction.v**, **tb_and.v**, **tb_xor.v**, **tb_alu.v**: Testbenches for different ALU operations.

#### Pipeline
Contains the pipelined version of the processor.
- **control.v**, **d_register.v**, **e_register.v**, **f_register.v**, **m_register.v**, **w_register.v**: Pipeline registers.
- **fetch_pc.v**, **decode_wb.v**, **execute.v**, **memory.v**, **processor.v**: Main modules for fetch, decode, execute, memory, and processor logic.
- **Demo.txt**: Example usage and demonstration.

#### SEQ
Contains the sequential version of the processor.
- **fetch.v**, **execute.v**, **memory.v**, **pc_update.v**, **register_file.v**, **processor.v**: Main modules for fetch, execute, memory, PC update, register file, and processor logic.
- **tb_fetch.v**, **tb_execute.v**, **tb_memory.v**, **tb_pc.v**: Testbenches for different stages.
- **Demo.txt**: Example usage and demonstration.

#### SampleTestcase
Contains various test cases for validating processor operations.
- **1.txt**, **call_ret.txt**: Test cases for different processor instructions and operations.
- **check_memory_op.txt**, **cmov_test.txt**: Test cases for memory operations and conditional moves.
- **factorial_result.txt**, **fetch_test.txt**: Test cases for specific algorithm implementations.
- **load_use_hazard.txt**, **ret_branch_mispredict.txt**: Test cases for pipeline hazards like load-use and branch misprediction.
- **recursive_factorial.txt**, **mult_10_19.txt**: Test cases for recursive functions and multiplication.

### Important Notes from the Report
- **Sequential Processor**: Describes the stages including Fetch, Decode, Execute, Memory, Write Back, and PC Update.
- **Pipelined Processor**: Explains stages with pipeline hazards like data dependencies, load-use hazard, branch misprediction, and return handling.
- **Control System**: Details the three modes of pipeline registers: Normal, Stall, and Bubble.
- **Test Cases**: Includes multiple binary code (and their associated assembly code) snippets to validate the processor's functionality and handle edge cases.

This structure ensures modularity and ease of testing for both sequential and pipelined versions of the Y86-64 processor.
