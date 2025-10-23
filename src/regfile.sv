`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: //spandan_bharadwaj_230102108
// 
// Create Date: 22.09.2025 07:06:19
// Design Name: 
// Module Name: regfile
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 3-port Register File
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Revision 0.02 - Changed write to negedge clk per user request.
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/**
 * @brief 3-port Register File (2 read, 1 write).
 * @details Implements the 32 RISC-V general-purpose registers.
 * Writes occur on the negative clock edge.
 * Reads are combinational.
 * Register x0 is hardwired to zero.
 *
 * @param clk   Clock signal.
 * @param we3   Write enable (from WB stage).
 * @param a1, a2 Read addresses.
 * @param a3    Write address.
 * @param wd3   Write data.
 * @param rd1, rd2 Read data outputs.
 */
module regfile (
  input  logic       clk,
  input  logic       we3,      // Write enable (from WB stage)
  input  logic [4:0] a1, a2, a3, // a1,a2=Read addrs, a3=Write addr
  input  logic [31:0] wd3,    // Write data
  output logic [31:0] rd1, rd2 // Read data
);

  // The register file storage array
  logic [31:0] rf[31:0];

  // three ported register file
  // read two ports combinationally (A1/RD1, A2/RD2)
  // write third port on *NEGATIVE* edge of clock (A3/WD3/WE3)
  // register 0 hardwired to 0

  // **MODIFICATION**: Writing on negedge clk as requested
  always_ff @(negedge clk)
    if (we3 & a3 != 0) rf[a3] <= wd3; // x0 no rewrites

  // Combinational reads
  // This simple logic works *because* write is on negedge
  // and read (in ID stage) is sampled on posedge.
  assign rd1 = (a1 != 0) ? rf[a1] : 0; // Hardwire x0 to 0
  assign rd2 = (a2 != 0) ? rf[a2] : 0; // Hardwire x0 to 0
  
endmodule
