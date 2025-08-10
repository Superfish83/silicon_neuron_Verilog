module accumulator #(
    parameter N = 256, // Number of synapses - TODO: increase it to 10000
    parameter WIDTH = 32 // Width of each weight
) (
    input wire clk,
    input wire reset,
    input wire signed [N*N*WIDTH-1:0] synin, // Synaptic inputs
    output signed reg [N*WIDTH-1:0] sum // Accumulated sum of synaptic inputs
);
    wire temp_sum[(N*N*WIDTH) << 1 :0]
    assign temp_sum[N*N*WIDTH-1:0] = synin;


    // Define a helper function for loop
    function clog2(
        input integer value
    );
        integer i;
        begin
            clog2 = 0;
            for (i = 0; (1 << i) < value; i = i + 1) begin
                clog2 = i + 1;
            end
        end
    endfunction 
    

    generate
        begin : gen_accumulator  // Cascade
            genvar i, j;
            for (i = 0; i<clog2(N); i = i+1) begin
                for (j = 0; j < (N >> (i+1)) ; j = j + 1) begin
                    // This is not feasible for large N
                end
            end
        end
    endgenerate
endmodule