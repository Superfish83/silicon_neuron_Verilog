`timescale 1ns / 1ps
module testbench;

    reg clk;
    reg reset;
    reg [31:0] I;
    wire signed [31:0] v;
    wire synout;

    neuron #(
        .N(32)
    ) uut (
        .clk(clk),
        .reset(reset),
        .I(I),
        .synout(synout),
        .vout(v)
    );

    always begin
        clk = 1;
        forever #5 clk = ~clk; // 10 ns clock period
    end

    initial begin
        reset = 1;
        I = 32'h0000_0000;
        
        #10;
        reset = 0;

        #100;
        I = 32'h000f_0000;
    end

endmodule