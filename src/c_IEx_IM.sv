`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2025 21:26:13
// Design Name: 
// Module Name: c_IEx_IM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Control Unit Pipeline Register (EX to MEM)
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/**
 * @brief Control Unit Pipeline Register between Instruction Execution and Memory Access Stage.
 * @details Latches control signals passing from EX to MEM.
 * Has an asynchronous reset.
 *
 * @param clk     Clock
 * @param reset   Asynchronous reset
 * @param ...E    Input control signals from Execute stage
 * @param ...M    Output latched control signals for Memory stage
 */
module c_IEx_IM (
  input  logic       clk, reset,
  input  logic       RegWriteE, MemWriteE,
  input  logic [1:0] ResultSrcE,  
  output logic       RegWriteM, MemWriteM,
  output logic [1:0] ResultSrcM
);

  always_ff @( posedge clk, posedge reset ) begin
    if (reset) begin // Asynchronous reset
      RegWriteM  <= 0;
      MemWriteM  <= 0;
      ResultSrcM <= 0;
    end
    else begin // Normal operation: latch inputs
      RegWriteM  <= RegWriteE;
      MemWriteM  <= MemWriteE;
      ResultSrcM <= ResultSrcE; 
    end
  end

endmodule
