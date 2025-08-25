module neuron_processor #(
    parameter NR_WIDTH = 56,
    parameter NR_V_WIDTH = 20,
    parameter NR_I_WIDTH = 16,
    parameter NR_V_FRAC_WIDTH = 11
) (
    input logic [NR_WIDTH-1:0] neuron_in,
    output logic [NR_WIDTH-1:0] neuron_out,
    output logic fire
);
    logic signed [NR_V_WIDTH-1:0] v_old, v_new;
    logic signed [NR_V_WIDTH-1:0] w_old, w_new;
    logic signed [NR_I_WIDTH-1:0] I_old, I_new;
    logic signed [NR_V_WIDTH-1:0] I_extend;

    IZH_integrator_approx #(
        .V_WIDTH(NR_V_WIDTH),
        .FR_WIDTH(NR_V_FRAC_WIDTH)
    ) integrator  (
        .v_old(v_old),
        .w_old(w_old),
        .I(I_extend),
        .v_new(v_new),
        .w_new(w_new),
        .fire(fire)
    );
    
    always_comb begin
        {v_old, w_old, I_old} = neuron_in;
        I_extend = {I_old, 4'b0};
        
        I_new = 0; // reset accumulated input to zero
        neuron_out = {v_new, w_new, I_new};
    end

endmodule

   
