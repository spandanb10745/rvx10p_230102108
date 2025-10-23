`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2025 21:25:38
// Design Name: 
// Module Name: c_ID_IEx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Control Unit Pipeline Register (ID to EX)
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/**
 * @brief Control Unit Pipeline Register between Decode and Execution Stage.
 * @details Latches control signals passing from ID to EX.
 * Has an asynchronous reset and a synchronous clear (flush).
 *
 * @param clk     Clock
 * @param reset   Asynchronous reset
 * @param clear   Synchronous clear (flush)
 * @param ...D    Input control signals from Decode stage
 * @param ...E    Output latched control signals for Execute stage
 */
module c_ID_IEx (
  input  logic       clk, reset, clear,
  input  logic       RegWriteD, MemWriteD, JumpD, BranchD, ALUSrcD,
  input  logic [1:0] ResultSrcD, 
  input  logic [3:0] ALUControlD,  
  output logic       RegWriteE, MemWriteE, JumpE, BranchE, ALUSrcE,
  output logic [1:0] ResultSrcE,
  output logic [3:0] ALUControlE
);

  always_ff @( posedge clk, posedge reset ) begin
    if (reset) begin // Asynchronous reset
      RegWriteE   <= 0;
      MemWriteE   <= 0;
      JumpE       <= 0;
      BranchE     <= 0; 
      ALUSrcE     <= 0;
      ResultSrcE  <= 0;
      ALUControlE <= 0;
    end
    else if (clear) begin // Synchronous clear (flushes to 0)
      RegWriteE   <= 0;
      MemWriteE   <= 0;
      JumpE       <= 0;
      BranchE     <= 0; 
      ALUSrcE     <= 0;
      ResultSrcE  <= 0;
      ALUControlE <= 0;
    end
    else begin // Normal operation: latch inputs
      RegWriteE   <= RegWriteD;
      MemWriteE   <= MemWriteD;
      JumpE       <= JumpD;
      BranchE     <= BranchD; 
      ALUSrcE     <= ALUSrcD;
      ResultSrcE  <= ResultSrcD;
      ALUControlE <= ALUControlD; 
    end
  end
  
endmodule
