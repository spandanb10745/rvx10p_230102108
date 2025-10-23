`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: //spandan_bharadwaj_230102108
// 
// Create Date: 22.09.2025 06:59:22
// Design Name: 
// Module Name: alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Arithmetic Logic Unit (ALU).
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: Includes standard RISC-V ops and custom RVX10 ops.
// 
//////////////////////////////////////////////////////////////////////////////////

/**
 * @brief Arithmetic Logic Unit (ALU).
 * @details Performs arithmetic and logical operations based on the 
 * 4-bit 'alucontrol' signal. Supports standard RISC-V
 * operations as well as custom RVX10 extensions.
 *
 * @param a, b        32-bit data inputs.
 * @param alucontrol  4-bit control signal selecting the operation.
 * @param result      32-bit output of the operation.
 * @param zero        1-bit flag, high if the result is zero.
 */
module alu(
  input  logic [31:0] a, b,
  input  logic [3:0]  alucontrol,
  output logic [31:0] result,
  output logic        zero
);

  // Existing signals
  logic [31:0] condinvb, sum;
  logic        v;          // overflow
  logic        isAddSub;   // true when add or subtract

  // Logic for add/sub/slt
  assign condinvb = alucontrol[0] ? ~b : b;       // Invert b for subtraction
  assign sum      = a + condinvb + alucontrol[0]; // Add/Sub
  assign isAddSub = ~alucontrol[2] & ~alucontrol[1] |
                    ~alucontrol[1] & alucontrol[0];

  // signed views for MIN/MAX/ABS
  wire signed [31:0] s1 = a;
  wire signed [31:0] s2 = b;

  // Main ALU operation logic
  always_comb
    case (alucontrol)
      // ---- original arithmetic/logic ----
      4'b0000:  result = sum;      // add
      4'b0001:  result = sum;      // subtract
      4'b0010:  result = a & b;    // and
      4'b0011:  result = a | b;    // or
      4'b0100:  result = a ^ b;    // xor
      4'b0101:  result = sum[31] ^ v; // slt (Set Less Than)

      // ---- new ops starting from 0110 (RVX10) ----
      4'b0110:  result = a & ~b;                       // ANDN
      4'b0111:  result = a | ~b;                       // ORN
      4'b1000:  result = ~(a ^ b);                     // XNOR (typo in original, was XORN)
      4'b1001:  result = (s1 < s2) ? a : b;            // MIN (signed)
      4'b1010:  result = (s1 > s2) ? a : b;            // MAX (signed)
      4'b1011:  result = (a  < b)  ? a : b;            // MINU (unsigned)
      4'b1100:  result = (a  > b)  ? a : b;            // MAXU (unsigned)
      4'b1101: begin                                   // ROL (Rotate Left)
          logic [4:0] sh = b[4:0];
          result = (sh == 0) ? a : ((a << sh) | (a >> (32 - sh)));
        end
      4'b1110: begin                                   // ROR (Rotate Right)
          logic [4:0] sh = b[4:0];
          result = (sh == 0) ? a : ((a >> sh) | (a << (32 - sh)));
        end
      4'b1111:  result = (s1 >= 0) ? a : (0 - a);      // ABS (Absolute Value)
      default:  result = 32'bx;
    endcase

  // Zero flag logic
  assign zero = (result == 32'b0);
  
  // Overflow logic (for 'slt')
  assign v    = ~(alucontrol[0] ^ a[31] ^ b[31]) & (a[31] ^ sum[31]) & isAddSub;

endmodule
