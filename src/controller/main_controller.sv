module controller #(
    parameter NR_WIDTH = 56, 
    parameter NR_DEPTH = 16,
    parameter SR_WIDTH = 64,
    parameter SR_DEPTH = 16384
) (
);
    
    logic freeze;
    logic spike_index;
    logic time_index;

    // Instantiate the neuron input module
    neuron_input_module #(
        .NR_WIDTH(NR_WIDTH),
        .NR_DEPTH(NR_DEPTH),
        .SR_WIDTH(SR_WIDTH),
        .SR_DEPTH(SR_DEPTH)
    ) neuron_input_inst (
        .clk(clk),
        .reset(reset),
        .nim_if_inst(nim_if.updater)
    );
    
endmodule
    
    