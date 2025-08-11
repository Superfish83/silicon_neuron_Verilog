module sram #(  // TODO: Define an interface for SRAM
    parameter WIDTH = 32, // Width of each weight
    parameter DEPTH = 256 // Depth of the SRAM
) (
    addr, 
    weight
);
    input wire [DEPTH-1:0] addr; // Address to read/write
    output reg signed [WIDTH-1:0] weight; // Output weight

    reg signed [WIDTH-1:0] memory [0:DEPTH-1]; // SRAM memory array

    always @(addr) begin
        weight = memory[addr]; // Read from SRAM
    end

    // always @(posedge clk) begin
    //     if (write_enable) begin
    //         memory[addr / WIDTH] <= data; // Write to SRAM
    //     end
    // end  
    
endmodule