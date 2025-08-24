module network_proc #(
    parameter NR_WIDTH = 56, 
    parameter NR_DEPTH = 16,
    parameter SR_WIDTH = 64,
    parameter SR_DEPTH = 16384,
    parameter MAX_NETWORK_TIME = 65536
)(
    input logic clk,
    input logic reset,
    input logic input_occurred,
    input logic [$clog2(SR_DEPTH)-1:0] input_index,
    output logic input_ack,
    output logic output_occurred,
    output logic [$clog2(NR_DEPTH)-1:0] output_index
);
    logic [$clog2(NR_DEPTH)-1:0] c_neuron_index;
    logic [$clog2(SR_DEPTH)-1:0] c_synapse_index;
    logic c_neuron_we;
    logic c_input;

    network_controller controller (
        .clk(clk),
        .reset(reset),
        .start(start),
        .input_occurred(input_occurred),
        .input_index(input_index),

        .input_ack(input_ack),
        .output_occurred(output_occurred),
        .output_index(output_index),

        .c_neuron_index(c_neuron_index),
        .c_synapse_index(c_synapse_index),
        .c_neuron_we(c_neuron_we),
        .c_input(c_input)
    );

    // Todo: connect control signals to NIM, NUM and SRAMs

endmodule