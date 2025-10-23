`timescale 1ns / 1ps
/**
 * @brief Forwarding unit for data hazards.
 * @details Detects RAW hazards between EX, MEM, and WB stages.
 * Generates control signals to forward data from later stages
 * to the inputs of the ALU in the EX stage.
 *
 * @param Rs1E, Rs2E  Source register addresses in Execute stage.
 * @param RdM, RdW    Destination register addresses in Memory and WriteBack stages.
 * @param RegWriteM, RegWriteW  Write enable signals for MEM and WB stages.
 * @param ForwardAE, ForwardBE  Output control signals for ALU operand muxes.
 */
module forwarding_unit(
  input  logic [4:0] Rs1E, Rs2E,  // Source registers in Execute
  input  logic [4:0] RdM, RdW,     // Destination registers in Memory & WriteBack
  input  logic       RegWriteM,   // Write enable in Memory
  input  logic       RegWriteW,   // Write enable in WriteBack
  output logic [1:0] ForwardAE,  // Forwarding control for ALU operand A
  output logic [1:0] ForwardBE   // Forwarding control for ALU operand B
);

  // Combinational logic for forwarding
  always_comb begin
    // --- Defaults (no forwarding) ---
    ForwardAE = 2'b00;
    ForwardBE = 2'b00;

    // --- Forwarding for Rs1 (Operand A) ---
    
    // EX/MEM Hazard: Forward from Memory stage (highest priority)
    // If Rs1 in EX matches Rd in MEM, and MEM is writing, forward ALUResultM
    if ((Rs1E == RdM) & RegWriteM & (Rs1E != 0))
      ForwardAE = 2'b10; // Forward ALUResultM
        
    // MEM/WB Hazard: Forward from WriteBack stage
    // Else if Rs1 in EX matches Rd in WB, and WB is writing, forward ResultW
    else if ((Rs1E == RdW) & RegWriteW & (Rs1E != 0))
      ForwardAE = 2'b01; // Forward ResultW

        
    // --- Forwarding for Rs2 (Operand B) ---
    
    // EX/MEM Hazard: Forward from Memory stage (highest priority)
    // If Rs2 in EX matches Rd in MEM, and MEM is writing, forward ALUResultM
    if ((Rs2E == RdM) & RegWriteM & (Rs2E != 0))
      ForwardBE = 2'b10; // Forward ALUResultM
        
    // MEM/WB Hazard: Forward from WriteBack stage
    // Else if Rs2 in EX matches Rd in WB, and WB is writing, forward ResultW
    else if ((Rs2E == RdW) & RegWriteW & (Rs2E != 0))
      ForwardBE = 2'b01; // Forward ResultW
  end

endmodule
