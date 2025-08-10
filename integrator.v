module integrator #(
    parameter WIDTH // number of precision bits
)(
    input wire [WIDTH-1:0] I,
    input wire signed [WIDTH-1:0] w_old, v_old,
    output reg signed [WIDTH-1:0] w_new, v_new,
    output reg fire
);
    // ** Neuron model: Izhikevich model (Quadratic model) **
    // ** Fixed-point arithmetic: 1.0은 32'h0001_0000 으로 표현 **
    // ** dt = 1/8 [ms] **


    // Function for fixed-point multiplication
    function signed [WIDTH-1:0] mult(
        input signed [WIDTH-1:0] a, b
    );
        reg [2*WIDTH-1:0] result;

        begin
            result = a*b;
            mult = result[3*WIDTH/2-1 : WIDTH/2];
        end
    endfunction

    // Multiply by dt
    function signed [WIDTH-1:0] mul_dt(
        input signed [WIDTH-1:0] a
    );
        begin
            mul_dt = a >>> 3; // dt = 1/8 [ms]
        end
    endfunction

    // Naive numerical integration using Euler's method (최적화 x)
    reg signed [WIDTH-1:0] v_tmp, w_tmp;
    wire signed [WIDTH-1:0] v_th = 32'h0020_0000; // 32 [mV]
    always @(I, w_old, v_old) begin

        // v' = (0.04 * v^2) + 5v + 140 - w + I
        v_tmp = v_old + mul_dt(
                    mult(mult(v_old, v_old), 32'h0000_0a3d) // 0.04 * v^2
                    + mult(v_old, 32'h0005_0000) // 5 * v
                    - w_old + I
                    + 32'h008c_0000 // 140
                );

        // w' = 0.004v - 0.02w
        w_tmp = w_old + mul_dt(
                    mult(v_old, 32'h0000_0106) // 0.004 * v
                    - mult(w_old, 32'h0000_051e) // -0.02 * w
                );

        // if v > 32 [mV]
        if (v_tmp > v_th) begin
            fire = 1'b1;

            v_new = 32'hffbf_0000; // v = -65
            w_new = w_old + 32'h0005_0000; // w = w + 5
        end else begin
            fire = 1'b0;

            v_new = v_tmp;
            w_new = w_tmp;
        end
    end
endmodule