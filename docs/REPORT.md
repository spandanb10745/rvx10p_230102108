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

## 🧪 3. Verification and Waveforms

A self-checking test program (`risctest.mem` / `rvx_pipeline.hex`) verifies the core — if correct, simulation prints `Simulation Succeeded`.

---

### ✅ Test 1: Functional Correctness — Instruction Set & Encodings

![The RVX10 Instruction Set (10 ops)](https://github.com/user-attachments/assets/8389582a-fc73-4436-9245-5e7963b313ee)  
![Encoding Table (Concrete)](https://github.com/user-attachments/assets/62deca4f-a804-4f6e-9954-b0ef7a0dbb8)

**Test program memory images:**  
![risctest.mem (Part 1)](https://github.com/user-attachments/assets/a7710874-5da2-47a9-b648-a8fef01ba181)  
![risctest.mem (Part 2)](https://github.com/user-attachments/assets/3a967e8c-093e-4f6f-acdb-0c3e7a98e328)

---

### 🧱 Test 2: `x0` Register Integrity

Write attempts to `x0` are blocked — waveforms showing attempts and protection:

![x0 Write Attempt in EX Stage](https://github.com/user-attachments/assets/cf858e0f-6ad6-4637-ac1d-60e869e5cc36)  
![x0 Write Attempt in MEM Stage](https://github.com/user-attachments/assets/d9c74e03-c83b-4412-a24e-1868904bd818)  
![x0 Write Attempt in WB Stage](https://github.com/user-attachments/assets/1eb6797c-3c0a-434e-83a8-abf6bfa8bc10)  
![x0 Register in RegFile (Stays X/0)](https://github.com/user-attachments/assets/25123f46-b990-4170-b32e-1b691d37e3fb)  
![Register File Write Logic (Prevents x0 Write)](https://github.com/user-attachments/assets/f8bae6c3-f868-423d-8125-9cacc9ecbd36)

---

### 🔄 Test 3: Data Hazard (ALU Forwarding)

Forwarding results used to resolve RAW dependencies — waveforms and snapshots:

![Forwarding Test 1 (EX Stage)](https://github.com/user-attachments/assets/6e9ef5b5-ef7b-46c5-a664-205aac77b00d)  
![Forwarding Test 1 (Waveform)](https://github.com/user-attachments/assets/4ed61edd-3e10-4814-a1be-3ce66a17827c)  
![Forwarding Test 2 (EX Stage)](https://github.com/user-attachments/assets/f201ee02-8168-43e0-9bd9-dd6fe3409aba)  
![Forwarding Test 2 (Waveform)](https://github.com/user-attachments/assets/5e478367-e20b-4c8e-ad46-3a0b03e93385)

---

### 🕒 Test 4: Load-Use Hazard (Stall)

`lw` followed immediately by use triggers one-cycle stall (StallF/StallD + FlushE):

![Load-Use Stall Waveform](https://github.com/user-attachments/assets/fc9d41c8-1da7-4a56-9ebf-87b36fa596bf)

---

### 🔀 Test 5: Control Hazard (Branch Flush)

Taken branch flushes incorrect IF/ID instructions:

![Branch Hazard (Before Flush)](https://github.com/user-attachments/assets/d72d300c-dc99-49c9-bd1a-9cdab0634d8d)  
![Branch Hazard (After Flush)](https://github.com/user-attachments/assets/9428145e-c6fd-452a-89ee-ba5d847887f1)

---

### 🧵 Test 6: Pipeline Concurrency

Multiple instructions in-flight — pipeline snapshots:

![Pipeline State (T=n)](https://github.com/user-attachments/assets/6ac72346-8082-45cb-a2b6-7193c8458b8e)  
![Pipeline State (T=n+1)](https://github.com/user-attachments/assets/c7a0013c-47b7-4eb5-a6c1-081c2e30c194)

---

## ⚡ 4. Performance Analysis (Bonus)

### 🧮 Performance Counters

Implementation and testbench display for cycle/instruction counters:

![Testbench Counter Logic (Declarations)](https://github.com/user-attachments/assets/1ce02f08-7541-4206-9576-5489033ae604)  
![Testbench Counter Logic (Display)](https://github.com/user-attachments/assets/2f8540de-ccc5-40f7-ab8c-637543b610e5)  
![riscv module screenshot](https://github.com/user-attachments/assets/817b3765-3776-425f-9223-8821815b53a7)

---

### 📊 Results Comparison & Final States

**Final register/memory comparisons (single-cycle vs pipelined):**

![Single-Cycle Final Register File](https://github.com/user-attachments/assets/c2234ee3-e8ce-4f80-bfb9-e5c0706d9e3b)  
![Pipelined Final Register File](https://github.com/user-attachments/assets/8a5132c5-2d4b-4acb-a1ac-e8ff44a3564d)  
![Single-Cycle Final Data Memory](https://github.com/user-attachments/assets/7dc925cc-fe2b-479e-93e9-099b12730d8e)  
![Pipelined Final Data Memory](https://github.com/user-attachments/assets/e25f936d-fb4e-4c56-8998-01b6553e85a3)

**CPI visuals:**  
![Single-Cycle CPI Result](https://github.com/user-attachments/assets/680e4599-d6ab-41c8-8e22-fcadae0da18d)  
![Pipelined CPI Result](https://github.com/user-attachments/assets/d38dfe05-ecca-4a58-b64b-78c4af50b8ee)

**Summary table**

| Core | Cycles | Instructions | CPI |
|---:|---:|---:|---:|
| Single-Cycle RVX10 | 29 | 29 | 1.00 |
| Pipelined RVX10-P | 38 | 29 | 1.31 |

> Note: pipeline fill/drain and stalls cause CPI > 1; the pipelined design still wins in time because of shorter clock period per stage.

---

## 🏁 5. Simulation Output

Self-checking testbench prints success when memory[100] == 25:

![Simulation Succeeded in Console (Example 1)](https://github.com/user-attachments/assets/33db9c56-eb1d-404a-b9c1-7b04d96c3e48)

---

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
