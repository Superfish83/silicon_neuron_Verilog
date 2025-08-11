module synapse #(
    parameter N = 256 // Number of synapses - TODO: increase it to 10000
    // Currently, it is assumed that both synaptic inputs and weights are WIDTH bits wide fixed-point numbers
    parameter WIDTH = 32 // Width of each synapse weight
    parameter int OUT_WIDTH = WIDTH + $clog2(N)
) (
    input wire [N-1:0] Iin,
    output wire signed [N*OUT_WIDTH-1:0] Iout
    input wire clk,
    input wire reset
);
    wire signed [N*N*WIDTH-1:0] weights;  // A flattened NxN weight with WIDTH bits each
    wire signed [N*N*WIDTH-1:0] weighted_I;


    accumulator #(
        .N(N),
        .WIDTH(WIDTH),
        .OUT_WIDTH(OUT_WIDTH)
    ) u_accum (
        .clk  (clk),
        .reset(reset),
        .synin(weighted_I),
        .sum  (Iout)
    );
    
    genvar ib;
    localparam NUM_BYTES = (N*N + 7) / 8; 
    generate
    for (ib = 0; ib < NUM_BYTES; ib = ib + 1) begin : gen_loop
        // TODO: Define an interface for SRAM and instantiate it here
        // Note: Additional padding is expected when it is not aligned to 8 * WIDTH bits
        sram get_weight_8 (
            .addr(WIDTH*ib*8),
            .weight(weights[WIDTH*ib*8 +: WIDTH*8]),
        );
        
    end
    endgenerate

    // calculate I_i = Sum (w_ij * I_j)
    genvar i, j;
    generate
    for (i = 0; i < N; i = i + 1) begin : gen_i
        for (j = 0; j < N; j = j + 1) begin : gen_j
            localparam int IDX = ((i*N)+j)*WIDTH;
            assign weighted_I[IDX +: WIDTH] =
                Iin[j] ? weights[IDX +: WIDTH] : '0;
        end
    end
    endgenerate


    always @(posedge clk or posedge reset) begin
        if (reset) begin
            Iout <= {N{1'b0}}; // Reset output to zero
        end 
    end
    
endmodule