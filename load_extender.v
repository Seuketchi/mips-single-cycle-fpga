`timescale 1ns / 1ps

module load_extender (
    input wire [31:0] mem_data,
    input wire [1:0]  byte_offset,
    input wire [1:0]  load_type,
    output reg [31:0] extended_data
);

    reg [7:0]  selected_byte;
    reg [15:0] selected_half;
    
    always @(*) begin
        case (byte_offset)
            2'b00: selected_byte = mem_data[7:0];
            2'b01: selected_byte = mem_data[15:8];
            2'b10: selected_byte = mem_data[23:16];
            2'b11: selected_byte = mem_data[31:24];
        endcase
        
        case (byte_offset[1])
            1'b0: selected_half = mem_data[15:0];
            1'b1: selected_half = mem_data[31:16];
        endcase
        
        case (load_type)
            2'b00: extended_data = {{24{selected_byte[7]}}, selected_byte};
            2'b01: extended_data = {{16{selected_half[15]}}, selected_half};
            2'b10: extended_data = {24'b0, selected_byte};
            2'b11: extended_data = {16'b0, selected_half};
            default: extended_data = mem_data;
        endcase
    end

endmodule