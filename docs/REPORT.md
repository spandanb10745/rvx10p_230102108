# ⚙️ RVX10-P: Design and Verification Report

---

## 🧩 1. Design Description

The **RVX10-P** is a **5-stage pipelined implementation** of the single-cycle **RVX10** core.  
It implements the full **RV32I** base instruction set plus **10 custom RVX10 ALU operations**:

`ANDN, ORN, XNOR, MIN, MAX, MINU, MAXU, ROL, ROR, ABS`

The datapath is partitioned into five stages:
**IF → ID → EX → MEM → WB**, with pipeline registers between stages and dedicated hazard/forwarding units.

---

### 🧠 High-Level Architecture

![Full Pipelined Datapath](https://github.com/user-attachments/assets/b30e0af6-e2ff-43d2-aaca-5209e3659a5a)  
*Figure 1 — High-Level Block Diagram of the RVX10-P Core*

---

### 🔹 Pipeline Stages and Registers

**IF (Instruction Fetch)**  
![IF Stage Datapath](https://github.com/user-attachments/assets/a79442b9-64f6-428f-9b2a-f44436fe925e)  
**IF/ID Register**  
![IF/ID Register Code](https://github.com/user-attachments/assets/4b1bd6b7-6295-4271-9eae-c841fac95c0f)

**ID (Instruction Decode)**  
![ID/EX Datapath Register Code (Part 1)](https://github.com/user-attachments/assets/7840d3ba-5395-4d58-b561-043361db5f90)  
![ID/EX Datapath Register Code (Part 2)](https://github.com/user-attachments/assets/9831c136-7e20-46e3-8b9e-2fb42f62d8bb)  
Control registers for ID/EX:  
![ID/EX Control Register Code (Part 1)](https://github.com/user-attachments/assets/5f93fa7f-932b-4f54-9b74-7220e972e30c)  
![ID/EX Control Register Code (Part 2)](https://github.com/user-attachments/assets/ad66b413-26bf-4c1e-97d4-a2462f0f5fb7)

**EX (Execute)**  
![EX/MEM Datapath Register Code](https://github.com/user-attachments/assets/9d847473-6580-4671-be8d-c1e3af33d5d5)  
![EX/MEM Control Register Code](https://github.com/user-attachments/assets/0dfe4a3b-ae3c-421e-942e-40516b7b5415)

**MEM (Memory Access)**  
![MEM/WB Datapath Register Code](https://github.com/user-attachments/assets/30013c2b-7335-41a4-89d5-458a062ea8a0)  
![MEM/WB Control Register Code](https://github.com/user-attachments/assets/249196b7-3ba9-451c-8c5d-037b12058110)

**WB (Write Back)**  
![WB Stage Datapath](https://github.com/user-attachments/assets/a60f1966-8a07-4b57-97e4-5a1721dfc5d4)

---

## ⚠️ 2. Hazard Handling

Two dedicated units were implemented: **Forwarding Unit** and **Hazard Unit**.

### 🔁 Forwarding Unit (implementation & pseudocode)

![Forwarding Unit Code (Part 1)](https://github.com/user-attachments/assets/8a16a1f8-ddb5-4ded-9e4b-7cc70fef41b1)  
![Forwarding Unit Code (Part 2)](https://github.com/user-attachments/assets/8e6a7abb-b383-4cfe-a9cb-cfbb2d9642be)  
![Forwarding Unit Pseudocode](https://github.com/user-attachments/assets/65fe49bf-ad16-426f-af85-ad0730b6e6d9)

---

### 🚧 Hazard Unit (implementation & pseudocode)

![Hazard Unit Code](https://github.com/user-attachments/assets/d46f0cf5-782b-4058-9104-cf81c62ed0f3)  
![Hazard Unit Pseudocode](https://github.com/user-attachments/assets/b0f71fbc-3d20-4614-ba31-45843ab14897)

---

## 🧪 Verification and Waveforms

### Test 1: Primary Test Program

The primary test program runs a series of instructions and, if all are correct, finishes by storing the value **25** at memory address **100**. The simulation output confirms this success.

<details>
<summary><b>Click to expand Test Program Details (RVX10, Encodings, Assembly)</b></summary>

The program exercises both standard RISC-V instructions and the 10 custom RVX10 instructions.

![The RVX10 Instruction Set (10 ops)](https://github.com/user-attachments/assets/8389582a-fc73-4436-9245-5e7963b313ee)
![Encoding Table (Concrete)](https://github.com/user-attachments/assets/62deca4f-a804-4f6e-9954-b0ef7a0dbb8c)

#### Instruction format (R-type style used by RVX10)

Bit positions (MSB left):

31 25 24 20 19 15 14 12 11 7 6 0
+-----------+------+-----+-------+-----+-------+
| func7 | rs2 | rs1 | func3 | rd | op |
+-----------+------+-----+-------+-----+-------+

All RVX10 custom instructions use the 7-bit opcode `0001011`.

---

*x2=25; x9=18; (Loaded before the commands below)*

#### Test Program Table

| Label   | RISC-V Assembly   | Description                          |           Address | Machine\_Code |            |
| ------- | ----------------- | ------------------------------------ | ----------------: | ------------: | ---------- |
| main:   | addi x2,x0,5      | x2 = 5                               |              0x00 |    0x00500113 |            |
|         | addi x3,x0,12     | x3 = 12                              |              0x04 |    0x00C00193 |            |
|         | addi x7,x3,-9     | x7 = 12 - 9 = 3                      |              0x08 |    0xFF718393 |            |
|         | or   x4,x7,x2     | x4 = 3 OR 5 = 7                      |              0x0C |    0x0023E233 |            |
|         | and  x5,x3,x4     | x5 = 12 AND 7 = 4                    |              0x10 |    0x0041F2B3 |            |
|         | add  x5,x5,x4     | x5 = 4 + 7 = 11                      |              0x14 |    0x004282B3 |            |
|         | beq  x5,x7,end    | branch if x5 == x7 (not taken)       |              0x18 |    0x02728863 |            |
|         | slt  x4,x3,x4     | x4 = (12 < 7) = 0                    |              0x1C |    0x0041A233 |            |
|         | beq  x4,x0,around | branch if x4 == 0 (taken)            |              0x20 |    0x00020463 |            |
|         | addi x5,x0,0      | should not execute                   |              0x24 |    0x00000293 |            |
| around: | slt  x4,x7,x2     | x4 = (3 < 5) = 1                     |              0x28 |    0x0023A233 |            |
|         | add  x7,x4,x5     | x7 = 1 + 11 = 12                     |              0x2C |    0x005203B3 |            |
|         | sub  x7,x7,x2     | x7 = 12 - 5 = 7                      |              0x30 |    0x402383B3 |            |
|         | sw   x7,84(x3)    | \[96] = 7                            |              0x34 |    0x0471AA23 |            |
|         | lw   x2,96(x0)    | x2 = \[96] = 7                       |              0x38 |    0x06002103 |            |
|         | add  x9,x2,x5     | x9 = 7 + 11 = 18                     |              0x3C |    0x005104B3 |            |
|         | jal  x3,end       | jump to end, x3 = 0x44               |              0x40 |    0x008001EF |            |
|         | addi x2,x0,1      | should not execute                   |              0x44 |    0x00100113 |            |
| end:    | add  x2,x2,x9     | x2 = 7 + 18 = 25                     |              0x48 |    0x00910133 |            |
|         | andn x10,x2,x9    | x10 = 25 & \~18 = 9                  |              0x4C |    0x0091050B |            |
|         | orn  x11,x2,x9    | x11 = 4294967293                     |              0x50 |    0x0091158B |            |
|         | xorn x12,x2,x9    | x12 = 25 ^ \~18 = 4294967284         |              0x54 |    0x0091260B |            |
|         | min  x13,x2,x9    | x13 = min(25,18) = 18                |              0x58 |    0x0291068B |            |
|         | max  x14,x2,x9    | x14 = max(25,18) = 25                |              0x5C |    0x0291170B |            |
|         | minu x15,x2,x9    | x15 = min unsigned(25,18) = 18       |              0x60 |    0x0291278B |            |
|         | maxu x16,x2,x9    | x16 = max unsigned(25,18) = 25       |              0x64 |    0x0291380B |            |
|         | ROL  x17,x2,x9    | x17 = 25 << 18 (rotl) = 6553600      |              0x68 |    0x0491088B |            |
|         | ROR  x18,x4,x4    | x18 = 1 >> 1 = 0x80000000 (INT\_MIN) |              0x6C |    0x0442190B |            |
|         | ABS  x19,x18,x0   | x19 = ABS(INT\_MIN) = 0x80000000     |              0x70 |    0x0609098B |            |
|         | ROR  x20,x9,x0    | x20 = x9 (no shift)                  |              0x74 |    0x04049A0B |            |
|         | add  x0,x2,x9     | x0 written = ignored                 |              0x78 |    0x06910033 |            |
|         | sw   x0,0x20(x3)  | \[100] = 25                          |              0x7C |    0x0221A023 |            |
| done:   | beq  x2,x2,done   | infinite loop                        |              0x80 |    0x00210063 |            |

*0x80000000= 2147483648
---

**Test Program (`risctest.mem`)**
![risctest.mem (Part 1)](https://github.com/user-attachments/assets/a7710874-5da2-47a9-b648-a8fef01ba181)
![risctest.mem (Part 2)](https://github.com/user-attachments/assets/3a967e8c-093e-4f6f-acdb-0c3e7a98e328)

</details>

---

### Test 2: `x0` Register Integrity

The `x0` register is hardwired to zero. A test instruction (`add x0,x2,x9` in 0x78 PC) was executed to confirm that its value cannot be overwritten. Waveforms show the write attempt through EX, MEM, WB, but the register file prevents the write.

![x0 Write Attempt in EX Stage](https://github.com/user-attachments/assets/cf858e0f-6ad6-4637-ac1d-60e869e5cc36)
![x0 Write Attempt in MEM Stage](https://github.com/user-attachments/assets/d9c74e03-c83b-4412-a24e-1868904bd818)
![x0 Write Attempt in WB Stage](https://github.com/user-attachments/assets/1eb6797c-3c0a-434e-83a8-abf6bfa8bc10)
![x0 Register in RegFile (Stays X/0)](https://github.com/user-attachments/assets/25123f46-b990-4170-b32e-1b691d37e3fb)
![Register File Write Logic (Prevents x0 Write)](https://github.com/user-attachments/assets/f8bae6c3-f868-423d-8125-9cacc9ecbd36)

---

### Test 3: Data Hazard (ALU Forwarding)

Back-to-back ALU operations were tested to verify forwarding.

**Test 1:**
- `addi x3,x0,12` in 0x04 PC followed by `addi x7,x3,-9`  in 0x08 PC
- `x3` value not yet in register file, forwarded from `ALUResultM`  

![Forwarding Test 1 (EX Stage)](https://github.com/user-attachments/assets/6e9ef5b5-ef7b-46c5-a664-205aac77b00d)
![Forwarding Test 1 (Waveform)](https://github.com/user-attachments/assets/4ed61edd-3e10-4814-a1be-3ce66a17827c)

**Test 2:**
- `add x7,x4,x5` in 0x2C PC followed by `sub x7,x7,x2`  in 0x30 PC
- Forwarded ALU result ensures correct computation

![Forwarding Test 2 (EX Stage)](https://github.com/user-attachments/assets/f201ee02-8168-43e0-9bd9-dd6fe3409aba)
![Forwarding Test 2 (Waveform)](https://github.com/user-attachments/assets/5e478367-e20b-4c8e-ad46-3a0b03e93385)

---

### Test 4: Data Hazard (Load-Use Stall)

- `lw x2,96(x0)` in 0x38 PC address followed by `add x9,x2,x5`  in 0x3C PC
- Hazard unit detects dependency, asserts `StallF` and `StallD`, flushes EX stage

![Load-Use Stall Waveform](https://github.com/user-attachments/assets/fc9d41c8-1da7-4a56-9ebf-87b36fa596bf)

---

### Test 5: Control Hazard (Branch Flush)

- `beq x4,x0,around`  in 0x20 PC taken branch  
- Pipeline flushes the incorrectly fetched instruction(s)

![Branch Hazard Before Flush](https://github.com/user-attachments/assets/d72d300c-dc99-49c9-bd1a-9cdab0634d8d)
![Branch Hazard After Flush](https://github.com/user-attachments/assets/9428145e-c6fd-452a-89ee-ba5d847887f1)


### 🧵 Test 6: Pipeline Concurrency

Multiple instructions in-flight — pipeline snapshots:

![Pipeline State (T=n)](https://github.com/user-attachments/assets/6ac72346-8082-45cb-a2b6-7193c8458b8e)  
![Pipeline State (T=n+1)](https://github.com/user-attachments/assets/c7a0013c-47b7-4eb5-a6c1-081c2e30c194)

---

## ⚡ 4. Performance Analysis (Bonus)

### 🧮 Performance Counters

Implementation and testbench display for cycle/instruction counters:

![Testbench Counter Logic (Declarations)](https://github.com/user-attachments/assets/1ce02f08-7541-4206-9576-5489033ae604)  
![Testbench Counter Logic (Display)](https://github.com/user-attachments/assets/453859bb-a3b7-43f4-a4be-80d4f9cfbaa5)
![riscv module screenshot](https://github.com/user-attachments/assets/478d2116-d0a6-4f9b-b4bf-685a74c207fa)
![riscv module screenshot](https://github.com/user-attachments/assets/af6a1f69-6a3c-450c-94b8-ae87cb66896b)
![riscv module screenshot](https://github.com/user-attachments/assets/f59699b0-5e69-4e12-ba69-9436605c7028)
![riscv module screenshot](https://github.com/user-attachments/assets/73689882-b05c-417a-8c27-800a280ddf2a)
![riscv module screenshot](https://github.com/user-attachments/assets/e49a4015-d5ee-4e0b-bc58-0e60b9271c43)

---

### 📊 Results Comparison & Final States

**Final register/memory comparisons (single-cycle vs pipelined):**

![Single-Cycle Final Register File](https://github.com/user-attachments/assets/c2234ee3-e8ce-4f80-bfb9-e5c0706d9e3b)  
![Pipelined Final Register File](https://github.com/user-attachments/assets/8a5132c5-2d4b-4acb-a1ac-e8ff44a3564d)  
![Single-Cycle Final Data Memory](https://github.com/user-attachments/assets/7dc925cc-fe2b-479e-93e9-099b12730d8e)  
![Pipelined Final Data Memory](https://github.com/user-attachments/assets/f2ed65ec-a5a0-4f37-b1d6-e096c07578a9)

**CPI visuals:**  
![Single-Cycle CPI Result](https://github.com/user-attachments/assets/680e4599-d6ab-41c8-8e22-fcadae0da18d)  
![Pipelined CPI Result](https://github.com/user-attachments/assets/a276b24b-e81f-45e1-b142-9f5c0d9f9ffc)


**Summary table**

| Core | Cycles | Instructions | CPI |
|---:|---:|---:|---:|
| Single-Cycle RVX10 | 29 | 29 | 1.00 |
| Pipelined RVX10-P | 39 | 31 | 1.256 |
> 35 cycles as for theory for 31 instructions, the formula is (n-1+k) where k are the stages and n is the total no. of instructions.
> As for n = 31 , it should come to be total cycles as 35 cycles but for 1 branch and 1 jump success. There will be 4 penalties.
> 31 instructions as two are not to be executed due to 1 branch success and 1 jump success.
> Note: pipeline fill/drain and stalls cause CPI > 1; the pipelined design still wins in time because of shorter clock period per stage.
---

## 🏁 5. Simulation Output

Self-checking testbench prints success when memory[100] == 25:

![Simulation Succeeded in Console (Example 1)](https://github.com/user-attachments/assets/33db9c56-eb1d-404a-b9c1-7b04d96c3e48)

---

## 📊 Instruction Type Distribution

The benchmark program executed a total of **33 instructions**, categorized as follows:

| **Instruction Type** | **Count** | **Percentage** |
|----------------------:|:---------:|:---------------:|
| **R-type**            | 21        | 63.64% |
| **I-type**            | 5         | 15.15% |
| **Branch**            | 3         | 9.09% |
| **Store**             | 2         | 6.06% |
| **Load**              | 1         | 3.03% |

---

## 🔧 Improvements & Future Work

![Benchmark Placeholder](https://github.com/user-attachments/assets/6952c882-4510-4698-9f61-ace036f2e8b3)


During testing, the **RVX10-P** core achieved **39 cycles for 31 instructions**, giving an **average CPI ≈ 1.258**.  
However, this result is **abstract** — it was not based on a standardized benchmark suite but rather on a self-constructed instruction sequence.
Now I can also design a testbench which contains 51 instructions containing only 2 branch instructions that are successful. So by theoretical calculations I will get CPI as 59/51= 1.156.
So, In my testbench as you keep branch and jump instructions constant and increase the testbench by adding instructions other than branch, jump or load, you can potentially even reach nearer to 1 CPI.

### 💡 Proposed Improvement
A key next step would be to:
- **Design a dedicated benchmark-driven testbench**, simulating realistic instruction mixes (arithmetic, logic, load/store, branch, and jump operations).
- **Compare theoretical and practical CPI values**, refining the pipeline control and forwarding mechanisms to minimize stalls and bubbles.

### 🧩 Outcome
This enhancement would make the performance analysis more robust, allowing future iterations of **RVX10-P** to:
- Achieve **benchmark-consistent CPI values**
- **Validate real-world throughput efficiency**
- Strengthen the design’s credibility through **quantitative comparison** of simulated vs. theoretical results.

## 📚 References

- *Digital Design and Computer Architecture (RISC-V Edition)* — David Harris & Sarah Harris  
- *Single-Cycle RVX10 Core:* https://github.com/spandanb10745/CS322M-230102108/tree/main/RVX10  
- Reference diagram:  
  ![Reference Diagram](https://github.com/user-attachments/assets/87863e0f-9cb3-4b95-a4ff-1014210ddfe1)

---

## 🏫 Acknowledgment

Developed under the guidance of  
**Dr. Satyajit Das**  
*Assistant Professor*  
Department of **Computer Science and Engineering**  
**Indian Institute of Technology, Guwahati**
