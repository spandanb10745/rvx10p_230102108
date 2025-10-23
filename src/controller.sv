`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: spandan_bharadwaj//230102108
// 
// Create Date: 22.10.2025 21:05:00
// Design Name: 
// Module Name: controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Pipelined controller for RVX10-P.
// 
// Dependencies: maindec.sv, aludec.sv, c_ID_IEx.sv, c_IEx_IM.sv, c_IM_IW.sv
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/**
 * @brief Pipelined controller.
 * @details Contains the instruction decoders ('maindec', 'aludec') and 
 * pipeline registers for control signals.
 *
 * @param op          Opcode field from instruction.
 * @param funct3      Funct3 field from instruction.
 * @param funct7b5    Bit 5 of Funct7 field (for SUB).
 * @param funct7_2b   Bits 26:25 of instruction (for RVX10).
 * @param ZeroE       Zero flag from ALU in Execute stage.
 * @param FlushE      Flush signal from hazard unit.
 * @param ResultSrcE0 Bit 0 of ResultSrc signal in Execute stage.
 * @param PCSrcE      Output signal to select the next PC.
 * @param ... (other ports) Various control signals for each pipeline stage.
 */
module controller(
  input  logic       clk, reset,
  input  logic [6:0] op,
  input  logic [2:0] funct3,
  input  logic       funct7b5,
  input  logic [1:0] funct7_2b,
  input  logic       ZeroE,
  input  logic       FlushE,
  output logic       ResultSrcE0,
  output logic [1:0] ResultSrcW,
  output logic       MemWriteM,
  output logic       PCSrcE, ALUSrcE, 
  output logic       RegWriteM, RegWriteW,
  output logic [1:0] ImmSrcD,
  output logic [3:0] ALUControlE
);

  // Internal wires for control signals in Decode stage
  logic [1:0] ALUOpD;
  logic [1:0] ResultSrcD, ResultSrcE, ResultSrcM;
  logic [3:0] ALUControlD;
  logic BranchD, BranchE, MemWriteD, MemWriteE, JumpD, JumpE;
  logic ZeroOp, ALUSrcD, RegWriteD, RegWriteE;

  // Instantiate the Main Decoder
  maindec md(
    .op        (op),
    .ResultSrc (ResultSrcD),
    .MemWrite  (MemWriteD),
    .Branch    (BranchD),
    .ALUSrc    (ALUSrcD),
    .RegWrite  (RegWriteD),
    .Jump      (JumpD),
    .ImmSrc    (ImmSrcD),
    .ALUOp     (ALUOpD)
  );

  // Instantiate the ALU Decoder
  aludec ad(
    .opb5       (op[5]),
    .funct3     (funct3),
    .funct7b5   (funct7b5),
    .funct7_2b  (funct7_2b),
    .ALUOp      (ALUOpD),
    .ALUControl (ALUControlD)
  );

  // Instantiate the ID/EX Control Pipeline Register
  c_ID_IEx c_pipreg0(
    .clk         (clk),
    .reset       (reset),
    .clear       (FlushE),       // FlushE clears this register
    .RegWriteD   (RegWriteD),
    .MemWriteD   (MemWriteD),
    .JumpD       (JumpD),
    .BranchD     (BranchD),
    .ALUSrcD     (ALUSrcD),
    .ResultSrcD  (ResultSrcD),
    .ALUControlD (ALUControlD), 
    .RegWriteE   (RegWriteE),
    .MemWriteE   (MemWriteE),
    .JumpE       (JumpE),
    .BranchE     (BranchE),
    .ALUSrcE     (ALUSrcE),
    .ResultSrcE  (ResultSrcE),
    .ALUControlE (ALUControlE)
  );
  
  // Expose bit 0 of ResultSrcE for the hazard unit (to detect loads)
  assign ResultSrcE0 = ResultSrcE[0];

  // Instantiate the EX/MEM Control Pipeline Register
  c_IEx_IM c_pipreg1(
    .clk        (clk),
    .reset      (reset),
    .RegWriteE  (RegWriteE),
    .MemWriteE  (MemWriteE),
    .ResultSrcE (ResultSrcE),
    .RegWriteM  (RegWriteM), 
    .MemWriteM  (MemWriteM),
    .ResultSrcM (ResultSrcM)
  );

  // Instantiate the MEM/WB Control Pipeline Register
  c_IM_IW c_pipreg2 (
    .clk        (clk),
    .reset      (reset),
    .RegWriteM  (RegWriteM),
    .ResultSrcM (ResultSrcM),
    .RegWriteW  (RegWriteW),
    .ResultSrcW (ResultSrcW)
  );

  // Logic to determine PC source: taken branch (BranchE AND ZeroE) OR a jump (JumpE)
  assign PCSrcE = (BranchE & ZeroE) | JumpE;

endmodule
