`timescale 1ns / 1ps

/*
** -------------------------------------------------------------------
**  Top-Level Processor Module for Single-Cycle MIPS Processor
**  
**  This module instantiates and connects all datapath components
**  according to the Lab 6 datapath schematic.
**
*/

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
    
    // Instruction fields (as shown in schematic)
    wire [4:0] instr_25_21;  // rs - Read register 1
    wire [4:0] instr_20_16;  // rt - Read register 2
    wire [4:0] instr_15_11;  // rd - destination register
    wire [15:0] instr_15_0;  // immediate field
    
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
    
    // ========================================================================
    // Instruction Field Extraction (matching schematic labels)
    // ========================================================================
    
    assign instr_25_21 = instruction[25:21];  // rs
    assign instr_20_16 = instruction[20:16];  // rt
    assign instr_15_11 = instruction[15:11];  // rd
    assign instr_15_0 = instruction[15:0];    // immediate
    
    // ========================================================================
    // Program Counter and PC+4
    // ========================================================================
    
    program_counter #(
        .RESET_ADDR(32'h00400000)
    ) pc (
        .clk(clk),
        .reset(reset),
        .next_pc(pc_next),
        .pc_out(pc_current)
    );
    
    // PC + 4 adder (top left of schematic)
    adder #(
        .WIDTH(32)
    ) pc_adder (
        .a(pc_current),
        .b(32'd4),
        .sum(pc_plus4)
    );
    
    // ========================================================================
    // Instruction Memory
    // ========================================================================
    
    inst_rom #(
        .INIT_PROGRAM("C:/intelFPGA_lite/18.0/new/blank.memh")
    ) instruction_memory (
        .clock(clk),
        .reset(reset),
        .addr_in(pc_next),
        .data_out(instruction)
    );
    
    // ========================================================================
    // Register File (center of schematic)
    // ========================================================================
    
    // MUX to select write register: rt (instr[20-16]) or rd (instr[15-11])
    mux2 #(
        .WIDTH(5)
    ) write_reg_mux (
        .a(instr_20_16),  // rt
        .b(instr_15_11),  // rd
        .sel(reg_dst),
        .y(write_register)
    );
    
    register register_file (
        .clk(clk),
        .we(reg_write_enable),
        .r_addr1(instr_25_21),    // Read register 1
        .r_addr2(instr_20_16),    // Read register 2
        .w_addr(write_register),  // Write register
        .w_data(write_data),      // Write data
        .r_data1(read_data_1),    // Read data 1
        .r_data2(read_data_2)     // Read data 2
    );
    
    // ========================================================================
    // Sign Extender (bottom center of schematic)
    // ========================================================================
    
    sign_extender #(
        .IN_WIDTH(16),
        .OUT_WIDTH(32)
    ) sign_ext (
        .in(instr_15_0),
        .out(sign_extended)
    );
    
    // ========================================================================
    // ALU Input B MUX (before ALU)
    // ========================================================================
    
    // MUX to select ALU input B: Read data 2 or sign-extended immediate
    mux2 #(
        .WIDTH(32)
    ) alu_b_mux (
        .a(read_data_2),
        .b(sign_extended),
        .sel(alu_src),
        .y(alu_input_b)
    );
    
    // ========================================================================
    // ALU (right side of schematic)
    // ========================================================================
    
    alu alu_unit (
        .Func_in(alu_func),
        .A_in(read_data_1),    // ALU input A always from Read data 1
        .B_in(alu_input_b),    // ALU input B from MUX
        .O_out(alu_result),
        .Branch_out(alu_branch),
        .Jump_out(alu_jump)
    );
    
    // ========================================================================
    // Data Memory (right side of schematic)
    // ========================================================================
    
    data_memory #(
        .INIT_PROGRAM0("C:/intelFPGA_lite/18.0/new/blank.memh"),
        .INIT_PROGRAM1("C:/intelFPGA_lite/18.0/new/blank.memh"),
        .INIT_PROGRAM2("C:/intelFPGA_lite/18.0/new/blank.memh"),
        .INIT_PROGRAM3("C:/intelFPGA_lite/18.0/new/blank.memh")
    ) data_mem (
        .clock(clk),
        .reset(reset),
        .addr_in(alu_result),         // Address from ALU result
        .writedata_in(read_data_2),   // Write data from Read data 2
        .re_in(mem_read_enable),      // RE
        .we_in(mem_write_enable),     // WE
        .size_in(mem_size),           // Size
        .readdata_out(read_data),     // Read data output
        .serial_in(serial_in),
        .serial_ready_in(serial_ready_in),
        .serial_valid_in(serial_valid_in),
        .serial_out(serial_out),
        .serial_rden_out(serial_rden_out),
        .serial_wren_out(serial_wren_out)
    );
    
    // ========================================================================
    // Write Back MUX (feeds back to register file)
    // ========================================================================
    
    // MUX to select write data: ALU result or memory read data
    mux2 #(
        .WIDTH(32)
    ) write_data_mux (
        .a(alu_result),
        .b(read_data),
        .sel(mem_to_reg),
        .y(write_data)
    );
    
    // ========================================================================
    // PC Next Logic (top of schematic - feeds back to PC)
    // ========================================================================
    
    // The schematic shows ALU outputs "Op", "Jump", and "Branch"
    // These control the PC next selection
    // For now, just use PC+4 (sequential execution)
    // The actual branch/jump logic will be added with the control unit
    assign pc_next = pc_plus4;
    
    // ========================================================================
    // Temporary Control Signal Assignments
    // These will be replaced by actual control unit in next lab
    // ========================================================================
    
    assign reg_write_enable = 1'b0;  // Disable writes for now
    assign mem_write_enable = 1'b0;  // Disable memory writes
    assign mem_read_enable = 1'b0;   // Disable memory reads
    assign mem_size = 2'b11;         // Default to word size
    assign alu_src = 1'b0;           // Default to register input
    assign mem_to_reg = 1'b0;        // Default to ALU result
    assign reg_dst = 1'b0;           // Default to rt
    assign alu_func = 6'b100000;     // Default to ADD operation
    
endmodule