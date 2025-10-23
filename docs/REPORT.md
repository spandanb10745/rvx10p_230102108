# RVX10-P: Design and Verification Report

**Author**: spandan_bharadwaj//230102108

**References**:
* Digital Design & Computer Architecture (RISC-V Edition) by Harris & Harris
* Single-Cycle RVX10 Core: [https://github.com/spandanb10745/CS322M-230102108/tree/main/RVX10](https://github.com/spandanb10745/CS322M-230102108/tree/main/RVX10)
* Reference Textbook Diagram:
    ![Sample of Sarah Harris ref book Digital design and computer architecture](https://github.com/user-attachments/assets/87863e0f-9cb3-4b95-a4ff-1014210ddfe1)

---

## 1. Design Description

The RVX10-P is a 5-stage pipelined implementation of the single-cycle RVX10 core. It implements the full RV32I base instruction set plus the 10 custom RVX10 ALU operations (ANDN, ORN, XNOR, MIN, MAX, MINU, MAXU, ROL, ROR, ABS).

The primary goal was to partition the single-cycle datapath into five distinct stages (IF, ID, EX, MEM, WB) to increase instruction throughput. This involved distributing the combinational logic across the stages and introducing pipeline registers to hold intermediate data and control signals between stages.

### High-Level Architecture

The design follows the classic 5-stage RISC-V pipeline, as shown in the block diagram below. The core logic from the single-cycle implementation was separated, and dedicated pipeline registers were added to isolate each stage.

![Full Pipelined Datapath](https://github.com/user-attachments/assets/b30e0af6-e2ff-43d2-aaca-5209e3659a5a)
*Figure 1: High-Level Block Diagram of the RVX10-P Core*

[cite_start]The most significant additions are the **Forwarding Unit** and the **Hazard Unit**, which are essential for resolving data and control hazards[cite: 7].

### Pipeline Stages and Registers

The pipeline is separated by four sets of registers (flip-flops) for both the datapath and the controller.

1.  **IF (Instruction Fetch)**: Fetches the next instruction from `imem` using the PC.
    * `IF` Datapath Logic:
        ![IF Stage Datapath](https://github.com/user-attachments/assets/a79442b9-64f6-428f-9b2a-f44436fe925e)
    * `IF_ID` **Register**: Latches the fetched `InstrF` and `PCPlus4F` to be used in the Decode stage.
        ![IF/ID Register Code](https://github.com/user-attachments/assets/4b1bd6b7-6295-4271-9eae-c841fac95c0f)

2.  **ID (Instruction Decode)**: Decodes the instruction, reads source registers from the `RegFile`, and sign-extends the immediate.
    * `ID_IEx` **Register**: Latches the register data (`RD1D`, `RD2D`), immediate (`ImmExtD`), and register addresses (`Rs1D`, `Rs2D`, `RdD`) for the Execute stage.
        ![ID/EX Datapath Register Code (Part 1)](https://github.com/user-attachments/assets/7840d3ba-5395-4d58-b561-043361db5f90)
        ![ID/EX Datapath Register Code (Part 2)](https://github.com/user-attachments/assets/9831c136-7e20-46e3-8b9e-2fb42f62d8bb)
    * `c_ID_IEx` **Register**: Latches the control signals (e.g., `ALUSrcD`, `BranchD`, `MemWriteD`) for the Execute stage.
        ![ID/EX Control Register Code (Part 1)](https://github.com/user-attachments/assets/5f93fa7f-932b-4f54-9b74-7220e972e30c)
        ![ID/EX Control Register Code (Part 2)](https://github.com/user-attachments/assets/ad66b413-26bf-4c1e-97d4-a2462f0f5fb7)

3.  **EX (Execute)**: The ALU performs the operation. It calculates branch targets and determines branch outcomes.
    * `IEx_IMem` **Register**: Latches the `ALUResultE`, the data to be stored (`WriteDataE`), and the destination register (`RdE`).
        ![EX/MEM Datapath Register Code](https://github.com/user-attachments/assets/9d847473-6580-4671-be8d-c1e3af33d5d5)
    * `c_IEx_IM` **Register**: Latches the control signals (`MemWriteE`, `RegWriteE`) for the Memory stage.
        ![EX/MEM Control Register Code](https://github.com/user-attachments/assets/0dfe4a3b-ae3c-421e-942e-40516b7b5415)

4.  **MEM (Memory Access)**: Reads from or writes to the `dmem`.
    * `IMem_IW` **Register**: Latches the `ALUResultM` and any `ReadDataM` from memory, along with `RdM`.
        ![MEM/WB Datapath Register Code](https://github.com/user-attachments/assets/30013c2b-7335-41a4-89d5-458a062ea8a0)
    * `c_IM_IW` **Register**: Latches the `RegWriteM` control signal for the WriteBack stage.
        ![MEM/WB Control Register Code](https://github.com/user-attachments/assets/249196b7-3ba9-451c-8c5d-037b12058110)

5.  **WB (Write Back)**: Writes the final result back to the `RegFile`.
    * `WB` Datapath Logic:
        ![WB Stage Datapath](https://github.com/user-attachments/assets/a60f1966-8a07-4b57-97e4-5a1721dfc5d4)

---

## 2. Hazard Handling

To ensure correct execution, two dedicated units were implemented as per the design requirements.

### Forwarding Unit

The `forwarding_unit` resolves Read-After-Write (RAW) data hazards by forwarding results from the EX or MEM stages directly to the ALU inputs. This avoids unnecessary stalls. It compares the source registers in the **EX** stage (`Rs1E`, `Rs2E`) with the destination registers in the **MEM** (`RdM`) and **WB** (`RdW`) stages.

![Forwarding Unit Code (Part 1)](https://github.com/user-attachments/assets/8a16a1f8-ddb5-4ded-9e4b-7cc70fef41b1)
![Forwarding Unit Code (Part 2)](https://github.com/user-attachments/assets/8e6a7abb-b383-4cfe-a9cb-cfbb2d9642be)
![Forwarding Unit Pseudocode](https://github.com/user-attachments/assets/65fe49bf-ad16-426f-af85-ad0730b6e6d9)

### Hazard Unit

The `hazard_unit` detects two conditions:
1.  **Load-Use Hazard**: Detects if an instruction in the **ID** stage depends on the result of a `lw` instruction currently in the **EX** stage. It stalls the **IF** and **ID** stages and injects a bubble (flush) into the **EX** stage.
2.  **Control Hazard**: Detects if a branch is taken in the **EX** stage (via `PCSrcE`). [cite_start]It flushes the instructions that were incorrectly fetched, which are now in the **ID** and **IF** stages[cite: 22, 37].

![Hazard Unit Code](https://github.com/user-attachments/assets/d46f0cf5-782b-4058-9104-cf81c62ed0f3)
![Hazard Unit Pseudocode](https://github.com/user-attachments/assets/b0f71fbc-3d20-4614-ba31-45843ab14897)

---

## 3. Verification and Waveforms

The test strategy relied on a self-checking test program (`risctest.mem` or `rvx_pipeline.hex`) used for ad-hoc testing. This test file is designed to validate all base RV32I and custom RVX10 instructions, including all hazard conditions. Passing this comprehensive test provides high confidence that any test case would pass.

### Test 1: Functional Correctness

The primary test program runs a series of instructions and, if all are correct, finishes by storing the value **25** at memory address **100**. The simulation output confirms this success.

<details>
<summary><b>Click to expand Test Program Details (RVX10, Encodings, Assembly)</b></summary>

The program exercises both standard RISC-V instructions and the 10 custom RVX10 instructions.

![The RVX10 Instruction Set (10 ops)](https://github.com/user-attachments/assets/8389582a-fc73-4436-9245-5e7963b313ee)
![Encoding Table (Concrete)](https://github.com/user-attachments/assets/62deca4f-a804-4f6e-9954-b0ef7a0dbb8c)

#### Instruction format (R-type style used by RVX10)

Bit positions (MSB left):
