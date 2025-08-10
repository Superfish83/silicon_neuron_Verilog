module synapse #(
    parameter N = 256 // Number of synapses - TODO: increase it to 10000
    // Currently, it is assumed that both synaptic inputs and weights are WIDTH bits wide fixed-point numbers
    parameter WIDTH = 32 // Width of each synapse weight
) (
    input wire [N-1:0] Iin,
    output signed reg [N-1:0] Iout,
    input wire clk,
    input wire reset
);
    wire signed [N*N*WIDTH-1:0] weights;  // A flattened NxN weight with WIDTH bits each
    wire signed [N*N*WIDTH-1:0] weighted_I;


    accumulator #(
            .N(N)
            .WIDTH(WIDTH)
        ) accumulator_inst (
            .clk(clk),
            .reset(reset),
            .synin(weighted_I),
            .sum(Iout)
        );
    
    genvar i;
    localparam NUM_BYTES = (N*N + 7) / 8; 
    generate
    for (i = 0; i < NUM_BYTES; i = i + 1) begin : gen_loop
        // TODO: Define an interface for SRAM and instantiate it here
        // Note: Additional padding is expected when it is not aligned to 8 * WIDTH bits
        sram get_weight_8 (
            .addr(WIDTH*i*8),
            .weight(weights[WIDTH*i*8 +: WIDTH*8]),
        );
    end
    endgenerate

    // calculate I_i = Sum (w_ij * I_j)
    generate
    for (i = 0; i < N; i = i + 1) begin : synapse_loop
        weighted_I[i*N +: N] = Iin[i] ? weights[i*N +: N]: {N{1'b0}};
    end
    endgenerate


    always @(posedge clk or posedge reset) begin
        if (reset) begin
            Iout <= {N{1'b0}}; // Reset output to zero
        end 
    end
    
endmodule