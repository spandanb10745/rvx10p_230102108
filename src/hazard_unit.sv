`timescale 1ns / 1ps
/**
 * @brief Hazard detection unit.
 * @details Detects load-use hazards (data hazard requiring a stall)
 * and control hazards (from taken branches).
 * Generates stall and flush signals for the pipeline.
 *
 * @param Rs1D, Rs2D    Source register addresses in Decode stage.
 * @param RdE           Destination register address in Execute stage.
 * @param ResultSrcE0   Control signal (1 if instruction in EX is 'lw').
 * @param PCSrcE        Control signal (1 if branch is taken in EX).
 * @param StallD, StallF Output signals to stall Decode and Fetch stages.
 * @param FlushD, FlushE Output signals to flush Decode and Execute stages.
 */
module hazard_unit(
  input  logic [4:0] Rs1D, Rs2D,    // Source registers in Decode
  input  logic [4:0] RdE,           // Destination register in Execute
  input  logic       ResultSrcE0,   // Control signal: 1 if instruction in EXE is a load
  input  logic       PCSrcE,        // Control signal: 1 if branch is taken
  output logic       StallD, StallF,  // Stall signals for Fetch and Decode
  output logic       FlushD, FlushE   // Flush signals for Decode and Execute
);

  // --- Load-Use Hazard Detection ---
  // Stall if instruction in Decode needs data from a load in Execute
  logic lwStall;
  assign lwStall = (ResultSrcE0 == 1) & ((RdE == Rs1D) | (RdE == Rs2D));

  // Stall the pipeline for one cycle
  assign StallF = lwStall; // Stall PC and IF/ID pipeline register
  assign StallD = lwStall; // Stall ID/EX pipeline register
    
  // --- Flush Logic ---
    
  // Flush Execute stage if a load-use stall occurs (insert bubble)
  // OR if a branch is taken (instruction in EXE is wrong)
  assign FlushE = lwStall | PCSrcE;
    
  // Flush Decode stage only if a branch is taken (instruction in DEC is wrong)
  assign FlushD = PCSrcE;

endmodule
