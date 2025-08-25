module neuron_accumulator #(
    parameter NR_WIDTH = 56,
    parameter NR_I_WIDTH = 16,
    parameter SR_SYN_WIDTH = 4
) (
    input logic [NR_WIDTH-1:0] neuron_in,
    input logic signed [SR_SYN_WIDTH-1:0] syn_in,
    output logic [NR_WIDTH-1:0] neuron_out
);
    logic signed [NR_I_WIDTH-1:0] I_old;
    logic signed [NR_I_WIDTH-1:0] I_new;

    always_comb begin
        I_old = neuron_in[NR_I_WIDTH-1:0];
        I_new = I_old + {NR_I_WIDTH'(signed'(syn_in))};
        neuron_out = {neuron_in[NR_WIDTH-1:NR_I_WIDTH], I_new};
    end

endmodule