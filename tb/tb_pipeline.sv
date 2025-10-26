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
module testbench();

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

  // Task to check success condition and display performance metrics
  // This block is separated for clarity.
  task check_success_and_display_performance(string message);
    begin
      $display("%s at time %0t", message, $time);
      
      final_cycles = dut.rv.cycle_count;   // clock cycles (total)
      final_instrs = dut.rv.instr_retired; // instructions completed (total)
      
      $display("---------------------------------");
      $display("--- Performance (Bonus) ---");
      $display("Total Cycles:           %0d", final_cycles); // as of first 2 cycles reset=1 to start the processor
      $display("Instructions Retired: %0d", final_instrs);

      // Add check to prevent division by zero
      if (final_instrs > 0) begin
        cpi = $itor(final_cycles) / $itor(final_instrs); // adjustments as sw and beq don't assert RegWriteW as 1 ( the no is variable , will depend on the testbench instructions)
        $display("Average CPI:          %f", cpi);
      end else begin
        $display("Average CPI:          N/A (0 instructions retired)");
      end

      $display("---------------------------------");
      // Stop simulation
    end
  endtask

  // Check for simulation success or failure based on memory write
  always @(negedge clk) begin
    if (MemWrite) begin
      // Use logical AND (&&) for boolean conditions
      if (DataAdr === 100 && WriteData === 25) begin
        $display("Simulation succeeded");
      end else if (DataAdr !== 96) begin 
        $display("Simulation failed: Wrote %0d to address %0d", WriteData, DataAdr);
        
      end
    end
  end

  // Timeout check
  // This block waits until 410ns, then calculates performance metrics and stops.
  initial begin
    #410; // Wait for 410ns
    check_success_and_display_performance("S410imulation timed out at 410ns"); // Call the task to display CPI and stop
  end

endmodule

