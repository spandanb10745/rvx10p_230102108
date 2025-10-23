# TESTPLAN.md

This file specifies the test program for the RVX10 single-cycle processor. The program exercises both standard RISC-V instructions and the 10 custom RVX10 instructions.

## Test Program Table

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

## Screenshots

![risctest.mem](https://github.com/user-attachments/assets/a7710874-5da2-47a9-b648-a8fef01ba181)

![risctest.mem_2](https://github.com/user-attachments/assets/3a967e8c-093e-4f6f-acdb-0c3e7a98e328)

![Risc test reg file screenshot](https://github.com/user-attachments/assets/2890c3d8-06ea-410c-abf9-39f7d5f3c313)

![Sample of Sarah Harris ref book Digital design and computer architecture](https://github.com/user-attachments/assets/87863e0f-9cb3-4b95-a4ff-1014210ddfe1)


---

## Implemented Checklist

* Rotate by 0 returns rs1; no shift-by-32 in RTL.
* ABS(INT\_MIN) returns 0x80000000.
* x0 writes are ignored.
* Final store writes 25 to address 100.



