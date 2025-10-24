`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: //spandan_bharadwaj_230102108
// 
// Create Date: 22.09.2025 11:12:33
// Design Name: 
// Module Name: datapath
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 5-Stage Pipelined Datapath for RVX10-P
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created (single-cycle)
// Revision 0.02 - Converted to 5-stage pipeline
// Revision 0.03 - Added valid bit propagation
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/**
 * @brief 5-stage pipelined datapath.
 * @details Contains all the functional units (ALU, regfile, muxes, adders)
 * and pipeline registers for the datapath.
 */
module datapath(
  input  logic       clk, reset,
  input  logic [1:0] ResultSrcW,
  input  logic       PCSrcE, ALUSrcE, 
  input  logic       RegWriteW,
  input  logic [1:0] ImmSrcD,
  input  logic [3:0] ALUControlE,
  output logic       ZeroE,
  output logic [31:0] PCF,
  input  logic [31:0] InstrF,
  output logic [31:0] InstrD,
  output logic [31:0] ALUResultM, WriteDataM,
  input  logic [31:0] ReadDataM,
  input  logic [1:0] ForwardAE, ForwardBE,
  output logic [4:0] Rs1D, Rs2D, Rs1E, Rs2E,
  output logic [4:0] RdE, RdM, RdW,
  input  logic       StallD, StallF, FlushD, FlushE,

  // --- MODIFICATION: VALID BITS ADDED ---
  output logic       validD,
  output logic       validE,
  output logic       validM,
  output logic       validW
  // --------------------------------------
);

  // Internal datapath signals
  logic [31:0] PCD, PCE, ALUResultE, ALUResultW, ReadDataW;
  logic [31:0] PCNextF, PCPlus4F, PCPlus4D, PCPlus4E, PCPlus4M, PCPlus4W, PCTargetE;
  logic [31:0] WriteDataE;
  logic [31:0] ImmExtD, ImmExtE;
  logic [31:0] SrcAE, SrcBE, RD1D, RD2D, RD1E, RD2E;
  logic [31:0] ResultW;
  logic [4:0] RdD; // destination register address

    
  // -----------------
  // --- Fetch Stage ---
  // -----------------
    
  // Mux to select next PC (either PC+4 or branch/jump target)
  mux2 #(.WIDTH(32)) pcmux(
    .d0 (PCPlus4F),
    .d1 (PCTargetE),
    .s  (PCSrcE),
    .y  (PCNextF)
  );
  
  // PC Register (stalls if StallF is high)
  flopenr #(.WIDTH(32)) IF(
    .clk   (clk),
    .reset (reset),
    .en    (~StallF), // Enable only if not stalling
    .d     (PCNextF),
    .q     (PCF)
  );
  
  // Adder for PC + 4
  adder pcadd4(
    .a (PCF),
    .b (32'd4),
    .y (PCPlus4F)
  );
    
  // ---------------------------------------------------
  // --- Instruction Fetch - Decode Pipeline Register ---
  // ---------------------------------------------------
    
  IF_ID pipreg0 (
    .clk      (clk),
    .reset    (reset),
    .clear    (FlushD),  // Flush if branch taken
    .enable   (~StallD), // Stall for load-use
    .InstrF   (InstrF),
    .PCF      (PCF),
    .PCPlus4F (PCPlus4F),
    .InstrD   (InstrD),
    .PCD      (PCD),
    .PCPlus4D (PCPlus4D),

    // --- MODIFICATION: VALID BIT ---
    // A new instruction is always valid (1'b1).
    // On stall, 'enable' is false, so 'validD' holds.
    // On flush, 'clear' is true, so 'validD' becomes 0.
    .valid_in (1'b1),
    .valid_out(validD)
    // -------------------------------
  );
  
  // ------------------
  // --- Decode Stage ---
  // ------------------
  
  // Extract register addresses from instruction
  assign Rs1D = InstrD[19:15];
  assign Rs2D = InstrD[24:20];  
  assign RdD  = InstrD[11:7];
  
  // Register File
  regfile rf (
    .clk (clk),
    .we3 (RegWriteW), // Write enable from WB stage
    .a1  (Rs1D),      // Read address 1
    .a2  (Rs2D),      // Read address 2
    .a3  (RdW),       // Write address from WB stage
    .wd3 (ResultW),   // Write data from WB stage
    .rd1 (RD1D),      // Read data 1 output
    .rd2 (RD2D)       // Read data 2 output
  );  
  
  // Sign/Immediate Extension Unit
  extend ext(
    .instr  (InstrD[31:7]),
    .immsrc (ImmSrcD),
    .immext (ImmExtD)
  );
    
  // ------------------------------------------------
  // --- Decode - Execute Pipeline Register ---
  // ------------------------------------------------
    
  ID_IEx pipreg1 (
    .clk      (clk),
    .reset    (reset),
    .clear    (FlushE), // Flush for stalls or taken branches
    .RD1D     (RD1D),
    .RD2D     (RD2D),
    .PCD      (PCD),
    .Rs1D     (Rs1D),
    .Rs2D     (Rs2D),
    .RdD      (RdD),
    .ImmExtD  (ImmExtD),
    .PCPlus4D (PCPlus4D),
    .RD1E     (RD1E),
    .RD2E     (RD2E),
    .PCE      (PCE),
    .Rs1E     (Rs1E),
    .Rs2E     (Rs2E),
    .RdE      (RdE),
    .ImmExtE  (ImmExtE),
    .PCPlus4E (PCPlus4E),

    // --- MODIFICATION: VALID BIT ---
    // Propagate valid bit. 'clear' (FlushE) will set validE to 0.
    // This register has no 'enable', so it never stalls.
    .valid_in (validD),
    .valid_out(validE)
    // -------------------------------
  );
  
  // -------------------
  // --- Execute Stage ---
  // -------------------
  
  // Forwarding Mux for ALU Operand A
  mux3 #(.WIDTH(32)) forwardMuxA (
    .d0 (RD1E),       // 00: From register file (RD1E)
    .d1 (ResultW),    // 01: From WriteBack (ResultW)
    .d2 (ALUResultM), // 10: From Memory (ALUResultM)
    .s  (ForwardAE),
    .y  (SrcAE)
  );
  
  // Forwarding Mux for ALU Operand B (also serves as WriteData for 'sw')
  mux3 #(.WIDTH(32)) forwardMuxB (
    .d0 (RD2E),       // 00: From register file (RD2E)
    .d1 (ResultW),    // 01: From WriteBack (ResultW)
    .d2 (ALUResultM), // 10: From Memory (ALUResultM)
    .s  (ForwardBE),
    .y  (WriteDataE)  // This is data to be written for 'sw'
  );
  
  // Mux to select ALU Operand B (either from regfile/forward or immediate)
  mux2 #(.WIDTH(32)) srcbmux(
    .d0 (WriteDataE), // From regfile/forwarding
    .d1 (ImmExtE),    // From immediate extender
    .s  (ALUSrcE),
    .y  (SrcBE)
  );  
  
  // Adder for branch/jump target address
  adder pcaddbranch(
    .a (PCE),
    .b (ImmExtE),
    .y (PCTargetE)
  );  
  
  // The main Arithmetic Logic Unit (ALU)
  alu alu(
    .a          (SrcAE),
    .b          (SrcBE),
    .alucontrol (ALUControlE),
    .result     (ALUResultE),
    .zero       (ZeroE)
  );
    
  // ----------------------------------------------------
  // --- Execute - Memory Access Pipeline Register ---
  // ----------------------------------------------------
  
  IEx_IMem pipreg2 (
    .clk        (clk),
    .reset      (reset),
    .ALUResultE (ALUResultE),
    .WriteDataE (WriteDataE),
    .RdE        (RdE),
    .PCPlus4E   (PCPlus4E),
    .ALUResultM (ALUResultM),
    .WriteDataM (WriteDataM),
    .RdM        (RdM),
    .PCPlus4M   (PCPlus4M),

    // --- MODIFICATION: VALID BIT ---
    // Propagate valid bit.
    .valid_in (validE),
    .valid_out(validM)
    // -------------------------------
  );
    
  // -----------------
  // --- Memory Stage ---
  // -----------------
  // (No components here, just wires to 'top' module's dmem)
    
  // --------------------------------------------------
  // --- Memory - Register Write Back Stage Register ---
  // --------------------------------------------------
  
  IMem_IW pipreg3 (
    .clk        (clk),
    .reset      (reset),
    .ALUResultM (ALUResultM),
    .ReadDataM  (ReadDataM),
    .RdM        (RdM),
    .PCPlus4M   (PCPlus4M),
    .ALUResultW (ALUResultW),
    .ReadDataW  (ReadDataW),
    .RdW        (RdW),
    .PCPlus4W   (PCPlus4W),

    // --- MODIFICATION: VALID BIT ---
    // Propagate valid bit.
    .valid_in (validM),
    .valid_out(validW)
    // -------------------------------
  );
  
  // ----------------------
  // --- WriteBack Stage ---
  // ----------------------
  
  // Mux to select the final result to write back to the register file
  mux3 #(.WIDTH(32)) resultmux(
    .d0 (ALUResultW), // 00: From ALU
    .d1 (ReadDataW),  // 01: From Data Memory
    .d2 (PCPlus4W),   // 10: From PC+4 (for JAL)
    .s  (ResultSrcW),
    .y  (ResultW)
  );

endmodule
