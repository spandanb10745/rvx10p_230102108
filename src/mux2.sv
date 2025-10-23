`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: //spandan_bharadwaj_230102108
// 
// Create Date: 22.09.2025 06:55:00
// Design Name: 
// Module Name: mux2
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 2-to-1 Multiplexer.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/**
 * @brief Parameterized 2-to-1 Multiplexer.
 * @param WIDTH The bit-width of the data inputs and output.
 */
module mux2 #(parameter WIDTH=8)(
  input  logic [WIDTH-1:0] d0, d1, // Data inputs
  input  logic             s,      // Select signal
  output logic [WIDTH-1:0] y       // Data output
);
    
  // If s=1, select d1; otherwise select d0
  assign y = s ? d1 : d0;
endmodule
