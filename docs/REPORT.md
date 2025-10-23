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

The most significant additions are the **Forwarding Unit** and the **Hazard Unit**, which are essential for resolving data and control hazards.

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
2.  **Control Hazard**: Detects if a branch is taken in the **EX** stage (via `PCSrcE`). It flushes the instructions that were incorrectly fetched, which are now in the **ID** and **IF** stages.

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
31 25 24 20 19 15 14 12 11 7 6 0 +-----------+------+-----+-------+-----+-------+ | func7 | rs2 | rs1 | func3 | rd | op | +-----------+------+-----+-------+-----+-------+

All RVX10 custom instructions use the 7-bit opcode `0001011`.

---
*x2=25; *x9=18; (Loaded before the commands below)*

#### Encoding table (concrete)

| func7 | rs2 | rs1 | func3 | rd | op | machine_code | assembly |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 0000000 | 01001 | 00010 | 000 | 01010 | 0001011 | 0x0091050B | `ANDN x10,x2,x9` |
| 0000000 | 01001 | 00010 | 001 | 01011 | 0001011 | 0x0091158B | `ORN  x11,x2,x9` |
| 0000000 | 01001 | 00010 | 010 | 01100 | 0001011 | 0x0091260B | `XORN x12,x2,x9` |
| 0000001 | 01001 | 00010 | 000 | 01101 | 0001011 | 0x0291068B | `MIN  x13,x2,x9` |
| 0000001 | 01001 | 00010 | 001 | 01110 | 0001011 | 0x0291170B | `MAX  x14,x2,x9` |
| 0000001 | 01001 | 00010 | 010 | 01111 | 0001011 | 0x0291278B | `MINU x15,x2,x9` |
| 0000001 | 01001 | 00010 | 011 | 10000 | 0001011 | 0x0291380B | `MAXU x16,x2,x9` |
| 0000010 | 01001 | 00010 | 000 | 10001 | 0001011 | 0x0491088B | `ROL  x17,x2,x9` |
| 0000010 | 00100 | 00100 | 001 | 10010 | 0001011 | 0x0442190B | `ROR  x18,x4,x4` |
| 0000011 | 00000 | 10010 | 000 | 10011 | 0001011 | 0x0609098B | `ABS  x19,x18` |
| 0000010 | 00000 | 01001 | 001 | 10100 | 0001011 | 0x04049A0B | `ROR  x20,x9,x0` |
| 0000000 | 01001 | 00010 | 000 | 00000 | 0001011 | 0x00910033 | `ADD  x0,x2,x9` |

---
#### Test Program Table

