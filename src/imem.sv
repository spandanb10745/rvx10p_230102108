`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: //spandan_bharadwaj_230102108
// 
// Create Date: 22.09.2025 07:20:29
// Design Name: 
// Module Name: imem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Instruction Memory
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/**
 * @brief Instruction Memory module.
 * @details A simple ROM initialized from an external file ("risctest.mem").
 * Implements combinational read.
 *
 * @param a   32-bit address input (word-aligned).
 * @param rd  32-bit read data (instruction) output.
 */
module imem (
  input  logic [31:0] a,  // Address
  output logic [31:0] rd  // Read data (instruction)
);
  // Memory array (64 entries, 32-bits wide)
  logic [31:0] RAM[63:0];

  // Initialize memory from file
  initial begin
    // Load the contents of "risctest.mem" into the RAM array
    $readmemh("risctest.mem", RAM);
  end
    
  // Combinational read (uses lower bits of 'a' as word index)
  assign rd = RAM[a[31:2]]; // word-aligned

endmodule
