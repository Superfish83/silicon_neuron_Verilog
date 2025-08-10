`define MAX_SYNIN_LEN 10000

module neuron #(
    parameter N = 32
)(
    input wire clk,
    input wire reset,
    //input wire [MAX_SYNIN_LEN-1:0] synin,
    input wire [N-1:0] I,
    output wire synout,
    output wire signed [N-1:0] vout // 테스트용
);
    //reg [N-1:0] I; // sum of synaptic input (어떻게 계산할지 미정)
    reg signed [N-1:0] v;
    reg signed [N-1:0] w;
    assign vout = v; // 테스트용

    wire signed [N-1:0] v_new;
    wire signed [N-1:0] w_new;
    wire fire;

    integrator #(
        .N(N)
    ) integrator_inst (
        .I(I),
        .w_old(w),
        .v_old(v),
        .w_new(w_new),
        .v_new(v_new),
        .fire(fire)
    );

    impulse_generator #(
        .HOLD_TIME(8)
    ) impulse_generator_inst (
        .clk(clk),
        .reset(reset),
        .fire(fire),
        .synout(synout)
    );

    always @(posedge clk or posedge reset) begin
        $display("%f",  $itor(v * (2.0**-16)));

        if (reset) begin
            v <= 32'hffbf_0000; // 초기값: -65 [mV]
            w <= 32'hfff1_0000; // 초기값: -15 [mV]
        end
        else begin
            // Integrator module will update v and w based on I
            v <= v_new;
            w <= w_new;
        end
    end

endmodule

module impulse_generator #(
    parameter HOLD_TIME = 8 // impulse 신호를 몇 클럭 동안 유지할지
)(
    input wire clk,
    input wire reset,
    input wire fire,
    output reg synout
);
    reg [$clog2(HOLD_TIME) - 1:0] holdctr;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            synout <= 0;
            holdctr <= 0;
        end else begin
            if (fire) begin
                synout <= 1'b1;
                holdctr <= HOLD_TIME - 1;
            end
            else if (holdctr > 0) begin
                synout <= 1'b1;
                holdctr <= holdctr - 1;
            end
            else begin
                synout <= 1'b0;
            end
        end
    end
endmodule