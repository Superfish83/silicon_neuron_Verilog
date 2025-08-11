module IZH_integrator_approx #(
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

    function signed [V_WIDTH-1:0] div4(
        input signed [V_WIDTH-1:0] a
    );
        begin
            div4 = a >>> 2;
        end
    endfunction
    
    function signed [V_WIDTH-1:0] div8(
        input signed [V_WIDTH-1:0] a
    );
        begin
            div8 = a >>> 3;
        end
    endfunction

    function signed [V_WIDTH-1:0] abs(
        input signed [V_WIDTH-1:0] a
    );
        begin
            abs = a[V_WIDTH-1] ? -a : a;
        end
    endfunction

    // Fourth-order Piecewise-Linear Approximation (H. Soleimani, A. Ahmadi)
    // - https://ieeexplore.ieee.org/abstract/document/6268301/
    reg signed [V_WIDTH-1:0] v_tmp, w_tmp;
    wire signed [V_WIDTH-1:0] v_th = (32 << FR_WIDTH); // 32 [mV]
    always @(I, w_old, v_old) begin

        // v' - (I - w) = 0.75 * (|x+73.5| + |x+51.5|) + 0.375 * |x+62.5| - 33
        //    = 3 * [ {(|x+73.5| + |x+51.5|) >> 2} + { |x+62.5| >> 3 } - 11 ]
        //    = 3 * ( |x/4 + 18.375| + |x/4 + 12.875| + |x/8 + 7.8125| - 11 )
        v_tmp = v_old + mul_dt(
                    mult((
                        (-11 << FR_WIDTH)
                        + abs(div4(v_old) + ((4704 << FR_WIDTH) >> 8))
                        + abs(div4(v_old) + ((3296 << FR_WIDTH) >> 8))
                        + abs(div8(v_old) + ((2000 << FR_WIDTH) >> 8))
                    ), (3 << FR_WIDTH)) 
                    + (I - w_old)
                );

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