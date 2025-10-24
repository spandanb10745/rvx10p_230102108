`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: spandan_bharadwaj//230102108
// 
// Create Date: 22.09.2025 11:49:03
// Design Name: 
// Module Name: testbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Testbench for the 'top' module of the RISC-V processor.
// 
// Dependencies: top.module
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/**
 * @brief Top-level testbench.
 * @details Generates clock and reset, instantiates the DUT ('top'), and
 * checks for a specific memory write operation to validate success.
 */
module tb_pipeline();

  logic clk;
  logic reset;

  logic [31:0] WriteData, DataAdr;
  logic MemWrite;

  int  final_cycles;
  int  final_instrs;
  real cpi;
  // ----------------------------------


  // Instantiate device to be tested (Device Under Test)
  riscvpipeline dut (
    .clk        (clk),
    .reset      (reset),
    .WriteDataM (WriteData), // Connects to DUT's WriteDataM output
    .DataAdrM   (DataAdr),   // Connects to DUT's DataAdrM output
    .MemWriteM  (MemWrite)   // Connects to DUT's MemWriteM output
  );

  // Initialize test
  initial begin
    reset <= 1; #20; // Assert reset for 20ns
    reset <= 0;      // De-assert reset
  end

  // Generate clock to sequence tests (10ns period)
  always begin
    clk <= 1; #5; // Clock high for 5ns
    clk <= 0; #5; // Clock low for 5ns
  end

  // Check results
  // This block monitors the memory write signals on the falling edge of the clock
// check results
always @(negedge clk) begin
    if (MemWrite) begin
      if (DataAdr === 100 & WriteData === 25) begin
        $display("Simulation succeeded at time %0t", $time);
        
        
        
        final_cycles = dut.rv.cycle_count;   // clock cycles (total)
        final_instrs = dut.rv.instr_retired; // instructions completed (total)
        
        cpi = $itor(final_cycles-2) / $itor(final_instrs); // adjustments as sw and beq don't assert RegWriteW as 1 ( the no is variable , will depend on the testbench instructions)

        $display("---------------------------------");
        $display("--- Performance (Bonus) ---");
        $display("Total Cycles:         %0d", final_cycles-2); // as of first 2 cycles reset=1 to start the processor
        $display("Instructions Retired: %0d", final_instrs);
        $display("Average CPI:          %f", cpi);
        $display("---------------------------------");
        
        $stop;
      end else if (DataAdr !== 96) begin 
        $display("Simulation failed: Wrote %0d to address %0d", WriteData, DataAdr);
        $stop; 
      end
    end
  end
endmodule
