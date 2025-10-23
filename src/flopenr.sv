`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.10.2025 19:50:51
// Design Name: 
// Module Name: flopenr
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Register with asynchronous reset and synchronous enable.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/**
 * @brief Parameterized N-bit register with asynchronous reset and synchronous enable.
 * @param WIDTH The bit-width of the register.
 */
module flopenr #(
  parameter WIDTH = 8
) (
  input  logic             clk,   // Clock
  input  logic             reset, // Asynchronous reset
  input  logic             en,    // Synchronous enable
  input  logic [WIDTH-1:0] d,     // Data input
  output logic [WIDTH-1:0] q      // Data output
);

  // Sequential logic with an asynchronous reset.
  always_ff @(posedge clk or posedge reset) begin
    // Asynchronous reset has the highest priority.
    if (reset)
      q <= 0;
    // On a clock edge, load 'd' into 'q' only if enabled.
    else if (en)
      q <= d;
    // If 'en' is low, 'q' holds its previous value.
    // else if (!en) // This is redundant
    //   q <= q;
  end

endmodule
