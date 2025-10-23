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
- Achieves an **average CPI ≈ 1.310** on the comprehensive test suite.
- Demonstrates **high throughput and efficiency** compared to the single-cycle version.

---

## 🧱 Core Block Diagram
*(Include your block diagram image here once available)*  
```markdown
![RVX10-P Block Diagram](docs/block_diagram.png)

🧪 How to Run
🖥️ Option 1: Using Vivado

Create a new project in Vivado.

Add all SystemVerilog files from the /src directory as Design Sources.

Add testbench.sv from the /tb directory as a Simulation Source.

Create a new memory file (e.g., risctest.mem) in Vivado.

Copy and paste the contents of risctest.mem (provided in /tb) into this new file.

Run Behavioral Simulation.

If the processor is correct, the console will display:

💻 Option 2: Using VS Code / Icarus Verilog / Verilator

Ensure you have a SystemVerilog toolchain (e.g., Icarus Verilog or Verilator).

Download the following files:

All .sv files from the /src directory

testbench.sv from the /tb directory

rvx10_pipeline.hex from the /tb directory (memory file)

Compile and run the simulation:📚 References

This project’s design and pipeline principles are inspired by:

Digital Design and Computer Architecture (RISC-V Edition)
David Harris and Sarah Harris

🏫 Acknowledgment

Developed under the guidance of
Dr. Satyajit Das
