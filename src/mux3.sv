`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: //spandan_bharadwaj_230102108
// 
// Create Date: 22.09.2025 06:57:37
// Design Name: 
// Module Name: mux3
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 3-to-1 Multiplexer.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/**
 * @brief Parameterized 3-to-1 Multiplexer.
 * @param WIDTH The bit-width of the data inputs and output.
 */
module mux3 #(parameter WIDTH=8)(
  input  logic [WIDTH-1:0] d0, d1, d2, // Data inputs
  input  logic [1:0]       s,        // Select signal
  output logic [WIDTH-1:0] y         // Data output
);
    
  // s=00 -> d0
  // s=01 -> d1
  // s=10 -> d2
  // s=11 -> d2 (based on this logic)
  assign y = s[1] ? d2 : (s[0] ? d1: d0);
endmodule
