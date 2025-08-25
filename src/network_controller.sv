typedef enum logic [1:0] {
    IDLE,
    PROC_NEURON, // The module is processing neurons
                 // (in time-multiplexed manner)
    PROC_INPUT  // The module is processing synaptic inputs for neurons
                 // (in time-multiplexed manner)
} c_state;

module network_controller #(
    parameter NR_WIDTH = 56, 
    parameter NR_DEPTH = 16,
    parameter SR_WIDTH = 64,
    parameter SR_DEPTH = 16384,
    parameter MAX_NETWORK_TIME = 65536
)(
    input logic clk,
    input logic reset,
    input logic start,

    input logic input_occurred, // 1: a spike occured in one of the presynaptic neuron, 0: no spike
    input logic [$clog2(SR_DEPTH)-1:0] input_index, // the index of the presynaptic neuron

    output logic input_ack, // 1: the presynaptic spike input was been registered to the controller
                            // 0: the controller was busy handling another spike input

    output logic [$clog2(NR_DEPTH)-1:0] c_neuron_index,  // [control] SRAM access index
    output logic [$clog2(SR_DEPTH)-1:0] c_synapse_index, // [control] SRAM access index
    output logic c_neuron_we, // [control] neuron SRAM write enable
                              //         (synapse SRAM is read-only for now.)
    output logic c_accumulate // [control] 0: neuron updator is working
                              //           1: neuron accumulator is working
);
    c_state state = IDLE;

    reg [$clog2(MAX_NETWORK_TIME)-1:0] network_time;
    // elapsed time in the simulated neural network (지금까지 neuron들이 몇 step씩 update되었는지)

    reg phase; // 0: Read SRAM, 1: Write SRAM
    reg [$clog2(NR_DEPTH)-1:0] i_proc; // time multiplexing index for neuron processing
    reg [$clog2(NR_DEPTH)-1:0] i_accu; // time multiplexing index for neuron accumulation


    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= IDLE;
            network_time <= 0;

            input_ack <= 0;
            c_neuron_we <= 0;
        end
        else if (state == IDLE && start) begin
            state <= PROC_NEURON;
            phase <= 0;

            input_ack <= 0;
            c_neuron_we <= 0;
        end
        else if (state == PROC_NEURON || state == PROC_INPUT) begin
            // (1) Set write enable signal
            c_neuron_we <= phase;
            c_neuron_index <= (state == PROC_INPUT) ? i_accu : i_proc;


            // (2-1) Update phase
            phase <= ~phase;

            // (2-2) Update time multiplexing index
            if (state == PROC_NEURON && phase==1) begin
                i_proc <= i_proc + 1;
                if (i_proc == (MAX_NETWORK_TIME-1)) begin
                    network_time <= network_time + 1;
                end
            end
            if (state == PROC_INPUT && phase==1) begin
                i_accu <= i_accu + 1;
            end


            // (3-1) state transition: PROC_NEURON -> PROC_INPUT
            if (state == PROC_NEURON && input_occurred) begin
                if(phase == 1) begin
                    c_synapse_index <= input_index;
                    state <= PROC_INPUT;
                    i_accu <= 0;
                    input_ack <= 1;
                end
                else begin
                    input_ack <= 0;
                end
            end

            // (3-2) state transition: PROC_INPUT -> PROC_NEURON
            else if (state == PROC_INPUT && i_accu == (MAX_NETWORK_TIME-1) && phase == 1) begin
                if (input_occurred) begin
                    c_synapse_index <= input_index;
                    state <= PROC_INPUT;
                    input_ack <= 1;
                end
                else begin
                    state <= PROC_NEURON;
                    input_ack <= 0;
                end
            end
            
            else begin
                input_ack <= 0;
            end
            
        end
    end
    
endmodule
    
    