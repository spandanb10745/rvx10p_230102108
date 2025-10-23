# ⚙️ RVX10-P: 5-Stage Pipelined RISC-V Core

---

## 🧩 1. Design Description

The **RVX10-P** is a **5-stage pipelined implementation** of the single-cycle **RVX10** core.  
It implements the full **RV32I** base instruction set plus **10 custom RVX10 ALU operations**:

`ANDN, ORN, XNOR, MIN, MAX, MINU, MAXU, ROL, ROR, ABS`

The primary goal was to partition the single-cycle datapath into **five distinct stages**:
> **IF → ID → EX → MEM → WB**

This increases instruction throughput by distributing combinational logic and adding pipeline registers to hold intermediate data and control signals between stages.

---

### 🧠 High-Level Architecture

The design follows the classic 5-stage RISC-V pipeline.  
Core logic from the single-cycle implementation was separated, and dedicated pipeline registers were added to isolate each stage.

![Full Pipelined Datapath](https://github.com/user-attachments/assets/b30e0af6-e2ff-43d2-aaca-5209e3659a5a)  
*Figure 1: High-Level Block Diagram of the RVX10-P Core*

Key additional components:
- **Forwarding Unit** – resolves data hazards  
- **Hazard Unit** – detects load-use and control hazards  

---

### 🔹 Pipeline Stages and Registers

| Stage | Description | Pipeline Register(s) |
|:------|:-------------|:---------------------|
| **IF** | Fetches instruction from `imem` | `IF_ID` |
| **ID** | Decodes, reads registers, extends immediates | `ID_IEx`, `c_ID_IEx` |
| **EX** | ALU executes and computes branch targets | `IEx_IMem`, `c_IEx_IM` |
| **MEM** | Reads/writes data memory | `IMem_IW`, `c_IM_IW` |
| **WB** | Writes results to `RegFile` | — |

Each stage uses flip-flop-based pipeline registers for datapath and control signals.

---

## ⚠️ 2. Hazard Handling

### 🔁 Forwarding Unit

Resolves **Read-After-Write (RAW)** hazards by forwarding results from MEM or WB to EX stage inputs.  
Compares source registers (`Rs1E`, `Rs2E`) with destination registers (`RdM`, `RdW`).

#### Forwarding Unit Implementation
![Forwarding Unit Code (Part 1)](https://github.com/user-attachments/assets/8a16a1f8-ddb5-4ded-9e4b-7cc70fef41b1)
![Forwarding Unit Code (Part 2)](https://github.com/user-attachments/assets/8e6a7abb-b383-4cfe-a9cb-cfbb2d9642be)
![Forwarding Unit Pseudocode](https://github.com/user-attachments/assets/65fe49bf-ad16-426f-af85-ad0730b6e6d9)

---

### 🚧 Hazard Unit

Detects and resolves:
1. **Load-Use Hazards** → Stalls IF/ID and injects a bubble in EX  
2. **Control Hazards** → Flushes IF and ID if branch taken (`PCSrcE`)

#### Hazard Unit Implementation
![Hazard Unit Code](https://github.com/user-attachments/assets/d46f0cf5-782b-4058-9104-cf81c62ed0f3)
![Hazard Unit Pseudocode](https://github.com/user-attachments/assets/b0f71fbc-3d20-4614-ba31-45843ab14897)

---

## 🧪 3. Verification and Waveforms

The self-checking test program (`risctest.mem` / `rvx_pipeline.hex`) validates:
- Base **RV32I** and custom **RVX10** instructions  
- All **data** and **control hazard** scenarios  

If the processor executes correctly, the simulation displays:
Simulation Succeeded

---

### ✅ Test 1: Functional Correctness

Final memory address **100** holds value **25** — confirming correctness.

<details>
<summary><b>Click to expand: RVX10 Instruction Encodings & Test Program</b></summary>

*(Include instruction encodings, binary formats, and memory initialization details here.)*

</details>

---

### 🧱 Test 2: `x0` Register Integrity

Confirms writes to `x0` are ignored (`add x0, x2, x9` → no effect).

![x0 Write Attempt in WB Stage](https://github.com/user-attachments/assets/1eb6797c-3c0a-434e-83a8-abf6bfa8bc10)
![Register File Write Logic (Prevents x0 Write)](https://github.com/user-attachments/assets/f8bae6c3-f868-423d-8125-9cacc9ecbd36)

---

### 🔄 Test 3: Data Hazard (ALU Forwarding)

Back-to-back ALU operations use forwarded values.

| Instruction | Description |
|:-------------|:-------------|
| `addi x7,x3,-9` | uses forwarded value from `x3=12` |
| `sub x7,x7,x2` | uses forwarded ALU result |

![Forwarding Test Waveform](https://github.com/user-attachments/assets/5e478367-e20b-4c8e-ad46-3a0b03e93385)

---

### 🕒 Test 4: Load-Use Hazard (Stall)

The `lw` followed by `add` causes a one-cycle stall detected by `hazard_unit`.

![Load-Use Stall Waveform](https://github.com/user-attachments/assets/fc9d41c8-1da7-4a56-9ebf-87b36fa596bf)

---

### 🔀 Test 5: Control Hazard (Branch Flush)

A taken `beq` flushes IF/ID pipeline stages (`FlushD`, `FlushE` asserted).

![Branch Hazard (After Flush)](https://github.com/user-attachments/assets/9428145e-c6fd-452a-89ee-ba5d847887f1)

---

### 🧵 Test 6: Pipeline Concurrency

Multiple instructions execute simultaneously — one per stage.

![Pipeline State (T=n+1)](https://github.com/user-attachments/assets/c7a0013c-47b7-4eb5-a6c1-081c2e30c194)

---

## ⚡ 4. Performance Analysis

### 🧮 Performance Counters

Counters for `cycle_count` and `instr_retired` implemented in the testbench.

![Testbench Counter Logic](https://github.com/user-attachments/assets/2f8540de-ccc5-40f7-ab8c-637543b610e5)

---

### 📊 Results Comparison

| Core | Cycles | Instructions | CPI | Comment |
|:------|:-------|:-------------|:----|:---------|
| **Single-Cycle RVX10** | 29 | 29 | **1.00** | Baseline |
| **Pipelined RVX10-P** | 38 | 29 | **1.31** | Slightly higher CPI due to stalls |

> ⏱️ Even though RVX10-P has a slightly higher CPI, its **clock period is much shorter**, resulting in higher **throughput** overall.

---

### 🧩 Architectural Equivalence

Both single-cycle and pipelined cores produce identical register and memory states.

![Pipelined Final Register File](https://github.com/user-attachments/assets/8a5132c5-2d4b-4acb-a1ac-e8ff44a3564d)

---

## 🏁 5. Simulation Output

Successful execution prints:

Simulation Succeeded

![Simulation Succeeded in Console](https://github.com/user-attachments/assets/33db9c56-eb1d-404a-b9c1-7b04d96c3e48)

---

## 📚 References

- *Digital Design and Computer Architecture (RISC-V Edition)* — David Harris & Sarah Harris  
- *Single-Cycle RVX10 Core:* [GitHub – RVX10](https://github.com/spandanb10745/CS322M-230102108/tree/main/RVX10)  
- Reference Block Diagram (Harris & Harris)
  
  ![Reference Diagram](https://github.com/user-attachments/assets/87863e0f-9cb3-4b95-a4ff-1014210ddfe1)

---

## 🏫 Acknowledgment

Developed under the guidance of  
**Dr. Satyajit Das**  
*Assistant Professor*  
Department of **Computer Science and Engineering**  
**Indian Institute of Technology, Guwahati**
