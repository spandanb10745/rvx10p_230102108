# RVX10-P: Design and Verification Report

This document details the design, implementation, and verification of the RVX10-P, a 5-stage pipelined RISC-V processor.

**References**:
* Digital Design & Computer Architecture (RISC-V Edition) by Harris & Harris
* Single-Cycle RVX10 Core: `[[Link to your single-cycle RVX10 GitHub repository](https://github.com/spandanb10745/CS322M-230102108/tree/main/RVX10)]`

---

## 1. Design Description

[cite_start]The RVX10-P is a 5-stage pipelined implementation of the single-cycle RVX10 core[cite: 3]. [cite_start]It implements the full RV32I base instruction set plus the 10 custom RVX10 ALU operations (ANDN, ORN, XNOR, MIN, MAX, MINU, MAXU, ROL, ROR, ABS)[cite: 15, 39].

[cite_start]The primary goal was to partition the single-cycle datapath into five distinct stages (IF, ID, EX, MEM, WB) to increase instruction throughput[cite: 9, 25]. [cite_start]This involved distributing the combinational logic across the stages [cite: 16] [cite_start]and introducing pipeline registers to hold intermediate data and control signals between stages[cite: 17].

### High-Level Architecture

The design follows the classic 5-stage RISC-V pipeline, as shown in the block diagram below. The core logic from the single-cycle implementation was separated, and dedicated pipeline registers were added to isolate each stage.

![Full Pipelined Datapath](image_733778.png)
*Figure 1: High-Level Block Diagram of the RVX10-P Core*

[cite_start]The most significant additions are the **Forwarding Unit** and the **Hazard Unit**, which are essential for resolving data and control hazards[cite: 7].

### Pipeline Stages and Registers

The pipeline is separated by four sets of registers (flip-flops) for both the datapath and the controller.

1.  **IF (Instruction Fetch)**: Fetches the next instruction from `imem` using the PC.
    * `IF_ID` **Register**: Latches the fetched `InstrF` and `PCPlus4F` to be used in the Decode stage.
    * ``

2.  **ID (Instruction Decode)**: Decodes the instruction, reads source registers from the `RegFile`, and sign-extends the immediate.
    * `ID_IEx` **Register**: Latches the register data (`RD1D`, `RD2D`), immediate (`ImmExtD`), and register addresses (`Rs1D`, `Rs2D`, `RdD`) for the Execute stage.
    * `c_ID_IEx` **Register**: Latches the control signals (e.g., `ALUSrcD`, `BranchD`, `MemWriteD`) for the Execute stage.
    * ``
    * ``

3.  **EX (Execute)**: The ALU performs the operation. It calculates branch targets and determines branch outcomes.
    * `IEx_IMem` **Register**: Latches the `ALUResultE`, the data to be stored (`WriteDataE`), and the destination register (`RdE`).
    * `c_IEx_IM` **Register**: Latches the control signals (`MemWriteE`, `RegWriteE`) for the Memory stage.
    * ``
    * ``

4.  **MEM (Memory Access)**: Reads from or writes to the `dmem`.
    * `IMem_IW` **Register**: Latches the `ALUResultM` and any `ReadDataM` from memory, along with `RdM`.
    * `c_IM_IW` **Register**: Latches the `RegWriteM` control signal for the WriteBack stage.
    * ``
    * ``

5.  **WB (Write Back)**: Writes the final result back to the `RegFile`.

---

## 2. Hazard Handling

[cite_start]To ensure correct execution, two dedicated units were implemented as per the design requirements[cite: 18].

### Forwarding Unit

[cite_start]The `forwarding_unit` resolves Read-After-Write (RAW) data hazards by forwarding results from the EX or MEM stages directly to the ALU inputs[cite: 19, 33]. This avoids unnecessary stalls. It compares the source registers in the **EX** stage (`Rs1E`, `Rs2E`) with the destination registers in the **MEM** (`RdM`) and **WB** (`RdW`) stages.

``

### Hazard Unit

The `hazard_unit` detects two conditions:
1.  [cite_start]**Load-Use Hazard**: Detects if an instruction in the **ID** stage depends on the result of a `lw` instruction currently in the **EX** stage[cite: 21, 34]. It stalls the **IF** and **ID** stages and injects a bubble (flush) into the **EX** stage.
2.  **Control Hazard**: Detects if a branch is taken in the **EX** stage (via `PCSrcE`). [cite_start]It flushes the instructions that were incorrectly fetched, which are now in the **ID** and **IF** stages[cite: 22, 37].

``

---

## 3. Verification and Waveforms

The test strategy relied on a self-checking test program (`risctest.mem`) used for ad-hoc testing. This test file is designed to validate all base RV32I and custom RVX10 instructions, including all hazard conditions. Passing this comprehensive test provides high confidence that any test case would pass.

Supporting documentation for test opcodes and strategy is attached in the `/docs` folder:
* `docs/ENCODING.md`
* `docs/testplan.md`

### Test 1: Functional Correctness

[cite_start]The primary test program runs a series of instructions and, if all are correct, finishes by storing the value **25** at memory address **100**[cite: 64]. The simulation output confirms this success.

``
``
``

### Test 2: `x0` Register Integrity

The `x0` register is hardwired to zero. [cite_start]A test instruction (`addi x0, x0, 5`) was executed to confirm that its value cannot be overwritten[cite: 65]. The waveform below shows `x0` remains 0.

`[Link to screenshot of x0 register remaining 0 during write attempt]`

### Test 3: Data Hazard (ALU Forwarding)

[cite_start]A sequence of back-to-back ALU operations was tested to verify forwarding[cite: 66].

**Code Snippet:**
