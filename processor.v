`timescale 1ns / 1ps

module processor(
    input clk,
    input reset,
    
    // Serial port connections
    input [7:0] serial_in,
    input serial_ready_in,
    input serial_valid_in,
    output [7:0] serial_out,
    output serial_rden_out,
    output serial_wren_out
);

    // ========================================================================
    // Wire Declarations
    // ========================================================================
    
    // Program Counter wires
    wire [31:0] pc_current;
    wire [31:0] pc_next;
    wire [31:0] pc_plus4;
    
    // Instruction memory wires
    wire [31:0] instruction;
    
    // Instruction fields
    wire [4:0] instr_25_21;  
    wire [4:0] instr_20_16;  
    wire [4:0] instr_15_11;  
    wire [15:0] instr_15_0;  
    
    // Register file wires
    wire [4:0] write_register;
    wire [31:0] write_data;
    wire [31:0] read_data_1;
    wire [31:0] read_data_2;
    wire reg_write_enable;
    
    // Sign extender wires
    wire [31:0] sign_extended;
    
    // ALU wires
    wire [31:0] alu_input_b;
    wire [31:0] alu_result;
    wire [5:0] alu_func;
    wire alu_branch;
    wire alu_jump;
    
    // Data memory wires
    wire [31:0] read_data;
    wire mem_read_enable;
    wire mem_write_enable;
    wire [1:0] mem_size;
    
    // Control signal wires
    wire alu_src;
    wire mem_to_reg;
    wire reg_dst;

    // Control unit wires
    wire RegWrite;
    wire RegDst_signal;
    wire ALUSrc_signal;
    wire MemRead;
    wire MemWrite;
    wire MemToReg;
    wire [5:0] ALUOp;

    // ========================================================================
    // Instruction Field Extraction
    // ========================================================================
    
    assign instr_25_21 = instruction[25:21];
    assign instr_20_16 = instruction[20:16];
    assign instr_15_11 = instruction[15:11];
    assign instr_15_0  = instruction[15:0];

    // ========================================================================
    // Program Counter
    // ========================================================================
    
    program_counter #(
        .RESET_ADDR(32'h003FFFFC)
    ) pc (
        .clk(clk),
        .reset(reset),
        .next_pc(pc_next),
        .pc_out(pc_current)
    );
    
    adder #(.WIDTH(32)) pc_adder (
        .a(pc_current),
        .b(32'd4),
        .sum(pc_plus4)
    );

    // ========================================================================
    // Instruction Memory
    // ========================================================================
    
    inst_rom #(
//        .INIT_PROGRAM("C:/intelFPGA_lite/18.0/new/lab7-test.inst_rom.memh")
		  .INIT_PROGRAM("C:/intelFPGA_lite/18.0/new/nbhelloworld.inst_rom.memh")
    ) instruction_memory (
        .clock(clk),
        .reset(reset),
        .addr_in(pc_next),
        .data_out(instruction)
    );

    // ========================================================================
    // Register File
    // ========================================================================
    
    mux2 #(.WIDTH(5)) write_reg_mux (
        .a(instr_20_16),
        .b(instr_15_11),
        .sel(reg_dst),
        .y(write_register)
    );
    
    register register_file (
        .clk(clk),
        .we(reg_write_enable),
        .r_addr1(instr_25_21),
        .r_addr2(instr_20_16),
        .w_addr(write_register),
        .w_data(write_data),
        .r_data1(read_data_1),
        .r_data2(read_data_2)
    );

    // ========================================================================
    // Sign Extender
    // ========================================================================
    
    sign_extender #(.IN_WIDTH(16), .OUT_WIDTH(32)) sign_ext (
        .in(instr_15_0),
        .out(sign_extended)
    );

    // ========================================================================
    // ALU Input MUX
    // ========================================================================
    
    mux2 #(.WIDTH(32)) alu_b_mux (
        .a(read_data_2),
        .b(sign_extended),
        .sel(alu_src),
        .y(alu_input_b)
    );

    // ========================================================================
    // ALU
    // ========================================================================
    
    alu alu_unit (
        .Func_in(alu_func),
        .A_in(read_data_1),
        .B_in(alu_input_b),
        .O_out(alu_result),
        .Branch_out(alu_branch),
        .Jump_out(alu_jump)
    );

    // ========================================================================
    // Data Memory
    // ========================================================================
    
    data_memory #(
//        .INIT_PROGRAM0("C:/intelFPGA_lite/18.0/new/lab7-test.data_ram0.memh"),
//        .INIT_PROGRAM1("C:/intelFPGA_lite/18.0/new/lab7-test.data_ram1.memh"),
//        .INIT_PROGRAM2("C:/intelFPGA_lite/18.0/new/lab7-test.data_ram2.memh"),
//        .INIT_PROGRAM3("C:/intelFPGA_lite/18.0/new/lab7-test.data_ram3.memh")
		  .INIT_PROGRAM0("C:/intelFPGA_lite/18.0/new/nbhelloworld.data_ram0.memh"),
        .INIT_PROGRAM1("C:/intelFPGA_lite/18.0/new/nbhelloworld.data_ram1.memh"),
        .INIT_PROGRAM2("C:/intelFPGA_lite/18.0/new/nbhelloworld.data_ram2.memh"),
        .INIT_PROGRAM3("C:/intelFPGA_lite/18.0/new/nbhelloworld.data_ram3.memh")
    ) data_mem (
        .clock(clk),
        .reset(reset),
        .addr_in(alu_result),
        .writedata_in(read_data_2),
        .re_in(mem_read_enable),
        .we_in(mem_write_enable),
        .size_in(mem_size),
        .readdata_out(read_data),
        .serial_in(serial_in),
        .serial_ready_in(serial_ready_in),
        .serial_valid_in(serial_valid_in),
        .serial_out(serial_out),
        .serial_rden_out(serial_rden_out),
        .serial_wren_out(serial_wren_out)
    );

    // ========================================================================
    // Write Back MUX
    // ========================================================================
    
    mux2 #(.WIDTH(32)) write_data_mux (
        .a(alu_result),
        .b(read_data),
        .sel(mem_to_reg),
        .y(write_data)
    );

    // ========================================================================
    // Control Unit (ADDED HERE)
    // ========================================================================

    control_unit CU (
        .instruction(instruction),
        .RegWrite(RegWrite),
        .RegDst(RegDst_signal),
        .ALUSrc(ALUSrc_signal),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemToReg(MemToReg),
        .ALUOp(ALUOp)
    );

    // ========================================================================
    // Connect Control Unit to Datapath
    // ========================================================================
    
    assign reg_write_enable = RegWrite;
    assign mem_write_enable = MemWrite;
    assign mem_read_enable  = MemRead;
    assign mem_size         = 2'b11;           // word size only
    assign alu_src          = ALUSrc_signal;
    assign mem_to_reg       = MemToReg;
    assign reg_dst          = RegDst_signal;
    assign alu_func         = ALUOp;

    // ========================================================================
    // PC Next (still sequential)
    // ========================================================================
    assign pc_next = pc_plus4;

endmodule