| Label | RISC-V Assembly | Description | Address | Machine_Code |
| :--- | :--- | :--- | ---: | ---: |
| main: | addi x2,x0,5 | x2 = 5 | 0x00 | 0x00500113 |
| | addi x3,x0,12 | x3 = 12 | 0x04 | 0x00C00193 |
| | addi x7,x3,-9 | x7 = 12 - 9 = 3 | 0x08 | 0xFF718393 |
| | or x4,x7,x2 | x4 = 3 OR 5 = 7 | 0x0C | 0x0023E233 |
| | and x5,x3,x4 | x5 = 12 AND 7 = 4 | 0x10 | 0x0041F2B3 |
| | add x5,x5,x4 | x5 = 4 + 7 = 11 | 0x14 | 0x004282B3 |
| | beq x5,x7,end | branch if x5 == x7 (not taken) | 0x18 | 0x02728863 |
| | slt x4,x3,x4 | x4 = (12 < 7) = 0 | 0x1C | 0x0041A233 |
| | beq x4,x0,around | branch if x4 == 0 (taken) | 0x20 | 0x00020463 |
| | addi x5,x0,0 | should not execute | 0x24 | 0x00000293 |
| around: | slt x4,x7,x2 | x4 = (3 < 5) = 1 | 0x28 | 0x0023A233 |
| | add x7,x4,x5 | x7 = 1 + 11 = 12 | 0x2C | 0x005203B3 |
| | sub x7,x7,x2 | x7 = 12 - 5 = 7 | 0x30 | 0x402383B3 |
| | sw x7,84(x3) | \[96] = 7 | 0x34 | 0x0471AA23 |
| | lw x2,96(x0) | x2 = \[96] = 7 | 0x38 | 0x06002103 |
| | add x9,x2,x5 | x9 = 7 + 11 = 18 | 0x3C | 0x005104B3 |
| | jal x3,end | jump to end, x3 = 0x44 | 0x40 | 0x008001EF |
| | addi x2,x0,1 | should not execute | 0x44 | 0x00100113 |
| end: | add x2,x2,x9 | x2 = 7 + 18 = 25 | 0x48 | 0x00910133 |
| | andn x10,x2,x9 | x10 = 25 & ~18 = 9 | 0x4C | 0x0091050B |
| | orn x11,x2,x9 | x11 = 4294967293 | 0x50 | 0x0091158B |
| | xorn x12,x2,x9 | x12 = 25 ^ ~18 = 4294967284 | 0x54 | 0x0091260B |
| | min x13,x2,x9 | x13 = min(25,18) = 18 | 0x58 | 0x0291068B |
| | max x14,x2,x9 | x14 = max(25,18) = 25 | 0x5C | 0x0291170B |
| | minu x15,x2,x9 | x15 = min unsigned(25,18) = 18 | 0x60 | 0x0291278B |
| | maxu x16,x2,x9 | x16 = max unsigned(25,18) = 25 | 0x64 | 0x0291380B |
| | ROL x17,x2,x9 | x17 = 25 << 18 (rotl) = 6553600 | 0x68 | 0x0491088B |
| | ROR x18,x4,x4 | x18 = 1 >> 1 = 0x80000000 | 0x6C | 0x0442190B |
| | ABS x19,x18,x0 | x19 = ABS(INT_MIN) = 0x80000000 | 0x70 | 0x0609098B |
| | ROR x20,x9,x0 | x20 = x9 (no shift) | 0x74 | 0x04049A0B |
| | add x0,x2,x9 | x0 written = ignored | 0x78 | 0x06910033 |
| | `sw x2, 100(x0)` | `[100] = 25` | 0x7C | `0x01902823` |
| done: | beq x2,x2,done | infinite loop | 0x80 | 0x00210063 |



