`timescale 1ns / 1ps

/*
** -------------------------------------------------------------------
**  Control Unit for Single-Cycle MIPS Processor
**
**  Supports the following instructions:
**  - R-type: ADD, SUB, AND, OR, NOR, XOR
**  - I-type: ADDI, LW, SW
**
**  Author: Lab 8 - Single-Cycle MIPS Control
** -------------------------------------------------------------------
*/

module control_unit (
    input  wire [31:0] instruction,
    output reg         RegWrite,
    output reg         RegDst,
    output reg         ALUSrc,
    output reg         MemRead,
    output reg         MemWrite,
    output reg         MemToReg,
    output reg  [5:0]  ALUOp  // 6-bit to match ALU Func_in
);

    // Extract opcode and function fields
    wire [5:0] opcode = instruction[31:26];
    wire [5:0] funct  = instruction[5:0];

    // MIPS Instruction Opcodes
    localparam OP_RTYPE = 6'b000000;  // R-type instructions (ADD, SUB, AND, OR, NOR, XOR)
    localparam OP_ADDI  = 6'b001000;  // ADDI - Add Immediate
    localparam OP_LW    = 6'b100011;  // LW - Load Word
    localparam OP_SW    = 6'b101011;  // SW - Store Word

    // MIPS Function Codes for R-type Instructions
    localparam FUNCT_ADD = 6'b100000; // ADD
    localparam FUNCT_SUB = 6'b100010; // SUB
    localparam FUNCT_AND = 6'b100100; // AND
    localparam FUNCT_OR  = 6'b100101; // OR
    localparam FUNCT_XOR = 6'b100110; // XOR
    localparam FUNCT_NOR = 6'b100111; // NOR

    // ALU Operation Codes (matching the ALU module spec from lab manual)
    localparam ALU_ADD = 6'b100000;   // A + B
    localparam ALU_SUB = 6'b100010;   // A - B
    localparam ALU_AND = 6'b100100;   // A & B
    localparam ALU_OR  = 6'b100101;   // A | B
    localparam ALU_XOR = 6'b100110;   // A ^ B
    localparam ALU_NOR = 6'b100111;   // ~(A | B)

    always @(*) begin
        // Default values (prevent latches)
        RegWrite = 1'b0;
        RegDst   = 1'b0;
        ALUSrc   = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        MemToReg = 1'b0;
        ALUOp    = 6'b000000;

        case(opcode)
            // ================================================================
            // R-TYPE INSTRUCTIONS (opcode = 000000)
            // ================================================================
            OP_RTYPE: begin
                RegWrite = 1'b1;        // Write result to register file
                RegDst   = 1'b1;        // Use rd (bits 15-11) as destination
                ALUSrc   = 1'b0;        // Use register value (rt) for ALU input B
                MemToReg = 1'b0;        // Write ALU result to register (not memory)
                MemRead  = 1'b0;        // No memory read
                MemWrite = 1'b0;        // No memory write
                
                // Pass the function code directly to ALU
                // The ALU will decode it to perform the correct operation
                ALUOp = funct;
                
                // Note: All R-type instructions we support have identical control signals
                // The only difference is the funct field, which goes to the ALU
                // Supported: ADD, SUB, AND, OR, XOR, NOR
            end

            // ================================================================
            // ADDI - Add Immediate
            // ================================================================
            OP_ADDI: begin
                RegWrite = 1'b1;        // Write result to register file
                RegDst   = 1'b0;        // Use rt (bits 20-16) as destination
                ALUSrc   = 1'b1;        // Use immediate value for ALU input B
                MemToReg = 1'b0;        // Write ALU result to register
                MemRead  = 1'b0;        // No memory read
                MemWrite = 1'b0;        // No memory write
                ALUOp    = ALU_ADD;     // Perform addition
            end

            // ================================================================
            // LW - Load Word
            // ================================================================
            OP_LW: begin
                RegWrite = 1'b1;        // Write loaded data to register file
                RegDst   = 1'b0;        // Use rt (bits 20-16) as destination
                ALUSrc   = 1'b1;        // Use immediate (offset) for address calculation
                MemToReg = 1'b1;        // Write memory data to register (not ALU result)
                MemRead  = 1'b1;        // Read from memory
                MemWrite = 1'b0;        // No memory write
                ALUOp    = ALU_ADD;     // Add base address + offset
            end

            // ================================================================
            // SW - Store Word
            // ================================================================
            OP_SW: begin
                RegWrite = 1'b0;        // Don't write to register file
                RegDst   = 1'bx;        // Don't care (not writing to registers)
                ALUSrc   = 1'b1;        // Use immediate (offset) for address calculation
                MemToReg = 1'bx;        // Don't care (not writing to registers)
                MemRead  = 1'b0;        // No memory read
                MemWrite = 1'b1;        // Write to memory
                ALUOp    = ALU_ADD;     // Add base address + offset
            end

            // ================================================================
            // DEFAULT - Unknown instruction
            // ================================================================
            default: begin
                RegWrite = 1'b0;
                RegDst   = 1'b0;
                ALUSrc   = 1'b0;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
                ALUOp    = 6'b000000;
            end
        endcase
    end

endmodule