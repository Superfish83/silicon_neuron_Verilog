`define MAX_SYNIN_LEN 10000

module neuron #(
    parameter N = 32
)(
    input wire clk,
    input wire reset,
    input wire [MAX_SYNIN_LEN-1:0] synin,
    output wire synout
);
    reg [N-1:0] I; // sum of synaptic input (어떻게 계산할지 미정)
    reg [N-1:0] v;
    reg [N-1:0] w;

    integrator #(
        .N(N)
    ) integrator_inst (
        .clk(clk),
        .reset(reset),
        .I(I),
        .w_in(w),
        .v_in(v),
        .w(w),
        .v(v)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            synout <= 0'b0;
        end else begin
            synout <= 0'b0;
        end
    end

endmodule

module integrator #(
    parameter N = 32
)(
    input wire clk,
    input wire reset,
    input wire [N-1:0] I,
    input wire [N-1:0] w_in,
    input wire [N-1:0] v_in,
    output reg [N-1:0] w,
    output reg [N-1:0] v
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            v <= 0;
            w <= 0;
        end else begin
            // numerical integration logic????? 어떤 미분방정식 모델 사용할지 미정
        end
    end
endmodule