**Test Program (`risctest.mem`)**
![risctest.mem (Part 1)](https://github.com/user-attachments/assets/a7710874-5da2-47a9-b648-a8fef01ba181)
![risctest.mem (Part 2)](https://github.com/user-attachments/assets/3a967e8c-093e-4f6f-acdb-0c3e7a98e328)

</details>

---

### Test 2: `x0` Register Integrity

The `x0` register is hardwired to zero. A test instruction (`add x0,x2,x9`) was executed to confirm that its value cannot be overwritten. The waveforms below show the write attempting to proceed through the pipeline, but the register file's internal logic (shown last) prevents the write, as `a3 != 0` is false.

![x0 Write Attempt in EX Stage](https://github.com/user-attachments/assets/cf858e0f-6ad6-4637-ac1d-60e869e5cc36)
![x0 Write Attempt in MEM Stage](https://github.com/user-attachments/assets/d9c74e03-c83b-4412-a24e-1868904bd818)
![x0 Write Attempt in WB Stage](https://github.com/user-attachments/assets/1eb6797c-3c0a-434e-83a8-abf6bfa8bc10)
![x0 Register in RegFile (Stays X/0)](https://github.com/user-attachments/assets/25123f46-b990-4170-b32e-1b691d37e3fb)
![Register File Write Logic (Prevents x0 Write)](https://github.com/user-attachments/assets/f8bae6c3-f868-423d-8125-9cacc9ecbd36)

---

### Test 3: Data Hazard (ALU Forwarding)

A sequence of back-to-back ALU operations was tested to verify forwarding.

**Test 1 Code Snippet:**
| Label | RISC-V Assembly | Description | Address | Machine_Code |
| :--- | :--- | :--- | ---: | ---: |
| | addi x3,x0,12 | x3 = 12 | 0x04 | 0x00C00193 |
| | addi x7,x3,-9 | x7 = 12 - 9 = 3 | 0x08 | 0xFF718393 |

**Waveform 1:**
The screenshots show `addi x7,x3,-9` in the EX stage. The value for `x3` (12) is not yet in the register file, so it is **forwarded** from the previous instruction's `ALUResultE` (now in `ALUResultM`). `ForwardAE` is `2'b10`.

![Forwarding Test 1 (EX Stage)](https://github.com/user-attachments/assets/6e9ef5b5-ef7b-46c5-a664-205aac77b00d)
![Forwarding Test 1 (Waveform)](https://github.com/user-attachments/assets/4ed61edd-3e10-4814-a1be-3ce66a17827c)

**Test 2 Code Snippet:**
| Label | RISC-V Assembly | Description | Address | Machine_Code |
| :--- | :--- | :--- | ---: | ---: |
| | add x7,x4,x5 | x7 = 1 + 11 = 12 | 0x2C | 0x005203B3 |
| | sub x7,x7,x2 | x7 = 12 - 5 = 7 | 0x30 | 0x402383B3 |

**Waveform 2:**
Similarly, the `sub` instruction needs the result of `add`. The value 12 is forwarded from the `ALUResultM` path.

![Forwarding Test 2 (EX Stage)](https://github.com/user-attachments/assets/f201ee02-8168-43e0-9bd9-dd6fe3409aba)
![Forwarding Test 2 (Waveform)](https://github.com/user-attachments/assets/5e478367-e20b-4c8e-ad46-3a0b03e93385)

---

### Test 4: Data Hazard (Load-Use Stall)

A `lw` instruction followed by an immediate use of its result was tested to verify the load-use stall mechanism.

**Code Snippet:**
| Label | RISC-V Assembly | Description | Address | Machine_Code |
| :--- | :--- | :--- | ---: | ---: |
| | lw x2,96(x0) | x2 = [96] = 7 | 0x38 | 0x06002103 |
| | add x9,x2,x5 | x9 = 7 + 11 = 18 | 0x3C | 0x005104B3 |

**Waveform:**
The screenshot below shows the `hazard_unit` detecting the load-use dependency (`lw` in EX, `add` in ID). It asserts `StallF` and `StallD` (freezing the PC and ID stage) and `FlushE` (injecting a bubble into the EX stage). This results in a one-cycle stall.

![Load-Use Stall Waveform](https://github.com/user-attachments/assets/fc9d41c8-1da7-4a56-9ebf-87b36fa596bf)

---

### Test 5: Control Hazard (Branch Flush)

A `beq` instruction that is *taken* was tested to verify the pipeline flush.

**Code Snippet:**
| Label | RISC-V Assembly | Description | Address | Machine_Code |
| :--- | :--- | :--- | ---: | ---: |
| | beq x4,x0,around | branch if x4 == 0 (taken) | 0x20 | 0x00020463 |

**Waveform:**
The screenshot below shows `PCSrcE` asserting (branch taken). In the next cycle, `FlushD` and `FlushE` assert, neutralizing the incorrectly fetched instructions by clearing the pipeline registers.

![Branch Hazard (Before Flush)](https://github.com/user-attachments/assets/d72d300c-dc99-49c9-bd1a-9cdab0634d8d)
![Branch Hazard (After Flush)](https://github.com/user-attachments/assets/9428145e-c6fd-452a-89ee-ba5d847887f1)

---

### Test 6: Pipeline Concurrency

To verify pipelining, a waveform was captured showing multiple instructions in different stages simultaneously, confirming concurrent execution.

![Pipeline State (T=n)](https://github.com/user-attachments/assets/6ac72346-8082-45cb-a2b6-7193c8458b8e)
![Pipeline State (T=n+1)](https://github.com/user-attachments/assets/c7a0013c-47b7-4eb5-a6c1-081c2e30c194)

---

## 4. Performance Analysis (Bonus)

### Performance Counters

Performance counters for `cycle_count` and `instr_retired` were added to the `riscv` module and monitored in the `testbench` as per the optional bonus task.

![Testbench Counter Logic (Declarations)](https://github.com/user-attachments/assets/1ce02f08-7541-4206-9576-5489033ae604)
![Testbench Counter Logic (Display)](https://github.com/user-attachments/assets/2f8540de-ccc5-40f7-ab8c-637543b610e5)
![riscv](https://github.com/user-attachments/assets/817b3765-3776-425f-9223-8821815b53a7)

### Identical Results

The final state of the register file was compared against the single-cycle RVX10 implementation. Both processors produced identical architectural results, proving functional correctness.

![Single-Cycle Final Register File](https://github.com/user-attachments/assets/c2234ee3-e8ce-4f80-bfb9-e5c0706d9e3b)
![Pipelined Final Register File](https://github.com/user-attachments/assets/8a5132c5-2d4b-4acb-a1ac-e8ff44a3564d)
![Single-Cycle Final Data Memory](https://github.com/user-attachments/assets/7dc925cc-fe2b-479e-93e9-099b12730d8e)
![Pipelined Final Data Memory](https://github.com/user-attachments/assets/e25f936d-fb4e-4c56-8998-01b6553e85a3)

### Cycle and CPI Comparison

The same test program was run on both the single-cycle and pipelined cores to compare performance.

* **Single-Cycle (RVX10):**
    * Total Cycles: 29
    * Instructions Retired: 29 *(Manually adjusted from 26; the counter doesn't increment for `sw` or `beq` as `RegWriteW` is 0)*
    * **CPI = 1.0** (By definition, 1 instruction takes 1 *long* clock cycle)
    ![Single-Cycle CPI Result](https://github.com/user-attachments/assets/680e4599-d6ab-41c8-8e22-fcadae0da18d)

* **Pipelined (RVX10-P):**
    * Total Cycles: 38
    * Instructions Retired: 29 *(Manually adjusted from 26 for `sw`/`beq`)*
    * **Average CPI = 1.310** (Calculated: 38 cycles / 29 instrs) 
    ![Pipelined CPI Result](https://github.com/user-attachments/assets/d38dfe05-ecca-4a58-b64b-78c4af50b8ee)

**Analysis:**
At first glance, the pipelined core took *more* clock cycles (38 vs 29). This is expected. The CPI of the pipelined core is greater than the ideal 1.0 due to:
1.  **Pipeline Fill:** The first 4 cycles are "wasted" filling the pipeline.
2.  **Hazard Stalls:** The test program contains load-use and branch hazards, which force stalls and flushes. Each stall/flush increases the `cycle_count` but not the `instr_retired` count, thus increasing the CPI.

However, the **total execution time** is drastically reduced. The single-cycle processor's clock period is limited by its longest path (e.g., `lw`). The pipelined processor's clock period is much smaller, limited only by the longest stage (e.g., EX or MEM).

* `Time (Single-Cycle) = 29 cycles * T_long_cycle`
* `Time (Pipelined) = 38 cycles * T_short_cycle` (where `T_short_cycle` << `T_long_cycle`)

The pipelined core achieves significantly higher instruction throughput, demonstrating the primary advantage of pipelining.

---

## 5. Simulation Succeeded

The self-checking test program verified the end-to-end functional correctness. The testbench monitors the data memory and prints a "Simulation Succeeded" message upon detecting the correct value (25) being written to the target address (100). The console output below confirms this successful execution.

![Simulation Succeeded in Console (Example 1)](https://github.com/user-attachments/assets/33db9c56-eb1d-404a-b9c1-7b04d96c3e48)

