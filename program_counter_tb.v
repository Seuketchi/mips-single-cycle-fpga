`timescale 1ns/1ps

module tb_program_counter;

    // Inputs
    reg clk;
    reg reset;
    reg [31:0] next_pc;

    // Output
    wire [31:0] pc_out;

    // Instantiate the Program Counter
    program_counter uut (
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc),
        .pc_out(pc_out)
    );

    // Clock generation: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;  // 50MHz clock (10ns period)

    // Test procedure
    initial begin
        // Initialize signals
        reset = 1;
        next_pc = 32'h00400000; // typical MIPS start

        #10;  // wait 10ns
        reset = 0;

        // Step through some PC values
        next_pc = 32'h00400004; #10;
        next_pc = 32'h00400008; #10;
        next_pc = 32'h0040000C; #10;
        next_pc = 32'h00400010; #10;

        // Apply reset again
        reset = 1; #10;
        reset = 0;

        next_pc = 32'h00400014; #10;

        // Finish simulation
        #10 $finish;
    end

    // Monitor outputs in console
    initial begin
        $monitor("Time=%0t | reset=%b | next_pc=%h | pc_out=%h", 
                 $time, reset, next_pc, pc_out);
    end

    // GTKWave VCD dump
    initial begin
        $dumpfile("pc.vcd");
        $dumpvars(0, tb_program_counter);
    end

endmodule
