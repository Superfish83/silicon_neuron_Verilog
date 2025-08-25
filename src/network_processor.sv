module network_processor #(
    parameter NR_WIDTH = 56, 
    parameter NR_DEPTH = 16,
    parameter NR_V_WIDTH = 20,
    parameter NR_V_FRAC_WIDTH = 11,
    parameter NR_I_WIDTH = 16, 

    parameter SR_WIDTH = 64,
    parameter SR_DEPTH = 16384,
    parameter SR_SYN_WIDTH = 4,

    parameter MAX_NETWORK_TIME = 65536
)(
    input logic clk,
    input logic reset,
    input logic start,
    input logic input_occurred,
    input logic [$clog2(SR_DEPTH)-1:0] input_index,

    output logic input_ack,
    output logic output_occurred,
    output logic [$clog2(NR_DEPTH)-1:0] output_index
);
    logic [$clog2(NR_DEPTH)-1:0] c_neuron_index;
    logic [$clog2(SR_DEPTH)-1:0] c_synapse_index;
    logic c_neuron_we;
    logic c_accumulate;


    // (1) Controller (Finite State Machine)
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
        .c_accumulate(c_accumulate)
    );

    // (2) SRAMs storing neuron states and synaptic weights

    logic [NR_WIDTH-1:0] neuron_read;
    logic [NR_DEPTH-1:0] neuron_write_accu;
    logic [NR_DEPTH-1:0] neuron_write_proc;
    logic [NR_DEPTH-1:0] neuron_write;
    logic [SR_WIDTH-1:0] synapse_read;

    assign neuron_write = (c_accumulate) ? neuron_write_accu : neuron_write_proc;

    sram #(
        .WIDTH(NR_WIDTH),
        .DEPTH(NR_DEPTH),
        .RESET_VALUE({(20'(-65)<<11),(20'(-12)<<11),(16'b0)}) // Todo: resolve hardcoded reset value
    ) sram_neuron (
        .clk(clk),
        .reset(reset),
        .addr(c_neuron_index),
        .write_enable(c_neuron_we),
        .word(neuron_read),
        .write_word(neuron_write)
    );

    sram #(
        .WIDTH(SR_WIDTH),
        .DEPTH(SR_DEPTH),
        .RESET_VALUE(0)
    ) sram_synapse (
        .clk(clk),
        .reset(reset),
        .addr(c_synapse_index),
        .write_enable(0), // synapse SRAM is read-only for now.
        .word(synapse_read),
        .write_word(0) // synapse SRAM is read-only for now.
    );

    // (3) the time-multiplexed neuron accumulator

    logic [SR_SYN_WIDTH-1:0] synaptic_weight;
    assign synaptic_weight = synapse_read[SR_SYN_WIDTH-1:0]; // Todo: bit selection according to c_neuron_index

    neuron_accumulator #(
        .NR_WIDTH(NR_WIDTH),
        .NR_I_WIDTH(NR_I_WIDTH),
        .SR_SYN_WIDTH(SR_SYN_WIDTH)
    ) neuron_accu (
        .neuron_in(neuron_read),
        .neuron_out(neuron_write_accu),
        .syn_in(synaptic_weight)
    );

    // (4) the time-multiplexed neuron processor

    assign output_index = c_neuron_index;

    neuron_processor #(
        .NR_WIDTH(NR_WIDTH),
        .NR_V_WIDTH(NR_V_WIDTH),
        .NR_I_WIDTH(NR_I_WIDTH),
        .NR_V_FRAC_WIDTH(NR_V_FRAC_WIDTH)
    ) neuron_proc (
        .neuron_in(neuron_read),
        .neuron_out(neuron_write_proc),
        .fire(output_occurred)
    );


endmodule