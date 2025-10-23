`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: //spandan_bharadwaj_230102108
// 
// Create Date: 22.09.2025 06:44:50
// Module Name: extend
// Description: Sign-extends immediate values based on instruction type.
//
//////////////////////////////////////////////////////////////////////////////////

module extend(
  // --- Input ---
  input  logic [31:7] instr,   // Relevant bits of the instruction
  input  logic [1:0]  immsrc,  // Selects immediate type
  
  // --- Output ---
  output logic [31:0] immext   // 32-bit sign-extended immediate
);
 
  // Combinational logic to generate the correct immediate
  always_comb
    case(immsrc) 
      // I-type (lw, addi, slti, etc.)
      2'b00:  immext = {{20{instr[31]}}, instr[31:20]}; 
            
      // S-type (stores)
      2'b01:  immext = {{20{instr[31]}}, instr[31:25], instr[11:7]}; 
            
      // B-type (branches)
      2'b10:  immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; 
            
      // J-type (jal)
      2'b11:  immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; 
            
      default: immext = 32'bx; // undefined
    endcase       
endmodule
