`timescale 1ns / 1ps

/*
** -------------------------------------------------------------------
**  Control Unit Testbench
**
**  Tests all supported instructions:
**  - R-type: ADD, SUB, AND, OR, NOR, XOR
**  - I-type: ADDI, LW, SW
**
**  Verifies correct control signal generation for each instruction
**  Compatible with iverilog and ModelSim
** -------------------------------------------------------------------
*/

module control_unit_tb();

    // Inputs
    reg [31:0] instruction;
    
    // Outputs
    wire RegWrite;
    wire RegDst;
    wire ALUSrc;
    wire MemRead;
    wire MemWrite;
    wire MemToReg;
    wire [5:0] ALUOp;

    // Instantiate the Unit Under Test (UUT)
    control_unit uut (
        .instruction(instruction),
        .RegWrite(RegWrite),
        .RegDst(RegDst),
        .ALUSrc(ALUSrc),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemToReg(MemToReg),
        .ALUOp(ALUOp)
    );

    // Test counter
    integer test_num;
    integer errors;

    initial begin
        // Initialize
        instruction = 32'h00000000;
        test_num = 1;
        errors = 0;
        
        $display("\n========================================");
        $display("Control Unit Testbench");
        $display("========================================");
        
        #20; // Initial delay
        
        // ====================================================================
        // R-TYPE INSTRUCTIONS
        // ====================================================================
        // Format: opcode(6) rs(5) rt(5) rd(5) shamt(5) funct(6)
        //         000000   src1   src2   dest  00000   funct
        
        // Test 1: ADD $t0, $t1, $t2  -> add $8, $9, $10
        // Instruction: 000000 01001 01010 01000 00000 100000
        $display("\n--- Test %0d: ADD $t0, $t1, $t2 ---", test_num);
        instruction = 32'b000000_01001_01010_01000_00000_100000;
        #10;
        $display("Instruction: 0x%h", instruction);
        $display("Expected -> RegWrite=1 RegDst=1 ALUSrc=0 MemRead=0 MemWrite=0 MemToReg=0 ALUOp=100000");
        $display("Got      -> RegWrite=%b RegDst=%b ALUSrc=%b MemRead=%b MemWrite=%b MemToReg=%b ALUOp=%b",
                 RegWrite, RegDst, ALUSrc, MemRead, MemWrite, MemToReg, ALUOp);
        if (RegWrite !== 1'b1 || RegDst !== 1'b1 || ALUSrc !== 1'b0 || 
            MemRead !== 1'b0 || MemWrite !== 1'b0 || MemToReg !== 1'b0 || ALUOp !== 6'b100000) begin
            $display("*** ERROR: Mismatch detected! ***");
            errors = errors + 1;
        end else begin
            $display("PASS");
        end
        test_num = test_num + 1;
        
        // Test 2: SUB $s0, $s1, $s2  -> sub $16, $17, $18
        // Instruction: 000000 10001 10010 10000 00000 100010
        $display("\n--- Test %0d: SUB $s0, $s1, $s2 ---", test_num);
        instruction = 32'b000000_10001_10010_10000_00000_100010;
        #10;
        $display("Instruction: 0x%h", instruction);
        $display("Expected -> RegWrite=1 RegDst=1 ALUSrc=0 MemRead=0 MemWrite=0 MemToReg=0 ALUOp=100010");
        $display("Got      -> RegWrite=%b RegDst=%b ALUSrc=%b MemRead=%b MemWrite=%b MemToReg=%b ALUOp=%b",
                 RegWrite, RegDst, ALUSrc, MemRead, MemWrite, MemToReg, ALUOp);
        if (RegWrite !== 1'b1 || RegDst !== 1'b1 || ALUSrc !== 1'b0 || 
            MemRead !== 1'b0 || MemWrite !== 1'b0 || MemToReg !== 1'b0 || ALUOp !== 6'b100010) begin
            $display("*** ERROR: Mismatch detected! ***");
            errors = errors + 1;
        end else begin
            $display("PASS");
        end
        test_num = test_num + 1;
        
        // Test 3: AND $a0, $a1, $a2  -> and $4, $5, $6
        // Instruction: 000000 00101 00110 00100 00000 100100
        $display("\n--- Test %0d: AND $a0, $a1, $a2 ---", test_num);
        instruction = 32'b000000_00101_00110_00100_00000_100100;
        #10;
        $display("Instruction: 0x%h", instruction);
        $display("Expected -> RegWrite=1 RegDst=1 ALUSrc=0 MemRead=0 MemWrite=0 MemToReg=0 ALUOp=100100");
        $display("Got      -> RegWrite=%b RegDst=%b ALUSrc=%b MemRead=%b MemWrite=%b MemToReg=%b ALUOp=%b",
                 RegWrite, RegDst, ALUSrc, MemRead, MemWrite, MemToReg, ALUOp);
        if (RegWrite !== 1'b1 || RegDst !== 1'b1 || ALUSrc !== 1'b0 || 
            MemRead !== 1'b0 || MemWrite !== 1'b0 || MemToReg !== 1'b0 || ALUOp !== 6'b100100) begin
            $display("*** ERROR: Mismatch detected! ***");
            errors = errors + 1;
        end else begin
            $display("PASS");
        end
        test_num = test_num + 1;
        
        // Test 4: OR $v0, $v1, $a0  -> or $2, $3, $4
        // Instruction: 000000 00011 00100 00010 00000 100101
        $display("\n--- Test %0d: OR $v0, $v1, $a0 ---", test_num);
        instruction = 32'b000000_00011_00100_00010_00000_100101;
        #10;
        $display("Instruction: 0x%h", instruction);
        $display("Expected -> RegWrite=1 RegDst=1 ALUSrc=0 MemRead=0 MemWrite=0 MemToReg=0 ALUOp=100101");
        $display("Got      -> RegWrite=%b RegDst=%b ALUSrc=%b MemRead=%b MemWrite=%b MemToReg=%b ALUOp=%b",
                 RegWrite, RegDst, ALUSrc, MemRead, MemWrite, MemToReg, ALUOp);
        if (RegWrite !== 1'b1 || RegDst !== 1'b1 || ALUSrc !== 1'b0 || 
            MemRead !== 1'b0 || MemWrite !== 1'b0 || MemToReg !== 1'b0 || ALUOp !== 6'b100101) begin
            $display("*** ERROR: Mismatch detected! ***");
            errors = errors + 1;
        end else begin
            $display("PASS");
        end
        test_num = test_num + 1;
        
        // Test 5: XOR $t3, $t4, $t5  -> xor $11, $12, $13
        // Instruction: 000000 01100 01101 01011 00000 100110
        $display("\n--- Test %0d: XOR $t3, $t4, $t5 ---", test_num);
        instruction = 32'b000000_01100_01101_01011_00000_100110;
        #10;
        $display("Instruction: 0x%h", instruction);
        $display("Expected -> RegWrite=1 RegDst=1 ALUSrc=0 MemRead=0 MemWrite=0 MemToReg=0 ALUOp=100110");
        $display("Got      -> RegWrite=%b RegDst=%b ALUSrc=%b MemRead=%b MemWrite=%b MemToReg=%b ALUOp=%b",
                 RegWrite, RegDst, ALUSrc, MemRead, MemWrite, MemToReg, ALUOp);
        if (RegWrite !== 1'b1 || RegDst !== 1'b1 || ALUSrc !== 1'b0 || 
            MemRead !== 1'b0 || MemWrite !== 1'b0 || MemToReg !== 1'b0 || ALUOp !== 6'b100110) begin
            $display("*** ERROR: Mismatch detected! ***");
            errors = errors + 1;
        end else begin
            $display("PASS");
        end
        test_num = test_num + 1;
        
        // Test 6: NOR $t6, $t7, $t8  -> nor $14, $15, $16
        // Instruction: 000000 01111 10000 01110 00000 100111
        $display("\n--- Test %0d: NOR $t6, $t7, $t8 ---", test_num);
        instruction = 32'b000000_01111_10000_01110_00000_100111;
        #10;
        $display("Instruction: 0x%h", instruction);
        $display("Expected -> RegWrite=1 RegDst=1 ALUSrc=0 MemRead=0 MemWrite=0 MemToReg=0 ALUOp=100111");
        $display("Got      -> RegWrite=%b RegDst=%b ALUSrc=%b MemRead=%b MemWrite=%b MemToReg=%b ALUOp=%b",
                 RegWrite, RegDst, ALUSrc, MemRead, MemWrite, MemToReg, ALUOp);
        if (RegWrite !== 1'b1 || RegDst !== 1'b1 || ALUSrc !== 1'b0 || 
            MemRead !== 1'b0 || MemWrite !== 1'b0 || MemToReg !== 1'b0 || ALUOp !== 6'b100111) begin
            $display("*** ERROR: Mismatch detected! ***");
            errors = errors + 1;
        end else begin
            $display("PASS");
        end
        test_num = test_num + 1;
        
        // ====================================================================
        // I-TYPE INSTRUCTIONS
        // ====================================================================
        
        // Test 7: ADDI $t0, $t1, 100  -> addi $8, $9, 100
        // Format: opcode(6) rs(5) rt(5) immediate(16)
        // Instruction: 001000 01001 01000 0000000001100100
        $display("\n--- Test %0d: ADDI $t0, $t1, 100 ---", test_num);
        instruction = 32'b001000_01001_01000_0000000001100100;
        #10;
        $display("Instruction: 0x%h", instruction);
        $display("Expected -> RegWrite=1 RegDst=0 ALUSrc=1 MemRead=0 MemWrite=0 MemToReg=0 ALUOp=100000");
        $display("Got      -> RegWrite=%b RegDst=%b ALUSrc=%b MemRead=%b MemWrite=%b MemToReg=%b ALUOp=%b",
                 RegWrite, RegDst, ALUSrc, MemRead, MemWrite, MemToReg, ALUOp);
        if (RegWrite !== 1'b1 || RegDst !== 1'b0 || ALUSrc !== 1'b1 || 
            MemRead !== 1'b0 || MemWrite !== 1'b0 || MemToReg !== 1'b0 || ALUOp !== 6'b100000) begin
            $display("*** ERROR: Mismatch detected! ***");
            errors = errors + 1;
        end else begin
            $display("PASS");
        end
        test_num = test_num + 1;
        
        // Test 8: LW $t0, 8($sp)  -> lw $8, 8($29)
        // Instruction: 100011 11101 01000 0000000000001000
        $display("\n--- Test %0d: LW $t0, 8($sp) ---", test_num);
        instruction = 32'b100011_11101_01000_0000000000001000;
        #10;
        $display("Instruction: 0x%h", instruction);
        $display("Expected -> RegWrite=1 RegDst=0 ALUSrc=1 MemRead=1 MemWrite=0 MemToReg=1 ALUOp=100000");
        $display("Got      -> RegWrite=%b RegDst=%b ALUSrc=%b MemRead=%b MemWrite=%b MemToReg=%b ALUOp=%b",
                 RegWrite, RegDst, ALUSrc, MemRead, MemWrite, MemToReg, ALUOp);
        if (RegWrite !== 1'b1 || RegDst !== 1'b0 || ALUSrc !== 1'b1 || 
            MemRead !== 1'b1 || MemWrite !== 1'b0 || MemToReg !== 1'b1 || ALUOp !== 6'b100000) begin
            $display("*** ERROR: Mismatch detected! ***");
            errors = errors + 1;
        end else begin
            $display("PASS");
        end
        test_num = test_num + 1;
        
        // Test 9: SW $t1, 12($sp)  -> sw $9, 12($29)
        // Instruction: 101011 11101 01001 0000000000001100
        $display("\n--- Test %0d: SW $t1, 12($sp) ---", test_num);
        instruction = 32'b101011_11101_01001_0000000000001100;
        #10;
        $display("Instruction: 0x%h", instruction);
        $display("Expected -> RegWrite=0 RegDst=X ALUSrc=1 MemRead=0 MemWrite=1 MemToReg=X ALUOp=100000");
        $display("Got      -> RegWrite=%b RegDst=%b ALUSrc=%b MemRead=%b MemWrite=%b MemToReg=%b ALUOp=%b",
                 RegWrite, RegDst, ALUSrc, MemRead, MemWrite, MemToReg, ALUOp);
        // For SW, we only check the important signals (RegDst and MemToReg are don't care)
        if (RegWrite !== 1'b0 || ALUSrc !== 1'b1 || 
            MemRead !== 1'b0 || MemWrite !== 1'b1 || ALUOp !== 6'b100000) begin
            $display("*** ERROR: Mismatch detected! ***");
            errors = errors + 1;
        end else begin
            $display("PASS");
        end
        test_num = test_num + 1;
        
        // ====================================================================
        // Summary
        // ====================================================================
        #20;
        $display("\n========================================");
        $display("Test Summary");
        $display("========================================");
        $display("Total Tests: %0d", test_num - 1);
        $display("Errors: %0d", errors);
        if (errors == 0) begin
            $display("*** ALL TESTS PASSED! ***");
        end else begin
            $display("*** SOME TESTS FAILED ***");
        end
        $display("========================================\n");
        
        $finish;
    end

endmodule