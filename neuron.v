`define N 32
`define MAX_SYNIN_LEN 10000

module neuron(
    input wire clk,
    input wire reset,
    input wire [MAX_SYNIN_LEN-1:0] synin,
    output wire synout
);

    reg [N-1:0] v;
    reg [N-1:0] w;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            synout <= 0'b0;
        end else begin
            synout <= 0'b0;
        end
    end

endmodule