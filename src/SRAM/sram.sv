module sram #(
    parameter WIDTH = 32, // Width (bits per word)
    parameter DEPTH = 256, // Depth (# of words)
    parameter RESET_VALUE = 0
) (
    input wire clk,
    input wire reset,

    input wire write_enable,
    input wire [$clog2(DEPTH)-1:0] addr, // address to read/write
    input wire signed [WIDTH-1:0] write_word, // word to write

    output reg signed [WIDTH-1:0] word // read output word
);
    reg signed [WIDTH-1:0] memory [0:DEPTH-1]; // SRAM memory array

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            integer i;
            for (i = 0; i < DEPTH; i = i + 1) begin
                memory[i] = RESET_VALUE; // Reset all memory locations to RESET_VALUE
            end
        end
        else begin
            if (write_enable) begin
                memory[addr] <= write_word; // Write to SRAM
            end
        end

        word <= memory[addr]; // Read from SRAM
    end

endmodule