`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: spandan_bharadwaj_230102108
// 
// Create Date: 22.09.2025 07:11:54
// Design Name: 
// Module Name: dmem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Data Memory
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/**
 * @brief Data Memory module.
 * @details A simple RAM (Random Access Memory).
 * Implements combinational read and synchronous write.
 *
 * @param clk Clock signal.
 * @param we  Write enable signal.
 * @param a   32-bit address input.
 * @param wd  32-bit write data input.
 * @param rd  32-bit read data output.
 */
module dmem(
  input  logic       clk, we,
  input  logic [31:0] a, wd,
  output logic [31:0] rd
);
    
  // Memory array (64 entries, 32-bits wide)
  logic [31:0] RAM [63:0];
    
  // Combinational read (word-aligned)
  assign rd = RAM[a[31:2]]; 
    
  // Synchronous write (on positive clock edge)
  always_ff @(posedge clk)
    if (we) RAM[a[31:2]] <= wd;
    
endmodule
