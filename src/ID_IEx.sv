`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2025 21:22:42
// Design Name: 
// Module Name: ID_IEx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Datapath Pipeline Register (ID to EX)
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/**
 * @brief Datapath Pipeline register between Decode and Execution Stage.
 * @details Latches data signals passing from ID to EX.
 * Has asynchronous reset and synchronous clear (flush).
 *
 * @param clk     Clock
 * @param reset   Asynchronous reset
 * @param clear   Synchronous clear (flush)
 * @param ...D    Inputs from Decode stage
 * @param ...E    Latched outputs for Execute stage
 */
module ID_IEx  (
  input  logic       clk, reset, clear,
  input  logic [31:0] RD1D, RD2D, PCD, 
  input  logic [4:0] Rs1D, Rs2D, RdD, 
  input  logic [31:0] ImmExtD, PCPlus4D,
  output logic [31:0] RD1E, RD2E, PCE, 
  output logic [4:0] Rs1E, Rs2E, RdE, 
  output logic [31:0] ImmExtE, PCPlus4E
);

  always_ff @( posedge clk, posedge reset ) begin
    if (reset) begin // Asynchronous reset
      RD1E     <= 0;
      RD2E     <= 0;
      PCE      <= 0;
      Rs1E     <= 0;
      Rs2E     <= 0;
      RdE      <= 0;
      ImmExtE  <= 0;
      PCPlus4E <= 0;
    end
    else if (clear) begin // Synchronous clear (flushes to 0)
      RD1E     <= 0;
      RD2E     <= 0;
      PCE      <= 0;
      Rs1E     <= 0;
      Rs2E     <= 0;
      RdE      <= 0;
      ImmExtE  <= 0;
      PCPlus4E <= 0;
    end
    else begin // Normal operation: latch inputs
      RD1E     <= RD1D;
      RD2E     <= RD2D;
      PCE      <= PCD;
      Rs1E     <= Rs1D;
      Rs2E     <= Rs2D;
      RdE      <= RdD;
      ImmExtE  <= ImmExtD;
      PCPlus4E <= PCPlus4D;
    end
  end

endmodule
