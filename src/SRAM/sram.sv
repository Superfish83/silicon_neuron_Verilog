module sram #(
    parameter WIDTH = 32, // Width (bits per word)
    parameter DEPTH = 256, // Depth (# of words)
    parameter RESET_VALUE = 0
) (
    input logic clk,
    input logic reset,

    input logic write_enable,
    input logic [$clog2(DEPTH)-1:0] addr, // address to read/write
    input logic signed [WIDTH-1:0] write_word, // word to write

    output logic signed [WIDTH-1:0] word // read output word
);
    logic signed [WIDTH-1:0] memory [0:DEPTH-1]; // SRAM memory array

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            integer i, j;
            for (i = 0; i < DEPTH / 16; i = i + 1) begin
                for (j = 0; j < 16; j = j + 1) begin
                    memory[i*16 + j] <= RESET_VALUE; // Reset all memory locations to RESET_VALUE
                end
            end
            word <= RESET_VALUE;
        end
        else begin
            if (write_enable) begin
                memory[addr] <= write_word; // Write to SRAM
            end
            word <= memory[addr]; // Read from SRAM
        end
    end

endmodule