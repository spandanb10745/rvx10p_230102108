`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2025 21:27:10
// Design Name: 
// Module Name: c_IM_IW
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Control Unit Pipeline Register (MEM to WB)
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/**
 * @brief Control Unit Pipeline Register for Memory Access - WriteBack Stage.
 * @details Latches control signals passing from MEM to WB.
 * Has an asynchronous reset.
 *
 * @param clk     Clock
 * @param reset   Asynchronous reset
 * @param ...M    Input control signals from Memory stage
 * @param ...W    Output latched control signals for WriteBack stage
 */
module c_IM_IW (
  input  logic       clk, reset, 
  input  logic       RegWriteM, 
  input  logic [1:0] ResultSrcM, 
  output logic       RegWriteW, 
  output logic [1:0] ResultSrcW
);

  always_ff @( posedge clk, posedge reset ) begin
    if (reset) begin // Asynchronous reset
      RegWriteW  <= 0;
      ResultSrcW <= 0;
    end
    else begin // Normal operation: latch inputs
      RegWriteW  <= RegWriteM;
      ResultSrcW <= ResultSrcM; 
    end
  end

endmodule
