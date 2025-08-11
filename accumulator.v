module accumulator #(
    parameter N = 256, // Number of synapses - TODO: increase it to 10000
    parameter WIDTH = 32 // Width of each weight
    parameter int OUT_WIDTH = WIDTH + $clog2(N)
) (
    input wire clk,
    input wire reset,
    input wire signed [N*N*WIDTH-1:0] synin, // Synaptic inputs
    output reg signed [N*OUT_WIDTH-1:0] sum // Accumulated sum of synaptic inputs
);
    wire temp_sum[(N*N*WIDTH) << 1 :0]
    assign temp_sum[N*N*WIDTH-1:0] = synin;



    localparam int STAGES = (N <= 1) ? 0 : $clog2(N);

    // Note: this is system verilog syntax
    wire signed [OUT_WIDTH-1:0] stage [0:STAGES][0:N-1][0:N-1];

    genvar i, j;
    generate
        for (i = 0; i < N; i = i + 1) begin : g_row0
            for (j = 0; j < N; j = j + 1) begin : g_col0
                localparam int IDX = ((i*N)+j)*WIDTH;
                wire signed [WIDTH-1:0] term = synin[IDX +: WIDTH];
                assign stage[0][i][j] = {{(OUT_WIDTH-WIDTH){term[WIDTH-1]}}, term};
            end
        end
    endgenerate

    genvar s, k;
    generate
        for (s = 0; s < STAGES; s = s + 1) begin : g_stage
            for (i = 0; i < N; i = i + 1) begin : g_row
                for (k = 0; k < (N >> (s+1)); k = k + 1) begin : g_pair
                    assign stage[s+1][i][k] = stage[s][i][2*k] + stage[s][i][2*k+1];
                end
            end
        end
    endgenerate

    generate
        for (i = 0; i < N; i = i + 1) begin : g_out
            assign sum[i*OUT_WIDTH +: OUT_WIDTH] = stage[STAGES][i][0];
        end
    endgenerate

endmodule