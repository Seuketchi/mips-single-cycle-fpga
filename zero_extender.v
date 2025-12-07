`timescale 1ns / 1ps

module zero_extender #(
    parameter IN_WIDTH = 16,
    parameter OUT_WIDTH = 32
)(
    input wire [IN_WIDTH-1:0] in,
    output wire [OUT_WIDTH-1:0] out
);

    assign out = {{(OUT_WIDTH-IN_WIDTH){1'b0}}, in};

endmodule