# 🧠 RVX10-P: 5-Stage Pipelined RISC-V Core

**RVX10-P** is a **five-stage pipelined RISC-V processor (RV32I)** enhanced with **10 custom ALU instructions** under the **RVX10 extension**.  
Developed as part of the course **Digital Logic and Computer Architecture** taught by **Dr. Satyajit Das**, **IIT Guwahati**.

---

## 🚀 Overview

RVX10-P transforms a single-cycle implementation into a **high-throughput pipelined core** by partitioning the datapath into five classic stages:

> **IF → ID → EX → MEM → WB**

The processor handles **data and control hazards** effectively using dedicated **Forwarding** and **Hazard** units, ensuring correct execution and efficient performance.

---

## ⚙️ Key Features

### 🧩 Pipeline Architecture
- **5-Stage Pipelined Datapath:** IF, ID, EX, MEM, WB
- **Base ISA:** Fully implements the **RV32I** instruction set
- **Custom Extension (RVX10):** Adds 10 ALU operations:
ANDN, ORN, XNOR, MIN, MAX, MINU, MAXU, ROL, ROR, ABS

### 🔁 Hazard Handling
- **Forwarding Unit:**  
Resolves **Read-After-Write (RAW)** data hazards from **MEM** and **WB** stages.
- **Hazard Unit:**  
Handles **load-use stalls** (1-cycle bubble) and **branch flushes** (via NOP insertion).

### ⚡ Performance
- Achieves an **average CPI ≈ 1.258** on the comprehensive test suite.
- Demonstrates **high throughput and efficiency** compared to the single-cycle version.

---

## 🔧 Improvements & Future Work

![Benchmark Placeholder](https://github.com/user-attachments/assets/6952c882-4510-4698-9f61-ace036f2e8b3)


During testing, the **RVX10-P** core achieved **39 cycles for 31 instructions**, giving an **average CPI ≈ 1.258**.  
However, this result is **abstract** — it was not based on a standardized benchmark suite but rather on a self-constructed instruction sequence.

### 💡 Proposed Improvement
A key next step would be to:
- **Design a dedicated benchmark-driven testbench**, simulating realistic instruction mixes (arithmetic, logic, load/store, branch, and jump operations).
- **Compare theoretical and practical CPI values**, refining the pipeline control and forwarding mechanisms to minimize stalls and bubbles.
- With balanced instruction distribution (keeping one branch and one jump), it’s expected that the **CPI could improve towards ~1.11**, aligning more closely with theoretical performance.

### 🧩 Outcome
This enhancement would make the performance analysis more robust, allowing future iterations of **RVX10-P** to:
- Achieve **benchmark-consistent CPI values**
- **Validate real-world throughput efficiency**
- Strengthen the design’s credibility through **quantitative comparison** of simulated vs. theoretical results.


## 🧱 Core Block Diagram
![dsd](https://github.com/user-attachments/assets/0296251d-c06e-440d-a48d-3899437b4aa2)


## 🧪 How to Run

### 🖥️ Option 1: Using Vivado

1. **Create a new project** in **Vivado**.  
2. **Add all SystemVerilog files** from the `/src` directory as **Design Sources**.  
3. **Add** `tb_pipeline.sv` from the `/tb` directory as a **Simulation Source**.  
4. **Create a new memory file** (e.g., `risctest.mem`) in Vivado.  
5. **Copy and paste** the contents of `risctest.mem` (provided in `/tb`) into the new file.  
6. **Run the Behavioral Simulation**.  
7. When the processor executes correctly, the console will display:



---

### 💻 Option 2: Using VS Code / Icarus Verilog / Verilator

1. Ensure you have a **SystemVerilog toolchain** installed (e.g., **Icarus Verilog** or **Verilator**).  
2. Download the following files:
- All `.sv` files from the `/src` directory  
- `tb_pipeline.sv` from the `/tb` directory  
- `rvx10_pipeline.hex` from the `/tb` directory (memory file)
3. **Compile and run** the simulation using your toolchain:



## 📚 References

This project’s design and pipeline architecture are based on:

> **Digital Design and Computer Architecture (RISC-V Edition)**  
> *David Harris and Sarah Harris*

---

## 🏫 Acknowledgment

Developed under the guidance of  
**Dr. Satyajit Das**  
*Assistant Professor*  
Department of **Computer Science and Engineering**  
**Indian Institute of Technology, Guwahati**

