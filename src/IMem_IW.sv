`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2025 21:24:49
// Design Name: 
// Module Name: IMem_IW
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Datapath Pipeline Register (MEM to WB)
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/**
 * @brief Datapath Pipeline register between Memory Access and WriteBack Stage.
 * @details Latches data signals passing from MEM to WB.
 * Has an asynchronous reset.
 *
 * @param clk     Clock
 * @param reset   Asynchronous reset
 * @param ...M    Inputs from Memory stage
 * @param ...W    Latched outputs for WriteBack stage
 */
module IMem_IW (
  input  logic       clk, reset,
  input  logic [31:0] ALUResultM, ReadDataM,  
  input  logic [4:0] RdM, 
  input  logic [31:0] PCPlus4M,
  output logic [31:0] ALUResultW, ReadDataW,
  output logic [4:0] RdW, 
  output logic [31:0] PCPlus4W
);

  always_ff @( posedge clk, posedge reset ) begin 
    if (reset) begin // Asynchronous reset
      ALUResultW <= 0;
      ReadDataW  <= 0;
      RdW        <= 0; 
      PCPlus4W   <= 0;
    end
    else begin // Normal operation: latch inputs
      ALUResultW <= ALUResultM;
      ReadDataW  <= ReadDataM;
      RdW        <= RdM; 
      PCPlus4W   <= PCPlus4M;      
    end
  end

endmodule
