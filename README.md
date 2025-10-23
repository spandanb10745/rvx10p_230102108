RVX10-P: 5-Stage Pipelined RISC-V Core

RVX10-P: A Five-Stage Pipelined RISC-V Core supporting RV32I + 10 Custom ALU Instructions, developed under the course Digital Logic and Computer Architecture taught by Dr. Satyajit Das, IIT Guwahati.

Overview

This project is a 5-stage pipelined RISC-V processor (RV32I) enhanced with 10 custom ALU instructions (the RVX10 extension). It transforms a single-cycle implementation into a high-throughput pipelined core by partitioning the datapath into five stages: IF, ID, EX, MEM, and WB.

The processor correctly handles all data and control hazards using dedicated Forwarding and Hazard units.

Key Features

5-Stage Pipelined Datapath: (IF, ID, EX, MEM, WB)

Full RV32I ISA: Implements the base integer instruction set.

RVX10 Custom Extension: Supports 10 custom ALU ops (ANDN, ORN, XNOR, MIN, MAX, MINU, MAXU, ROL, ROR, ABS).

Full Hazard Handling:

Forwarding Unit: Resolves Read-After-Write (RAW) data hazards from MEM and WB stages.

Hazard Unit: Manages load-use stalls (1-cycle bubble) and branch flushes (NOP insertion).

Performance: Achieves an average CPI of ~1.310 on the comprehensive test suite, demonstrating high throughput.

Core Block Diagram

How to Run

This project includes a self-checking testbench that runs a comprehensive test program (risctest.mem). If the processor is correct, the simulation will end by printing "Simulation Succeeded" to the console.

Option 1: In Vivado

Create a new project in Vivado.

Add all SystemVerilog files from the /src directory as Design Sources.

Add testbench.sv from the /tb directory as a Simulation Source.

In the Vivado project, create a new memory file (e.g., risctest.mem).

Copy the entire contents of the risctest.mem file (provided in /tb) and paste it into the new memory file you just created.

Run the behavioral simulation.

Option 2: In VS Code (or other simulators like Icarus Verilog)

Ensure you have a SystemVerilog toolchain (like Icarus Verilog or Verilator) installed.

Download the necessary files:

All .sv files from the /src directory.

testbench.sv from the /tb directory.

rvx10_pipeline.hex from the /tb directory (this is the memory file formatted for this setup).

Compile and run the simulation using your toolchain. For example, with Icarus Verilog:

# Compile all source files and the testbench
iverilog -o sim -s testbench -g2012 tb/testbench.sv src/*.sv

# Run the compiled simulation
vvp sim


References

This project's design and pipeline principles are based on the concepts from:

Digital Design and Computer Architecture (RISC-V Edition) by David Harris and Sarah Harris.
