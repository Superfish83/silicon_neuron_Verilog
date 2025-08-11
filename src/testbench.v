`timescale 1ns / 1ps

module testbench;
    parameter WIDTH = 20;
    parameter FR_WIDTH = 11;

    reg clk, reset;
    reg signed [WIDTH-1:0] synin;
    wire signed [WIDTH-1:0] v;
    wire synout;

    IZH_neuron #(
        .WIDTH(WIDTH),
        .FR_WIDTH(FR_WIDTH)
    ) uut (
        .clk(clk),
        .reset(reset),
        .synin(synin),
        .synout(synout),
        .vout(v)
    );

    always begin
        clk = 1;
        forever #5 clk = ~clk; // 10 ns clock period
    end

    initial begin
        reset = 1;
        synin = 0;
        
        #10;
        reset = 0;

        #100;
        synin = 1 << (FR_WIDTH + 3);
    end

endmodule