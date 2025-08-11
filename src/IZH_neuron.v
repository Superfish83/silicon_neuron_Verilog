module IZH_neuron #(
    parameter V_WIDTH = 20,
    parameter FR_WIDTH = 11
)(
    input wire clk,
    input wire reset,
    input wire [V_WIDTH-1:0] synin,
    output wire synout,
    output wire signed [V_WIDTH-1:0] vout // 테스트용
);
    reg signed [V_WIDTH-1:0] v;
    reg signed [V_WIDTH-1:0] w;
    assign vout = v; // 테스트용

    wire signed [V_WIDTH-1:0] v_new;
    wire signed [V_WIDTH-1:0] w_new;
    wire fire;

    IZH_integrator_approx #(
        .V_WIDTH(V_WIDTH),
        .FR_WIDTH(FR_WIDTH)
    ) integrator_inst (
        .I(synin),
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
        $display("%f",  $itor(v * (2.0**-(FR_WIDTH))));

        if (reset) begin
            v <= (-65 << FR_WIDTH); // 초기값: -65 [mV]
            w <= (-12 << FR_WIDTH); // 초기값: -12 [mV]
        end
        else begin
            // Integrator module will update v and w based on I
            v <= v_new;
            w <= w_new;
        end
    end

endmodule