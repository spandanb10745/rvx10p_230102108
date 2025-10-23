# ENCODINGS.md

This document lists the RVX10 instruction set (10 ops) and the concrete encodings for each added instruction.

![The RVX10 Instruction Set (10 ops)](https://github.com/user-attachments/assets/8389582a-fc73-4436-9245-5e7963b313ee)

![Encoding Table (Concrete)](https://github.com/user-attachments/assets/62deca4f-a804-4f6e-9954-b0ef7a0dbb8c)

---

## Instruction format (R-type style used by RVX10)

Bit positions (MSB left):

```
 31        25 24   20 19   15 14   12 11    7 6     0
 +-------------+------+-------+-------+------+-------+
 |   func7     | rs2  | rs1   | func3 | rd   |  op   |
 +-------------+------+-------+-------+------+-------+
```

Field widths:

* func7: 7 bits (bits 31..25)
* rs2:   5 bits (bits 24..20)
* rs1:   5 bits (bits 19..15)
* func3: 3 bits (bits 14..12)
* rd:    5 bits (bits 11..7)
* op:    7 bits (bits 6..0)

All RVX10 custom instructions use the 7-bit opcode `0001011` for the new opcodes.

---
*x2=25;
*x9=18; 
Already been loaded before doing the below commands.

## Encoding table (concrete)

| func7   | rs2   | rs1   | func3 | rd    | op      | machine\_code | assembly         |
| ------- | ----- | ----- | ----- | ----- | ------- | ------------- | ---------------- |
| 0000000 | 01001 | 00010 | 000   | 01010 | 0001011 | 0x0091050B    | `ANDN x10,x2,x9` |
| 0000000 | 01001 | 00010 | 001   | 01011 | 0001011 | 0x0091158B     | `ORN  x11,x2,x9` |
| 0000000 | 01001 | 00010 | 010   | 01100 | 0001011 | 0x0091260B    | `XORN x12,x2,x9` |
| 0000001 | 01001 | 00010 | 000   | 01101 | 0001011 | 0x0291068B    | `MIN  x13,x2,x9` |
| 0000001 | 01001 | 00010 | 001   | 01110 | 0001011 | 0x0291170B    | `MAX  x14,x2,x9` |
| 0000001 | 01001 | 00010 | 010   | 01111 | 0001011 | 0x0291278B    | `MINU x15,x2,x9` |
| 0000001 | 01001 | 00010 | 011   | 10000 | 0001011 | 0x0291380B    | `MAXU x16,x2,x9` |
| 0000010 | 01001 | 00010 | 000   | 10001 | 0001011 | 0x0491088B    | `ROL  x17,x2,x9` |
| 0000010 | 00100 | 00100 | 001   | 10010 | 0001011 | 0x0442190B    | `ROR  x18,x4,x4` |
| 0000011 | 00000 | 10010 | 000   | 10011 | 0001011 | 0x0609098B    | `ABS  x19,x18`   |
| 0000010 | 00000 | 01001 | 001   | 10100 | 0001011 | 0x04049A0B    | `ROR  x20,x9,x0` |
| 0000000 | 01001 | 00010 | 000   | 00000 | 0001011 | 0x00910033    | `ADD  x0,x2,x9`  |

---


