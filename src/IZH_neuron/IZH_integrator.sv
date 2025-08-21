module IZH_integrator #(
    parameter V_WIDTH = 20,
    parameter FR_WIDTH = 11
)(
    input wire [V_WIDTH-1:0] I,
    input wire signed [V_WIDTH-1:0] w_old, v_old,
    output reg signed [V_WIDTH-1:0] w_new, v_new,
    output reg fire
);
    // ** Neuron model: Izhikevich model, with Fixed-point Arithmetic **
    // ** dt = 1/4 [ms] **

    // Function for fixed-point multiplication
    function signed [V_WIDTH-1:0] mult(
        input signed [V_WIDTH-1:0] a, b
    );
        reg [2*V_WIDTH-1:0] result;

        begin
            result = a*b;
            mult = result[V_WIDTH + FR_WIDTH - 1 : FR_WIDTH];
        end
    endfunction

    // Multiply by dt
    function signed [V_WIDTH-1:0] mul_dt(
        input signed [V_WIDTH-1:0] a
    );
        begin
            mul_dt = a >>> 2; // dt = 1/4 [ms]
        end
    endfunction

    // Naive numerical integration using Euler's method (최적화 x)
    reg signed [V_WIDTH-1:0] v_tmp, w_tmp;
    wire signed [V_WIDTH-1:0] v_th = (32 << FR_WIDTH); // 32 [mV]
    always @(I, w_old, v_old) begin

        // v' = (0.04 * v^2) + 5v + 140 - w + I
        v_tmp = v_old
                    + mult(mul_dt(v_old), mult(v_old, ((2621 << FR_WIDTH) >> 16))) // 0.04 * v^2
                    + mult(v_old, mul_dt(5 << FR_WIDTH)) // 5 * v
                    + mul_dt((140 << FR_WIDTH) - w_old + I);

        // w' = 0.004v - 0.02w
        w_tmp = w_old + mul_dt(
                    + mult(v_old, ((261 << FR_WIDTH) >> 16)) // 0.004 * v
                    + mult(w_old, ((-1311 << FR_WIDTH) >>> 16)) // -0.02 * w
        );


        // if v > 32 [mV]
        if (v_tmp > v_th) begin
            fire = 1'b1;

            v_new = (-65 << FR_WIDTH); // v = -65
            w_new = w_old + (8 << FR_WIDTH); // w = w + 8
        end else begin
            fire = 1'b0;

            v_new = v_tmp;
            w_new = w_tmp;
        end
    end
endmodule