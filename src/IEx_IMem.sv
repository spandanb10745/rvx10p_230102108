`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2025 21:23:28
// Design Name: 
// Module Name: IEx_IMem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Datapath Pipeline Register (EX to MEM)
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/**
 * @brief Datapath Pipeline register between Execution and Memory Access Stage.
 * @details Latches data signals passing from EX to MEM.
 * Has an asynchronous reset.
 *
 * @param clk     Clock
 * @param reset   Asynchronous reset
 * @param ...E    Inputs from Execute stage
 * @param ...M    Latched outputs for Memory stage
 */
module IEx_IMem(
  input  logic       clk, reset,
  input  logic [31:0] ALUResultE, WriteDataE, 
  input  logic [4:0] RdE, 
  input  logic [31:0] PCPlus4E,
  output logic [31:0] ALUResultM, WriteDataM,
  output logic [4:0] RdM, 
  output logic [31:0] PCPlus4M
);

  always_ff @( posedge clk, posedge reset ) begin 
    if (reset) begin // Asynchronous reset
      ALUResultM <= 0;
      WriteDataM <= 0;
      RdM        <= 0; 
      PCPlus4M   <= 0;
    end
    else begin // Normal operation: latch inputs
      ALUResultM <= ALUResultE;
      WriteDataM <= WriteDataE;
      RdM        <= RdE; 
      PCPlus4M   <= PCPlus4E;      
    end
  end

endmodule
