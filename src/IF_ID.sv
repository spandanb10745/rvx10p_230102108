`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: //spandan_bharadwaj_230102108
// 
// Create Date: 22.10.2025 21:21:58
// Design Name: 
// Module Name: IF_ID
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Datapath Pipeline Register (IF to ID)
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Revision 0.02 - Added valid bit logic
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/**
 * @brief Datapath Pipeline register between Fetch and Decode Stage.
 * @details Latches data signals passing from IF to ID.
 * Has asynchronous reset, synchronous clear (flush), and enable (stall).
 */
module IF_ID (
  input  logic       clk, reset, clear, enable,
  input  logic [31:0] InstrF, PCF, PCPlus4F,
  output logic [31:0] InstrD, PCD, PCPlus4D,
  
  // --- MODIFICATION: VALID BIT ---
  input  logic       valid_in,  // Valid bit from fetch (always 1'b1)
  output logic       valid_out  // Valid bit for decode
  // -------------------------------
);

  always_ff @( posedge clk, posedge reset ) begin
    if (reset) begin // Asynchronous Clear
      InstrD   <= 0;
      PCD      <= 0;
      PCPlus4D <= 0;
      valid_out<= 0; // Clear valid bit
    end
    else if (enable) begin // Only latch if enabled (not stalled)
      if (clear) begin // Synchronous Clear (flushes to a NOP)
        InstrD   <= 32'h00000033; // add x0,x0,x0 (nop)
        PCD      <= 0;
        PCPlus4D <= 0; 
        valid_out<= 0; // Clear valid bit
      end
      else begin // Normal operation
        InstrD   <= InstrF;
        PCD      <= PCF;
        PCPlus4D <= PCPlus4F;
        valid_out<= valid_in; // Propagate valid bit
      end
    end
    // If enable is 0, registers (including valid_out) hold their previous value (stall)
  end

endmodule
