`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: spandan_bharwaj//230102108
// 
// Create Date: 22.10.2025 21:00:00
// Design Name: 
// Module Name: riscv
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 5-Stage Pipelined RVX10 Processor Core
// 
// Dependencies: datapath.sv, controller.sv, hazard_unit.sv, forwarding_unit.sv
// 
// Revision:
// Revision 0.01 - File Created
// Revision 0.02 - Added valid bit for retirement counting
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/**
 * @brief The main RISC-V processor core.
 * @details Connects the 'controller', 'datapath', 'forwarding_unit', 
 * and 'hazard_unit' to form the complete pipelined processor.
 */
module riscv(
  input  logic       clk, reset,
  output logic [31:0] PCF,
  input  logic [31:0] InstrF,
  output logic       MemWriteM,
  output logic [31:0] ALUResultM, WriteDataM,
  input  logic [31:0] ReadDataM
);
    
  // Internal wires for control and data signals
  logic ALUSrcE, RegWriteM, RegWriteW, ZeroE, PCSrcE;
  logic StallD, StallF, FlushD, FlushE, ResultSrcE0;
  logic [1:0] ResultSrcW; 
  logic [1:0] ImmSrcD;
  logic [3:0] ALUControlE;
  logic [31:0] InstrD;
  logic [4:0] Rs1D, Rs2D, Rs1E, Rs2E;
  logic [4:0] RdE, RdM, RdW;
  logic [1:0] ForwardAE, ForwardBE;
  logic validD, validE, validM, validW; // Valid bits for each stage
  
  // Instantiate the Pipelined Controller
  controller c(
    .clk        (clk),
    .reset      (reset),
    .op         (InstrD[6:0]),
    .funct3     (InstrD[14:12]),
    .funct7b5   (InstrD[30]),
    .funct7_2b  (InstrD[26:25]),
    .ZeroE      (ZeroE),
    .FlushE     (FlushE),
    .ResultSrcE0(ResultSrcE0),
    .ResultSrcW (ResultSrcW),
    .MemWriteM  (MemWriteM),
    .PCSrcE     (PCSrcE),
    .ALUSrcE    (ALUSrcE),
    .RegWriteM  (RegWriteM),
    .RegWriteW  (RegWriteW),
    .ImmSrcD    (ImmSrcD),
    .ALUControlE(ALUControlE)
  );

  // *** NEW SEPARATED UNITS (ADDED) ***
  
  // Instantiate the new Forwarding Unit
  forwarding_unit fu (
    .Rs1E     (Rs1E), 
    .Rs2E     (Rs2E),
    .RdM      (RdM), 
    .RdW      (RdW),
    .RegWriteM(RegWriteM), 
    .RegWriteW(RegWriteW),
    .ForwardAE(ForwardAE), 
    .ForwardBE(ForwardBE)
  );

  // Instantiate the new Hazard Unit
  hazard_unit hu (
    .Rs1D       (Rs1D), 
    .Rs2D       (Rs2D),
    .RdE        (RdE),
    .ResultSrcE0(ResultSrcE0),
    .PCSrcE     (PCSrcE),
    .StallD     (StallD), 
    .StallF     (StallF), 
    .FlushD     (FlushD), 
    .FlushE     (FlushE)
  );
  // *** END OF NEW INSTANTIATIONS ***

  // Instantiate the 5-Stage Pipelined Datapath
  datapath dp(
    .clk        (clk),
    .reset      (reset),
    .ResultSrcW (ResultSrcW),
    .PCSrcE     (PCSrcE),
    .ALUSrcE    (ALUSrcE),
    .RegWriteW  (RegWriteW),
    .ImmSrcD    (ImmSrcD),
    .ALUControlE(ALUControlE),
    .ZeroE      (ZeroE),
    .PCF        (PCF),
    .InstrF     (InstrF),
    .InstrD     (InstrD),
    .ALUResultM (ALUResultM),
    .WriteDataM (WriteDataM),
    .ReadDataM  (ReadDataM),
    .ForwardAE  (ForwardAE),
    .ForwardBE  (ForwardBE),
    .Rs1D       (Rs1D),
    .Rs2D       (Rs2D),
    .Rs1E       (Rs1E),
    .Rs2E       (Rs2E),
    .RdE        (RdE),
    .RdM        (RdM),
    .RdW        (RdW),
    .StallD     (StallD),
    .StallF     (StallF),
    .FlushD     (FlushD),
    .FlushE     (FlushE),

    // --- MODIFICATION: VALID BITS ADDED ---
    .validD     (validD),
    .validE     (validE),
    .validM     (validM),
    .validW     (validW)
    // --------------------------------------
  );
  
  // --- Performance Counters (Bonus) ---
  logic [31:0] cycle_count;
  logic [31:0] instr_retired;
  // ------------------------------------

  // --- Performance Counter Logic (Bonus) ---
  always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
      // Reset counters to zero
      cycle_count   <= '0; // Use '0 to set all bits to zero
      instr_retired <= '0;
    end
    else begin
      // Always increment the cycle counter
      cycle_count <= cycle_count + 1;

      // --- MODIFICATION: RETIREMENT LOGIC ---
      // Increment instruction counter ONLY if a VALID instruction
      // reaches the WriteBack (WB) stage. This correctly
      // counts ALL retired instructions (R-type, I-type, loads,
      // stores, and branches) and ignores flushed bubbles.
      if (validW) begin
        instr_retired <= instr_retired + 1;
      end
      // --------------------------------------
    end
  end
  // -----------------------------------------

endmodule
